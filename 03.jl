function parse_line(line)
    id, x, y, w, h = parse.(Int, match(r"#(\d+) @ (\d+),(\d+): (\d+)x(\d+)", line).captures)
    (id, x .+ (1:w), y .+ (1:h))
end

input = parse_line.(readlines("03.input"))

cloth = zeros(Int, 1000, 1000)
for (id, xrange, yrange) in input
    cloth[xrange, yrange] .+= 1
end

@show sum(c > 1 for c in cloth)

[id for (id, xrange, yrange) in input if all(isequal(1), view(cloth, xrange, yrange))]
