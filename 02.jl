using BenchmarkTools

# part 1: find number of IDs that contain exactly 2 of any letter and number
# with exactly 3
input_strings = readlines("02.input")
input = collect.(input_strings)

function count_map(elems::AbstractArray{T}) where T
    counts = Dict{T,Int}()
    for x in elems
        counts[x] = get(counts, x, 0) + 1
    end
    counts
end

n2and3 = reduce((x,y)->x.+y, (x -> (2∈x, 3∈x)).(values.(count_map.(input))))
checksum = prod(n2and3)

# part 2: find two IDs that differ in exactly one position.  make a short
# circuiting distance function that returns true if total edit distance is less
# than n.

function edit_dist_lt_n(x, y, n::Int=2)
    edits = 0
    @inbounds for i in eachindex(x,y)
        edits += x[i] != y[i]
        edits >= n && return false
    end
    return true
end

function edit_dist_lt_n_zip(x, y, n::Int=2)
    edits = 0
    for (xi,yi) in zip(x,y)
        edits += xi != yi
        edits >= n && return false
    end
    return true
end

# they're pretty close (indexing is faster if you add inbounds)
@btime edit_dist_lt_n_zip($input[1], $input[2], 2)
@btime edit_dist_lt_n($input[1], $input[2], 2)

function star2(input; distf::Function=edit_dist_lt_n_zip)
    input = copy(input)
    while !isempty(input)
        x = pop!(input)
        for y in input
            if distf(x, y, 2)
                return x,y
            end
        end
    end
    return nothing
end

# ...but working direclty with strings is way more expensive:
@btime star2(input_strings)               # 571 μs
@btime star2(input)                       # 140 μs
@btime star2(input, distf=edit_dist_lt_n) # 134 μs

matches = star2(input)
join(matches[1][matches[1] .== matches[2]])
