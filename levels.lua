--scaled_maps
function init_levels()
    default_sprite=39
    target_sprite=24

    level_init_data = {
        -- 8 small
        {pos(0,0), 8}, {pos(16,0), 8}, {pos(32,0), 8}, {pos(48,0), 8},
        {pos(0,8), 8}, {pos(16,8), 8}, {pos(32,8), 8}, {pos(48,8), 8},
        -- 6 medium
        {pos(0,16), 4}, {pos(32,16), 4},
        {pos(0,32), 4}, {pos(32,32), 4},
        {pos(0,48), 4}, {pos(32,48), 4},
        -- 2 large
        {pos(64,0), 2},
        {pos(64,32), 2}
    }
    level_titles = {
        {"move green?","... means move right"},
        {"move green, paint red?",""},
        {"move green, paint red, ...", "... and remember yellow?"},
        {"move blue (down) on blue!", ""},
        {"side step the wall",""},
        {"i am stuck in a loop! save me!", ""},
        {"",""},
        {"",""},
        {"",""},
        {"",""},
        {"",""},
        {"",""},
        {"",""},
        {"the yellow brick road",""},
        {"",""},
        {"",""}
    }

    levels = {}

    for l=1,#level_init_data do add(levels, load_level(level_init_data[l])) end
    level_idx = -1 -- should get reset
    init_level(14)
end

function load_level(init_data)
    local map_pos, scale = unpack(init_data)
    local width, height = 128/scale, 64/scale

    -- RELOAD MAP DATA FROM CART
    local byte = 8
    local map_mem_row_shift = 128
    local map_mem = 0
    local y_offset = 0 
    if map_pos.y < 32 then
        map_mem = 32 * 128 * 2  -- 8192
        y_offset = map_pos.y
    else 
        map_mem = 32 * 128      -- 4096
        y_offset = map_pos.y - 32
    end
    map_mem += map_pos.x + map_mem_row_shift * y_offset 
    for r = 1, height do
        -- debug(map_mem)
        reload(map_mem, map_mem, width)
        map_mem += map_mem_row_shift
    end

    -- PROCESS MAP DATA
    -- default source and target
    local source = pos(2,2)
    local target = pos(width-1,height-1)
    local mem = 0

    for r = 1, height do
        for c = 1, width do
            local sprite_pos = pos(map_pos.x + c - 1, map_pos.y + r - 1)
            local sprite_idx = mget(sprite_pos.x, sprite_pos.y)

            -- where the robot starts
            if 16 <= sprite_idx and sprite_idx <= 23 then 
                source = pos(c,r)
                mset(sprite_pos.x, sprite_pos.y, default_sprite) -- swap to solid color default
                mem = sprite_to_idx(sprite_idx+16)
            end
            -- where the robot wants to get
            if sprite_idx == target_sprite then 
                target = pos(c,r)
            end
            -- override helper sprites with correct value
            if sprite_idx == 0 or sprite_idx == 24 then
                mset(sprite_pos.x, sprite_pos.y, default_sprite)
            end
        end
    end
    return {
        p=map_pos,
        scale=scale, 
        width=width, 
        height=height, 
        source=source, 
        target=target, 
        robot={p=source, mem=mem}
    }
end

function write_to_level(p, val)
    local lvl_pos = get_level_pos(p)
    mset(lvl_pos.x, lvl_pos.y, val)
end

function init_level(idx)
    level_idx = 1 + ((idx-1) % #levels)
    validate_scope()
end

function reload_level()
    levels[level_idx] = load_level(level_init_data[level_idx])
    validate_scope()
end

function validate_scope()
    -- establishes global variables
    level = levels[level_idx]
    robot = level.robot
end

function draw_level()
    -- actual level
    for r = 1, level.height do
        for c = 1, level.width do
            local p = pos(c,r)
            draw_level_sprite(p, get_level_sprite(p))
        end
    end
    -- target 
    draw_level_sprite(level.target, target_sprite)

    -- title
    local title    = level_titles[level_idx][1]
    local subtitle = level_titles[level_idx][2]
    print(title, 2, 2, 0)
    print(title, 1, 1, 7)
    print(subtitle, 2, 58, 0)
    print(subtitle, 1, 57, 7)
end

function draw_level_sprite(p, sprite_idx)
    local scale = level.scale
    spr(
        sprite_idx,
        (p.x-1) * scale, (p.y-1) * scale,
        scale/8, scale/8
    )
end

function get_level_pos(p)
    return pos(level.p.x + p.x - 1, level.p.y + p.y - 1)
end

function get_level_sprite(p)
    local lvl_pos = get_level_pos(p)
    local sprite_idx = mget(lvl_pos.x, lvl_pos.y) 
    return sprite_idx
end 
