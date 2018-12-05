# same letter of different case cancel
#
# could do this in place but my hunch is that it's expensive to delete in middle
# of a vector so let's use an output vector we push to one at a time, while
# iterating over the input

input = read("05.input", String) |> strip |> collect

cancels(a::Char, b::Char) = abs(a-b) == 32

function cancel!(output, next)
    if !isempty(output) && cancels(next, last(output))
        pop!(output)
    else
        push!(output, next)
    end
    output
end

cancel(input) = reduce(cancel!, input, init=Char[])

cancel(collect("dabAcCaCBAcCcaDA")) |> String == "dabCBAcaDA"

# star 1
canceled = cancel(input)
length(canceled)

# star 2:
minimum((length(cancel(Iterators.filter(!in((t, uppercase(t))), input))), t)
         for t
         in unique(lowercase(c) for c in input))

# in-place version: don't delete, just move (and resize)
function canceli!(input)
    # the last index in the working area
    j = 0
    for i in eachindex(input)
        if j > 0 && cancels(input[j], input[i])
            j -= 1
        else
            j += 1
            input[j] = input[i]
        end
    end
    resize!(input, j)
    input
end

canceli!(collect("dabAcCaCBAcCcaDA")) |> String == "dabCBAcaDA"


using BenchmarkTools

input = read("05.input", String) |> strip |> collect

@btime canceli!(copy($input));
@btime cancel($input);
