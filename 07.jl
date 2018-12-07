using Test

# each line is "Step X must be completed before step Y can begin"
parseline(line) = (line[6], line[37])

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

function star1(input)
    f_edges = forward(input)
    b_edges = Dict(t=>Set(f) for (t,f) in backward(input))
    frontier = sort!(collect(setdiff(keys(f_edges), keys(b_edges))), rev=true)
    ordered = Char[]
    while !isempty(frontier)
        next = pop!(frontier)
        for dep in get(f_edges, next, ())
            if isempty(delete!(b_edges[dep], next))
                push!(frontier, dep)
                # could also delete dep from back edges but not necessary
            end
        end
        sort!(frontier, rev=true)
        push!(ordered, next)
    end
    ordered
end

test_input = parseline.(split(strip("""
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
"""), '\n'))

@test String(star1(test_input)) == "CABDFE"

String(star1(input))
