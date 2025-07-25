function init_brains()
    -- positions on sprite sheet
    edit_idx=1 -- color to write for editting

    brain_labels={"paint", "feel", "move"}

    brain_offsets={{},{},{}} -- points to upper left corner of grid
    brain_boxes={{{},{},{},{},{},{},{},{}},
                 {{},{},{},{},{},{},{},{}},
                 {{},{},{},{},{},{},{},{}}}

    brain_headers={{},{},{}}
    brain_consters={}

    hs = 4 -- header size

    for b=1,3 do

        brain_offsets[b]=pos((b-1)*44+6,88)
        local const_box = box(brain_offsets[b].x-hs-1, brain_offsets[b].y-hs-1, brain_offsets[b].x-2, brain_offsets[b].y-2)
        add_clickable(const_box, change_brain_all_callback(b), nil, "levels")
        add(brain_consters, const_box)
        for i=1,8 do     -- row

            -- headers for row and col 
            local header_pos = pos(brain_offsets[b].x+4*(i-1), brain_offsets[b].y+4*(i-1))
            local col_box = box(header_pos.x,  brain_offsets[b].y-hs-1,
                                header_pos.x+3,brain_offsets[b].y-2)
            local row_box = box(brain_offsets[b].x-hs-1, header_pos.y,
                                brain_offsets[b].x-2, header_pos.y+3)
            add(brain_headers[b], {row=row_box, col=col_box})
            add_clickable(col_box, change_brain_col_callback(b,i-1), change_edit_callback(i-1), "levels")
            add_clickable(row_box, change_brain_row_callback(b,i-1), change_edit_callback(i-1), "levels")

            -- grid
            for j=1,8 do -- col
                local ij_offset  = pos(4*(j-1),4*(i-1))
                local bij_offset = add_pos(brain_offsets[b], ij_offset)
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
                    "levels"
                )
                add(brain_boxes[b][i],d_box)
            end
        end
    end
end

function draw_brains()
    for b=1,3 do
        -- gray background
        rectfill(brain_offsets[b].x-hs-2,brain_offsets[b].y-hs-2,brain_offsets[b].x+32,brain_offsets[b].y+32+7, 5)
        draw_box(brain_consters[b], 7, true)

        -- underneath text
        local text_pos = pos(brain_offsets[b].x, brain_offsets[b].y+32+1)
        print(brain_labels[b], text_pos.x+1, text_pos.y+1, 0)
        print(brain_labels[b], text_pos.x, text_pos.y, 7)

        -- extra move icon
        if b==3 then spr(15,text_pos.x+24,text_pos.y-1)  end

        -- drawing headers
        for h=1,8 do
            local draw_color = idx_to_color(h-1)
            draw_box(brain_headers[b][h].row, draw_color, true)
            draw_box(brain_headers[b][h].col, draw_color, true)
        end

        -- drawing grids
        for i=1,8 do     -- row
            for j=1,8 do -- col
                local brain_idx = get_brain(b, pos(j-1,i-1))
                local draw_color = idx_to_color(brain_idx) -- hack, called idx_to_c on c_to_idx
                draw_box(brain_boxes[b][i][j], draw_color, true)
            end
        end

        if level and robot then
            -- indicate which part of brain is activate
            local active_box = brain_boxes[b][under_robot()+1][robot.mem+1]
            draw_box(feather(active_box), 6)
        end
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

function change_brain_all_callback(b)
    return function() 
        for i=1,8 do
            for j=1,8 do
                set_brain(b, pos(j-1, i-1), edit_idx) 
            end
        end
    end
end

function change_edit_from_brain_callback(b, pos)
    return function() edit_idx = get_brain(b, pos) end
end

function change_edit_callback(idx)
    return function() edit_idx = idx end
end

function randomize_brain(b)
    for i=1,8 do
        for j=1,8 do
            set_brain(b, pos(i-1,j-1), flr(rnd(8)))
        end
    end
end

function randomize_brain_callback(b)
    return function () randomize_brain(b) end
end

function randomize_all_callback()
    for b=1,3 do
        randomize_brain(b)
    end
end

-- access brain data
function get_brain_sprite_pos(b, p)

    local x_shift = 8 * (level_idx - 1)
    local y_shift = 16 + 8 * (b-1)
    if level_idx > 10 then 
        x_shift -= 80
        y_shift += 24 
    end

    local sprite_pos = pos(x_shift + p.x, y_shift + p.y)
    return sprite_pos
end

function get_brain(b, p)
    local sprite_pos = get_brain_sprite_pos(b,p)
    local col = sget(sprite_pos.x,sprite_pos.y)
    return color_to_idx(col)
end

function set_brain(b, p, new)
    local sprite_pos = get_brain_sprite_pos(b,p)
    sset(sprite_pos.x, sprite_pos.y, idx_to_color(new))
end
