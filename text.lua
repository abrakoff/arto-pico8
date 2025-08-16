function print_with_shadow(string, x, y)
    print(string, x, y+1, 0) -- black
    print(string, x, y, 7) -- white
end
