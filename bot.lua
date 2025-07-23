--robot
function update_robot()
    if is_on_target() then
        pause()
        return
    end
    --where in the brain to look
    local data_pos = active_neuron()
    --writing
    local write = get_brain(1,data_pos)
    write_to_level(robot.p, idx_to_sprite(write))
    --memory
    robot.mem = get_brain(2,data_pos)
    --movement
    local move_idx = get_brain(3,data_pos)
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
    local data_pos = active_neuron()
    local mem_col = idx_to_color(data_pos.x)
    local floor_col = idx_to_color(data_pos.y)
    local write_col = idx_to_color(get_brain(1,data_pos))

    -- sprite robot
    pal(10, floor_col) -- yellow 
    pal(12, mem_col)   -- blue
    pal(11, write_col) -- green
    palt(14,true)
    palt(0,false)

    -- robot on map 
    local scale = level.scale
    local dx = scale * (robot.p.x-1)
    local dy = scale * (robot.p.y-1)
    if scale == 8 then
        sspr(104,0,8,8,dx,dy,8,8)
    elseif scale == 4 then
        sspr(104,8,4,4,dx,dy,4,4)
    elseif scale == 2 then
        sspr(108,8,2,2,dx,dy,2,2)
    end

    -- robot between controls
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

