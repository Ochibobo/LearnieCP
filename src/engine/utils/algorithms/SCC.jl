## Implementation of the strongly connected components algorithm
using DataStructures

"""
    getSCC(g::Graph)::Vector{Integer}

Compute the `strongly connected components` of Graph `g`
"""
function getStronglyConnectedComponents(g::Graph)::Vector{Integer}
    ## Traverse the normal graph
    visited = Set{Integer}()
    nodes = Stack{Integer}()

    for node in 1:g.n
        ## Only traverse nodes who are yet to be visited
        if !in(node, visited)
            dfs(g, node, visited, nodes)
        end
    end
    
    ## Traverse the reverse graph
    revGraph = reverseGraph(g)
    visited = Set{Integer}()
    ## vector to hold the scc for each node
    scc = fill(-1, g.n)
    ## Index of scc
    sccNumber = 1

    while !isempty(nodes)
        ## Get the top most node
        node = pop!(nodes)
        components = Stack{Integer}()
        if !in(node, visited)
            dfs(revGraph, node, visited, components)
            ## Add the nodes to the scc vector
            while !isempty(components)
                valueIndex = pop!(components)
                ## Mark all components with the same scc number to show they are in the same scc
                scc[valueIndex] = sccNumber
            end
            sccNumber += 1
        end
    end

    return scc
end


"""
    reverseGraph(g::Graph)::Graph

Get a `reverse graph` of this graph
"""
function reverseGraph(g::Graph)::Graph
    return Graph(n = g.n, m = Matrix(g.m'))
end


"""
    dfs(g::Graph, source::Integer, visited::Set{Integer}, nodes::Stack{Integer})::Nothing

DFS helper
"""
function dfs(g::Graph, source::Integer, visited::Set{Integer}, nodes::Stack{Integer})::Nothing
    if in(source, visited)
        return
    end

    ## Add the node to the visited set
    push!(visited, source)

    ## Traverse the node's neighbours
    for node in Structures.into(g, source)
        dfs(g, node, visited, nodes)
    end

    ## Append the element into the stack of visited nodes
    push!(nodes, source)

    return nothing
end