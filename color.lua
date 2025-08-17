
function init_colors()
    color_to_idx_map=
     {nil,  7,  6,  5,
      nil,nil,nil,nil,
        2,  4,  0,  1,
        3,nil,nil,nil}
    idx_to_color_map = {10,11,8,12,9,3,2,1}
end

function color_to_idx(col)
    return color_to_idx_map[col+1]
end

function is_color_sprite(sprite_idx)
    return sprite_idx >= 1 and sprite_idx <= 8
end

function idx_to_color(idx)
    return idx_to_color_map[idx+1]
end

function idx_to_sprite(idx)
    return idx+1
end

function sprite_to_idx(sprite_idx)
    if not is_color_sprite(sprite_idx) then
        debug("tried to convert non-color sprite "..sprite_idx)
    end
    return sprite_idx-1
end

function idx_to_move(idx)
    -- direction and amount
    -- left, right, up, down
    local move_map = {
        {dir=0,a=1}, -- yellow / left
        {dir=1,a=1}, -- green / right
        {dir=2,a=1}, -- red / up
        {dir=3,a=1}, -- blue / down
        {dir=0,a=2},
        {dir=1,a=2},
        {dir=2,a=2},
        {dir=3,a=2}
    }
    return move_map[idx+1]
end
