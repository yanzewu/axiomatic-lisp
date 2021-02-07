; Parser
1
'a
()
'(1 2)
'(() (()))
'('a '(a 'b '('())))
'('
(

))

; Axioms, should all return t

(let not (lambda (c) (cond 
    (c ())
    ('t 't)
)))

(print (eq 'a 'a))
(print (eq () ()))
(print (eq '() ()))
(print (not (eq '(a) 'a)))
(print (not (eq 'a 'b)))
(print (not (eq 'a ())))
(print (not (eq 'a '(a b))))
(print (not (eq '(a b) '(a b))))

(print (atom ()))
(print (atom '()))
(print (atom 'a))
(print (atom 1))
(print (not (atom '(atom 'a))))
(print (not (atom '(()))))
(print (atom (atom 'a)))

(print (eq (car '(a b c)) 'a))
(print (eq (car '(a)) 'a))
(print (eq (car (cdr '(a b c))) 'b))
(print (eq (car (cdr (cdr '(a b c)))) 'c))
(print (eq (cdr '(c)) ()))
(print (eq (car (cons 'a ())) 'a))
(print (eq (car (cons 'a '(b))) 'a))
(print (eq (car (car (cons '(a b) '(b c)))) 'a))
(print (eq (car (cons '() ())) ()))

(print (eq (cond ('t 1) ('t 2)) 1))
(print (eq (cond (() 1) ('t 2)) 2))
(print (eq (cond (() 1) (() 2)) ()))
(print (eq (cond ('(a b c) 1) ((eq 1 1) 2)) 2))

(print '(axiom tests end))

(load 'prelude)

; Unit test
(let total_test 1)
(let passed_test 1)
(defmacro test-assert (value) (do 
    (if value 
        (do 
            (print (concatenate 'test total_test 'passed))
            (let passed_test (+ passed_test 1))
        )
        (print (concatenate 'test total_test 'failed))
    )
    (let total_test (+ total_test 1))) 
)


; Predefined lib function

(test-assert (eq (concatenate 'a 'b) (concatenate 'a 'b)))
(test-assert (eq (concatenate 'a) 'a))       
(test-assert (eq (+ 1 1) 2))         
(test-assert (eq (- 5 (* 2 (+ 1 1))) 1))     
(test-assert (eq (do (+ 1 2) (+ 3 4)) ()))   
(test-assert (equal (list (+ 1 2) (+ 3 4)) '(3 7)))  

; Prelude
(test-assert (if 't 't ()))      
(test-assert (if () () 't ))     

(test-assert (and 't 't))    
(test-assert (not (and 't '()))) 
(test-assert (not (and '() '())))    
(test-assert (not (or '() '()))) 

(test-assert (or 't 't)) 
(test-assert (or 't '())) 
(test-assert (not (or '() '()))) 

(test-assert (equal '(a (b c)) '(a (b c)))) 
(test-assert (equal '() '())) 
(test-assert (equal '((a b)) '((a b)))) 
(test-assert (!= 'a '(a b))) 
(test-assert (!= 'a ())) 
(test-assert (!= '(a b) '((a b)))) 
(test-assert (!= 'a '(a))) 

(test-assert (eq (cadr '(a b c)) 'b)) 
(test-assert (eq (caddr '(a b c)) 'c)) 
(test-assert (equal (cdar '((a b c) b c)) '(b c))) 
(test-assert (equal (caar '((a b c))) 'a)) 

(test-assert (equal (append '(a b) '(c d)) '(a b c d) ))
(test-assert (equal (append '() '(c d)) '(c d) ))
(test-assert (equal (append '(a b) '()) '(a b) ))
(test-assert (equal (append '() '()) '() ))

(test-assert (equal (zip '(a b) '(c d)) '((a c) (b d)) ))
(test-assert (equal (zip '(a) '(c)) '((a c)) ))
(test-assert (equal (zip '() '()) '() ))


(let my-dict (zip '(1 2 3) '(a b c)))
(test-assert (equal (assoc 1 my-dict) 'a))

(if (eq passed_test total_test)
    (print (concatenate 'all 'tests 'are 'successful))
    ()
)

