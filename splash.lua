function init_splash()
    if not cart_image_mode then
        add_clickable(box(1,1,126,126), change_state_callback("tutorial"), change_state_callback("tutorial"), "splash")
    else
        add_clickable(box(1,1,126,126), play, pause, "splash")
    end
    change_level(22)
    if dget(0) > 0 then -- the app has been loaded before
        randomize_all_callback()
    end
    play()
end

function draw_splash()
    local dp = pos(32, 5)

    draw_arto(pos(88,dp.y-1), 2)

    sspr(96,16,32,16,dp.x-16,dp.y,64,32)
    dp.y+=36

    draw_level(dp.y)
    draw_robot(dp.y)
    rect(-1,dp.y-1,128,dp.y+64,5)

    dp.y+=70
    print("requires mouse", dp.x-2, dp.y, 7)
    draw_mouse_sprite(pos(dp.x+4*15-2,dp.y-2), false, false)
    if not cart_image_mode then
        dp.x-=2
        dp.y+=8
        print("click to continue", dp.x, dp.y, 7)
    end
end

