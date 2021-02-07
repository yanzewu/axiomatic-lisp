Axiomatic Lisp
---

Lisp with 7 "axioms", following The Roots of Lisp (2002) by Paul Graham:

- quote: `(quote a)` => `a`. Abbreviated as `'a`. 
- atom: `(atom a)` returns `t` if a == `()` or a single token, otherwise `()`;
- eq: `(eq a b)` returns `t` if a == b and both are atomic, otherwise `()`;
- car: `(car '(a ...))` => `a`;
- cdr: `(cdr '(a b ...))` => `(b ...)`;
- cons: `(cons a '(b ...))` => `(a b ...)`;
- cond: `(cond (p1 e1) (p2 e2) ...)` => `ei` if `pi` evaluates to `t`;

To make it useable I added several other functions:

- lambda: `(lambda (a1 a2 ...) body)` abstracts a closure with args a1,a2, .... To use a lambda, use the form `(my_lambda a1 a2 ...)`.
- macro `(macro (a1 a2 ...) body)` abstracts a macro with args a1,a2 ....
- let: `(let name value)` defines a variable in the current scope with value evaluated. A scope is valid anywhere within the same lambda body.
- print: `(print a)`;
- concatenate: `(concatenate a1,a2...)` stringifies all arguments and connects them (with spaces as infix);
- load: `(load filename)` load the file and evaluates everything inside it. Suffix is excluded in the filename;
- list: `(list a1 a2 ...)` creates a list with a1,a2 ... evaluated;
- do: `(do a1 a2 ...)` evaluates a1,a2... and return `()`;
- +, -, *: Integer operations;

Evaluation:

- An evaluation is triggered wherever all the brackets are paired;
- A non-quoted atom is always evaluated, except `t`, `()` and integers;
- For a list, the first element is evaluated if it is not atomic, then the whole list is evaluated. First element must evaluate to either a predefined function mentioned above or a lambda;
- A function call is done by first (1) evaluates all arguments (2) replacing all the occurences of arguments in the body (3) evaluating the body. Nested lambda cannot have same variable names as they will be replaced during the evaluation of the outer lambda;
- A macro is like a closure except (1) the arguments are not evaluated before substitution and (2) no additional local scope is created during the evaluation;
- Keywords cannot be used as variable or function/macro arguments;
- Note there is no type system. Everything is either a string or a list.
