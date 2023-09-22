"""
The `Table` constraint
"""
@with_kw mutable struct TableCT{T} <: AbstractConstraint
    vars::Vector{<:AbstractVariable{T}}
    table::Matrix{T}

    ## Constraint-wide variables
    active::State
    scheduled::Bool
end


"""
    post(c::Table)::Nothing

Function to `post` the `Table` constraint
"""
function post(c::TableCT)::Nothing
    _ = c

    return nothing
end


"""
    propagate(c::Table{T})::Nothing where T

Function to `propagate` the `Table` constraint
"""
function propagate(c::TableCT{T})::Nothing where T
    _ = c

    return nothing
end