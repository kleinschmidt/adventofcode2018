using Test, BenchmarkTools

input = 9798

xs = 1:300
ys = (1:300)'


rack_id = xs .+ 10 # Find the fuel cell's rack ID, which is its X coordinate plus 10.
# Begin with a power level of the rack ID times the Y coordinate.
# Increase the power level by the value of the grid serial number (your puzzle input).
# Set the power level to itself multiplied by the rack ID.
# Keep only the hundreds digit of the power level (so 12345 becomes 3; numbers with no hundreds digit become 0).
# Subtract 5 from the power level.




function star1(input, sizes=1:300)
    xs = (1:300) .+ 10
    ys = (1:300)'
    
    power = ((((xs .* ys .+ input) .* xs) .÷ 100) .% 10) .- 5

    maxpower = typemin(Int)
    maxxysz = (0,0,0)
    for sz in sizes
        for x in 1:(300-sz+1)
            for y in 1:(300-sz+1)
                pow = sum(power[xx,yy] for xx in x:(x+sz-1), yy in y:(y+sz-1))
                maxpower = max(maxpower, pow)
                maxxysz = maxpower == pow ? (x,y,sz) : maxxysz
            end
        end
    end
    return maxxysz, maxpower
end

star1(18, 3)

@test star1(18) == ((33,45), 29)
@test star1(42) == ((21,61), 30)

xy, maxp = star1(input)
