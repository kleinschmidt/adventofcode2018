# list of point position + velocity.  need to figure out what they
# "spell"...maybe can use min distance from origin as a heuristic here?  it
# seems like all the inputs are large but have opposite signs from their
# velocies (on a scale of like 10_000x or something).  or sum of pairwise
# distances?
#
# or just find the relative position/velocity of each pair of point and use that
# to get the overall (sum) pariwise distance as a function of time then find the
# minimum...
#
# ((a_0 - b_0) + (a_v - b_v)*t)^2 = Δ_0^2 + 2 Δ_0 Δ_v t + Δ_v^2 t^2
# derivative of that is 2Δ_0Δ_v + 2Δ_v^2 t => max/min at t = Δ0 / Δv
#
# that's just for one.  the quadratic coefficients sum but need to do the sum
# first though...

mutable struct Star
    x::Tuple{Int,Int}
    v::Tuple{Int,Int}
end

function parseline(line)
    regex = r"position=< *(-?\d*), *(-?\d*)> velocity=< *(-?\d*), *(-?\d*)>"
    x, y, vx, vy = parse.(Int, match(regex, line).captures)
    Star((x,y), (vx, vy))
end

test_input = parseline.(split(strip(
    """position=< 9,  1> velocity=< 0,  2>
position=< 7,  0> velocity=<-1,  0>
position=< 3, -2> velocity=<-1,  1>
position=< 6, 10> velocity=<-2, -1>
position=< 2, -4> velocity=< 2,  2>
position=<-6, 10> velocity=< 2, -2>
position=< 1,  8> velocity=< 1, -1>
position=< 1,  7> velocity=< 1,  0>
position=<-3, 11> velocity=< 1, -2>
position=< 7,  6> velocity=<-1, -1>
position=<-2,  3> velocity=< 1,  0>
position=<-4,  3> velocity=< 2,  0>
position=<10, -3> velocity=<-1,  1>
position=< 5, 11> velocity=< 1, -2>
position=< 4,  7> velocity=< 0, -1>
position=< 8, -2> velocity=< 0,  1>
position=<15,  0> velocity=<-2,  0>
position=< 1,  6> velocity=< 1,  0>
position=< 8,  9> velocity=< 0, -1>
position=< 3,  3> velocity=<-1,  1>
position=< 0,  5> velocity=< 0, -1>
position=<-2,  2> velocity=< 2,  0>
position=< 5, -2> velocity=< 1,  2>
position=< 1,  4> velocity=< 2,  1>
position=<-2,  7> velocity=< 2, -2>
position=< 3,  6> velocity=<-1, -1>
position=< 5,  0> velocity=< 1,  0>
position=<-6,  0> velocity=< 2,  0>
position=< 5,  9> velocity=< 1, -2>
position=<14,  7> velocity=<-2,  0>
position=<-3,  6> velocity=< 2, -1>
"""), '\n'))


input = parseline.(readlines("10.input"))

move(star::Star, t::Int) = Star(star.x .+ t .* star.v, star.v)

# compute the coefficients of the quadratic expression of squared distance for a pair
coefs(a::Star, b::Star) = (sum((a.x .- b.x).^2),
                           sum(2 .* (a.x .- b.x) .* (a.v .- b.v)),
                           sum((a.v .- b.v).^2)

function tmin(input)
    a,b,c = reduce((x,y)->x.+y, coefs(a,b) for a in input for b in input)
    tmin = round(Int, -b / (2c))
end

function draw(stars::Vector{Star})
    mins, maxs = foldl(((minx,maxx),x) -> (min.(minx,x), max.(maxx,x)),
                       s.x for s in stars,
                       init=(typemax(Int), typemin(Int)))
    img = fill(' ', maxs .- mins .+ 1)
    for s in stars
        img[(s.x .- mins .+ 1)...] = '█'
    end
    cols, rows = axes(img)
    println()
    for r in rows
        for c in cols
            print(img[c,r])
        end
        println()
    end
    img
end

star1(input) = draw(move.(input, tmin(input)))

star1(test_input);

star1(input);

# star 2:
tmin(input)
