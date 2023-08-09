### Notes
- Surprisingly, through very important, it has one of the shortest interface definitions.
- Most of the focus is on the implementation of `post` and `propagate`.
- It maintains an internal `active` state variable.
- Also has boolean to indicate whether it's been `scheduled` or not.
  - `scheduled` here means that the constraint had been placed in the propagation queue of the solver.
  - `scheduled` doesn't have to be a state variable because it's only local to one state of propagation; never transferred from node to node.
  - `active` is however a State variable.
  - These are considered as performance APIs.
- Schedule constraints only when they are active and not already on the queue.
- To `propagate` a constraint, set the scheduled flag to false and only propagate when the constraint is currently acitve.


### Sum constraint
- Very interesting when it comes to bound consistency
- You'd want all variables to sum to 0
- May require the rearrangement of the way varaibles are keyed in


### Element Constraint
- A family of constraints that is used to index an array with variables.
- An array of integers in this case.
- Can be `1D` or `2D`.
```julia
Element2D(T::Integer[][], x::IntVar, y::IntVar, z::IntVar)
```
- Works on putting no holes in the domain of `z` because `z` participates in the __sum__ constraint that uses bounds consistency.
- `T` is indexed by `x` and `y`.
- `T[x][y] = z`.
- This constraint achieves a hybrid consistency - a mix of `domain` and `bounds` consistency.
#### Quadratic Assignment Problem
- The decision variables are of size `n` showing where to place facility `i` in order to minimize the total overall cost.
- 