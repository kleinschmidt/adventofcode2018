using Test

input = parse.(Int, readlines("01.input"))

star1(input) = sum(input)
@show star1(input)

function star2(input)
    seen = Set{Int}([0])
    freq = 0
    for i in Iterators.cycle(input)
        freq += i
        if freq ∈ seen
            return freq
        else
            push!(seen, freq)
        end
    end
end

@test [+1, -1] |> star2 == 0
@test [+3, +3, +4, -2, -4] |> star2 == 10
@test [-6, +3, +8, +5, -6] |> star2 == 5
@test [+7, +7, -2, -7, -4] |> star2 == 14

@show star2(input)


# can maybe use a BitSet to speed things up (represents a set of integers with a
# bitstring).
function star2bitset(input)
    seen = BitSet([0])
    freq = 0
    for i in Iterators.cycle(input)
        freq += i
        if freq ∈ seen
            return freq
        else
            push!(seen, freq)
        end
    end
end

@test [+1, -1] |> star2bitset == 0
@test [+3, +3, +4, -2, -4] |> star2bitset == 10
@test [-6, +3, +8, +5, -6] |> star2bitset == 5
@test [+7, +7, -2, -7, -4] |> star2bitset == 14

star2bitset(input)

using BenchmarkTools
@btime star2(input)             # 3.8 ms
@btime star2bitset(input)       # 301 μs
