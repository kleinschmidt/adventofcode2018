# insert "marbles" in a "circle"
# original, naive version:
function star1(players, marbles)
    circle = [0]
    scores = zeros(Int, players)
    pos = 1
    for i in 1:marbles
        if i % 23 == 0
            # score marble i, and remove+score marble 7 marbles CCW from positive
            pos = mod(pos - 7 - 1, length(circle)) + 1
            scores[(i-1) % players + 1] += i + circle[pos]
            deleteat!(circle, pos)
        else
            # insert after marble that's ONE clockwise from current pos:
            pos = pos % length(circle) + 1 + 1
            insert!(circle, pos, i)
        end
    end
    maximum(scores)
end

# represents the active node in a circular linked list:
mutable struct Node
    value::Int
    next::Node
    prev::Node
    function Node(i::Int)
        n = new(i)
        n.next = n.prev = n
    end
end

link!(first::Node, second::Node) = (first.next = second; second.prev = first)

next(n::Node, i::Int=1) = i > 1 ? next(n.next, i-1) : n.next
prev(n::Node, i::Int=1) = i > 1 ? prev(n.prev, i-1) : n.prev
function insertafter!(n::Node, i::Int)
    new = Node(i)
    link!(new, next(n))
    link!(n, new)
    return new
end

# remove node from circle and return NEW node at that position
function Base.delete!(n::Node)
    ret = next(n)
    link!(prev(n), next(n))
    return ret, n
end

# just for visualization:
function Base.collect(n::Node)
    out = Int[n.value]
    m = next(n)
    while m !== n
        push!(out, m.value)
        m = next(m)
    end
    return out
end

function star1_nodes(players, marbles)
    circle = Node(0)
    scores = zeros(Int, players)
    for i in 1:marbles
        if i % 23 == 0
            circle, del = delete!(prev(circle, 7))
            scores[(i-1) % players + 1] += i + del.value
        else
            circle = insertafter!(next(circle), i)
        end
    end
    maximum(scores)
end

using Test, BenchmarkTools

@test star1(9, 25) == 32
@test star1(10, 1618) == 8317
@test star1(13, 7999) == 146373

@test star1_nodes(9, 25) == 32
@test star1_nodes(10, 1618) == 8317
@test star1_nodes(13, 7999) == 146373

input = (462, 71938)
@btime star1(input...)
#   63.378 ms (20 allocations: 2.00 MiB)
# 398371
@btime star1_nodes(input...)
#   518.707 μs (68815 allocations: 2.10 MiB)
# 398371

# very fast until the GC kicks in...
input100 = (462, 7193800)
@btime star1_nodes(input100...)
# julia> @time star1_nodes(input100...)
#   0.575544 seconds (6.88 M allocations: 209.996 MiB, 73.14% gc time)
# 3212830280
#   0.139192 seconds (6.88 M allocations: 209.996 MiB)
# 3212830280
