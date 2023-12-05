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
    lines = readlines("test_case.txt")
    lines
end

function getMapping(s, maps, from, to) 

    mappings = maps[from * "-" * to]
    nextDest = DEST_MAPS[to]
    for (key, value) in mappings
        end_range = key + value[2]
        if s >= key && s < end_range
            if to == "location"
                return value[1] + (s - key)
            else
                return getMapping(value[1] + (s - key), maps, to, nextDest)
            end
            
        end
    end
    if to == "location"
        return s
    else 
        return getMapping(s, maps, to, nextDest)
    end
end

function getMappingForRange(rangesToCheck, maps, from, to) 

    mappings = maps[from * "-" * to]
    nextDest = DEST_MAPS[to]
    for range in rangesToCheck
        rangeStart = rangesToCheck[0]
        rangeEnd = rangeStart + rangesToCheck[1]
        for (key, value) in mappings
            newRanges = []
            beforeDestRange = key - rangeStart
            destEndRange = key + value[2]
            insideRange = 
        end
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
        @show i
        push!(seedTuples, (seeds[i], seeds[i+1]))
    end
    return seedTuples
end

maps, seeds = buildMaps()
seedTuples = buildSeedTuples(seeds)

@show seedTuples

locations = []
for seed in seeds
    mapping = getMapping(seed, maps, "seed", "soil")
    push!(locations, mapping)
    @show seed, mapping
end

@show findmin(locations)

