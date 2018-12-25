# 16 opcodes.  don't know which one is which.  instructions are of the form
# op A B C
#
# they all write their output to register C.
#
# differ based on
# * operation they perform (add, mul, and, or, assign, greater than, equals)
# * source of input1 (register vs. identity)
# * source of input2 (register vs. identity)

struct Op
    f::Function
    areg::Bool                  # register A or value A
    breg::Bool                  # register B or value B
end

ops = (addr = Op(+, true, true),
       addi = Op(+, true, false),
       mulr = Op(*, true, true),
       muli = Op(*, true, false),
       banr = Op(&, true, true),
       bani = Op(&, true, false),
       borr = Op(|, true, true),
       bori = Op(|, true, false),
       setr = Op((a,b) -> a, true, false),
       seti = Op((a,b) -> a, false, false),
       eqir = Op(isequal, false, true),
       eqri = Op(isequal, true, false),
       eqrr = Op(isequal, true, true),
       gtir = Op((a,b) -> a>b, false, true),
       gtri = Op((a,b) -> a>b, true, false),
       gtrr = Op((a,b) -> a>b, true, true))



function call_op(o::Op, registers, instruction)
    opcode, a, b, c = instruction
    a = o.areg ? registers[a+1] : a
    b = o.breg ? registers[b+1] : b
    return o.f(a,b)
end


function check(o::Op, before, instruction, after)
    c = last(instruction)
    call_op(o, before, instruction) == after[c+1]
end

function count_ops(before, instruction, after)
    matches = 0
    for (name,op) in pairs(ops)
        if check(op, before, instruction, after)
            matches += 1
            println("$name matches")
        end
    end
    return matches
end


input1, input2 = split(read("16.input", String), "\n\n\n");

tupleify(v::Vector) = tuple(v...)
parse_line(s) = tupleify(parse.(Int, match(r"(\d+).*(\d+).*(\d+).*(\d+)", s).captures))



function star1(input1)

    three_ops = 0

    for input in split(input1, "\n\n")
        before, instruction, after = parse_line.(split(input, "\n"))
        if count_ops(before, instruction, after) >= 3
            three_ops += 1
        end
    end

    return three_ops
end

star1(input1)


function op_matches(before, instruction, after)
    matches = Set{Op}()
    for op in ops
        if check(op, before, instruction, after)
            push!(matches, op)
        end
    end
    return matches
end


function star2(input1, input2)
    op_candidates = Dict{Int,Set{Op}}()

    for input in split(input1, "\n\n")
        before, instruction, after = parse_line.(split(input, "\n"))
        matches = op_matches(before, instruction, after)
        intersect!(get!(op_candidates, instruction[1], matches), matches)
    end

    # this isn't enough to uniquely identify.

    opcodes = missings(Op, 16)
    while any(ismissing, opcodes)
        code = findfirst(c->length(c)==1, op_candidates)
        op = first(op_candidates[code])
        opcodes[code+1] = op
        delete!(op_candidates, code)
        for cands in values(op_candidates)
            delete!(cands, op)
        end
    end

    opnames = findfirst.(isequal.(opcodes), Ref(ops))

    registers = [0, 0, 0, 0]
    for line in split(strip(input2), "\n")
        println("Before: $registers")
        inst = parse.(Int, split(line))
        println("$inst ($(opnames[inst[1]+1]))")
        registers[inst[4]+1] = call_op(opcodes[inst[1]+1], registers, inst)
        println("After: $registers\n")
    end

    return op_candidates
end

op_cands = star2(input1, input2)
