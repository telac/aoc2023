# done and start are added as padding 
# so there's no need to check for keys
DEST_MAPS = Dict{String, String}(
    "start" => "seed",
    "seed" => "soil",
    "soil" => "fertilizer",
    "fertilizer" => "water",
    "water" => "light",
    "light" => "temperature",
    "temperature" => "humidity",
    "humidity" => "location",
    "location" => "done"
) 

REVERSE_MAPS = Dict(value => key for (key, value) in DEST_MAPS)

function getLines()
    lines = readlines("input.txt")
    lines
end

function getMapping(s, maps, from, to) 

    mappings = maps[from * "-" * to]
    next_dest = DEST_MAPS[to]
    for (key, value) in mappings
        end_range = key + value[2]
        if s >= key && s < end_range
            if to == "location"
                return value[1] + (s - key)
            else
                return getMapping(value[1] + (s - key), maps, to, next_dest)
            end
            
        end
    end
    if to == "location"
        return s
    else 
        return getMapping(s, maps, to, next_dest)
    end
end

function getMappingForRange(ranges_to_check, maps, from, to) 
    
    while (!isempty(ranges_to_check))
        next_dest = DEST_MAPS[to]
        #@show ranges_to_check, from, to, next_dest
        mappings = maps[from * "-" * to]
        range = pop!(ranges_to_check)
        s1 = range[1]
        e1 = s1 + range[2]
        new_seeds = []
        matched = false
        for (key, value) in mappings
            s0 = key
            e0 = key + value[2]
            # inside
            middleStart = max(s1, s0) #+ (s1 - s0)
            middleEnd = min(e0, e1) # (s1 - s0)

            if middleEnd > middleStart
                matched = true
                # right side
                rightStart = max(middleEnd, s1) 
                rightEnd = e1 
                # left side
                leftStart = s1 
                leftEnd = min(e1, s0) 
                # shift values
                diff_mapping = value[1] - key
                #@show range, from, to
                #@show s1, e1, s0, e0, diff_mapping, key, value
                middleStart += diff_mapping
                middleEnd += diff_mapping

                push!(new_seeds, (middleStart, middleEnd - middleStart))
                #@show leftEnd, leftStart, e1, s0
                if (leftEnd > leftStart)
                    push!(ranges_to_check, (leftStart, leftEnd - leftStart + 1))
                    #@show new_seeds
                end

                if rightEnd > rightStart
                    push!(ranges_to_check, (rightStart, rightEnd - rightStart + 1))
                end

            end
        end
        if matched == false
            push!(new_seeds, range)
        end
        if to == "location"
            #push!(ranges_to_check, range)
            
            for new_seed in new_seeds
                push!(ranges_to_check, new_seed)
            end
            return ranges_to_check
        end
        from, to = to, next_dest
        ranges_to_check = new_seeds

    end 
end

function buildMaps()
    lines = getLines()
    maps = Dict{String, Dict{Int64, Tuple{Int64,Int64}}}()
    #reverseMaps = Dict{String, Dict{Int64, Tuple{Int64,Int64}}}()
    seeds = [parse(Int, ss) for ss in split(split(lines[1], ":")[2], " ") if ss != ""] 
    to = ""
    from = ""
    composite = ""
    #reverseComposite = ""
    for line in lines[1:end]
        if occursin("-to-", line)
            splitLine = split(line, "-to-")
            from = splitLine[1]
            to = split(splitLine[2], " ")[1]
            composite = from * "-" * to
            reverseComposite = to * "-" * from
        end
        values = split(line, " ")
        if length(values) == 3
            src = parse(Int, values[2])
            dst = parse(Int, values[1])
            range = parse(Int, values[3])
            if !haskey(maps, composite)
                maps[composite] = Dict{Int64, Tuple{Int64,Int64}}()
                maps[composite][src] = (dst, range)

                #reverseMaps[reverseComposite] = Dict{Int64, Tuple{Int64,Int64}}()
                #reverseMaps[reverseComposite][dst] = (src, range)
            else
                maps[composite][src] = (dst, range)

                #reverseMaps[reverseComposite][dst] = (src, range)
            end
        end
    end
    (maps, seeds)
end

function buildSeedTuples(seeds)
    seedTuples = Array{Tuple{Int64,Int64},1}()
    for i in (1:2:length(seeds))
        push!(seedTuples, (seeds[i], seeds[i+1]))
    end
    return seedTuples
end

maps, seeds = buildMaps()
seedTuples = buildSeedTuples(seeds)


locations = []
for seed in seeds
    mapping = getMapping(seed, maps, "seed", "soil")
    push!(locations, mapping)
end

@show findmin(locations)

ranges = []
for seedTuple in seedTuples
    val = getMappingForRange([seedTuple], maps, "seed", "soil")
    for range in val
        push!(ranges, range)    
    end
end
range_starts =[x[1] for x in ranges] 
@show findmin(range_starts)