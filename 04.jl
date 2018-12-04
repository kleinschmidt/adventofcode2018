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

let
    id = -1
    last_sleep = DateTime(0)
    longest_sleep = Minute(0)
    sleepiest = -1
    for (time, event) in input
        if event isa Int
            id = event
        elseif event == :sleep
            last_sleep = time
        else # event == :wake
            sleep = time - last_sleep
            longest_sleep = max(sleep, longest_sleep)
            sleepiest = longest_sleep == sleep ? id : sleepiest
        end
    end

    sleepiest, longest_sleep
end
