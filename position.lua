--positioning
function pos(p_x, p_y)
    return { x=p_x, y=p_y }
end

function add_pos(p1, p2)
    return pos(p1.x + p2.x, p1.y + p2.y)
end

function subtract_pos(p1, p2)
    return pos(p1.x - p2.x, p1.y - p2.y)
end

function equal_pos(p1, p2)
    return p1.x == p2.x and p1.y == p2.y
end

function manhattan_dist(p1, p2)
    return abs(p1.x - p2.x) + abs(p1.y - p2.y)
end

function lerp(p1, p2, a)
    return pos(a * p1.x + (1-a) * p2.x, a * p1.y + (1-a) * p2.y)
end

function step_lerp(p1, p2, p3, s)
    local mdist12 = manhattan_dist(p1, p2)
    if mdist12 == 0 then 
        -- nothing to interpolate
        return copy_pos(p1) 
    end
    local dist_frac = manhattan_dist(p1, p3) / mdist12 

    if dist_frac >= 1 then
        return lerp(p1, p2, s)
    else
        return lerp(p1, p2, min(1, s + (1 - dist_frac)) )
    end
end

function copy_pos(p)
    return pos(p.x, p.y)
end

function box(p_l, p_t, p_r, p_b)
    return { l=p_l, t=p_t, r=p_r, b=p_b }
end

function feather(p_box, a)
    a = a or 1
    return box(p_box.l-a,p_box.t-a,p_box.r+a,p_box.b+a)
end

function draw_box(box, color, fill)
    if fill then
        rectfill(box.l,box.t,box.r,box.b,color)
    else
        rect(box.l,box.t,box.r,box.b,color)
    end
end

function p_to_str(p)
    return "(x="..p.x..", y="..p.y..")"
end

function p_in_box(p,box)
    return p.x >= box.l and p.x <= box.r and p.y >= box.t and p.y <= box.b
end

function shift(p,d,a)
    -- left, right, up, down
    local dx,dy = p.x,p.y
    a = a or 1
    if d==0 then dx-=a end
    if d==1 then dx+=a end
    if d==2 then dy-=a end
    if d==3 then dy+=a end
    return pos(dx,dy) 
end

function one_indexed_wrap(i, w)
    i = 1 + (i - 1) % w
    if i <= 0 then i += w end
    return i
end

function wrap(p, size)
    local wx = one_indexed_wrap(p.x, size.x) 
    local wy = one_indexed_wrap(p.y, size.y) 
    return pos(wx, wy)
end
