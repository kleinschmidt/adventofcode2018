input = [(parse.(Int, split(pair, ','))..., ) for pair in readlines("06.input")]

# strategy: brute force.  find closest point for each grid cell
xs = 1:maximum(first.(input))+50
ys = 1:maximum(last.(input))+50

manhattan_dist(a,b) = sum(abs.(a.-b))

function findmin_noties(xs, tie_sentinel=0)
    minx = first(xs)
    mini = 0
    for (i,x) in enumerate(xs)
        mini = x > minx ? mini : x == minx ? tie_sentinel : i
        minx = min(x, minx)
    end
    mini
end

function count_map(xs, n)
    counts = zeros(Int, n)
    for x in xs
        x > 0 && (counts[x] += 1)
    end
    counts
end

function star1(input)
    xs = 1:maximum(first.(input))+50
    ys = 1:maximum(last.(input))+50
    closest = [findmin_noties(manhattan_dist((x,y), i) for i in input) for x in xs, y in ys]
    dq = union(Set(closest[1:end, 1]),
               Set(closest[1:end, end]),
               Set(closest[1, 1:end]),
               Set(closest[end, 1:end]))
    delete!(dq, 0)
    counts[collect(dq)] .= 0
    findmax(counts)
end

function star2(input)
    xs = 1:maximum(first.(input))+50
    ys = 1:maximum(last.(input))+50
    sum(sum(manhattan_dist((x,y), i) for i in input)<10000 for x in xs, y in ys)
end
