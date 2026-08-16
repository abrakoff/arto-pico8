function init_brains()
    -- positions on sprite sheet
    edit_idx=1 -- color to write for editting
    default_mouse_callback_r = pick_color_at_mouse

    brains={
        {
            label="paint",
            offset=pos(50,88),
            grid_boxes={{},{},{},{},{},{},{},{}},
            header_boxes={},
            const_box=nil,
        },
        {
            label="feel",
            offset=pos(94,88),
            grid_boxes={{},{},{},{},{},{},{},{}},
            header_boxes={},
            const_box=nil,
        },
        {
            label="move",
            offset=pos(6,88),
            grid_boxes={{},{},{},{},{},{},{},{}},
            header_boxes={},
            const_box=nil,
        },
        {
            label="tutorial",
            offset=pos(94,74),
            grid_boxes={{},{},{},{},{},{},{},{}},
            header_boxes={},
            const_box=nil,
        }
    }


    hs = 4 -- header size

    for b=1,4 do

        brains[b].const_box = box(brains[b].offset.x-hs-1, brains[b].offset.y-hs-1, brains[b].offset.x-2, brains[b].offset.y-2)
        local brain_state = "levels"
        if b == 4 then brain_state = "tutorial" end

        -- paint and feel start locked, unlocked incrementally in later levels
        local locked = nil
        if b == 1 or b == 2 then
            locked = function() return is_brain_locked(b) end
        end

        -- selects the null (black) instruction for painting
        add_clickable(brains[b].const_box, change_edit_callback(null_idx), nil, brain_state, locked)

        for i=1,8 do     -- row
            -- headers for row and col
            local header_pos = pos(brains[b].offset.x+4*(i-1), brains[b].offset.y+4*(i-1))
            local col_box = box(header_pos.x,  brains[b].offset.y-hs-1,
                                header_pos.x+3,brains[b].offset.y-2)
            local row_box = box(brains[b].offset.x-hs-1, header_pos.y,
                                brains[b].offset.x-2, header_pos.y+3)
            add(brains[b].header_boxes, {row=row_box, col=col_box})

            add_clickable(col_box, change_brain_col_callback(b,i-1), change_edit_callback(i-1), brain_state, locked)
            add_clickable(row_box, change_brain_row_callback(b,i-1), change_edit_callback(i-1), brain_state, locked)

            -- grid
            for j=1,8 do -- col
                local ij_offset  = pos(4*(j-1),4*(i-1))
                local bij_offset = add_pos(brains[b].offset, ij_offset)
                local d_box = box(
                        bij_offset.x,
                        bij_offset.y,
                        bij_offset.x+3,
                        bij_offset.y+3
                    )
                add_clickable(
                    d_box,
                    change_brain_callback(b, pos(j-1,i-1)),
                    change_edit_from_brain_callback(b, pos(j-1,i-1)),
                    brain_state,
                    locked
                )
                add(brains[b].grid_boxes[i],d_box)
            end
        end
    end
end

function is_brain_locked(b)
    if not level then return false end
    if b == 1 then return level.idx == 1 end     -- paint unlocks after level 1
    if b == 2 then return level.idx <= 2 end      -- feel unlocks after level 2
    return false
end

function draw_level_brains()
    for b=1,3 do
        draw_brain(b)
    end
end

function draw_brain(b)
    -- gray background
    rectfill(brains[b].offset.x-hs-2,brains[b].offset.y-hs-2,brains[b].offset.x+32,brains[b].offset.y+32+7, 5)
    draw_box(brains[b].const_box, idx_to_color(null_idx), true)

    -- underneath text
    local text_pos = pos(brains[b].offset.x, brains[b].offset.y+32+1)
    print_with_shadow(brains[b].label, text_pos.x, text_pos.y, 0)

    -- extra move icon
    if b==3 then spr(15,text_pos.x+24,text_pos.y-1)  end

    -- drawing headers
    for h=1,8 do
        local draw_color = idx_to_color(h-1)
        draw_box(brains[b].header_boxes[h].row, draw_color, true)
        draw_box(brains[b].header_boxes[h].col, draw_color, true)
    end

    -- drawing grids
    for i=1,8 do     -- row
        for j=1,8 do -- col
            local brain_idx = get_brain(b, pos(j-1,i-1))
            local draw_color = idx_to_color(brain_idx) -- hack, called idx_to_c on c_to_idx
            draw_box(brains[b].grid_boxes[i][j], draw_color, true)
        end
    end

    local is_locked = (b == 1 or b == 2) and is_brain_locked(b)
    if level and robot and not is_locked then
        -- indicate which part of brain is active (nil when mem is out of the 8-value grid, e.g. a null feel state)
        local active_row = brains[b].grid_boxes[under_robot()+1]
        local active_box = active_row and active_row[robot.mem+1]
        if active_box then
            draw_box(feather(active_box), 6)
        end
    end

    -- show the lock over the grid
    if is_locked then
        sspr(103,43,10,15, brains[b].offset.x+11, brains[b].offset.y+8, 10, 15)
    end
end

function under_robot()
    return sprite_to_idx(get_level_sprite(robot.p))
end

function change_brain_callback(b, pos)
    return function() set_brain(b, pos, edit_idx) end
end

function change_brain_col_callback(b, col)
    return function() 
        for i=1,8 do
            set_brain(b, pos(col,i-1), edit_idx) 
        end
    end
end

function change_brain_row_callback(b, row)
    return function() 
        for j=1,8 do
            set_brain(b, pos(j-1, row), edit_idx) 
        end
    end
end

function change_edit_from_brain_callback(b, pos)
    return function() edit_idx = get_brain(b, pos) end
end

function change_edit_callback(idx)
    return function() edit_idx = idx end
end

function pick_color_at_mouse()
    local idx_at_mouse = color_to_idx(mouse.pixel_under)
    -- ensure the pixel is a paintable color
    if idx_at_mouse != nil then
        edit_idx = idx_at_mouse
    end
end

function randomize_brain(b)
    for i=1,8 do
        for j=1,8 do
            set_brain(b, pos(i-1,j-1), flr(rnd(8)))
        end
    end
end

function randomize_all_callback()
    level.use_random = true
    for b=1,3 do
        randomize_brain(b)
    end
end

function derandomize_all_callback()
    level.use_random = false
end

-- access brain data
function get_brain_sprite_pos(b, p)
    -- points to sprite 24 by default
    local x_shift = 64
    local y_shift = 8

    -- standard brains depend on level and brain index
    if brains[b].label != "tutorial" then
        x_shift = 8 * (level.idx - 1)
        y_shift = 16 + 8 * (b-1)
        if level.idx > 10 then 
            x_shift -= 80
            y_shift += 24 
        end
    end
    if level.use_random then
        x_shift = 120
        y_shift = 40 + 8 * (b-1)
    end

    local sprite_pos = pos(x_shift + p.x, y_shift + p.y)
    return sprite_pos
end

function get_brain(b, p)
    local sprite_pos = get_brain_sprite_pos(b,p)
    local col = sget(sprite_pos.x,sprite_pos.y)
    -- p.x/p.y can fall outside the 8x8 block (e.g. reading with a null mem state);
    -- treat any color that isn't a recognized instruction as null rather than crashing
    return color_to_idx(col) or null_idx
end

function set_brain(b, p, new)
    local sprite_pos = get_brain_sprite_pos(b,p)
    sset(sprite_pos.x, sprite_pos.y, idx_to_color(new))
end
