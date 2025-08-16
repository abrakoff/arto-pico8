function init_tutorial()
    exit_tutorial_box = box(126-36,126-8,126-1,126-1)
    add_clickable(exit_tutorial_box, change_state_callback("levels"), change_state_callback("levels"), "tutorial")
end


function draw_tutorial()
    local offset = pos(4,12)
    print("arto is a robot artist", offset.x, offset.y, 7)
    offset.y += 12
    print("arto paints, feels,", offset.x, offset.y, 7)
    offset.y += 7
    print("and moves around ", offset.x, offset.y, 7)
    offset.y += 7 
    print("based on 2 variables:", offset.x, offset.y, 7)
    offset.y += 8
    print(" arto's current feelings (col)", offset.x, offset.y, 7)
    offset.y += 7
    print(" the current floor color (row)", offset.x, offset.y, 7)


    offset.y = 70 
    print("program arto to", offset.x, offset.y, 7)
    offset.y += 7
    print("reach the flag", offset.x, offset.y, 7)
    spr(0, offset.x+3*19, offset.y-2)
    offset.y += 12
    print("controls:", offset.x, offset.y, 7)
    offset.y += 7
    draw_mouse_sprite(offset, true, false)
    print("edit arto's brain", offset.x+9, offset.y+1, 7)
    offset.y += 9
    draw_mouse_sprite(offset, false, true)
    print("change edit color", offset.x+9, offset.y+1, 7)

    local etb = exit_tutorial_box
    draw_control_box(box(etb.l,etb.t,etb.r-8,etb.b)) -- so black arrow shows
    spr(22, exit_tutorial_box.r-7, exit_tutorial_box.t)
    print("proceed", etb.l+1,etb.t+1,0)

    draw_arto(pos(92,4), 2)
    draw_brain(4)
end
