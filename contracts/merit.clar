;; Academy Merit Rewards Distribution Contract
;; This contract manages the distribution of academic achievement tokens to deserving students

;; Define SIP-010 Fungible Token trait
(define-trait merit-token-trait
    (
        (transfer (uint principal principal (optional (buff 34))) (response bool uint))
        (get-name () (response (string-ascii 32) uint))
        (get-symbol () (response (string-ascii 32) uint))
        (get-decimals () (response uint uint))
        (get-balance (principal) (response uint uint))
        (get-total-supply () (response uint uint))
        (get-token-uri () (response (optional (string-utf8 256)) uint))
    )
)

;; Academic Error Codes
(define-constant ERR-UNAUTHORIZED-DEAN (err u300))
(define-constant ERR-ALREADY-GRADUATED (err u301))
(define-constant ERR-NOT-ENROLLED (err u302))
(define-constant ERR-INSUFFICIENT-CREDITS (err u303))
(define-constant ERR-SCHOLARSHIP-DEPLETED (err u304))
(define-constant ERR-SEMESTER-CLOSED (err u305))
(define-constant ERR-NO-CURRICULUM (err u306))
(define-constant ERR-INVALID-COURSE (err u307))
(define-constant ERR-INVALID-CREDIT-VALUE (err u308))
(define-constant ERR-TERM-EXPIRED (err u309))
(define-constant ERR-RESTRICTED-ACCESS (err u310))

;; Academic Constants
(define-constant MAX-SCHOLARSHIP-POOL u1000000000)
(define-constant MIN-MERIT-CREDIT u1)
(define-constant MAX-SEMESTER-LENGTH u10000)
(define-constant UNIVERSITY-VAULT (as-contract tx-sender))

;; Administrative Variables
(define-data-var dean-of-students principal tx-sender)
(define-data-var total-scholarship-fund uint u0)
(define-data-var enrollment-open bool true)
(define-data-var semester-end-block uint u0)
(define-data-var credits-per-achievement uint u0)
(define-data-var approved-curriculum (optional principal) none)

;; Student Records
(define-map enrolled-students principal uint)
(define-map earned-credits principal uint)
(define-map honor-roll principal bool)
(define-map accredited-courses principal bool)

;; Private academic validation
(define-private (validate-credit-amount (credits uint))
    (and 
        (>= credits MIN-MERIT-CREDIT)
        (<= credits MAX-SCHOLARSHIP-POOL)
    )
)

(define-private (validate-semester-length (duration uint))
    (<= duration MAX-SEMESTER-LENGTH)
)

(define-private (validate-student-identity (student principal))
    (and
        (not (is-eq student UNIVERSITY-VAULT))
        (not (is-eq student (var-get dean-of-students)))
    )
)

(define-private (is-accredited-course (course principal))
    (default-to false (map-get? accredited-courses course))
)

(define-private (validate-course-material (course <merit-token-trait>))
    (let ((course-identifier (contract-of course)))
        (and 
            (is-accredited-course course-identifier)
            (match (contract-call? course get-name)
                success true
                error false)
        )
    )
)

;; Read-only academic functions
(define-read-only (get-student-progress (student principal))
    (default-to u0 (map-get? earned-credits student))
)

(define-read-only (get-approved-curriculum)
    (var-get approved-curriculum)
)

(define-read-only (is-student-enrolled (student principal))
    (is-some (map-get? enrolled-students student))
)

(define-read-only (get-dean-of-students)
    (var-get dean-of-students)
)

(define-read-only (is-on-honor-roll (student principal))
    (default-to false (map-get? honor-roll student))
)

(define-read-only (get-academic-overview)
    (ok {
        total-funding: (var-get total-scholarship-fund),
        enrollment-status: (var-get enrollment-open),
        semester-conclusion: (var-get semester-end-block),
        credits-per-milestone: (var-get credits-per-achievement)
    })
)

;; Private student eligibility verification
(define-private (verify-academic-standing (student principal))
    (and 
        (is-student-enrolled student)
        (< (get-student-progress student) (default-to u0 (map-get? enrolled-students student)))
        (var-get enrollment-open)
        (<= block-height (var-get semester-end-block))
    )
)

;; Dean's administrative functions
(define-public (establish-curriculum (course <merit-token-trait>))
    (begin
        (asserts! (is-eq tx-sender (var-get dean-of-students)) ERR-UNAUTHORIZED-DEAN)
        (asserts! (match (contract-call? course get-name)
                    success true
                    error false) ERR-INVALID-COURSE)
        (let ((course-identifier (contract-of course)))
            (map-set accredited-courses course-identifier true)
            (var-set approved-curriculum (some course-identifier))
            (ok true)
        )
    )
)

(define-public (launch-academic-program (total-funding uint) (credits-per-milestone uint) (semester-duration uint))
    (begin
        (asserts! (is-eq tx-sender (var-get dean-of-students)) ERR-UNAUTHORIZED-DEAN)
        (asserts! (validate-credit-amount total-funding) ERR-INVALID-CREDIT-VALUE)
        (asserts! (validate-credit-amount credits-per-milestone) ERR-INVALID-CREDIT-VALUE)
        (asserts! (validate-semester-length semester-duration) ERR-TERM-EXPIRED)
        (asserts! (>= total-funding credits-per-milestone) ERR-INVALID-CREDIT-VALUE)
        
        (var-set total-scholarship-fund total-funding)
        (var-set credits-per-achievement credits-per-milestone)
        (var-set semester-end-block (+ block-height semester-duration))
        (var-set enrollment-open true)
        (ok true)
    )
)

(define-public (add-to-honor-roll (student principal))
    (begin
        (asserts! (is-eq tx-sender (var-get dean-of-students)) ERR-UNAUTHORIZED-DEAN)
        (asserts! (validate-student-identity student) ERR-RESTRICTED-ACCESS)
        (asserts! (not (is-on-honor-roll student)) ERR-ALREADY-GRADUATED)
        (map-set honor-roll student true)
        (ok true)
    )
)

(define-public (remove-from-honor-roll (student principal))
    (begin
        (asserts! (is-eq tx-sender (var-get dean-of-students)) ERR-UNAUTHORIZED-DEAN)
        (asserts! (validate-student-identity student) ERR-RESTRICTED-ACCESS)
        (asserts! (is-on-honor-roll student) ERR-NOT-ENROLLED)
        (map-delete honor-roll student)
        (ok true)
    )
)

(define-public (register-student (student principal) (max-credits uint))
    (begin
        (asserts! (is-eq tx-sender (var-get dean-of-students)) ERR-UNAUTHORIZED-DEAN)
        (asserts! (validate-student-identity student) ERR-RESTRICTED-ACCESS)
        (asserts! (validate-credit-amount max-credits) ERR-INVALID-CREDIT-VALUE)
        (map-set enrolled-students student max-credits)
        (ok true)
    )
)

(define-public (earn-academic-credits (course <merit-token-trait>))
    (let (
        (student tx-sender)
        (maximum-credits (default-to u0 (map-get? enrolled-students student)))
        (current-credits (get-student-progress student))
        (curriculum-source (unwrap! (var-get approved-curriculum) ERR-NO-CURRICULUM))
    )
        (asserts! (validate-student-identity student) ERR-RESTRICTED-ACCESS)
        (asserts! (validate-course-material course) ERR-INVALID-COURSE)
        (asserts! (is-eq curriculum-source (contract-of course)) ERR-INVALID-COURSE)
        (asserts! (verify-academic-standing student) ERR-NOT-ENROLLED)
        (asserts! (>= (- maximum-credits current-credits) (var-get credits-per-achievement)) ERR-SCHOLARSHIP-DEPLETED)
        
        ;; Record academic progress
        (map-set earned-credits student (+ current-credits (var-get credits-per-achievement)))
        
        ;; Distribute merit tokens
        (as-contract
            (contract-call? course transfer
                (var-get credits-per-achievement)
                tx-sender
                student
                none
            )
        )
    )
)

(define-public (close-enrollment)
    (begin
        (asserts! (is-eq tx-sender (var-get dean-of-students)) ERR-UNAUTHORIZED-DEAN)
        (var-set enrollment-open false)
        (ok true)
    )
)

;; Emergency administrative functions
(define-public (extend-semester (new-end-block uint))
    (begin
        (asserts! (is-eq tx-sender (var-get dean-of-students)) ERR-UNAUTHORIZED-DEAN)
        (asserts! (validate-semester-length (- new-end-block block-height)) ERR-TERM-EXPIRED)
        (var-set semester-end-block new-end-block)
        (ok true)
    )
)

(define-public (emergency-fund-recovery (course <merit-token-trait>) (recovery-amount uint))
    (let ((curriculum-source (unwrap! (var-get approved-curriculum) ERR-NO-CURRICULUM)))
        (asserts! (is-eq tx-sender (var-get dean-of-students)) ERR-UNAUTHORIZED-DEAN)
        (asserts! (validate-credit-amount recovery-amount) ERR-INVALID-CREDIT-VALUE)
        (asserts! (validate-course-material course) ERR-INVALID-COURSE)
        (asserts! (is-eq (contract-of course) curriculum-source) ERR-INVALID-COURSE)
        (as-contract
            (contract-call? course transfer
                recovery-amount
                tx-sender
                (var-get dean-of-students)
                none
            )
        )
    )
)