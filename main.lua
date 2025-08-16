--robot flasher
--oort cloud
function _init()
    cartdata("oortcloud_arto_version_1")
    state = "splash"
    init_mouse()
    init_sound()
    init_levels()
    init_animation()
    init_brains()
    init_robot()
    init_controls()
    init_splash()
end

function _update60()
    update_mouse()

    if state == "levels" then
        update_level()
    elseif state == "splash" then
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
        draw_brains()
        draw_controls()
    elseif state == "splash" then
        draw_splash()
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
        sim_speed_idx = 1 -- want normal speed by default
        pause()
        local stored_level_idx = dget(0)
        if stored_level_idx >= 0 and stored_level_idx <= #levels then
            change_level(stored_level_idx)
        else
            change_level(1)
        end
    end
end

function change_state_callback(new_state)
    return function() change_state(new_state) end
end
