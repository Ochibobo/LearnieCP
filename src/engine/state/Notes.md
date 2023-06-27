
- State depends on nothing.
- Should be part of the core library implementation
- The backup of the trailer is only activated when the current value of a state variable is changed through setValue! primitives.
- The backup is cleared at each saveState()
- We ought to set the size to clear all elements that at this time are irrelevant for the Copier.
  - so SetSize does make a difference
- 
  