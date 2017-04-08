import functools
import time
from functools import singledispatch

@singledispatch
def check_type (arg):
    name_type=type(arg).__name__
    assert False, "Wrong type " + name_type

@check_type.register(int)
def _(arg):
    return arg

@check_type.register(str)
def _(arg):
    return arg

@check_type.register(dict)
def _(arg):
    return arg


print(check_type({'one':1,'two':2,'three':3}))