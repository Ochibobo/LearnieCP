### Notes on making the solver


## Overall Design
- One may end up investing more in designing constraints than in designing search strategies, especially if search is DFS.
- Constraint modelling is worth spending time in. 
- Search should be invested in more when exploring ML in search.
- A constraint program is a model +  a search procedure
  - Apprently, the search oughts to be interesting.
- You have to specify the search
  - Work with a default search -> DFS
  - Allow for search specification otherwise.
- Use a closure to define a search procedure.
- Constraint propagation modifies the domains in-place.


## Branching Schema
- Branching scheme is very essential.
 

## DomainListener
- The purpose of a listener is to `listen` to domain changes & schedule constraints.
- The listener has no state, just accompanying functions to schedule constraints for propagation based on certian events.
- 


## Variables
- The list of constraints is associated to a variable.
- Constraints are added to the variable through propagation functions
- 


## Domiain
- Removal of values is delegated to the the domain.
- Storage, however, is upon the state.
- The domain interface is independent of the solver.
- State management is the state of the domains of the variables
- An `AbstractDomain` is used as an interface to define the contract all domain implementations are to adhere to.
- An `SparseSetDomain` is an implementation of the `AbstractDomain` having a `StateSparseSet` as the underlying store implementation.


## State
- Completely separated from the search itself.
- `MiniCP` exploits the `LIFO` nature of `DFS` to optimize the state management.
  - Other search strategies may not benefit from similar optimizations.
- What we need to save when starting a search is the `minimum`, the `maximum` and the `size` of a particular domain.
  - They are all `StateIntegers`. They are persisted in the solver's `StateManager`
  - At the beginning of a branch, the `StateManager` takes all the state variables of all the `domains` and creates a `backup`.
  - Restoration is independent of success.
    - Choose -> saveState()
    - Explore -> branching()
    - Unchoose -> restore()
- The `State<T>` sets & gets state values.
  - It is just an interface that takes in any type.
  - The implementation contains a `StateEntry`
  - `restore` returns the value saved in it's associated `StateEntry` instance.


- The `StateEntry` implements the `restore()` function as every `StateEntry` oughts to be restorable.
  - `Classname.this` in `Java` is used to refer to an outer class instance when one is using nested class. 
    - `Restore` refers to the outer class' instance when updating it's value.
  - Keeps track of a value `v`  of a `State<T>` at a particular point in time upon saving.
  - This is what is implemented by the `BackUp` instance.
    - There's the need to be able to restore.
  - Used to record a `snapshot` and possible `restore` its content later.


- `Copier` implements the `StateManager` interface.
  - Variable `store` keeps track of all state objects ever created.
    - `makeStateInt` and `makeStateBool` add a reference to any object they create here; they create the state objects.
  - Variable `prior` contains a stack of variables which were saved by method `saveState` and restored by method `restoreState`.
    - state accumulated going down the branch. 
  - `saveState` creates an instance of a `Backup` class whose constructor saves a copy of every object in the state `store`
  - `restore` of every backup restores the saved objects.
  - `Backup` also store the `size` of the `store` since state objects may be created during the `search` and proper `size` must be restored.
  - 


- `Storage` is squashed into the `Copy{T}` interface.
- Rethink the position of `StateEntry` restore function; it actually restores a `State{T}`  object's value.
  - Maybe make it present in the `Copy{T}`

-  `Trailer` implements the `StateManager` interface.
   -  It saves states `onChange` only.
   -  Does not copy the entire state.
   -  Main steps:
      -  When we call `saveState`, nothing needs to be done.
      -  When a stateful object is modified, save the state.
         -  Put it inside the BackUp; this means the objects are placed one by one in the backup instead of taking everything and putting them in the backup
      -  Restore the state
   -  The `current` backup is the backup of the current active objects.
   -  In `saveState` add the previous `backUp` to the prior and "close" it by setting the `current` backup to a new backup.
   -  Saving a variable state multiple times when the domain is being updated may actually be less efficient than saving everything in the beginning
      -  Keep track when the state variable was last saved.
      -  

## Questions:
- [ ] Do I need all those interfaces really??
- [ ] 