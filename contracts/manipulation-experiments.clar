;; Cosmic String Manipulation Experiments Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-experiment-not-active (err u102))

;; Data Variables
(define-data-var experiment-counter uint u0)
(define-map experiments uint {
    cosmic-string-id: uint,
    technique: (string-ascii 100),
    energy-input: uint,
    status: (string-ascii 20),
    result: (optional (string-utf8 500)),
    experimenter: principal,
    start-block: uint,
    end-block: (optional uint)
})

;; Public Functions
(define-public (start-experiment (cosmic-string-id uint) (technique (string-ascii 100)) (energy-input uint))
    (let
        (
            (experiment-id (+ (var-get experiment-counter) u1))
        )
        (asserts! (> energy-input u0) err-invalid-parameters)
        (map-set experiments experiment-id {
            cosmic-string-id: cosmic-string-id,
            technique: technique,
            energy-input: energy-input,
            status: "active",
            result: none,
            experimenter: tx-sender,
            start-block: block-height,
            end-block: none
        })
        (var-set experiment-counter experiment-id)
        (ok experiment-id)
    )
)

(define-public (end-experiment (experiment-id uint) (result (string-utf8 500)))
    (let
        (
            (experiment (unwrap! (map-get? experiments experiment-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get experimenter experiment)) err-owner-only)
        (asserts! (is-eq (get status experiment) "active") err-experiment-not-active)
        (map-set experiments experiment-id
            (merge experiment {
                status: "completed",
                result: (some result),
                end-block: (some block-height)
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-experiment (experiment-id uint))
    (map-get? experiments experiment-id)
)

(define-read-only (get-experiment-count)
    (var-get experiment-counter)
)

