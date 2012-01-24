
(define-macro (%test hook src val . args)
  `(let ((comp (if (null? ',args) equal? (car ',args)))
         (res (,hook ,src)))
     (if (not (comp res ,val))
         (throw (string-append "FAILURE with " (->string ',hook) ": "
                               (->string ,src)
                               " got "
                               (->string res)
                               " but expected "
                               (->string ,val))))))


(define-macro (test-read src val . args)
  `(%test read ,src ,val ,@args))

(define-macro (test-eval src val . args)
  `(%test eval-outlet ',src ,val ,@args))

;; integers
(test-read "4.0" 4)
(test-read "4.0" 4)
(test-read "-5.5" -5.5)

;; strings
(test-read "\"foo\"" "foo")
(test-read "\"bar\\\"buz\"" "bar\"buz")
(test-read "\"bar\\nbuz\"" "bar\nbuz")
(test-eval "bar\nbuz" "bar
buz")

;; booleans
(test-read "#t" #t)
(test-read "#f" #f)
(test-eval (not #t) #f)
(test-eval (not #f) #t)
(test-eval (and #f #t) #f)

;; symbols
(test-read "foo" 'foo)
(test-read "bar-buz?!" 'bar-buz?!)
(test-eval 'foo 'foo)

;; lists
(define foo 4)
(test-read "(1 2 3 4)" '(1 2 3 4))
(test-read "(foo 2 3 4)" '(foo 2 3 4))
(test-eval (list 1 2 3 foo) (list 1 2 3 4))

;; vectors
(define foo 4)
(test-read "[1 2 3]" '[1 2 3])
(test-eval [1 2 3] (vector 1 2 3))
(test-eval [1 2 3 foo] (vector 1 2 3 4))
(test-eval (vector 1 2 3 foo) (vector 1 2 3 4))

;; quoting/splicing for lists and vectors
(define foo 4)
(define foo-lst '(4 5))
(define foo-vec [4 5])
(test-eval '3 3)
(test-eval `3 3)
(test-eval '(1 2 3) (list 1 2 3))
(test-eval `(1 2 3 ,4) (list 1 2 3 4))
(test-eval `(1 2 3 ,foo) '(1 2 3 4))
(test-eval '(1 2 3 foo) (list 1 2 3 'foo))
(test-eval `(1 2 3 foo) '(1 2 3 foo))
(test-eval `(1 2 3 ,@'(4 5)) '(1 2 3 4 5))
(test-eval `(1 2 3 ,@foo-lst) '(1 2 3 4 5))

(test-eval '[1 2 3] (vector 1 2 3))
(test-eval `[1 2 3 ,4] (vector 1 2 3 4))
(test-eval `[1 2 3 ,foo] (vector 1 2 3 4))
(test-eval `[1 2 3 foo] (vector 1 2 3 'foo))
(test-eval '[1 2 3 foo] (vector 1 2 3 'foo))
(test-eval `[1 2 3 ,@[4 5]] (vector 1 2 3 4 5))
(test-eval `[1 2 3 ,@foo-vec] (vector 1 2 3 4 5))

;; functions
(define (foo x y z) (+ x y z))
(test-eval (foo 1 2 3) 6)

(define (bar t) (* (foo 1 2 3) t))
(test-eval (bar 5) 30)

(test-eval ((lambda (x)
               (bar (+ x 2))) 5)
           42)

;; lambda

(define foo (lambda (x y z) (+ x y z)))
(test-eval (foo 1 2 3) 6)

(define foo (lambda args args))
(test-eval (foo 1 2 3) '(1 2 3))



;; set!
(test-eval ((lambda (x)
               (set! x 10)
               (* x x)) 5)
           100)

;; if
(test-eval (if true 1 2) 1)
(test-eval (if false 1 2) 2)
(test-eval (if true
                (begin
                  (define a 5)
                  (* a 2)))
           10)

;; cond
(define x 3)
(test-eval (cond
             ((eq? x 0) 'zero)
             ((eq? x 1) 'one)
             ((eq? x 2) 'two)
             ((eq? x 3) 'three))
           'three)

(test-eval (cond
            ((eq? x 0) 'zero)
            ((eq? x 1) 'one)
            ((eq? x 2) 'two)
            (else 'none))
           'none)
