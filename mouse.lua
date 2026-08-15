--mouse
function init_mouse()
    poke(0x5f2d, 1)
    clickables={}
    default_mouse_callback_l=nil
    default_mouse_callback_r=nil
    mouse={
        p=pos(0,0), 
        down=false, down_l=false, down_r=false, 
        press=false, press_l=false, press_r=false,
        pixel_under=0
    }
    update_mouse_table()
end

function add_clickable(p_box, p_lfunc, p_rfunc, state, p_locked)
    add(clickables,{box=p_box, lfunc=p_lfunc, rfunc=p_rfunc, is_hover=false, state=state, locked=p_locked})
end

function is_locked(c)
    return c.locked != nil and c.locked()
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
        if c.state == state and not is_locked(c) then
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
    if #functions_to_call > 0 then
        for f in all(functions_to_call) do
            f()
        end
    else
        if mouse.press_l and default_mouse_callback_l != nil then
            default_mouse_callback_l()
        end
        if mouse.press_r and default_mouse_callback_r != nil then
            default_mouse_callback_r()
        end
    end
    -- debug("p "..p_to_str(mouse.p), 2)
    -- debug("pixel_under"..mouse.pixel_under, 3)
end

function draw_mouse()
    mouse.pixel_under = pget(mouse.p.x,mouse.p.y) -- need to compute pixel under before drawing the mouse, otherwise its always the color of the paint on the brush
    for c in all(clickables) do
        if c.state == state and not is_locked(c) then
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
    sspr(120,8,3,5,mouse.p.x,mouse.p.y,3,5)
    pal()
end

function draw_mouse_sprite(p, l, r) -- a computer mouse
    spr(14,p.x,p.y)
    -- for left and right click
    if l then
        sspr(126,8,2,2,p.x+1,p.y+1,2,2)
    end
    if r then
        sspr(126,8,2,2,p.x+4,p.y+1,2,2)
    end
end

