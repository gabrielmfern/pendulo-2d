Gravity = -1

function calculatePositionFromAngle(angle, length, origin)
    local result = {}

    result.x = length * math.sin(angle) + origin.x
    result.y = length * math.cos(angle) + origin.y

    return result
end

function hipotenuse(position)
    return math.sqrt(position.x * position.x + position.y * position.y)
end

function calculateAngleFromPosition(position, length, origin)
    if (origin.y < position.y) then
        return math.asin((position.x-origin.x)/length)
    else
        return math.pi/2 - math.asin((position.x-origin.x)/length) + math.pi/2
    end
end

function calculateForceFromAngle(angle)
    return Gravity * math.sin(angle)
end

function calculateDistance(x1, y1, x2, y2)
    return {x=math.abs(x1-x2), y=math.abs(y1-y2)}
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function table.merge(t1, t2)
    local temp = t1

    for k, v in pairs(t2) do
       temp[k] = v
    end

    return temp
end