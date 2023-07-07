# JuliaCP

A constraint solver written completely in Julia. It is heavily inspired by [MiniCP](http://minicp.org/). The intent of this project is for pedagogical purposes. However, as development has continued, it seems like in time, it shall be released for use in development & production systems. 

--- 
### High Level Architectural View

This is a very very high level view of the components that make up the `Engine`. The problems the solver aims to provide a means to solve are `Discrete` and `Deterministic`. So far, there's only support for `Integer` variables - though not or long - rich variables will be introduced in time.

![JuliaCP Components Graph](assets/OverviewArchitectire.png)


---
> Contributions are welcome.