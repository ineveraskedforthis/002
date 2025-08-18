return function (rx, ry, rw, rh, x, y)
    if x < rx then
        return false
    end
    if x > rx + rw then
        return false
    end
    if y < ry then
        return false
    end
    if y > ry + rh then
        return false
    end
    return true
end