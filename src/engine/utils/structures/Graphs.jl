using SparseArrays
using Parameters
"""
    struct Graph
        n::Int
        matrix::BitMatrix
    end

Custom `Graph` data structure used within this engine.
`n` is the number of nodes.
The graph contains nodes `1...n`.
"""
@with_kw struct Graph
    n::Int
    m::SparseMatrixCSC

    function Graph(n::Integer)
        n <= 0 && throw(DomainError("Graph must contain at least 1 node. Found $n nodes specified."))
        m = sparse(BitMatrix(undef, n, n))

        new(n, m)
    end

    function Graph(n::Integer, m::Matrix{Bool})
        new(n, sparse(m))
    end
end


"""
    into(g::Graph, node::Integer)::BitVector

Function to return the nodes with edges going `into` node `node`
"""
function into(g::Graph, node::Integer)::Vector{Integer}
    (node < 1 || node > g.n) && throw(DomainError("Node not available in the graph"))
    return findall(==(1), g.m[node, :])
end


"""
    out(g::Graph, node::Integer)::BitVector

Function to return the nodes whose edge comes `out` of node `node`
"""
function out(g::Graph, node::Integer)::Vector{Integer}
    (node < 1 || node > g.n) && throw(DomainError("Node not available in the graph"))

    return findall(==(1), g.m[:, node])
end


"""
    addNeighbour(g::Graph, source::Integer, destination::Integer)::Nothing

Function to create a node's neighbours
"""
function addNeighbour(g::Graph, source::Integer, destination::Integer)::Nothing
    g.m[source, destination] = 1

    return nothing
end


"""
    addNeighbours(g::Graph, source::Integer, destination::Vector{<:Integer})::Nothing

Function to add multiple neighbours of a node
"""
function addNeighbours(g::Graph, source::Integer, destinations::Vector{<:Integer})::Nothing
    g.m[source, destinations] .= 1

    return nothing
end

"""
    clear(g::Graph, node::Integer)::Nothing

Function to `reset` all the graph's relationships
"""
function clear(g::Graph, node::Integer)::Nothing
    g.m[node, :] = falses(g.n) ## Clear incoming relationships
    g.m[:, node] = falses(g.n) ## Clear outgoing relationships

    return nothing
end
