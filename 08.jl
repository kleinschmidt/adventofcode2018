# string of ints, describe a tree structure.
# header: number of children, number of "metadata" entries
# children: (length unknown)
# metadata:

struct Tree{M}
    children::Vector{Tree}
    metadata::M
end

function extract_tree(content)
    nchil, nmeta, content = content[1], content[2], @view(content[3:end])

    children = Tree[]
    for _ = 1:nchil
        child, content = extract_tree(content)
        push!(children, child)
    end

    metadata, content = @view(content[1:nmeta]), @view(content[nmeta+1:end])

    Tree(children, metadata), content
end


star1(tree::Tree) = sum(tree.metadata) + mapreduce(star1, +, tree.children, init=0)

# I thougth this might be faster but I was way wrong
star11(tree::Tree) = sum(tree.metadata) +
    (isempty(tree.children) ? 0 : sum(star11(c) for c in tree.children))


test_input = parse.(Int, split("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"))
test_tree, _ = extract_tree(test_input)
star1(test_tree) == 138

input = parse.(Int, split(read("08.input", String)))

tree, _ = extract_tree(input);

star1(tree)

star2(tree::Tree, child::Int) =
    child ∈ 1:length(tree.children) ? star2(tree.children[child]) : 0
star2(tree::Tree) =
    if length(tree.children) > 0
        mapreduce(i->star2(tree, i), +, tree.metadata, init=0)
    else
        sum(tree.metadata)
    end

star2(test_tree) == 66
star2(tree)


################################################################################
# some optimizations??

using BenchmarkTools

# variant that pulls metadata out into its own vector
function extract_tree_noview(content)
    nchil, nmeta, content = content[1], content[2], @view(content[3:end])

    children = Tree[]
    for _ = 1:nchil
        child, content = extract_tree(content)
        push!(children, child)
    end

    metadata, content = content[1:nmeta], @view(content[nmeta+1:end])

    Tree(children, metadata), content
end

tree_noview, _ = extract_tree_noview(input);

# really does not seem to make any difference.  I'd have expect some difference
# in the allocations but I guess if the vectors are all small allocating the
# view isn't saving you anything over allocating the vector directly
# 
# julia> @btime extract_tree($input)
#   99.348 μs (10210 allocations: 479.88 KiB)
# julia> @btime extract_tree_noview($input);
#   99.560 μs (10210 allocations: 480.00 KiB)

# julia> @btime star1($tree)
#   410.655 μs (6380 allocations: 147.94 KiB)
# 36891

# julia> @btime star1($tree_noview)
#   411.760 μs (6380 allocations: 147.94 KiB)
# 36891

# julia> @btime star2($tree)
#   95.911 μs (1291 allocations: 27.67 KiB)
# 20083

# julia> @btime star2($tree_noview)
#   95.952 μs (1287 allocations: 27.58 KiB)
# 20083


function extract_tree_noview_plus(content)
    nchil, nmeta, content = content[1], content[2], content[3:end]

    children = Tree[]
    for _ = 1:nchil
        child, content = extract_tree(content)
        push!(children, child)
    end

    metadata, content = content[1:nmeta], content[nmeta+1:end]

    Tree(children, metadata), content
end

@btime extract_tree_noview_plus($input);

# take a SMALL hit for duplicating the content every time but still, not nearly
# as I would have thought.
# 
# julia> @btime extract_tree_noview_plus($input);
#   112.935 μs (10211 allocations: 591.88 KiB)
