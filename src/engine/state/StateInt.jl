"""
    increment(s::StateInt)::Integer

Increment the state value by `1` and return it
"""
increment(s::StateInt)::Integer = setValue!(s, value(s) + 1)


"""
    decrement(s::StateInt)::Integer 

Decrement the state value by `1` and return it
"""
decrement(s::StateInt)::Integer = setValue!(s, value(s) - 1)