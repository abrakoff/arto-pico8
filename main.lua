--robot flasher
--oort cloud
function _init()
    cartdata("oortcloud_arto_version_1")
    --clear_cart_data()
    state = "splash"

    init_mouse()
    init_sound()
    init_colors()
    init_levels()
    init_animation()
    init_brains()
    init_controls()
    init_splash()
    init_tutorial()
    init_robot()
end

function clear_cart_data()
    -- only for testing
    for i=0,63 do dset(i,0) end
end

function _update60()
    update_mouse()

    if state == "levels" then
        update_level()
    elseif state == "splash" then
        sim_speed_idx = 4 -- override
        update_level()
    elseif state == "tutorial" then
        sim_speed_idx = 1 -- overrride
        update_level()
    else
    end

    update_animation()
end

function _draw()
    cls(0)
    if state == "levels" then
        draw_level()
        draw_robot()
        draw_arto(pos(55,65), 1)
        draw_level_brains()
        draw_controls()
    elseif state == "splash" then
        draw_splash()
    elseif state == "tutorial" then
        draw_tutorial()
    end
    draw_mouse()
    draw_debug()
end

function change_state(new_state)
    if new_state == state then 
        return 
    end

    sfx(sounds["state"])
    state = new_state

    if new_state == "levels" then
        reset_level() -- the splash and tutorial levels need clearing
        sim_speed_idx = 1 -- want normal speed by default
        pause()
        local stored_level_idx = dget(0)
        if stored_level_idx > 0 and stored_level_idx <= #levels then
            change_level(stored_level_idx)
        else
            change_level(1)
        end
    elseif new_state == "tutorial" then
        reset_level() -- the splash and tutorial levels need clearing
        derandomize_all_callback()
        sim_speed_idx = 1
        change_level(22)
        play()
    end
end

function change_state_callback(new_state)
    return function() change_state(new_state) end
end
