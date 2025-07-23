-- color mapping
function color_to_idx(col)
    local idxmap=
         {nil,  7,  6,  5,
          nil,nil,nil,nil,
            2,  4,  0,  1,
            3,nil,nil,nil}

    local idx = idxmap[col+1]
    return idx 
end

function idx_to_color(idx)
    local colmap = {10,11,8,12,9,3,2,1}
    return colmap[idx+1]
end

function idx_to_sprite(idx)
    return idx+32
end

function sprite_to_idx(s)
    local idx = s-32
    if idx < 0 or idx > 7 then
        debug("tried to convert sprite "..s.."\n to brain index "..idx)
    end
    return idx
end

function idx_to_move(idx)
    -- direction and amount
    -- left, right, up, down
    local move_map = {
        {dir=0,a=1},
        {dir=1,a=1},
        {dir=2,a=1},
        {dir=3,a=1},
        {dir=0,a=2},
        {dir=1,a=2},
        {dir=2,a=2},
        {dir=3,a=2}
    }
    return move_map[idx+1]
end
