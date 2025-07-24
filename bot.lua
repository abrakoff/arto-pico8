--robot
function update_robot()
    if is_on_target() then
        pause()
        return
    end
    --where in the brain to look
    local data_pos = pos(robot.mem, under_robot())
    --writing
    local write = get_brain(1, data_pos)
    write_to_level(robot.p, idx_to_sprite(write))
    --memory
    robot.mem = get_brain(2, data_pos)
    --movement
    local move_idx = get_brain(3, data_pos)
    robot.p = resolve_move(move_idx, robot.p)
end

function animate_robot()
    if robot_anim_frame == nil then robot_anim_frame = 0 end
    robot_anim_frame = 1 + (robot_anim_frame % 2)
    if is_paused then robot_anim_frame = 1 end
end

function is_on_target()
    return robot.p.x == level.target.x and robot.p.y == level.target.y
end

function resolve_move(idx, old)
    -- determines where robot should move to given obstacles

    -- desired direction and amount 
    local desired = idx_to_move(idx)
    local amount  = desired.a
    local dir     = desired.dir

    -- desired position
    local desired = shift(old, dir, amount)
    local middle  = shift(old, dir,      1)

    if fget(get_level_sprite(middle),0) then
        return old 
    end
    if fget(get_level_sprite(desired),0) then
        return middle
    end
    return desired
end

function draw_robot()
    -- for sprite color remapping
    local scale = level.scale
    local dx = scale * (robot.p.x-1)
    local dy = scale * (robot.p.y-1)

    local mem_col   = idx_to_color(robot.mem)
    local floor_col = idx_to_color(under_robot())
    local data_pos  = pos(robot.mem, under_robot())
    local write = get_brain(1,data_pos)

    local write_col = idx_to_color(write)

    -- movement indicator
    local move_idx = get_brain(3, data_pos)
    local next_pos = resolve_move(move_idx, robot.p)
    local next_dx = scale * (next_pos.x-1)
    local next_dy = scale * (next_pos.y-1)

    --local move_col = idx_to_color(get_brain(3,data_pos))
    --if flr((anim_clock % 32)/16) > 0 then move_col = 7 end

    rect(next_dx+1, next_dy+1, next_dx+scale-2, next_dy+scale-2, 7)

    -- sprite robot
    pal(10, floor_col) -- orig yellow 
    pal(12, mem_col)   -- orig blue
    pal(11, write_col) -- orig green
    palt(14,true)
    palt(0,false)

    -- robot on map 
    if scale == 8 then
        sspr(104,0,8,8,dx,dy,8,8)
    elseif scale == 4 then
        sspr(104,8,4,4,dx,dy,4,4)
    elseif scale == 2 then
        sspr(108,8,2,2,dx,dy,2,2)
    end

    -- robot standing between controls
    if robot_anim_frame == 1 then
        sspr(72,0,16,16,55,65,16,16)
    else
        sspr(72+16,0,16,16,55,65,16,16)
    end

    -- reset the palette
    pal()
    palt(14,false)
    palt(0,true)

end

