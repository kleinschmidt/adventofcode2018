function parse_line(line)
    id, x, y, w, h = parse.(Int, match(r"#(\d+) @ (\d+),(\d+): (\d+)x(\d+)", line).captures)
    (id, x .+ (1:w), y .+ (1:h))
end

input = parse_line.(readlines("03.input"))

cloth = zeros(Int, 1000, 1000)
for (id, xrange, yrange) in input
    cloth[xrange, yrange] .+= 1
end

# part 1: number of squares with >1 claim
@show sum(c > 1 for c in cloth)

# part 2: find only claim that has no intersection
# (re-use the "cloth" marked up for the first star to make this O(n))

@btime [id
        for (id, xrange, yrange)
        in input
        if all(isequal(1), view(cloth, xrange, yrange))]
#   452.265 μs (5281 allocations: 185.72 KiB)
# 1-element Array{Int64,1}:
#  724

@btime first(id
             for (id, xrange, yrange)
             in input
             if all(isequal(1), view(cloth, xrange, yrange)))
#   244.011 μs (2899 allocations: 101.86 KiB)
# 724
