module CircuitList

using UUIDs
import Base.append!
import Base.iterate
import Base.push!

"""
Node element in LList-type structure. Maintains forward and reverse links, data, and UUID.
"""
mutable struct Node{T}
    data::Union{Nothing, T}
    next::Union{Nothing, Node{T}}
    prev::Union{Nothing, Node{T}}
    uuid::UUID
    Node{T}() where {T} = new(nothing, nothing, nothing, UUIDs.uuid1())
    Node{T}(data) where {T} = new(data, nothing, nothing, UUIDs.uuid1())
    Node{T}(data, prev) where {T} = new(data, nothing, prev, UUIDs.uuid1())
    Node{T}(data, next, prev) where {T} = new(data, next, prev, UUIDs.uuid1())
end

"""
DLList structure for representing GateCalls. Maintains start, end and position pointer.
"""
mutable struct CList{T}
    len::Int
    head::Union{Nothing, Node{T}}
    tail::Union{Nothing, Node{T}}
    current::Union{Nothing, Node{T}}
    CList{T}() where {T} = new(0, nothing, nothing, nothing)
end

function push!(cl::CList{T}, data::T) where T
    if cl.len == 0
        n = Node{T}(data)
        cl.head = n
        cl.tail = n
        cl.current = n
        cl.current = cl.head
    else
        cl.tail.next = Node{T}(data, cl.tail)
        cl.tail.next.prev = cl.tail
        cl.tail = cl.tail.next
    end
    cl.len += 1
end

function clear!(l::CList{T}) where T
    l.head = nothing
    l.tail = nothing
    l.current = nothing
    l.len = 0
end

function append!(l1::CList{T}, l2::CList{T}) where T
    if l2.current == nothing
        return
    end
    l2c = deepcopy(l2)
    l1.tail.next = l2c.head
    l2c.head.prev = l1.tail
    l1.len += l2c.len
    clear!(l2)
    return l1
end

function copy(l::CList{T}) where T
    lc = CList{T}()
    for val in l
        push!(lc, val)
    end
    return lc
end

function iterate(list::CircuitList.CList{T}) where T 
    if list.len == 0
        return nothing 
    else
        list.current = list.head
        return (list.current.data, list.current.next)
    end
end

function iterate(list::CircuitList.CList{T}, n::Union{CircuitList.Node{T}, Nothing}) where T
    if list.current.next == nothing 
        return nothing 
    else
        res = (list.current.next.data, list.current.next)
        list.current = list.current.next
        return res
    end
end

end