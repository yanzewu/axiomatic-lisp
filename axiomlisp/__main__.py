import sys
import re
from collections import deque, namedtuple

var_stack = [{}]    # The stack

class LispError(RuntimeError):
    def __init__(self, *args):
        super().__init__(*args)

Closure = namedtuple('Closure', ('args', 'expression', 'name'))
Macro = namedtuple('Macro', ('args', 'expression', 'name'))

def main_loop():
    while True:
        if repl(input('Lisp> ')):
            break

def read_file(filename):
    text = re.sub(r';.*[\n$]', '', open(filename, 'r').read()).replace('\n', ' ')
    tokens = tokenize(text)
    if not tokens:
        return 0
    for tree in parse(tokens, single_tree=False):
        try:
            execute(tree, var_stack=var_stack)
        except LispError as e:
            print('Error: %s' % e, file=sys.stderr)
            return 1

def repl(s):
    if s == 'quit':
        return 1
    try:
        tokens = tokenize(s)
        if not tokens:
            return 0
        print(str_tree(execute(parse(tokens), var_stack=var_stack)))
    except LispError as e:
        print('Error: %r' % e, file=sys.stderr)
    return 0

def tokenize(string):
    return re.findall(r"[^\(\)'\s]+|[\(\)']", string)
    
def my_assert(cond, context):
    if not cond:
        raise LispError(context)

def assert_args(context, tree, narg):
    my_assert(len(tree) == narg + 1, '%s expect %d args' % (context, narg))

def parse(tokens, single_tree=True):
    stack = []
    for t in tokens:
        if t == ')':
            tree = []
            while True:
                if len(stack) == 0:
                    raise LispError('Bracket not match')
                if stack[-1] == '(':
                    break
                tree = [stack.pop()] + tree
            stack[-1] = tree
        else:
            stack.append(t)
        if t != '(' and len(stack) > 1 and stack[-2] == '\'':
            stack[-1] = ['quote', stack.pop()]

    #print(stack)
    my_assert(not '(' in stack, 'Bracket not match')
    if single_tree:
        my_assert(len(stack) == 1, 'Only one sentence may be input once')
        return stack[0]
    else:
        return stack

def is_atom_or_empty(tree):
    return not isinstance(tree, (list, Macro, Closure)) or len(tree) == 0

def is_list(tree):
    return isinstance(tree, list)

def is_number(tree):
    return isinstance(tree, str) and re.fullmatch(r'\-?[\d]+', tree)

def is_bool(tree):
    return tree == [] or tree == 't'

def to_int(tree):
    try:
        return int(tree)
    except ValueError:
        raise LispError('%s is not an integer' % str_tree(tree))

def to_bool(tree):
    if tree == 't': 
        return True
    elif tree == []:
        return False
    else:
        raise LispError("%s is not a boolean" % str_tree(tree))

keywords = {'quote', 'atom', 'eq', 'car', 'cdr', 'cons', 'cond', 'lambda', 'macro', 'let', 'print', 'concatenate', 'load', 'do', 'list', '+', '-', '*', '>', '<'}

def assert_varname(a):
    my_assert(isinstance(a, str) and not a.isdigit() and a not in keywords and a != 't',
     "Invalid variable name %s" % a)

def find_variable(tree, var_stack):
    for a in reversed(var_stack):   # find variable
        if tree in a:
            return a[tree]
    else:
        raise LispError('Variable %s is not defined' % tree)

def execute(tree, var_stack=[], lvalue='#closure'):

    if is_atom_or_empty(tree):
        return find_variable(tree, var_stack) if not is_number(tree) and not is_bool(tree) else tree

    my_execute = lambda x: execute(x, var_stack=var_stack, lvalue='#closure')
    if is_atom_or_empty(tree[0]):
        command = find_variable(tree[0], var_stack) if tree[0] not in keywords else tree[0]
    else:
        command = my_execute(tree[0])

    if isinstance(command, Closure):
        assert_args(command.name, tree, len(command.args))
        try:
            return execute(replace_tree(command.expression, dict(zip(range(len(command.args)), map(my_execute, tree[1:])))), var_stack + [{}])
        except LispError:
            print('In function %s' % str_tree(command), file=sys.stderr)
            raise
    elif isinstance(command, Macro):
        assert_args(command.name, tree, len(command.args))
        r = replace_tree(command.expression, dict(zip(range(len(command.args)), tree[1:])))
        try:
            return execute(r, var_stack)
        except LispError:
            print('In macro %s' % str_tree(command), file=sys.stderr)
            raise

    elif command == 'quote':
        assert_args(command, tree, 1)
        return tree[1]
    elif command == 'atom':
        assert_args(command, tree, 1)
        r = my_execute(tree[1])
        return 't' if is_atom_or_empty(r) else []
    elif command == 'eq':
        assert_args(command, tree, 2)
        r1 = my_execute(tree[1])
        r2 = my_execute(tree[2])
        return 't' if is_atom_or_empty(r1) and is_atom_or_empty(r2) and r1 == r2 else []
    elif command == 'car':
        assert_args(command, tree, 1)
        r = my_execute(tree[1])
        my_assert(not is_atom_or_empty(r), "car requires a list")
        return r[0]
    elif command == 'cdr':
        assert_args(command, tree, 1)
        r = my_execute(tree[1])
        my_assert(not is_atom_or_empty(r), "cdr requires a list")
        return r[1:]
    elif command == 'cons':
        assert_args(command, tree, 2)
        r1 = my_execute(tree[1])
        r2 = my_execute(tree[2])
        my_assert(is_list(r2), "cons requires a list of arg #2")
        return [r1] + r2
    elif command == 'cond':
        for subtree in tree[1:]:
            my_assert(len(subtree) == 2, 'cond expect paired subtrees')
            if my_execute(subtree[0]) == 't':
                return my_execute(subtree[1])
        return []

    elif command == 'lambda':
        assert_args(command, tree, 2)
        my_assert(not is_atom_or_empty(tree[1]), 'Lambda args cannot be atom or empty')
        for a in tree[1]:
            assert_varname(a)
        mapping = dict(zip(tree[1], range(len(tree[1])))) # arg => numerical representation
        return Closure(tree[1], replace_tree(tree[2], mapping, var_stack[1:]), lvalue)
    elif command == 'macro':
        assert_args(command, tree, 2)
        for a in tree[1]:
            assert_varname(a)
        mapping = dict(zip(tree[1], range(len(tree[1])))) # arg => numerical representation
        return Macro(tree[1], replace_tree(tree[2], mapping), lvalue if lvalue != '#closure' else '#macro')
    elif command == 'let':
        assert_args(command, tree, 2)
        assert_varname(tree[1])
        r = execute(tree[2], var_stack=var_stack, lvalue=tree[1])
        var_stack[-1][tree[1]] = r
        return r
    elif command == 'load':
        assert_args(command, tree, 1)
        r = my_execute(tree[1])
        my_assert(isinstance(r, str), 'Filename must be string')
        read_file(r + '.lsp')
        return []
    elif command == 'print':
        assert_args(command, tree, 1)
        print(str_tree(my_execute(tree[1])))
        return []
    elif command == 'concatenate':
        my_assert(len(tree) >= 2, 'concatenate requires at least 1 arg')
        return ' '.join(map(lambda x:str_tree(my_execute(x)), tree[1:]))
    elif command == 'do':
        r = []
        for t in tree[1:]:
            r = my_execute(t)
        return r
    elif command == 'list':
        return list(map(my_execute, tree[1:]))
    elif command == '+':
        assert_args(command, tree, 2)
        return str(to_int(my_execute(tree[1])) + to_int(my_execute(tree[2])))
    elif command == '-':
        assert_args(command, tree, 2)
        return str(to_int(my_execute(tree[1])) - to_int(my_execute(tree[2])))
    elif command == '*':
        assert_args(command, tree, 2)
        return str(to_int(my_execute(tree[1])) * to_int(my_execute(tree[2])))
    elif command == '>':
        assert_args(command, tree, 2)
        return 't' if to_int(my_execute(tree[1])) > to_int(my_execute(tree[2])) else []
    elif command == '<':
        assert_args(command, tree, 2)
        return 't' if to_int(my_execute(tree[1])) < to_int(my_execute(tree[2])) else []
    else:
        raise LispError('Cannot understood: %s' % str_tree(tree))

def replace_tree(tree, mapping:dict, var_stack=None):
    """ replace recursively according to mapping. If var_stack is given, will also replace
    according to var_stack as a list of dict.
    """
    
    if isinstance(tree, list):
        return [replace_tree(t, mapping, var_stack) for t in tree]
    elif isinstance(tree, (Closure, Macro)):
        return tree
    elif is_number(tree) or is_bool(tree):
        return tree
    elif not var_stack:
        return mapping.get(tree, tree)
    else:
        if tree in mapping:
            return mapping[tree]
        for s in reversed(var_stack):
            if tree in s:
                return s[tree]
        return tree

def str_tree(tree):
    if isinstance(tree, list):
        return '(' + ' '.join(map(str_tree, tree)) + ')'
    elif isinstance(tree, (Closure, Macro)):
        return '%s (nargs=%d)' % (tree.name, len(tree.args))
    else:
        return str(tree)

if len(sys.argv) > 1:
    read_file(sys.argv[1])
else:
    main_loop()
