using Dates

lines = readlines("04.input")

function parseevent(event::AbstractString)
    num = match(r"(\d+)", event)
    if num isa Nothing
        return event == "falls asleep" ? :sleep : :wake
    else
        return parse(Int, num.captures[1])
    end
end

function parseline(line)
    date_string, event = match(r"\[(.*)\] (.*)", line).captures
    datetime = Dates.DateTime(date_string, dateformat"y-m-d H:M")
    event = parseevent(event)
    datetime, event
end

input = sort!(parseline.(lines), by=first)

function collect_sleeps(input)
    id = -1
    last_sleep = DateTime(0)
    sleeps = Dict{Int,Vector{Tuple{DateTime,DateTime}}}()
    for (time, event) in input
        if event isa Int
            id = event
        elseif event == :sleep
            last_sleep = time
        else # event == :wake
            push!(get!(sleeps, id, Vector{Tuple{DateTime,DateTime}}()),
                  (last_sleep, time))
        end
    end
    sleeps
end

sleeps = collect_sleeps(input)

function find_sleepiest_min(sleeps::Vector{Tuple{DateTime,DateTime}})
    mins_asleep = zeros(Int, 60)
    for (sleep, wake) in sleeps
        sleep_min = minute(sleep)+1 # one-based indexing ;)
        wake_min = minute(wake)
        mins_asleep[sleep_min:wake_min] .+= 1
    end
    sleep_freq, sleepiest_min = findmax(mins_asleep) .- (0,1)
end

total_sleeps = Dict(id => mapreduce(((x,y),) -> Minute(y-x), +, sleeps)
                    for (id, sleeps) in sleeps)
mins, id = findmax(total_sleeps)
_, sleepiest_min = find_sleepiest_min(sleeps[id])

@show id * sleepiest_min


(freq, mins2), id2 = findmax(Dict(id => find_sleepiest_min(sleeps)
                                  for (id, sleeps) in sleeps))
@show id2 * mins2
