"""
The individual State Item. It can set and get it's value
"""
abstract type State{T} end

"""
    setValue(s::State{T}, v::T)::Nothing where T

Function to set the value of `State{T}`
"""
function setValue!(s::State{T}, v::T)::T where T
    throw(error("setValue($s,$v) not implemented for State{$T}"))
end


"""
    value(s::State{T})::T

Function to retrieve the value of `State{T}`
"""
function value(s::State{T})::T where T
    throw(error("value($s) not implemented for State{$T}"))    
end


"""
save a state
"""
function save(s::State{T})::StateEntry{T} where T
    throw(error("save($s) not implemented for State{$T}"))
end


"""
    const StateInt = State{Integer}

Implementation of `StateInt`
"""
const StateInt = State{Integer}


"""
    const StateBool = State{Bool}

Implementation of `StateBool`
"""
const StateBool = State{Bool}