"""
Exceptions used in the solver
"""
abstract type AbstractSolverException <: Exception end


"""
    struct InconsistencyException <: AbstractSolverException
        message::String
    end

Exception thrown when the `domain` of a `variable` becomes `empty` upon propagation.
"""
struct InconsistencyException <: AbstractSolverException
    message::String
end



"""
    struct NotImplementedException <: AbstractSolverException
        message::String
    end

Exception thrown when a function expected to be implemented is present but not implmented
"""
struct NotImplementedException <: AbstractSolverException
    message::String
end


"""
    struct EmptyBackUpException <: AbstractSolverException
        message::String
    end

Exception thrown when one tries to retrieve elements from an empty BackUp instance
"""
struct EmptyBackUpException <: AbstractSolverException
    message::String
end


