-- controls
function init_controls()
    update_logic_clock = 0
    sim_speeds = {32,16,8,4,2,1,1/2,1/4,1/8,1/16,1/32}
    is_paused  = true
    step_counter  = 0
    sim_speed_idx = 1 

    controls = {}
    local x_offset = 1
    add_control_button(pos(x_offset,68), default_control_draw(16), step)
    x_offset += 10
    add_control_button(pos(x_offset,68), draw_play_pause, play_pause)
    x_offset += 10
    add_control_button(pos(x_offset,68), default_control_draw(18), increase_speed, decrease_speed)
    x_offset += 10
    add_control_button(pos(x_offset,68), default_control_draw(21), reset_level)
    x_offset += 57 

    add_control_button(pos(x_offset,68), default_control_draw(20), previous_level)
    x_offset += 10
    add_control_button(pos(x_offset,68), draw_level_number)
    x_offset += 11
    add_control_button(pos(x_offset,68), default_control_draw(22), next_level)
    x_offset += 10
    add_control_button(pos(x_offset,68), default_control_draw(23), randomize_all_callback)
end

function add_control_button(p, draw_func, left_func, right_func)
    local button_box = box(p.x, p.y, p.x+7, p.y+7)
    add_clickable(button_box, left_func, right_func, "levels")
    add(controls, {p=p, draw=draw_func})
end

function default_control_draw(sprite_idx)
    return function (control) spr(sprite_idx, control.p.x, control.p.y) end
end

function draw_play_pause(control)
    if is_paused then
        spr(17, control.p.x, control.p.y)
    else
        spr(19, control.p.x, control.p.y)
    end
end

function draw_level_number(control)
    rectfill(control.p.x, control.p.y, control.p.x+8, control.p.y+7,6)
    rectfill(control.p.x, control.p.y, control.p.x+8, control.p.y+6,7)
    if level_idx >= 10 then
        print(level_idx, control.p.x+1, control.p.y+1, 0)
    else
        print(level_idx, control.p.x+3, control.p.y+1, 0)
    end
end

function draw_controls()
    for control in all(controls) do
        if control.draw then
            control.draw(control)
        end
    end
end

function play()
    if level.completed then
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
    if level.completed then
        reset_level()
    else
        is_paused = true
        update_logic_clock = 0
        step_counter+=1
    end
end

function increase_speed()
    sim_speed_idx = ((sim_speed_idx-1+1) % #sim_speeds) + 1
    play()
end

function decrease_speed()
    sim_speed_idx = ((sim_speed_idx-1-1) % #sim_speeds) + 1
    play()
end

function next_level()
    sfx(sounds["next"])
    pause()
    change_level(level_idx+1)
end

function reset_level()
    pause()
    reload_level()
end

function previous_level()
    sfx(sounds["prev"])
    pause()
    change_level(level_idx-1)
end

