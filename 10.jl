# list of point position + velocity.  need to figure out what they
# "spell"...maybe can use min distance from origin as a heuristic here?  it
# seems like all the inputs are large but have opposite signs from their
# velocies (on a scale of like 10_000x or something).
#
# or just find the relative position/velocity of each pair of point and use that
# to get the overall (sum) pariwise distance as a function of time then find the
# minimum...
#
# (a_0 - b_0) + (a_v - b_v)*t = Δ_0^2 + 2 Δ_0 Δ_v t + Δ_v^2 t^2


function parseline(line)
    regex = r"position=< *(-?\d*), *(-?\d*)> velocity=< *(-?\d*), *(-?\d*)>"
    x, y, vx, vy = parse.(Int, match(regex, line).captures)
    (x,y), (vx, vy)
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


