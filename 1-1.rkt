#lang racket

(define (what-floor initial-floor input)
  (sequence-fold
   (lambda (total e)
     (+ total (match e
       [#\( 1]
       [#\) -1])))
  initial-floor input))

(call-with-input-file "1.input"
  (lambda (in)
    (what-floor 0 (in-input-port-chars in))))