using SparseArrays

# iterate through units in "reading order":
#   if enemy adjacent, attack, else move
# move:
#   find (reachable) squares in range of enemy
#   find closest by path length (break ties by reading order)
#   take first step
#
# _COULD_ optimize this a bit: do like a BFS/Dijkstra's from the start,
# terminate when you find an enemy...but then how to handle the actual
# pathfinding part?  I guess if you build the minimum distance _tree_ at the
# same time...

# keep track of
# * map (empty squares)
# * list of units
# * array of units (inverse index location -> unit)

mutable struct Board
    openmap::BitArray{2}
    units::SparseMatrixCSC{Int,Int}
    turns::Int
    attacks::Tuple{Int,Int}
end

function Base.show(io::IO, board::Board)
    xs, ys = axes(board.openmap)
    for y in ys
        hps = []
        for x in xs
            unit = board.units[x,y]
            if unit == 0
                print(io, board.openmap[x,y] ? '.' : '#')
            else
                ch = unit > 0 ? 'E' : 'G'
                print(io, ch)
                push!(hps, "$ch ($(abs(unit)))")
            end
        end
        print(io, "   ")
        println(io, join(hps, " "))
    end
end

test_input = """
#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######
"""

parseinput(input) = reduce(hcat, collect.(split(strip(input, '\n'))))

Board(input::String, args...) = Board(parseinput(input), args...)
function Board(input::Matrix{Char}, attacks=(3,-3))
    openmap = input .!= '#'

    elves = sparse(200 .* (input .== 'E'))
    goblins = sparse(200 .* (input .== 'G'))
    units = elves .- goblins
    Board(openmap, units, 0, attacks)
end

neighbors(x) = (x + d for d in CartesianIndex.(((0,-1), (-1,0), (1,0), (0,1))))

# keep track of a frontier (nodes that are waiting to be visited).  in a queue
# but ... don't need to sort because the distances are the same... so you work
# through all the distance = 1 first, and each of those pushes a d=2, then you
# hit those and they each push a d=3.
#
# but...what do we need to keep track of in order to choose the MOVE??  keep
# track of the ancestor for each visited location

function next_step(start, board::Board)

    openmap = board.openmap
    units = board.units

    goodness = sign(units[start])

    queue = CartesianIndex{2}[start]
    ancestors = zeros(CartesianIndex{2}, size(openmap))

    done = false
    while !isempty(queue)
        current = popfirst!(queue)
        # println("current: $(current.I)")
        # current tile is not done.  check each neighbor for valid
        for neighbor in neighbors(current)
            if sign(units[neighbor]) * goodness == -1
                # we're on a neighboring tile to opposite badness, so done.
                # println("enemy found at $(neighbor.I) (from $(current.I))")
                # walk back to position where current is ancestor:
                # print("  walking back: $(current.I)")
                while ancestors[current] != start && !iszero(ancestors[current])
                    current = ancestors[current]
                    # print(" -> $(current.I)")
                end
                # println()
                return current
            elseif openmap[neighbor] && units[neighbor] == 0 && iszero(ancestors[neighbor])
                # println("  neighbor $(neighbor.I): added to queue")
                # neighbor is valid and unvisited. record ancestor and add to queue
                ancestors[neighbor] = current
                push!(queue, neighbor)
            else
                # println("invalid!")
            end
        end
    end
    # no reachable enemy found so don't move, return start location as "next step"
    return start
end


function turn!(board, unit)
    units = board.units
    next = next_step(unit, board)
    if iszero(board.units[next])
        # println("moving: $(unit.I) -> $(next.I)")
        # move
        units[unit], units[next], unit = units[next], units[unit], next
    end

    enemies = [(abs(units[n]), n)
               for n
               in neighbors(unit)
               if sign(units[n]*units[unit])==-1]
    if !isempty(enemies)
        hp, location = minimum(enemies)
        attack = units[unit] > 0 ? board.attacks[1] : board.attacks[2]
        if hp <= abs(attack)
            units[location] = 0 # dead
        else
            units[location] += attack
        end
    end
end

done(board::Board) = all(u>=0 for u in board.units) || all(u<=0 for u in board.units)

function turn!(board::Board)
    for unit in findall(!iszero, board.units)
        done(board) && return
        # println("unit at $(unit.I)")
        turn!(board, unit)
        # println(board)
    end
    board.turns += 1
    return board
end

board = Board(test_input)

for _ in 1:23
    turn!(board)
end

for _ in 24:47
    turn!(board)
end


test_input2 = """
#######
#G..#E#
#E#E.E#
#G.##.#
#...#E#
#...E.#
#######
"""

score(board::Board) = board.turns * abs(sum(board.units))

function star1(input)
    board = Board(input)
    while turn!(board) !== nothing
    end
    return score(board), board
end


star1(test_input)
star1(test_input2)

"""
#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########
""" |> star1

"""
#######
#.E...#
#.#..G#
#.###.#
#E#G#G#
#...#G#
#######
""" |> star1


read("15.input", String) |> star1


################################################################################
# star 2: boost attack power of elves until no elves die
n_elves(board::Board) = sum(u > 0 for u in board.units)

function star2(input)
    for attack = 4:100
        board = Board(input, (attack, -3))
        n0 = n_elves(board)
        while n_elves(board)==n0 && turn!(board) !== nothing end
        println("attack $attack, score $score, board\n$board)")
        if n_elves(board) == n0
            return board.turns * abs(sum(board.units)), board
        end
    end
end

"""
#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######
""" |> star2

"""
#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######
""" |> star2

"""
#######
#E.G#.#
#.#G..#
#G.#.G#
#G..#.#
#...E.#
#######
""" |> star2

"""
#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########
""" |> star2

read("15.input", String) |> star2
