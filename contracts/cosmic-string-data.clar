;; Cosmic String Data Management Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))

;; Data Variables
(define-data-var string-data-counter uint u0)
(define-map cosmic-strings uint {
    identifier: (string-ascii 50),
    length: uint,
    energy-density: uint,
    location: (tuple (x int) (y int) (z int)),
    discovery-block: uint,
    discoverer: principal
})

;; Public Functions
(define-public (register-cosmic-string (identifier (string-ascii 50)) (length uint) (energy-density uint) (x int) (y int) (z int))
    (let
        (
            (string-id (+ (var-get string-data-counter) u1))
        )
        (asserts! (> length u0) err-invalid-parameters)
        (asserts! (> energy-density u0) err-invalid-parameters)
        (map-set cosmic-strings string-id {
            identifier: identifier,
            length: length,
            energy-density: energy-density,
            location: {x: x, y: y, z: z},
            discovery-block: block-height,
            discoverer: tx-sender
        })
        (var-set string-data-counter string-id)
        (ok string-id)
    )
)

(define-public (update-cosmic-string (string-id uint) (new-length uint) (new-energy-density uint) (new-x int) (new-y int) (new-z int))
    (let
        (
            (cosmic-string (unwrap! (map-get? cosmic-strings string-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get discoverer cosmic-string)) err-owner-only)
        (asserts! (> new-length u0) err-invalid-parameters)
        (asserts! (> new-energy-density u0) err-invalid-parameters)
        (map-set cosmic-strings string-id
            (merge cosmic-string {
                length: new-length,
                energy-density: new-energy-density,
                location: {x: new-x, y: new-y, z: new-z}
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-cosmic-string (string-id uint))
    (map-get? cosmic-strings string-id)
)

(define-read-only (get-cosmic-string-count)
    (var-get string-data-counter)
)

