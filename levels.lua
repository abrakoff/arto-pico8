--scaled_maps
function init_levels()
    default_sprite=8
    target_sprite=0
    wall_sprites={42,43,58}

    -- special_tile_phaser = get_phaser(3,16)
    level_init_data = {
        -- map_pos, scale, source, target, mem
        -- 16 small
        {pos(0,0),   8, pos(3,4), pos(14,4), 7}, 
        {pos(16,0),  8, pos(3,4), pos(14,4), 7}, 
        {pos(32,0),  8, pos(3,4), pos(14,4), 7}, 
        {pos(48,0),  8, pos(3,4), pos(14,6), 7},

        {pos(0,8),   8, pos(3,4), pos(14,4), 1},
        {pos(16,8),  8, pos(3,3), pos(14,5), 1},
        {pos(32,8),  8, pos(3,6), pos(14,6), 2},
        {pos(48,8),  8, pos(3,4), pos(15,5), 1},

        {pos(0,16),  8, pos(3,4), pos(14,4), 1},
        {pos(16,16), 8, pos(2,7), pos(15,7), 2},
        {pos(32,16), 8, pos(3,6), pos(13,6), 1},
        {pos(48,16), 8, pos(5,4), pos(12,4), 0},

        {pos(0,24),  8, pos(13,7), pos(5,5), 2},
        {pos(16,24), 8, pos(5,5),  pos(12,5), 2},
        {pos(32,24), 8, pos(4,6),  pos(14,3), 3},
        {pos(48,24), 8, pos(4,4),  pos(13,4), 3},
        -- 4 medium
        {pos(64,0),  4, pos(2,14), pos(31,14), 2},
        {pos(96,0),  4, pos(4,6),  pos(16,11), 3},
        {pos(64,16), 4, pos(13,9), pos(19,9), 2}, 
        {pos(96,16), 4, pos(4,10), pos(25,6), 0},
        -- 1 large
        {pos(0,32), 2, pos(31,16), nil, 2},
        {pos(64,32), 2, pos(31,16), nil, 2}
    }
    level_titles = {
        -- small
        {"move green?","... means move right"},
        {"move green, paint red?",""},
        {"move green, paint red, ...", "... and feel blue?"},
        {"move blue (down) on yellow!", ""},

        {"side step the wall",""},
        {"i am stuck in a loop!", "save me!"},
        {"rainbow road",""},
        {"the floor is lava","... or maybe orange paint?"},

        {"side step the wall?","...with feelings"},
        {"i love red!","paint all red"},
        {"i hate red!","paint the fence green"},
        {"moustache city",""},

        {"par 9","avoid water and sand"},
        {"look both ways",""},
        {"icarus",""},
        {"segmented snake",""},
        -- medium
        {"the maze",""},
        {"paint your feelings","feel your paintings"},
        {"the real maze",""},
        {"the yellow brick road",""},
        -- large
        {"",""},
        {"",""}
    }

    levels = {}

    for l=1,#level_init_data do add(levels, load_level(level_init_data[l])) end

    level_idx = 22 -- the torus sandbox
    validate_scope()
end

function load_level(init_data)
    local map_pos, scale, source, target, mem = unpack(init_data)
    local width, height = 128/scale, 64/scale

    local scale_idx = -1
    if scale == 8 then 
        scale_idx = 1
    elseif scale == 4 then
        scale_idx = 2
    else -- scale == 2 
        scale_idx = 3
    end

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

    return {
        p=map_pos,
        scale=scale,          -- in {8,4,1}
        scale_idx=scale_idx,  -- in {1,2,3}
        width=width, 
        height=height, 
        source=source, 
        target=target, 
        completed=false,
        robot={
            p = copy_pos(source),                                   -- logical position
            mem = mem,                                              -- memory/mood
            display_positions = {copy_pos(source),copy_pos(source)} -- display positions (for torus levels need more than one)
        }
    } 
end

function change_level(idx)
    level_idx = 1 + ((idx-1) % #levels)
    dset(0, level_idx)
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

-- function draw_special_border(p, col, a)
--     local phase = special_tile_phaser.phase
--     local scale = level.scale
--     local l_x, l_y = (p.x-1) * scale, (p.y-1) * scale
--     local tile_box = box(l_x, l_y, l_x + scale - 1, l_y + scale - 1)
--     if phase == 0 then tile_box = feather(tile_box, a) end
--     if phase == 2 then tile_box = feather(tile_box, -a) end
--     draw_box(tile_box, col)
-- end

function update_level()
    if step_counter > 0 then
        phase_phaser(standing_robot_phaser)
        update_robot_logic()
        step_counter = max(0, step_counter-1)
    end

    if update_logic_clock == 0 then -- time to update
        if not is_paused then

            local target_speed = sim_speeds[sim_speed_idx]
            update_logic_clock = max(target_speed, 1)

            local steps_to_sim = 1
            if target_speed < 1 then 
                steps_to_sim = ceil(1/target_speed) 
            end

            phase_phaser(standing_robot_phaser)
            for i=1,steps_to_sim do
                update_robot_logic()
            end
        end
    end

    update_logic_clock = max(0, update_logic_clock-1)
    update_robot_display()
end


function draw_level(y_offset)
    if y_offset == nil then y_offset = 0 end
    -- actual level
    local mdy = ((level.height / 64))
    local mdx = ((level.width / 128))
    for i = 0, 63 do
        tline(0, i + y_offset, 128, i + y_offset, level.p.x, level.p.y + i*level.height/64, 1*level.width/128, 0)
    end

    -- target
    if level.target != nil then 
        local scale = level.scale
        local dp = pos((level.target.x-1) * scale, (level.target.y-1) * scale)
        spr(target_sprite, dp.x, dp.y, scale/8, scale/8)
    end

    -- title
    local title    = level_titles[level_idx][1]
    local subtitle = level_titles[level_idx][2]
    if #title > 0 then
        print(title, 3, 2, 0)
        print(title, 2, 1, 7)
    end
    if #subtitle then
        print(subtitle, 3, 58, 0)
        print(subtitle, 2, 57, 7)
    end
end

function get_level_pos(p)
    return pos(level.p.x + p.x - 1, level.p.y + p.y - 1)
end

function get_level_sprite(p)
    local lvl_pos = get_level_pos(p)
    return mget(lvl_pos.x, lvl_pos.y) 
end 

function write_to_level(p, val)
    local lvl_pos = get_level_pos(p)
    mset(lvl_pos.x, lvl_pos.y, val)
end


