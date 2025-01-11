;; Cosmic String Energy Harvesting Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))

;; Data Variables
(define-data-var harvest-counter uint u0)
(define-map energy-harvests uint {
    cosmic-string-id: uint,
    energy-amount: uint,
    harvester: principal,
    harvest-block: uint
})

;; Public Functions
(define-public (record-energy-harvest (cosmic-string-id uint) (energy-amount uint))
    (let
        (
            (harvest-id (+ (var-get harvest-counter) u1))
        )
        (asserts! (> energy-amount u0) err-invalid-parameters)
        (map-set energy-harvests harvest-id {
            cosmic-string-id: cosmic-string-id,
            energy-amount: energy-amount,
            harvester: tx-sender,
            harvest-block: block-height
        })
        (var-set harvest-counter harvest-id)
        (ok harvest-id)
    )
)

;; Read-only Functions
(define-read-only (get-energy-harvest (harvest-id uint))
    (map-get? energy-harvests harvest-id)
)

(define-read-only (get-harvest-count)
    (var-get harvest-counter)
)

