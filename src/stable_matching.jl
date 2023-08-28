## Implementation of the Stable Matching
include("JuliaCP.jl")

using .JuliaCP

solver = Engine.LearnieCP()

## Variable Definition
## company[s] is the company chosen for student s
