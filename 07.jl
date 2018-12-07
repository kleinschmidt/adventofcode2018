using Test

# each line is "Step X must be completed before step Y can begin"
parseline(line) = (line[6], line[37])

test_input = parseline.(split(strip("""
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
"""), '\n'))

input = parseline.(readlines("07.input"))

# my feeling is that you can either start from the top or the bottom.  let's try
# the top first: for each step, make a list of its dependents

# idea here is to keep track of frontier as a sorted list.  then each time you
# do a step, add all the steps it unlocks to the frontier.  the tricky thing is
# that you still need to track the backward dependencies too to check if a step
# is ready.

# convert pairs into the forward edges (the vector of all the nodes that depend
# on a given node)
function forward(input)
    edges = Dict{Char,Vector{Char}}()
    for (before, after) in input
        push!(get!(edges, before, Char[]), after)
    end
    edges
end

# backward edges: all the steps that must be completed before a given step can
# begin
backward(input) = forward(reverse(i) for i in input)

roots(input) = setdiff(keys(backward(input)), keys(forward(input)))

# gonna work backwards, starting at roots (steps with no dependents).  give each
# node a number: root is one.  all it's precursors are 2.  theirs are 3.  etc.
# okayyyy but this doesn't address the fact that the sorting really depends on
# the FORWARD direction (doing things when they first become available).
#
# the most straightforward way is to use a forward frontier and the backwards
# edges to determine whether completing a task should add it to the frontier.

mutable struct JobQueue
    f_edges::Dict{Char}
    b_edges::Dict{Char}
    queue::Vector{Char}
end

function JobQueue(input)
    f_edges = forward(input)
    b_edges = Dict(t=>Set(f) for (t,f) in backward(input))
    queue = sort!(collect(setdiff(keys(f_edges), keys(b_edges))), rev=true)
    JobQueue(f_edges, b_edges, queue)
end

Base.iterate(jq::JobQueue) = iterate(jq, 0)
function Base.iterate(jq::JobQueue, state)
    isempty(jq.queue) && return nothing
    next = pop!(jq.queue)
    for dep in get(jq.f_edges, next, ())
        if isempty(delete!(jq.b_edges[dep], next))
            push!(jq.queue, dep)
            # could also delete dep from back edges but not necessary
        end
    end
    sort!(jq.queue, rev=true)
    (next, state+1)
end

Base.length(jq::JobQueue) = length(union(keys(jq.f_edges), keys(jq.b_edges)))
Base.eltype(::Type{JobQueue}) = Char

star1(input) = collect(JobQueue(input))
@test String(star1(test_input)) == "CABDFE"

String(star1(input))
