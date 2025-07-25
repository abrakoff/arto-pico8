
function draw_debug_line(str, line)
    rectfill(0, 6*(line-1), #str * 4, 6*line, 0)
    print(str,0,6*(line-1),7)
end

function draw_debug()
    if debug_strings == nil then debug_strings = {} end
    local line = 1
    for i = 1,#debug_strings do
        if #debug_strings[i] > 0 then
            draw_debug_line(debug_strings[i], line)
            line+=1
        end
    end
end

function debug(str, i)
    i = i or 1
    if debug_strings == nil then debug_strings = {} end
    while #debug_strings <= i do
        add(debug_strings, "")
    end
    debug_strings[i] = tostr(str)
end

function debug_now(str)
    draw_debug_line(tostr(str),1)
    stop()
end
