
(let defmacro (macro (name args body) (let name (macro args body))))
(let defun (macro (name args body) (let name (lambda args body))))

(defun id (x) x)

; Booleans

(defmacro if (c br-true br-false ) (cond
    (c br-true)
    (t br-false)
))

(let True t)
(let False ())
(let otherwise t)

(defun null (x) (eq 'x '()))
(defun and (lhs rhs) (cond
    ((not lhs) False)
    (rhs True)
))

(defun or (lhs rhs) (cond
    (lhs True)
    (rhs True)
))

(defun not (c) (cond 
    (c ()) ('t 't)
))

; Both are atom => eq
; Both are list => (eq (car a) (car b))
(defun equal (lhs rhs) (cond
    ((and (atom 'lhs) (atom 'rhs)) (eq 'lhs 'rhs))
    ((not (or (atom 'lhs) (atom 'rhs))) 
        (and (equal (car 'lhs) (car 'rhs)) (equal (cdr 'lhs) (cdr 'rhs))))
    (otherwise False)
))
(let = equal)
(defmacro != (lhs rhs) (not (equal lhs rhs)))

; Lists

(defun cadr (x) (car (cdr 'x)))
(defun caddr (x) (car (cdr (cdr 'x))))
(defun cadar (x) (car (cdr (car 'x))))
(defun cdar (x) (cdr (car 'x)))
(defun caar (x) (car (car 'x)))
(let second cadr)
(let third caddr)

(defun length (x) (if (null 'x) 0
    (+ 1 (length (cdr 'x)))
))
(defun append  (a b) (if (eq 'a '())
    'b
    (cons (car 'a) (append (cdr 'a) 'b))
))
(defun sublist (x start end) (cond
    ((eq 'end 0) '())
    ((eq 'start 0) (cons (car 'x) (sublist (cdr 'x) 0 (- 'end 1))))
    (otherwise (sublist (cdr 'x) (- 'start 1) (- 'end 1)))
))
(defmacro head (arr k) (sublist arr 0 k))

; List: find & filter

(defun member (obj arr) (cond 
    ((null 'arr) '())
    ((equal 'obj (car 'arr)) 'arr)
    (otherwise (member 'obj (cdr 'arr)))
))
(defun memq (obj arr) (cond 
    ((null 'arr) '())
    ((eq obj (car 'arr)) 'arr)
    (otherwise (member obj (cdr arr)))
))
(defun filter (predicate a) (cond
    ((null 'a) '())
    (('predicate (car 'a)) (cons (car 'a) (filter 'predicate (cdr 'a))))
    (otherwise (filter 'predicate (cdr 'a)))
))

; List: binary operations

(defun map (f x) (cond
    ((null 'x) ())
    (otherwise (cons ('f (car 'x)) (map 'f (cdr 'x))))
))
(defun map2 (f x y) (cond
    ((and (null 'x) (null 'y)) ())
    (otherwise (cons ('f (car 'x) (car 'y)) (map2 'f (cdr 'x) (cdr 'y))))
))
(defun for-each (f x y) (cond
    ((and (null 'x) (null 'y)) '())
    ((and (not (atom 'x)) (not (atom 'y))) 
        (do 'f ((car 'x) (car 'y)) (for-each 'f (cdr 'x) (cdr 'y)))
    )
    (otherwise (print (concatenate 'error: 'list 'length 'not 'equal)))
))
(defun fold-left (f init arr) (cond
    ((null 'arr) 'init)
    (otherwise (fold-left 'f ('f 'init (car 'arr)) (cdr 'arr)))
))

(defun fold-right (f init arr) (do
    (let myf (lambda (myarr cont) (cond
        ((null 'myarr) ('cont 'init))
        (otherwise (do
            (let myh (car 'myarr))
            (myf (cdr 'myarr) (lambda (x) ('f myh ('cont 'x))) )))
    )))
    (myf 'arr id)
))

(defmacro reverse (x) (fold-right 'cons '() x))
(defun pair (f x y) (cond
    ((and (null 'x) (null 'y)) '())
    ((and (not (atom 'x)) (not (atom 'y))) 
        ('f (list (car 'x) (car 'y)) (pair 'f (cdr 'x) (cdr 'y)))
    )
    (otherwise (print (concatenate 'error: 'list 'length 'not 'equal)))
))
(defmacro zip (x y) (map2 'list x y))

; Associated Lists

; y => ((key1 val1) (key2 val2)) ...
; 
(defun assoc (k d) (cond
    ((null 'd) ())
    ((eq (caar 'd) 'k) (cadar 'd))
    (otherwise (assoc 'k (cdr 'd)))
))