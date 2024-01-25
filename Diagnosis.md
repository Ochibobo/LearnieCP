### Looking at the problem with optimization

Elements to examine:

BoolVar
Branching Schema
Sum Constraint
Modeling
DFS
Minimize
Branching schema


## IntMultView
- Fixed the remove function
  - Was set to `-`  instead of int-`/`


### AllDifferentDC constraint
- Not working as expected for variables with -ve domains where the min(v) > numberOfVariables


- The facility cost issue was on the branching schema
- Define a `Typed` branching schema