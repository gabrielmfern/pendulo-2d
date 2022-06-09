local TextBox = { }

local key_disable = {"up", "down", "left", "right", "home", "end", "pageup", "pagedown", -- Navigation keys
"insert", "tab", "clear", "delete", -- Editing keys
"f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12", "f13", "f14", "f15", -- Function keys
"numlock", "scrollock", "ralt", "lalt", "rmeta", "lmeta", "lsuper", "rsuper", "mode", "compose", "lshift", "rshift",
                     "lctrl", "rctrl", "capslock", -- Modifier keys
"pause", "escape", "help", "print", "sysreq", "break", "menu", "power", "euro", "undo" -- Miscellaneous keys
}

TextBoxActive = false

function TextBox.create(x, y, width, height, textScale, value, type)
    local temp = {}
    temp.x = x
    temp.y = y
    temp.width = width
    temp.height = height
    temp.value = value
    temp.type = type
    temp.active = false
    temp.textScale = textScale
    temp.maxLength = width * 3 / 50
    local temp2 = TextBox
    temp2.__index = table.merge(temp2, temp)
    setmetatable(temp, {__index = table.merge(temp2, temp)})
    return temp
end

function TextBox:isInsideTextBox(x, y, w, h)
    if x + w > self.x and x < self.x + self.width and y + h > self.y and y < self.y + self.height then
        return true
    end

    return false
end

function TextBox:keypressed(key)
    if self.active then
        if key == "backspace" then
            local str = tostring(self.value)

            self.value = string.sub(str, 1, string.len(str) - 1)
        elseif string.len(tostring(self.value)) < self.maxLength then
            if self.type == "number" then
                if key:match("[0-9]") or key == '-' or key == '.' then
                    self.value = tostring(self.value) .. key
                end
            elseif self.type == "text" and key:match("[A-Za-z0-9]") and not table.contains(key_disable, key) then
                local str = tostring(self.value)
                local newKey = key

                if love.keyboard.isDown("shift") then
                    newKey = string.upper(key)
                end

                str = str .. newKey
                self.value = tostring(self.value) .. key
            end
        end
        self.__index.value = self.value
    end
end

function TextBox:mousepressed(x, y, button)
    if button == 1 and self:isInsideTextBox(x, y, 0, 0) then
        self.active = true
        self.__index.active = true
    elseif button == 1 then
        self.active = false
        self.__index.active = false
        TextBoxActive = false
    end
end

function TextBox:update(dt)
    if self.active then
        TextBoxActive = true
    end
end

function TextBox:draw()
    if self.active then
        love.graphics.setColor(50 / 255, 50 / 255, 50 / 255)
    else
        love.graphics.setColor(25 / 255, 25 / 255, 25 / 255)
    end
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.value, self.x, self.y, 0, self.textScale)
end

return TextBox