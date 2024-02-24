-- returns a shuffled table without touching the original
function shuffle(t)
    local s = {}
    for i = 1, #t do s[i] = t[i] end
    for i = #t, 2, -1 do
        local j = math.random(i)
        s[i], s[j] = s[j], s[i]
    end
    return s
end

-- handy for debugging
function print_ordered_table(t)
    for k, v in ipairs(t) do
        print(k, v)
    end
end

-- from http://www.love2d.org/wiki/BoundingBox.lua
function check_collision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
  end
