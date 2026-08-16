--scaled_maps
function init_levels()
    default_sprite=8
    target_sprite=0
    wall_sprites={42,43,58}
    level_save_data_offset = 1 -- for dset and dget

    -- special_tile_phaser = get_phaser(3,16)
    level_init_data = {
        -- map_pos, scale, source, target, mem, titles, switches
        {pos( 0, 0),  8, pos(3,4),  pos(14,4), 7  , {"move green?","... means move right"},               },
        {pos(16, 0),  8, pos(3,4),  pos(14,4), 7  , {"move green, paint red?",""}, make_switch_row(8,8,4,2) },
        {pos(32, 0),  8, pos(3,4),  pos(14,4), 2  , {"move green, feel colors", "... and paint feelings?"}, },
        {pos(48, 0),  8, pos(3,4),  pos(14,6), 7  , {"move blue (down) on yellow!", ""},                  },
        {pos( 0, 8),  8, pos(3,4),  pos(14,4), 1  , {"side step the wall",""},                            },
        {pos(16, 8),  8, pos(3,3),  pos(14,5), 1  , {"i am stuck in a loop!", "save me!"},                },
        {pos(32, 8),  8, pos(5,4),  pos(12,4), 0  , {"moustache city",""},                                },
        {pos(48, 8),  8, pos(3,4),  pos(15,4), 1  , {"side step the wall?","...with feelings"},           },
        {pos( 0,16),  8, pos(2,7),  pos(15,2), 3 , {"wiggle",""},                                        },
        {pos(16,16),  8, pos(3,4),  pos(15,5), 1  , {"the floor is lava","... or maybe orange paint?"},   },
        {pos(32,16),  8, pos(2,7),  pos(15,7), 2  , {"i love red!","paint all red"},                      },
        {pos(48,16),  8, pos(3,6),  pos(13,4), 1  , {"i hate red!","paint the fence green"},              },
        {pos( 0,24),  8, pos(13,7), pos(5,5), 2  , {"par 9","avoid water and sand"},                     },
        {pos(16,24),  8, pos(4,5),  pos(12,5), 2 , {"look both ways",""},                                },
        {pos(32,24),  8, pos(4,4),  pos(13,4), 3 , {"segmented snake",""},                               },
        {pos(48,24),  8, pos(3,7),  pos(14,7), 2  , {"rainbow road",""},                                  },
        {pos(64,0),  4, pos(2,14), pos(31,14), 2, {"the maze",""},                                      },
        {pos(96,0),  4, pos(4,6),  pos(16,11), 3, {"paint your feelings","feel your paintings"},        },
        {pos(64,16), 4, pos(13,9), pos(19,9), 2 , {"the real maze",""},                                 },
        {pos(96,16), 4, pos(4,11), pos(27,7), 0 , {"the yellow brick road",""},                         },
        {pos(0,32),  2, pos(32,16), nil, 2      , {"",""},                                              },
        {pos(64,32), 2, pos(32,16), nil, 2      , {"",""}                                               }
    }

    levels = {}

    for l=1,#level_init_data do add(levels, load_level(l, level_init_data[l])) end
end

function make_switch_row(x1, x2, y, target)
    -- a switch at every cell from x1 to x2 (inclusive) along row y, all requiring the same color
    local switches = {}
    for x=x1,x2 do
        add(switches, {p=pos(x,y), target=target})
    end
    return switches
end

function switches_solved()
    for sw in all(level.switches) do
        if sprite_to_idx(get_level_sprite(sw.p)) != sw.target then
            return false
        end
    end
    return true
end

function load_level(idx, init_data)
    local map_pos, scale, source, target, mem, titles, switches = unpack(init_data)
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

    local level_save_data = dget(level_save_data_offset + idx - 1)
    local was_completed_ever = (level_save_data > 0)

    return {
        idx=idx,
        titles=titles,
        p=map_pos,
        scale=scale,          -- in {8,4,2}
        scale_idx=scale_idx,  -- in {1,2,3}
        width=width,
        height=height,
        source=source,
        target=target,
        switches=switches or {},
        use_random=false,
        completed_now=false,
        completed_ever=was_completed_ever,
        robot={
            p = copy_pos(source),                                   -- logical position
            mem = mem,                                              -- memory/mood
            display_positions = {copy_pos(source),copy_pos(source)} -- display positions (for torus levels need more than one)
        }
    } 
end

function change_level(idx)
    desired_level_idx = 1 + ((idx-1) % #levels) -- desired_level_idx might not match level.idx now
    validate_scope()
end

function save_last_level(idx)
    dset(0, level.idx)
end

function reload_level()
    -- reload the level
    levels[level.idx] = load_level(level.idx, level_init_data[level.idx])
    validate_scope()
end

function validate_scope()
    -- establishes global variables
    level = levels[desired_level_idx] -- desired_level_idx should match level.idx now
    robot = level.robot
end

function update_level()
    if step_counter > 0 then
        if robot.mem != null_idx then phase_phaser(standing_robot_phaser) end
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

            if robot.mem != null_idx then phase_phaser(standing_robot_phaser) end
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
    local scale = level.scale
    local mdy = (level.height / 64)
    local mdx = (level.width / 128)

    local lpx, lpy = level.p.x, level.p.y

    local bytes_per_line = 64
    local start_mem_loc = 24576 + y_offset * bytes_per_line
    for r = 0, level.height-1 do
        -- render a representative line
        local sr = scale*r
        tline(0, sr + y_offset, 127, sr + y_offset, lpx, lpy + sr * mdy, mdx, 0)

        -- copy remaining rendered lines
        for i = 1, scale-1 do -- number of lines to copy is scale - 1
            memcpy(start_mem_loc + (sr+i) * bytes_per_line, start_mem_loc + sr * bytes_per_line, bytes_per_line) 
        end
    end

    -- switches: overlay sprite 74 on top of the floor, recolored from grey to the switch's
    -- target color (color 0 stays transparent so the floor shows through underneath)
    for sw in all(level.switches) do
        local dp = pos((sw.p.x-1) * scale, (sw.p.y-1) * scale)
        pal(6, idx_to_color(sw.target))
        spr(74, dp.x, dp.y, scale/8, scale/8)
        pal()
    end

    -- target
    if level.target != nil then
        local dp = pos((level.target.x-1) * scale, (level.target.y-1) * scale)

        -- if level completed, change flag color
        if level.completed_ever then
            -- red to green
            pal(8,11)
            pal(2,3)
        end
        spr(target_sprite, dp.x, dp.y, scale/8, scale/8)
        pal() -- reset palette if needed
    end

    -- title
    local title    = level.titles[1]
    local subtitle = level.titles[2]
    if #title > 0 then
        print_with_shadow(title, 2, 1)
    end
    if #subtitle > 0 then
        print_with_shadow(subtitle, 2, 57)
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


