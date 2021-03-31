require 'lib/queue'
function FloodFill(x, y, map, value)
    Q = List.new()
    if map[x][y] == 0 then
        List.pushright(Q, {x=x,y=y})
    end
    while not (Q.first > Q.last) do
        n = List.popright(Q)
        i, j = n.x, n.y
        map[i][j] = value
        if map[i+1][j] == 0 then
            List.pushright(Q, {x=i+1,y=j})
        end
        if map[i-1][j] == 0 then
            List.pushright(Q, {x=i-1,y=j})
        end
        if map[i][j+1] == 0 then
            List.pushright(Q, {x=i,y=j+1})
        end
        if map[i][j-1] == 0 then
            List.pushright(Q, {x=i,y=j-1})
        end
    end
    return map
end

return FloodFill