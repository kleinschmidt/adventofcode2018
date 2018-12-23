
function star1(n_wait)
    scores = [3, 7]

    elf1 = 1
    elf2 = 2

    while length(scores) < 10 + n_wait
        new_score = scores[elf1] + scores[elf2]
        scores = append!(scores, reverse!(digits(new_score)))

        elf1 = mod(elf1 + scores[elf1], length(scores)) + 1
        elf2 = mod(elf2 + scores[elf2], length(scores)) + 1
    end
    
    print.(scores[ (1:10) .+ n_wait ])
    println()

end



function star2(input::String)
    scores = [3, 7]

    elf1 = 1
    elf2 = 2

    looking_for = parse.(Int, collect(input))
    n_check = length(looking_for)
    done = false

    while !done
        new_score = scores[elf1] + scores[elf2]

        for new_recipe in reverse!(digits(new_score))
            push!(scores, new_recipe)
            # check if last digits have come up
            if length(scores) >= n_check && scores[end-n_check+1:end] == looking_for
                # println("Found $input in $scores")
                return length(scores)-n_check
            end
        end

        elf1 = mod(elf1 + scores[elf1], length(scores)) + 1
        elf2 = mod(elf2 + scores[elf2], length(scores)) + 1

    end
end
