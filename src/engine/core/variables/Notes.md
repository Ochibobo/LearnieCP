-  A variable:
   - State:
     - Recalls the solver that created the variable
     - Encapsulates the domain 
     - Tracks the constraints that mention it
   - API:
     - Domain queries
     - Domain updates
     - Connection to the constraint


- IntVarMultView

Function: __removeAbove()__

| Coeffecient   | Query     | Algorithm Written   | Passes |
| :-----------: | :-------- | :-----------------: | ------ |
| Positive      | Positive  |   Yes               |        |
| Positive      | Negative  |   No                |        |
| Negative      | Negative  |   No                |        |
| Negative      | Positive  |   No                |        |
|               |           |                     |        |


Function: __removeBelow()__

| Coeffecient   | Query     | Algorithm Written   | Passes |
| :-----------: | :-------- | :-----------------: | ------ |
| Positive      | Positive  |   Yes               |        |
| Positive      | Negative  |   No                |        |
| Negative      | Negative  |   No                |        |
| Negative      | Positive  |   No                |        |
|               |           |                     |        |

Function: __remove()__

| Coeffecient   | Query     | Algorithm Written   | Passes |
| :-----------: | :-------- | :-----------------: | ------ |
| Positive      | Positive  |   Yes               |        |
| Positive      | Negative  |   No                |        |
| Negative      | Negative  |   No                |        |
| Negative      | Positive  |   No                |        |
|               |           |                     |        |

Function: __removeAllBut()__

| Coeffecient   | Query     | Algorithm Written   | Passes |
| :-----------: | :-------- | :-----------------: | ------ |
| Positive      | Positive  |   Yes               |        |
| Positive      | Negative  |   No                |        |
| Negative      | Negative  |   No                |        |
| Negative      | Positive  |   No                |        |
|               |           |                     |        |


- All the above are tested.
- 