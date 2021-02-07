
(let defmacro (macro (name args body) (let name (macro args body))))
(let defun (macro (name args body) (let name (lambda args body))))

(defun id (x) x)

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

(defun cadr (x) (car (cdr 'x)))
(defun caddr (x) (car (cdr (cdr 'x))))
(defun cadar (x) (car (cdr (car 'x))))
(defun cdar (x) (cdr (car 'x)))
(defun caar (x) (car (car 'x)))
(let second cadr)
(let third caddr)

(defun append  (a b) (if (eq 'a '())
    'b
    (cons (car 'a) (append (cdr 'a) 'b))
))

(defun map (f x y) (cond
    ((and (null 'x) (null 'y)) '())
    ((and (not (atom 'x)) (not (atom 'y))) 
        ('f (list (car 'x) (car 'y)) (map 'f (cdr 'x) (cdr 'y)))
    )
))
(defmacro zip (x y) (map 'cons x y))

; y => ((key1 val1) (key2 val2)) ...
; 
(defun assoc (k d) (if (eq (caar 'd) 'k)
    (cadar 'd)
    (assoc x (cdr y))
))