
function init_animation()
    phases = {}
end

function update_animation()
    for phaser in all(phases) do
        if phaser.active then
            tick_phaser(phaser)
        end
    end
end

function tick_phaser(phaser)
    phaser.tick += 1
    if phaser.tick == phaser.phase_duration then
        phaser.tick = 0
        phase_phaser(phaser)
    end
end

function phase_phaser(phaser)
    phaser.phase += 1
    if phaser.phase == phaser.max_phase then
        phaser.phase = 0
    end
    if phaser.func then
        phaser.func()
    end
end

function get_phaser(max_phase, phase_duration, new_phase_func)
    phase_duration = phase_duration or 1 
    max_phase = max_phase or 2
    -- phaser have a phase which ranges from 0 up to max_phase - 1
    -- where each phase lasts for phase_duration frames
    -- tick ranges from 0 to phase_duration - 1
    local phaser = {tick=0, phase_duration=phase_duration, max_phase=max_phase, phase=0, active=true, func=new_phase_func}
    add(phases, phaser)
    return phaser
end
