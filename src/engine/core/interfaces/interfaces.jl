"""
Contains a definition of abstract structs shared across the core module
"""

"""
    abstract type AbstractConstraint end

`Interface` that all constraints should implement
"""
abstract type AbstractConstraint end


"""
    abstract type AbstractDomain{T} end

`Interface` definition of a domain. All domains should implement this Interface
"""
abstract type AbstractDomain{T} end


"""
    abstract type AbstractDomainListener end

`Interface` of a domain listener
"""
abstract type AbstractDomainListener end


"""
    abstract type AbstractVariable{T} end

`Interface` of a variable
"""
abstract type AbstractVariable{T} end


"""
    abstract type AbstractSolver end

`Interface` definition of a solver
"""
abstract type AbstractSolver end



"""
    abstract type AbstractObjective end

`Interface` definition of the Objective of a solver
"""
abstract type AbstractObjective end