--robot flasher
--oort cloud
function _init()
    printh("[Robot Flasher]","log")
    init_mouse()
    init_brains()
    init_levels()
    init_controls()
    anim_clock = 0
    printh("_init() finished","log")
end

function _update60()
    update_mouse()

    if anim_clock % 16 == 0 then
        animate_robot()
    end

    if step_counter > 0 then
        update_robot()
        step_counter = max(0, step_counter-1)
    end
    if update_clock == 0 then -- time to update
        if not is_paused then
            local target_speed = sim_speeds[sim_speed_idx]
            update_clock = max(target_speed, 1)
            local steps_to_sim = 1
            if target_speed < 1 then 
                steps_to_sim = ceil(1/target_speed) 
            end
            for i=1,steps_to_sim do
                update_robot()
            end
        end
    end

    update_clock = max(0, update_clock-1)
    anim_clock += 1
    if anim_clock >= 128 then anim_clock = 0 end
end

function _draw()
    cls(0)
    draw_level()
    draw_robot()
    draw_brains()
    draw_controls()
    draw_mouse()
end

function debug(str)
    if true then
        cls()
        print(str,1,1,0)
        print(str,0,0,7)
        stop()
        cls()
    end
end
