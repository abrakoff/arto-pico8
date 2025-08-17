-- controls
function init_controls()
    update_logic_clock = 0
    sim_speeds        = {32,16,8,4,2,1,1/2,1/4,1/8,1/16,1/32}
    sim_speed_strings = {"/32","/16","/8","/4","/2","X1","X2","X4","X8","X16","X32"}
    is_paused  = true
    step_counter  = 0
    sim_speed_idx = 1 

    controls = {}
    local offset = pos(1,68)
    add_control_button(default_control_box(offset), default_control_draw(16), step)
    offset.x += 10
    add_control_button(default_control_box(offset), draw_play_pause, play_pause)
    offset.x += 10
    add_control_button(box(offset.x, offset.y, offset.x+12, offset.y+7), draw_sim_speed, increase_speed, decrease_speed)
    offset.x += 15
    add_control_button(default_control_box(offset), default_control_draw(21), reset_level)

    offset.x += 42 
    add_control_button(default_control_box(offset), draw_tutorial_button, change_state_callback("tutorial"))
    offset.x += 10
    add_control_button(default_control_box(offset), default_control_draw(20), previous_level)
    offset.x += 10
    add_control_button(box(offset.x, offset.y, offset.x+8, offset.y+7), draw_level_number)
    offset.x += 11
    add_control_button(default_control_box(offset), default_control_draw(22), next_level)
    offset.x += 10
    add_control_button(default_control_box(offset), default_control_draw(23), randomize_all_callback, derandomize_all_callback)
end

function add_control_button(button_box, draw_func, left_func, right_func)
    add_clickable(button_box, left_func, right_func, "levels")
    add(controls, {box=button_box, draw=draw_func})
end

function default_control_box(p)
    return box(p.x, p.y, p.x+7, p.y+7)
end

function default_control_draw(sprite_idx)
    return function (control) spr(sprite_idx, control.box.l, control.box.t) end
end

function draw_play_pause(control)
    if is_paused then
        spr(17, control.box.l, control.box.t)
    else
        spr(19, control.box.l, control.box.t)
    end
end

function draw_control_box(box)
    rectfill(box.l, box.b, box.r, box.b, 6) -- gray 
    rectfill(box.l, box.t, box.r, box.b-1, 7) -- white
end

function draw_level_number(control)
    draw_control_box(control.box)
    if level.idx >= 10 then
        print(level.idx, control.box.l+1, control.box.t+1, 0)
    else
        print(level.idx, control.box.l+3, control.box.t+1, 0)
    end
end

function draw_tutorial_button(control)
    draw_control_box(control.box)
    print("?", control.box.l+2, control.box.t+1, 0)
end

function draw_sim_speed(control)
    draw_control_box(control.box)
    print(sim_speed_strings[sim_speed_idx], control.box.l+1, control.box.t+1, 0)
end

function draw_controls()
    for control in all(controls) do
        if control.draw then
            control.draw(control)
        end
    end
end

function play()
    if level.completed_now then
        reset_level()
    end
    is_paused = false
    update_logic_clock = 0
end

function pause()
    is_paused = true 
    update_logic_clock = 0
end

function play_pause()
    if is_paused then 
        play() 
    else
        pause()
    end
end

function step()
    if level.completed_now then
        reset_level()
    else
        is_paused = true
        update_logic_clock = 0
        step_counter+=1
    end
end

function increase_speed()
    sim_speed_idx = min(sim_speed_idx+1, #sim_speeds)
end

function decrease_speed()
    sim_speed_idx = max(sim_speed_idx-1, 1)
end

function next_level()
    sfx(sounds["next"])
    pause()
    change_level(level.idx+1)
    save_last_level() -- so it can be reloaded
end

function reset_level()
    pause()
    reload_level()
end

function previous_level()
    sfx(sounds["prev"])
    pause()
    change_level(level.idx-1)
    save_last_level() -- so it can be reloaded
end

