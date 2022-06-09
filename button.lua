local Button = { }

function Button.create(x, y, width, height, textScale, type, textOrImage)
    local temp = {}
    temp.x = x
    temp.y = y
    temp.width = width
    temp.height = height
    temp.type = type
    if type == "text" then
        temp.text = textOrImage
    elseif type == "image" then
        temp.image = love.graphics.newImage(textOrImage)
    end
    temp.textScale = textScale
    temp.active = false
    temp.hover = false
    temp.timeSinceActive = 0
    local temp2 = Button
    temp2.__index = table.merge(temp2, temp)
    setmetatable(temp, {__index = table.merge(temp2, temp)})
    return temp
end

function Button:isInside(x, y, w, h)
    if x + w > self.x and x < self.x + self.width and y + h > self.y and y < self.y + self.height then
        return true
    end

    return false
end

function Button:mousepressed(x, y, button)
    if button == 1 and self:isInside(love.mouse.getX(), love.mouse.getY(), 0, 0) then
        self.active = true
        self.__index.active = true
    end
end

function Button:update(dt)
    if self.active == true and self.timeSinceActive > 30 then
        self.timeSinceActive = 0
        self.__index.timeSinceActive = 0
        self.active = false
        self.__index.active = false
    elseif self.active == true then
        self.timeSinceActive = self.timeSinceActive + 1
        self.__index.timeSinceActive = self.__index.timeSinceActive + 1
    end

    if self:isInside(love.mouse.getX(), love.mouse.getY(), 0, 0) then
        self.hover = true
        self.__index.hover = true
    else
        self.hover = false
        self.__index.hover = false
    end
end

function Button:draw()
    if self.type == "text" then
        if self.hover or self.active then
            love.graphics.setColor(50 / 255, 50 / 255, 50 / 255)
        else
            love.graphics.setColor(25 / 255, 25 / 255, 25 / 255)
        end
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(self.text, self.x, self.y, 0, self.textScale)
    elseif self.type == "image" then
        love.graphics.draw(self.image, self.x, self.y, 0, self.width, self.height)
    end
end

return Button