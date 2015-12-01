#lang racket

(define (what-floor initial-floor input)
  (sequence-fold
   (lambda (result e i)
     (cons
      (+ (car result)
         (match e
           [#\( 1]
           [#\) -1]))
      (match (cdr result)
        [0 (cond
             [(< (car result) 0) i]
             [else (cdr result)])]
        [_ (cdr result)])))
   initial-floor (in-indexed input)))

(call-with-input-file "1.input"
  (lambda (in)
    (what-floor '(0 . 0) (in-input-port-chars in))))