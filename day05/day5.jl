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

function get_lines()
    lines = readlines("input.txt")
    lines
end

function get_mapping(s, maps, from, to) 

    mappings = maps[from * "-" * to]
    next_dest = DEST_MAPS[to]
    for (key, value) in mappings
        end_range = key + value[2]
        if s >= key && s < end_range
            if to == "location"
                return value[1] + (s - key)
            else
                return get_mapping(value[1] + (s - key), maps, to, next_dest)
            end
            
        end
    end
    if to == "location"
        return s
    else 
        return get_mapping(s, maps, to, next_dest)
    end
end

function get_mapping_for_range(ranges_to_check, maps, from, to) 
    
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
            middle_start = max(s1, s0) #+ (s1 - s0)
            middle_end = min(e0, e1) # (s1 - s0)

            if middle_end > middle_start
                matched = true
                # right side
                right_start = max(middle_end, s1) 
                right_end = e1 
                # left side
                left_start = s1 
                left_end = min(e1, s0) 
                # shift values
                diff_mapping = value[1] - key
                #@show range, from, to
                #@show s1, e1, s0, e0, diff_mapping, key, value
                middle_start += diff_mapping
                middle_end += diff_mapping

                push!(new_seeds, (middle_start, middle_end - middle_start))
                #@show left_end, left_start, e1, s0
                if (left_end > left_start)
                    push!(ranges_to_check, (left_start, left_end - left_start + 1))
                    #@show new_seeds
                end

                if right_end > right_start
                    push!(ranges_to_check, (right_start, right_end - right_start + 1))
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

function build_maps()
    lines = get_lines()
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

function build_seed_tuples(seeds)
    seed_tuples = Array{Tuple{Int64,Int64},1}()
    for i in (1:2:length(seeds))
        push!(seed_tuples, (seeds[i], seeds[i+1]))
    end
    return seed_tuples
end

maps, seeds = build_maps()
seed_tuples = build_seed_tuples(seeds)


locations = []
for seed in seeds
    mapping = get_mapping(seed, maps, "seed", "soil")
    push!(locations, mapping)
end

@show findmin(locations)

ranges = []
for seed_tuple in seed_tuples
    val = get_mapping_for_range([seed_tuple], maps, "seed", "soil")
    for range in val
        push!(ranges, range)    
    end
end
@show ranges
range_starts =[x[1] for x in ranges] 
@show findmin(range_starts)