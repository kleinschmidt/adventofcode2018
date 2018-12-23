# carts moving on tracks.  move until they hit a crossroad, then their behavior
# depends on some state (turn left, then straight, then right, then repeat)

test_input = """
/->-\\        
|   |  /----\\
| /-+--+-\\  |
| | |  | v  |
\\-+-/  \\-+--/
  \\------/   
"""


mutable struct Cart
    pos::CartesianIndex{2}
    vel::CartesianIndex{2}
    turn::Int
end

Base.isless(a::Cart, b::Cart) = isless(a.pos, b.pos)

mutable struct Board
    map::Matrix{Char}
    tmp::Matrix{Char}
    carts::Vector{Cart}
    crashes::BitVector
end

Board(map::String) = Board(reduce(hcat, collect.(split(strip(map, '\n'), '\n'))))
function Board(map::Matrix{Char})
    board = Board(map, similar(map), Cart[], falses(0))
    for (char, dir, rep) in (('>', (1,0), '-'), ('<', (-1,0), '-'),
                             ('^', (0,-1), '|'), ('v', (0,1), '|'))
        for i in findall(isequal(char), board.map)
            push!(board.carts, Cart(i, CartesianIndex(dir), 0))
            board.map[i] = rep
        end
    end
    sort!(board.carts)
    return board
end


board = Board(read("13.input", String))

# right (CW) turn: up -> right, right -> down, down -> left, left -> up
# (0,-1) -> (1,0)
# (1,0)  -> (0,1)
# (0,1)  -> (-1,0)
# (-1,0) -> (0,-1)

# x1 = -1 * y0
# y1 = x0
right(x::CartesianIndex{2}) = CartesianIndex(-1*x.I[2], x.I[1])
left(x::CartesianIndex{2}) = CartesianIndex(x.I[2], -1*x.I[1])


function turn!(cart::Cart, location::Char)
    if location == '+'
        # turn depends on state
        cart.vel =
            cart.turn == 0 ? left(cart.vel) :
            cart.turn == 2 ? right(cart.vel) :
            cart.vel
        cart.turn = (cart.turn + 1) % 3
    elseif location == '/'
        cart.vel = -1 * CartesianIndex(reverse(cart.vel.I))
    elseif location == '\\'
        cart.vel = CartesianIndex(reverse(cart.vel.I))
    end
    cart
end

function move!(board::Board)
    resize!(board.crashes, length(board.carts))
    fill!(board.crashes, false)

    for (i,cart) in enumerate(board.carts)
        turn!(cart, board.map[cart.pos])
        cart.pos += cart.vel
        # check for collisions
        for (other_i, other_cart) in enumerate(board.carts)
            board.crashes[other_i] && continue
            if i != other_i && cart.pos == other_cart.pos
                board.crashes[i] = board.crashes[other_i] = true
                println("Collision at $(cart.pos.I .- 1)")
                @show board.crashes
            end
        end
    end

    deleteat!(board.carts, board.crashes)
    sort!(board.carts)
    return board
end


function Base.show(io::IO, board::Board)
    copyto!(board.tmp, board.map)
    for cart in board.carts
        board.tmp[cart.pos] =
            cart.vel.I == (1,0) ? '>' :
            cart.vel.I == (-1,0) ? '<' :
            cart.vel.I == (0,1) ? 'v' :
            '^'
    end
    xs, ys = axes(board.tmp)
    for y in ys
        println(String(board.tmp[:, y]))
    end
end

function star1(input)
    board = Board(input)
    n_carts = length(board.carts)
    while length(board.carts) == n_carts
        move!(board)
    end
end


star1(test_input)
star1(read("13.input", String))

    
test_input_2 = """
/>-<\\  
|   |  
| /<+-\\
| | | v
\\>+</ |
  |   ^
  \\<->/
"""

function star2(input)
    board = Board(input)
    while length(board.carts) > 1
        move!(board)
    end
    return first(board.carts).pos.I .- 1
end

star2(test_input_2)
star2(read("13.input", String))
