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

start!(jq::JobQueue) = pop!(jq.queue)
function finish!(jq::JobQueue, job)
    for dep in get(jq.f_edges, job, ())
        if isempty(delete!(jq.b_edges[dep], job))
            push!(jq.queue, dep)
            # could also delete dep from back edges but not necessary
        end
    end
    
    sort!(jq.queue, rev=true)
    job
end
Base.isempty(jq::JobQueue) = isempty(jq.queue)

Base.iterate(jq::JobQueue) = iterate(jq, 0)
Base.iterate(jq::JobQueue, state) =
    isempty(jq) ? nothing : (finish!(jq, start!(jq)), state+1)


Base.length(jq::JobQueue) = length(union(keys(jq.f_edges), keys(jq.b_edges)))
Base.eltype(::Type{JobQueue}) = Char

star1(input) = collect(JobQueue(input))
@test String(star1(test_input)) == "CABDFE"

String(star1(input))


# star 2: two twists.  jobs have a TIME associated (61 seconds for A, 62 for B,
# etc.), and there are multiple workers who can work in parallel.  the strategy
# is very similar, except that instead of just taking jobs straight out of the
# queue, need to have an additional step where each worker takes a job and then
# reports when they'll be done.  then advance the time to the next worker to
# finish.

# what to do next depends on whether there are workers free and jobs available.
# 
# while there are jobs in the master queue and the workers aren't all busy,
# start a job and hand it to the workers.
#
# if there are no jobs available, take the next job the workers will finish, and
# finish it in the main queue (and update the current time)
#
# if there are no workers free, same as above...
mutable struct MultiWorkerQueue
    jobs::JobQueue
    working_on::Vector{Char}
    t_done::Vector{Int}
    t::Int
    job_time::Function
end

function MultiWorkerQueue(input, n_worker::Int, job_time::Function)
    working_on = fill('.', n_worker)
    t_done = fill(typemax(Int), n_worker)
    jobs = JobQueue(input)
    MultiWorkerQueue(jobs, working_on, t_done, 0, job_time)
end

function Base.iterate(mwq::MultiWorkerQueue, state)
    println("t = $(mwq.t)")
    
    # done when no more jobs and all workers idle
    isempty(mwq.jobs) && all(isequal('.'), mwq.working_on) && return nothing

    # while there are idle workers and jobs available, fill the work queues
    for worker in findall(isequal('.'), mwq.working_on)
        isempty(mwq.jobs) && break
        job = start!(mwq.jobs)
        mwq.working_on[worker] = job
        mwq.t_done[worker] = mwq.t + mwq.job_time(job)
        println("  queueing job $job for worker $worker (done at t=$(mwq.t_done[worker]))")
    end

    # find the next job to be finished, increment the time, and return it
    mwq.t, worker = findmin(mwq.t_done)
    job = mwq.working_on[worker]
    finish!(mwq.jobs, job)
    mwq.t_done[worker] = typemax(Int)
    mwq.working_on[worker] = '.'
    return job, mwq.t
end

Base.iterate(mwq::MultiWorkerQueue) = iterate(mwq::MultiWorkerQueue, 0)    
Base.length(mwq::MultiWorkerQueue) = length(mwq.jobs)

function star2(input; n_worker=5, job_t = (c) -> c-'A'+61)
    jobs = MultiWorkerQueue(input, n_worker, job_t)
    jobs_done = collect(jobs)
    jobs_done, jobs.t
end
