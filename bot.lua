--robot
function init_robot()
    robot_sprites = {pos(104,0),pos(104,8),pos(108,8)}
    standing_robot_phaser = get_phaser(2, 1, beep_boop)
    standing_robot_phaser.active = false
end

function update_robot_logic()
    -- a null feel state is permanently dead: freeze entirely rather than reading
    -- write/move from a mem value that no longer indexes into this level's brain data
    if robot.mem == null_idx then
        return
    end

    --where in the brain to look
    local data_pos = pos(robot.mem, under_robot())
    local write = get_brain(1, data_pos)
    local memory = get_brain(2, data_pos)
    local move = get_brain(3, data_pos)

    if not level.completed_now then
        -- writing
        if write != null_idx then
            write_to_level(robot.p, idx_to_sprite(write))
        end

        -- memory (null explicitly transitions to a dead state, not a no-op)
        robot.mem = memory

        -- animation movement
        robot.p_last = robot.p
        if move != null_idx then
            robot.p_unwrapped = resolve_move(move, robot.p, false)
            -- logical movement
            robot.p            = resolve_move(move, robot.p, true)
        else
            robot.p_unwrapped = robot.p
        end

        -- more animation movement
        robot.p_last_wrapped = add_pos(robot.p_last, subtract_pos(robot.p, robot.p_unwrapped))
    end

    if has_completed_level() then
        -- @HACK allow one last write for paint all level (fix for more complicated completion checking
        local final_write = get_brain(1, pos(robot.mem, under_robot()))
        if final_write != null_idx then
            write_to_level(robot.p, idx_to_sprite(final_write))
        end

        if not level.completed_now then sfx(sounds["win"]) end
        level.completed_now = true
        level.completed_ever = true
        dset(level_save_data_offset - 1 + level.idx, 1) -- enables completed_ever to be saved and reloaded
        pause()
        return
    end
end

function update_robot_display()
    -- ensure last and unwrapped and well defined for animating
    if robot.p_last         == nil then robot.p_last         = robot.p end
    if robot.p_unwrapped    == nil then robot.p_unwrapped    = robot.p end
    if robot.p_last_wrapped == nil then robot.p_last_wrapped = robot.p end

    -- for fast speeds, no animation should occur
    local logic_interval = sim_speeds[sim_speed_idx]
    if logic_interval <= 1 then -- meaning more than one logic update per frame
        robot.display_positions[1] = copy_pos(robot.p)
        robot.display_positions[2] = copy_pos(robot.p)
        return
    end

    -- [Protocol]
    -- robot.display_positions[1]
    -- ... animates from p_last         to p_unwrapped
    -- robot.display_positions[2]
    -- ... animates from p_last_wrapped to p

    local p              = robot.p
    local p_last         = robot.p_last
    local p_unwrapped    = robot.p_unwrapped
    local p_last_wrapped = robot.p_last_wrapped

    -- debug("p_unwrapped    "..p_to_str(p_unwrapped),1)
    -- debug("p_last         "..p_to_str(p_last),2)
    -- debug("p              "..p_to_str(p),3)
    -- debug("p_last_wrapped "..p_to_str(p_last_wrapped),4)
    -- debug("dp[1]          "..p_to_str(robot.display_positions[1]),5)
    -- debug("dp[2]          "..p_to_str(robot.display_positions[1]),6)

    local s = 2/logic_interval
    robot.display_positions[1] = step_lerp(p_unwrapped, p_last, robot.display_positions[1], s)
    robot.display_positions[2] = step_lerp(p, p_last_wrapped, robot.display_positions[2], s)
end

function beep_boop()
    if state == "levels" then
        if standing_robot_phaser.phase == 1 then
            sfx(sounds["beep"])
        else
            sfx(sounds["boop"])
        end
    end
end

function has_completed_level()
    if level.target != nil then
        return equal_pos(robot.p, level.target)
    else
        return false
    end
end

function resolve_move(idx, old, wrapped)
    -- determines where robot should move to given obstacles
    if wrapped == nil then wrapped = true end

    -- desired direction and amount 
    local desired = idx_to_move(idx)
    local amount  = desired.a
    local dir     = desired.dir

    -- desired position
    local level_size = pos(level.width, level.height)
    local desired    = shift(old, dir, amount)
    local middle     = shift(old, dir,      1)
    local desired_wrapped = wrap(desired, level_size)
    local middle_wrapped  = wrap(middle, level_size)

    if fget(get_level_sprite(middle_wrapped),0) then
        return old 
    end
    if fget(get_level_sprite(desired_wrapped),0) then
        if wrapped then 
            return middle_wrapped
        else
            return middle
        end
    end
    -- otherwise no obstacles
    if wrapped then 
        return desired_wrapped
    else
        return desired
    end
end

function draw_robot(y_offset)
    if y_offset == nil then y_offset = 0 end

    draw_with_context(function() 
        local sprite_pos = robot_sprites[level.scale_idx]
        local scale = level.scale

        -- robot on map 
        clip(0, y_offset, 128, 64)
        for dp in all(robot.display_positions) do
            local dx = scale * (dp.x-1)
            local dy = scale * (dp.y-1)
            sspr(sprite_pos.x,sprite_pos.y,scale, scale,dx,dy+y_offset,scale,scale)
        end
        clip()
    end)

end

function draw_with_context(func)
    -- for sprite color remapping
    local scale     = level.scale
    local mem_col   = idx_to_color(robot.mem)
    local floor_col = idx_to_color(under_robot())
    local data_pos  = pos(robot.mem, under_robot())
    local write_b   = 1 -- the brain for writing
    if state == "tutorial" then write_b = 4 end -- override for tutorial screen only

    local write = null_idx
    if robot.mem != null_idx then
        write = get_brain(write_b,data_pos)
    end
    local write_col = idx_to_color(write)

    -- sprite robot
    pal(10, floor_col) -- orig yellow 
    pal(12, mem_col)   -- orig blue
    pal(11, write_col) -- orig green
    palt(14,true)
    palt(0,false)

    func()

    -- reset the palette
    pal()
    palt(14,false)
    palt(0,true)
end

function draw_arto(p_offset, arto_scale)
    draw_with_context(function()
        if standing_robot_phaser.phase == 0 then
            sspr(72,0,16,16,p_offset.x,p_offset.y,16*arto_scale,16*arto_scale)
            if level.completed_now then sspr(112,8,7,4,p_offset.x+5,p_offset.y+7,7*arto_scale,4*arto_scale) end
        else
            sspr(72+16,0,16,16,p_offset.x,p_offset.y,16*arto_scale,16*arto_scale)
            if level.completed_now then sspr(112,8,7,4,p_offset.x+5,p_offset.y+8,7*arto_scale,4*arto_scale) end
        end
    end)
end
