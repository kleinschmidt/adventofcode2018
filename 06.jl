input = [(parse.(Int, split(pair, ','))..., ) for pair in readlines("06.input")]

# strategy: brute force.  find closest point for each grid cell
xs = 1:maximum(first.(input))+50
ys = reshape(1:maximum(last.(input))+50, 1, :)

input3d = reshape(input, 1, 1, :)

xd = abs.(xs .- first.(input3d))
yd = abs.(ys .- last.(input3d))

abs_diff(a,b) = a > b ? a-b : b-a
@btime distmap = abs.(xs .- first.(input3d)) .+ abs.(ys .- last.(input3d));
@btime abs_diff.(xs, first.(input3d)) .+ abs_diff.(ys, last.(input3d));

mindist, closest = findmin(abs.(xs .- first.(input3d)) .+ abs.(ys .- last.(input3d)); dims=3)
last.(convert.(Tuple, closest))

# the issue with that solution is there's no easy way to detect ties...

function star1(input)
    xs = 1:maximum(first.(input))+50
    ys = 1:maximum(last.(input))+50
    closest = zeros(Int, length(xs), length(ys))
    for x in xs, y in ys
        mindist = typemax(Int)
        for i in 1:length(input)
            dist = abs(input[i][1]-x) + abs(input[i][2]-y)
            closest[x,y] = dist == mindist ? 0 : dist < mindist ? i : closest[x,y]
            mindist = min(dist, mindist)
        end
manhattan_dist(a,b) = sum(abs.(a.-b))
@btime distmap = abs.($xs .- first.($input3d)) .+ abs.($ys .- last.($input3d));
@btime distmap2 = manhattan_dist.(tuple.($xs, $ys), $input3d);



closest = last.(Tuple.(last(findmin(distmap2, dims=3))))
closest_rev = size(distmap2,3)+1 .-
    last.(Tuple.(last(findmin(view(distmap2, :, :, 50:-1:1), dims=3))))
closest[closest .!= closest_rev] .= 0
    end
    closest
end

@btime closest = star1(input);

counts = zeros(Int, size(input))
for i in closest
    i > 0 && (counts[i] += 1)
end

dq = union(Set(closest[1:end, 1]),
           Set(closest[1:end, end]),
           Set(closest[1, 1:end]),
           Set(closest[end, 1:end]))
delete!(dq, 0)

counts[[dq...]] .= 0

findmax(counts)
