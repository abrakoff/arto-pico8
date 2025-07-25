--mouse
function init_mouse()
    poke(0x5f2d, 1)
    clickables={}
    mouse={
        p=pos(0,0), 
        down=false, down_l=false, down_r=false, 
        press=false, press_l=false, press_r=false
    }
    update_mouse_table()
end

function add_clickable(p_box, p_lfunc, p_rfunc, state)
    add(clickables,{box=p_box, lfunc=p_lfunc, rfunc=p_rfunc, is_hover=false, state=state})
end

function update_mouse_table()
    mouse.p      = pos(stat(32), stat(33))
    local down_l = (stat(34)&0b001)>0
    local down_r = (stat(34)&0b010)>0

    mouse.press_l = down_l and not mouse.down_l
    mouse.press_r = down_r and not mouse.down_r
    mouse.press   = mouse.press_l or mouse.press_r

    mouse.down_l = down_l
    mouse.down_r = down_r
    mouse.down   = down_l or down_r
end

function update_mouse()
    update_mouse_table()
    local functions_to_call = {}
    for c in all(clickables) do
        local is_hover = p_in_box(mouse.p, c.box)
        if c.state == state then
            if is_hover then 
                if mouse.press_l or (mouse.down_l and not c.is_hover) then 
                    if c.lfunc then add(functions_to_call, c.lfunc) end
                end
                if mouse.press_r or (mouse.down_r and not c.is_hover) then 
                    if c.rfunc then add(functions_to_call, c.rfunc) end
                end
            end
        end
        c.is_hover = is_hover
    end
    for f in all(functions_to_call) do
        f()
    end
end

function draw_mouse()
    for c in all(clickables) do
        if c.state == state then
            if p_in_box(mouse.p, c.box) then
                if mouse.down then
                    draw_box(feather(c.box),6)
                else
                    draw_box(feather(c.box),7)
                end
            end
        end
    end

    -- show mouse
    local write_col = idx_to_color(edit_idx)
    pal(11, write_col) -- orig green
    sspr(109,11,3,5,mouse.p.x,mouse.p.y,3,5)
    pal()
end

