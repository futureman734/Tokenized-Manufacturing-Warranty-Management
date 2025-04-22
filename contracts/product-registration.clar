;; Product Registration Contract
;; Records details of manufactured items

(define-data-var last-product-id uint u0)

(define-map products
  { product-id: uint }
  {
    serial-number: (string-utf8 50),
    model: (string-utf8 50),
    manufacturer: principal,
    manufacture-date: uint,
    registered: bool
  }
)

(define-map product-owners
  { product-id: uint }
  { owner: principal }
)

;; Register a new product
(define-public (register-product (serial-number (string-utf8 50)) (model (string-utf8 50)) (manufacture-date uint))
  (let
    (
      (new-id (+ (var-get last-product-id) u1))
    )
    (asserts! (is-eq tx-sender contract-caller) (err u403))
    (var-set last-product-id new-id)
    (map-set products
      { product-id: new-id }
      {
        serial-number: serial-number,
        model: model,
        manufacturer: tx-sender,
        manufacture-date: manufacture-date,
        registered: true
      }
    )
    (map-set product-owners
      { product-id: new-id }
      { owner: tx-sender }
    )
    (ok new-id)
  )
)

;; Transfer product ownership
(define-public (transfer-ownership (product-id uint) (new-owner principal))
  (let
    (
      (current-owner (unwrap! (get owner (map-get? product-owners { product-id: product-id })) (err u404)))
    )
    (asserts! (is-eq tx-sender current-owner) (err u403))
    (map-set product-owners
      { product-id: product-id }
      { owner: new-owner }
    )
    (ok true)
  )
)

;; Get product details
(define-read-only (get-product-details (product-id uint))
  (map-get? products { product-id: product-id })
)

;; Get product owner
(define-read-only (get-product-owner (product-id uint))
  (map-get? product-owners { product-id: product-id })
)

;; Check if product exists
(define-read-only (product-exists (product-id uint))
  (is-some (map-get? products { product-id: product-id }))
)
