# game of life kinda thing: 5-tile rules.


function parseinput(f)
    initial_input = match(r"[#.]+", readline(f)).match
    readline(f)
    (collect(initial_input),
     Dict(collect(l[1]) => l[2][1]
          for l
          in split.(strip.(readlines(f)), Ref(" => "))))
end    

test_start, test_rules = parseinput(IOBuffer("""
initial state: #..#.#..##......###...###

...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #
"""))

start, rules = open(parseinput, "12.input")


function pad!(state, starti; n=3)
    # need at least 3 '.' on the front and  on the end
    front_pad = max(0, n + 1 - findfirst(isequal('#'), state))
    starti -= front_pad
    for _ in 1:front_pad
        pushfirst!(state, '.')
    end
    back_pad = n-(length(state)-findlast(isequal('#'), state))
    for _ in 1:back_pad
        push!(state, '.')
    end
    state, starti
end

function generation!(next_state, state, rules)
    for i in 3:(lastindex(state)-2)
        next_state[i] = get(rules, view(state, i-2:i+2), '.')
    end
    next_state
end


function grow(start, rules; n=20)
    state, starti = pad!(copy(start), 0, n=n+3)
    next_state = fill!(similar(state), '.')
    println(String(state))
    for gen in 1:n
        state, next_state = generation!(next_state, state, rules), fill!(state, '.')
        println(String(state))
    end
    state, starti
end

star1(state, starti) = sum(findall(isequal('#'), state) .- 1 .+ starti)

star1(grow(test_start, test_rules; n=20)...)
star1(grow(start, rules; n=20)...)


# star 2: 50 billion generations!! there's gotta be some kind of shortcut...  if
# you look at the patterns visually it's clear that at some point (around
# generation 101) the game reaches a repeating state that's a bunch of "##..."
# repeated some number of time, and the whole thing moves to the right 1 square
# each time.  so need to just figure out the score for one generation and the
# number of live cells...


state100, starti100 = grow(start, rules; n=100)
score = star1(state100, starti100)
nlive = sum(isequal('#'), state100)

# score will increase by $nlive every generation...so score(t) = score(100) + (t-100)*nlive
score + (50_000_000_000-100)*nlive
