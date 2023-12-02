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


#### Element1DVar
- Domain Consistency
- Relaxed Domain Consistency
  - Assume Range domains for D(z) & All D(T[i])

### Stable Matching
- A feasibility problem
- The domain for each student variable is the set of companies and the domain for all companies is a set of students
- Enforce reciprocity in the student - company association
  - Index an array of variables with a variable
- y is the guiding looping factor
- Uses:
  - Element Constraint
  - Logical Combination of constraints with reification

### IsLessOrEqual
- When this or any other value cannot be met by the values of `iv` & `v`, then there is not solution. There's no need to proceed.


#### TableCT
-  We have one bit for each of the bit set for each of the tuple.
-  Gather all tuples with x = 1, for example and mark all their equivalent bitset values with `true`. Do the same for all the other bitsets x=2, x=3, x=n, y= 1,..., z = n


### Disjunctive
- Also called Unary resource - specific case of cumulative; capacity = 1, demand = 1.
- Reduce the makespan
- Fix the starting time
- Binary Decomposition is at least as strong as Cumulative constraint
2 alternatives in search:
- Fix the start times
- Fix the ordering on each machine then eventually start
  - Branch on the precedence
  - Branch on the `reified` constraints to achieve this.
    - bij = si + di <= sj
    - bji = sj + dj <= si
    - bji != bij
- Take the earliest completion time into consideration
  - With time windows, this is NP-hard
  - Relax the problem; relax the lct constraint
  - Compute the ect lower bound
    - Sort activities by est first
    - At each step, get the maximum between the est_i + p_i & ect + p_i
    - Take into account the lst of the activities, which is exactly the `dual` problem 
- Earliest completion time of nested sets of activities
  - Nested set means the next set = previous set + 1 activity
  - 
- Perform overload checking
  - Use an activity's left cut
  - An inefficient approach involves using the `Theta-tree` n times with a complexity of `n^2*log(n)`
- Consider a nested LCut by sorting activities by the latest completion time
  - Complexity is now `O(n(log n))`
- If the earliest completion time of the `Theta-Tree` exceeds the `Latest completion time` of activity `j`, throw an exception
- Detectable Precedences
  - DPrec(T, i) = {j | j in T \ {i} & est_i + p_i > lst_j - p_j } - i cannot be included in this set
  - Hence the est_i >= max(est_i, ect(DPrec(T, i)))
- Not-Last Rule
  - An activity cannot be placed as the last one in a set; you'll go beyond the deadline.
  - 