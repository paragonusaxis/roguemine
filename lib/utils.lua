function clamp(v, min, max)
    print(min, max)
    local _min = nil
    local _max = nil
    if max < min then 
         _min = max
         _max = min
    else
         _min = min
         _max = max
    end
    if v < _min then return _min elseif v > _max then return _max else return v end
end