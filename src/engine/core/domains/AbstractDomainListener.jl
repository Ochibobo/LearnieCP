"""
`AbstractDomainListener` interface
"""
abstract type AbstractDomainListener end


"""
    empty(l::AbstractDomainListener)

Function called when the domain of a variable is empty
"""
function onEmpty(l::AbstractDomainListener)
    throw(error("Domain is empty!!"))
end


"""
    change(l::AbstractDomainListener)

Function that is executed when the domain of a variable is `changed`
"""
function onChange(l::AbstractDomainListener)
    throw(error("onChange not implemented for domain listener $(l)"))
end


"""
    onChangeMin(l::AbstractDomainListener)

Function that is executed when the `minimum` value of a domain variable changes
"""
function onChangeMin(l::AbstractDomainListener)
    throw(error("onChangeMin not implemented for domain listener $(l)"))
end


"""
    onChangeMax(l::AbstractDomainListener)

Function that is executed when the `maximum` value of a domain variable changes
"""
function onChangeMax(l::AbstractDomainListener)
    throw(error("onChangeMax not implemented for domain listener $(l)"))
end


"""
    onBind(l::AbstractDomainListener)

Function that is executed when the domanin of a variable is `bound`
"""
function onBind(l::AbstractDomainListener)
    throw(error("onChangeMax not implemented for domain listener $(l)"))
end


