# insert "marbles" in a "circle"

function star1(players, marbles)
    circle = [0]
    scores = zeros(Int, players)
    pos = 1
    for i in 1:marbles
        if i % 23 == 0
            # score marble i, and remove+score marble 7 marbles CCW from positive
            pos = mod(pos - 7 - 1, length(circle)) + 1
            scores[(i-1) % players + 1] += i + circle[pos]
            deleteat!(circle, pos)
        else
            # insert after marble that's ONE clockwise from current pos:
            pos = pos % length(circle) + 1 + 1
            insert!(circle, pos, i)
        end
    end
    maximum(scores)
end

using Test

@test star1(9, 25) == 32
@test star1(10, 1618) == 8317
@test star1(13, 7999) == 146373

input = (462, 71938)
@btime star1(input...)

input10 = (462, 719380)
@time star1(input10...)

input100 = (462, 7193800)
@time star1(input100...)
