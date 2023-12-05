import Base: insert!, delete!, reset
"""
    @with_kw mutable struct Node{T}
        sumP::T
        ect::T

        function Node{T}(sumP::T, ect::T) where T
            new{T}(sumP, ect)
        end
    end

`Node` element that is part of the `ThetaTree`

`sumP`- represents the total sum of processing times for all nodes that are the children of this node (this node inclusive if it's the leaf node)

`ect` - represents the earliest completion time for all activities below this node (this node inclusive if it's the leaf node)
"""
@with_kw mutable struct Node{T}
    sumP::T
    ect::T

    function Node{T}(sumP::T, ect::T) where T
        new{T}(sumP, ect)
    end
end


"""
    createEmptyNode()::Node{T} where T

Function to create an `unitialized` node

Initialize the sum of the processes and earliest completion time if they are not specified
"""
function createEmptyNode()::Node
    return Node(0, typemin(Int))
end


"""
    reset(node::Node{T})::Nothing where T

Function to `reset` the `Node`. This essentially sets `sumP` to `0` and `ect` to the minimum value of type `T`
"""
function reset(node::Node{T})::Nothing where T
    node.sumP = 0
    node.ect = typemin(T)

    return nothing
end


"""
    ect(node::Node{T})::T where T

Function to get the `ect` - (earliest completion time) of a `Node` instance
"""
function ect(node::Node{T})::T where T
    return node.ect
end


"""
    sumP(node::Node{T})::T where T

Function to get the `sumP` - (total processing time) of a `Node` instance
"""
function sumP(node::Node{T})::T where T
    return node.sumP    
end


"""
    setEct!(node::Node{T}, ect::T)::Nothing where T

Function to set the `ect` - (earliest completion time) of a `Node` instance
"""
function setEct!(node::Node{T}, ect::T)::Nothing where T
    node.ect = ect
    
    return nothing
end


"""
    setSumP!(node::Node{T}, sumP::T)::Nothing where T

Function to set the `sumP` - (total processing time) of a `Node` instance
"""
function setSumP!(node::Node{T}, sumP::T)::Nothing where T
    node.sumP = sumP

    return nothing
end


"""
    @with_kw struct ThetaTree{T}
        nodes::Vector{Node{T}}
        size::Int
        isize::Int

        function ThetaTree{T}(size::Int) where T
            isize = 1

            ## Use this to count the maximum number of leaf nodes in the complete binary theta-tree
            while isize < size
                isize *= 2
            end

            ## The total number of nodes in a complete binary tree with isize leaves is (isize * 2) - 1
            totalNumberOfNodes = (isize * 2) - 1
            nodes = [createEmptyNode() for _ in 1:totalNumberOfNodes]

            ## Because isize represents the number of internal nodes, decrement it by 1
            isize -= 1

            new{T}(nodes, size, isize)
        end
    end

`ThetaTree` structure that holds a number of activities, each identified as a number between 1 and size. The activities
inserted are assumed to be of increasing earliest starting time. 

`size` is the number of activities that can possibly be inserted in the tree.

`isize` is the number of internal nodes

`nodes` are the nodes present in the `ThetaTree`
"""
struct ThetaTree{T}
    nodes::Vector{Node{<:T}}
    size::Int
    isize::Int

    function ThetaTree{T}(size::Int) where T
        isize = 1

        ## Use this to count the maximum number of leaf nodes in the complete binary theta-tree
        while isize < size
            isize *= 2
        end

        ## The total number of nodes in a complete binary tree with isize leaves is (isize * 2) - 1
        totalNumberOfNodes = (isize * 2) - 1
        nodes = [createEmptyNode() for _ in 1:totalNumberOfNodes]

        ## Because isize represents the number of internal nodes, decrement it by 1
        isize -= 1

        new{T}(nodes, totalNumberOfNodes, isize)
    end
end


"""
    reset(t::ThetaTree)::Nothing

Function to `remove` all nodes from the `ThetaTree`
"""
function reset(t::ThetaTree)::Nothing
    for node in t.nodes
        reset(node)
    end

    return nothing
end


"""
    ect(t::ThetaTree{T}, pos::Int)::T where T

Function to get the `earliest completion time` of activity at position `pos`
"""
function ect(t::ThetaTree{T}, pos::Int)::T where T
    (pos < 1 || pos > t.size) && throw(DomainError("Specified position $pos is out of bounds"))

    return ect(t.nodes[pos])
end


"""
    ect(t::ThetaTree{T})::T where T

Function to get the `earliest completion time` for the `root` node of the `ThetaTree`
"""
function ect(t::ThetaTree{T})::T where T
    return ect(t, 1)
end


"""
    sumP(t::ThetaTree{T}, pos::Int)::T where T

Function to get the `total processing time` of activity at position `pos`
"""
function sumP(t::ThetaTree{T}, pos::Int)::T where T
    (pos < 1 || pos > t.size) && throw(DomainError("Specified position $pos is out of bounds"))

    return sumP(t.nodes[pos])
end


"""
    father(pos::Int)::Int

Function to get the index of the `father` of the element at position `pos`
"""
function father(pos::Int)::Int
    pos < 1 && throw(DomainError("Specified position $pos is out of bounds"))

    if pos == 1 return 1 end
    
    ## To get the father/parent index you divide the current index by 2
    return pos ÷ 2
end


"""
    left(pos::Int)::Int

Function to get the `left child` of `pos`
"""
function left(pos::Int)::Int
    pos < 1 && throw(DomainError("Specified position $pos is out of bounds"))

    return pos * 2
end


"""
    right(pos::Int)::Int

Function to get the `right child` of `pos`
"""
function right(pos::Int)::Int
    pos < 1 && throw(DomainError("Specified position $pos is out of bounds"))

    return (pos * 2) + 1
end


"""
    insert!(t::ThetaTree{T}, pos::Int, ect::T, dur::T)::Nothing where T

Function to insert activity in leaf nodes at the given position `pos`. The `ect` is taken into account when creating this.

`pos` is the position in the leaf node where the insert is to happen.

`ect` is the earliest completion time of activity to be inserted

`dur` is the duration taken to process this activity
"""
function insert!(t::ThetaTree{T}, pos::Int, ect::T, dur::T)::Nothing where T
    ## Pad the position with isize to account for internal nodes
    targetPos = t.isize + pos
    node = t.nodes[targetPos]

    ## Update the node values
    setEct!(node, ect)
    setSumP!(node, dur)

    ## Update the internal nodes
    reCompute(t, father(targetPos))

    return nothing
end


"""
    delete!(t::ThetaTree, pos::Int)::Nothing

Function used to `delete!` a `node` from the `ThetaTree` so that it has no effect on the `earliest completion time` computation.

This basically means that the node at `pos` is `reset`
"""
function delete!(t::ThetaTree, pos::Int)::Nothing
    ## Get the current pos
    totalPos = t.isize + pos
    ## Assert that the positions are valid
    (pos < 1 || totalPos > t.size) && throw(DomainError("Specified position $totalPos is out of bounds"))

    ## Retrieve the node at pos
    node = t.nodes[totalPos]

    ## Reset this node
    reset(node)

    ## Recompute the earliest computation time and the total processing time
    reCompute(t, father(totalPos))

    return nothing
end

"""
    reComputeAux(t::ThetaTree, pos::Int)::Nothing

Auxilliary function that update's a `ThetaTree's` internal node's `ect` & `sumP`.
"""
function reComputeAux(t::ThetaTree, pos::Int)::Nothing
    (pos < 1 || pos > t.size) && throw(DomainError("Specified position $pos is out of bounds"))

    ## Get the node instance
    node = t.nodes[pos]

    ## Get the sum of the processing times from the left & right child nodes of the node at `pos`
    leftNodeSumOfProcessingTime = sumP(t, left(pos))
    rightNodeSumOfProcessingTime = sumP(t, right(pos))

    ## Update the node's total processing time
    setSumP!(node, leftNodeSumOfProcessingTime + rightNodeSumOfProcessingTime)

    ## Get the earliest completion time from the left & right nodes
    ectLeft = ect(t, left(pos))
    ectRight = ect(t, right(pos))

    ## Get the maximum between the right node's earliest completion time &
    ## the left node's earliest completion time + the right node's total processing time
    ## Use this to update this node's earliest completion time
    currentEct = max(ectRight, ectLeft + rightNodeSumOfProcessingTime)
    setEct!(node, currentEct)
    
    return nothing
end


"""
    reCompute(t::ThetaTree, pos::Int)::Nothing

Function used to update a `ThetaTree's` internal nodes' `ect` & `sumP` variables.
"""
function reCompute(t::ThetaTree, pos::Int)::Nothing
    (pos < 1 || pos > t.size) && throw(DomainError("Specified position $pos is out of bounds"))
    
    ## Continuously update the father upwards
    while pos > 1
        reComputeAux(t, pos)
        pos = father(pos)
    end

    ## Get the left node's ect
    leftEct = ect(t.nodes[2])
    ## Get the right node's ect & sumP
    rightEct = ect(t.nodes[3])
    rightSumP = sumP(t.nodes[3])

    ## Update the root's ect & sumP values eventually
    root = t.nodes[1]
    currentEct = max(leftEct + rightSumP, rightEct)
    setEct!(root, currentEct)
    setSumP!(root, sumP(t.nodes[2]) + rightSumP)

    return nothing
end
