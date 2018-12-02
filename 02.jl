# find number of IDs that contain exactly 2 of any letter and number with
# exactly 3
input = collect.(readlines("02.input"))

function count_map(elems::AbstractArray{T}) where T
    counts = Dict{T,Int}()
    for x in elems
        counts[x] = get(counts, x, 0) + 1
    end
    counts
end

has2has3(x) = (2 ∈ x, 3 ∈ x)

prod(reduce((x,y)->x.+y, (x -> (2∈x, 3∈x)).(values.(count_map.(input)))))
