local TextBox = require('textbox')
local Button = require('button')
require('util')

function love.load()
    Pendulums = {}
    Mouse = {}
    Points = {}
    Mouse.x = love.mouse.getX()
    Mouse.y = love.mouse.getY()

    Callmath = love.audio.newSource("fakely happy.wav", "static")
    Callmath:setLooping(true)
    Callmath:setVolume(0.25)
    Callmath:play()
    CallmathPlaying = true

    Scale = 1
    FrictionRate = 0
    PendulumCircleRadius = 10
    AlreadyGrabbed = false
    Paused = false
    IndexGrabbed = 0

    GravityTextBox = TextBox.create(10, love.graphics.getHeight() - 40, 100, 30, 2, 1, "number")
    FrictionTextBox = TextBox.create(120, love.graphics.getHeight() - 40, 100, 30, 2, 0, "number")
    ApplyButton = Button.create(230, love.graphics.getHeight() - 40, 100, 30, 2, "text", "aplicaa")

    Pendulums[1] = {}
    Pendulums[1].angle = 0
    Pendulums[1].len = 100
    Pendulums[1].angleA = 0
    Pendulums[1].angleV = 0
    Pendulums[1].origin = {}
    Pendulums[1].origin.x = love.graphics.getWidth() / 2 / Scale
    Pendulums[1].origin.y = 0
    Pendulums[1].force = 0
    Pendulums[1].grabbed = false
    Pendulums[1].voardo = calculatePositionFromAngle(Pendulums[1].angle, Pendulums[1].len, Pendulums[1].origin)

    -- Pendulums[2] = {}
    -- Pendulums[2].angle = -math.pi + 1/1000
    -- Pendulums[2].len = 100
    -- Pendulums[2].angleA = 0
    -- Pendulums[2].angleV = 0
    -- Pendulums[2].origin = {}
    -- Pendulums[2].origin.x = Pendulums[1].voardo.x
    -- Pendulums[2].origin.y = Pendulums[1].voardo.y
    -- Pendulums[2].force = 0
    -- Pendulums[2].grabbed = false
    -- Pendulums[2].voardo = calculatePositionFromAngle(Pendulums[2].angle, Pendulums[2].len, Pendulums[2].origin)
end

function love.keypressed(key)
    if TextBoxActive == false then
        if key == 'space' then
            Paused = not Paused
        elseif key == '=' then
            Pendulums[table.getn(Pendulums) + 1] = {}
            Pendulums[table.getn(Pendulums)].angle = 0
            Pendulums[table.getn(Pendulums)].len = 100
            Pendulums[table.getn(Pendulums)].angleA = 0
            Pendulums[table.getn(Pendulums)].angleV = 0
            Pendulums[table.getn(Pendulums)].force = 0
            Pendulums[table.getn(Pendulums)].grabbed = false
            Pendulums[table.getn(Pendulums)].origin = Pendulums[table.getn(Pendulums) - 1].voardo
            Pendulums[table.getn(Pendulums)].voardo = calculatePositionFromAngle(Pendulums[table.getn(Pendulums)].angle, Pendulums[table.getn(Pendulums)].len, Pendulums[table.getn(Pendulums)].origin)
        elseif key == '-' and table.getn(Pendulums) > 1 then
            table.remove(Pendulums, table.getn(Pendulums))
        elseif key == 'm' then
            if CallmathPlaying then
                Callmath:stop()
                CallmathPlaying = false
            else
                Callmath:play()
                CallmathPlaying = true
            end
        elseif key == 'r' then
            Pendulums = {}
            Pendulums[1] = {}
            Pendulums[1].angle = 0
            Pendulums[1].len = 100
            Pendulums[1].angleA = 0
            Pendulums[1].angleV = 0
            Pendulums[1].origin = {}
            Pendulums[1].origin.x = love.graphics.getWidth() / 2 / Scale
            Pendulums[1].origin.y = 0
            Pendulums[1].force = 0
            Pendulums[1].grabbed = false
            Pendulums[1].voardo = calculatePositionFromAngle(Pendulums[1].angle, Pendulums[1].len, Pendulums[1].origin)
            Points = {}
        end
    end

    GravityTextBox:keypressed(key)
    FrictionTextBox:keypressed(key)
end

function arePendulumnsColliding(i, j)
    local distance = calculateDistance(Pendulums[i].voardo.x, Pendulums[i].voardo.y, Pendulums[j].voardo.x, Pendulums[j].voardo.y)
    return distance.x <= PendulumCircleRadius * Scale and distance.y <= PendulumCircleRadius * Scale
end

function love.mousepressed(x, y, button)
    if button == 2 and not TextBoxActive then
        if not AlreadyGrabbed then
            for i = 1, table.getn(Pendulums) do
                Pendulums[i].voardo = calculatePositionFromAngle(Pendulums[i].angle, Pendulums[i].len, Pendulums[i].origin)
                local distance = calculateDistance(Mouse.x/Scale, Mouse.y/Scale, Pendulums[i].voardo.x, Pendulums[i].voardo.y)
                if distance.x <= PendulumCircleRadius*Scale and distance.y <= PendulumCircleRadius*Scale then
                    -- print(calculateDistance(Mouse.x/Scale, Mouse.y/Scale, Pendulums[i].voardo.x, Pendulums[i].voardo.y), "MouseX: " .. Mouse.x, "MouseY: " .. Mouse.y, "VoardoX: " .. Pendulums[i].voardo.x, "VoardoY: " .. Pendulums[i].voardo.y)
                    IndexGrabbed = i
                    Pendulums[IndexGrabbed].voardo = Mouse
                    Pendulums[IndexGrabbed].len = hipotenuse({ x = Mouse.x - Pendulums[IndexGrabbed].origin.x, y = Mouse.y - Pendulums[IndexGrabbed].origin.y })
                    Pendulums[IndexGrabbed].angle = calculateAngleFromPosition(Pendulums[IndexGrabbed].voardo, Pendulums[IndexGrabbed].len, Pendulums[IndexGrabbed].origin)
                    Pendulums[IndexGrabbed].angleA = 0
                    Pendulums[IndexGrabbed].angleV = 0
                    Pendulums[i].grabbed = true
                    AlreadyGrabbed = true
                    break
                end
            end
        else
            Pendulums[IndexGrabbed].grabbed = false
            AlreadyGrabbed = false
            IndexGrabbed = 0
        end
    end

    GravityTextBox:mousepressed(x, y, button)
    FrictionTextBox:mousepressed(x, y, button)
    ApplyButton:mousepressed(x, y, button)
end

function love.wheelmoved( dx, dy )
    if not TextBoxActive and Scale > 0.1 then
        Scale = Scale * (1 + dy/2)
        for i = 1, table.getn(Points) do
            Points[i].x = Points[i].x - Pendulums[1].origin.x + (love.graphics.getWidth() - Mouse.x) / (love.graphics.getWidth() / Pendulums[1].origin.x)
            Points[i].y = Points[i].y - Pendulums[1].origin.y + (love.graphics.getHeight() - Mouse.y) / (love.graphics.getHeight() / Pendulums[1].origin.y)
        end
        Pendulums[1].origin.x = (love.graphics.getWidth() - Mouse.x) / (love.graphics.getWidth() / Pendulums[1].origin.x)
        Pendulums[1].origin.y = (love.graphics.getHeight() - Mouse.y) / (love.graphics.getHeight() / Pendulums[1].origin.y) 
    end
end

function love.update(dt)
    if love.mouse.isDown(1) and not TextBoxActive then
        Pendulums[1].origin.y = Pendulums[1].origin.y + (love.mouse.getY() - Mouse.y) / Scale
        Pendulums[1].origin.x = Pendulums[1].origin.x + (love.mouse.getX() - Mouse.x) / Scale

        for i = 1, table.getn(Points) do
            Points[i].x = Points[i].x + (love.mouse.getX() - Mouse.x) / Scale
            Points[i].y = Points[i].y + (love.mouse.getY() - Mouse.y) / Scale
        end
    end

    Mouse.x = love.mouse.getX()
    Mouse.y = love.mouse.getY()

    GravityTextBox.y = love.graphics.getHeight() - 40
    GravityTextBox.__index.y = love.graphics.getHeight() - 40
    ApplyButton.y = love.graphics.getHeight() - 40
    ApplyButton.__index.y = love.graphics.getHeight() - 40
    FrictionTextBox.y = love.graphics.getHeight() - 40
    FrictionTextBox.__index.y = love.graphics.getHeight() - 40

    if ApplyButton.active then
        local temp = tonumber(GravityTextBox.value) or Gravity
        if not (temp == -Gravity) then
            Gravity = -temp
        end

        FrictionRate = tonumber(FrictionTextBox.value) or FrictionRate
    end

    if AlreadyGrabbed then
        Pendulums[IndexGrabbed].voardo = { x = Mouse.x / Scale, y = Mouse.y / Scale}
        Pendulums[IndexGrabbed].len = hipotenuse({ x = Mouse.x / Scale - Pendulums[IndexGrabbed].origin.x, y = Mouse.y / Scale - Pendulums[IndexGrabbed].origin.y })
        Pendulums[IndexGrabbed].angle = calculateAngleFromPosition(Pendulums[IndexGrabbed].voardo, Pendulums[IndexGrabbed].len, Pendulums[IndexGrabbed].origin)
        -- Pendulums[IndexGrabbed].voardo = calculatePositionFromAngle(Pendulums[IndexGrabbed].angle, Pendulums[IndexGrabbed].len, Pendulums[IndexGrabbed].origin)
    end

    if not Paused then
        if Pendulums[1].grabbed == false and IndexGrabbed < 1 then
            local force = calculateForceFromAngle(Pendulums[1].angle)
            Pendulums[1].angleA = force / Pendulums[1].len
            Pendulums[1].angleV = Pendulums[1].angleV + Pendulums[1].angleA
            Pendulums[1].angle = Pendulums[1].angle + Pendulums[1].angleV

            if table.getn(Pendulums) > 1 then
                Pendulums[2].angleV = Pendulums[2].angleV + Pendulums[1].angleV * FrictionRate
            end
            Pendulums[1].angleV = Pendulums[1].angleV * (1-FrictionRate)
        end
    end

    for i = 1, table.getn(Pendulums) do
        if (i > 1) then
            Pendulums[i].origin = Pendulums[i - 1].voardo
            if (Pendulums[i].grabbed == false and IndexGrabbed < i and i > 1) then
                if not Paused then
                    Pendulums[i].force = calculateForceFromAngle(Pendulums[i].angle)
                    Pendulums[i].angleA = Pendulums[i].force / Pendulums[i].len
                    Pendulums[i].angleV = Pendulums[i].angleV + Pendulums[i].angleA
                    local initalAngle = Pendulums[i].angle
                    Pendulums[i].angle = Pendulums[i].angle + Pendulums[i].angleV
                    for j = 1, table.getn(Pendulums) do
                        if not (j == i) then
                            if arePendulumnsColliding(i, j) then
                                local iInitialVelocity = Pendulums[i].angleV
                                local iInitialAcceleration = Pendulums[i].angleA
                                Pendulums[i].angleV = Pendulums[j].angleV
                                Pendulums[j].angleV = iInitialVelocity
                            end
                        end
                    end

                    if (i < table.getn(Pendulums)) then
                        Pendulums[i+1].angleV = Pendulums[i+1].angleV + Pendulums[i].angleV * FrictionRate
                    end
                    Pendulums[i].angleV = Pendulums[i].angleV * (1-FrictionRate)
                end
            end
        end

        Pendulums[i].voardo = calculatePositionFromAngle(Pendulums[i].angle, Pendulums[i].len, Pendulums[i].origin)
    end

    if (table.getn(Points) == 10000) then
        table.remove(Points, 1)
        for i = 2, table.getn(Points) + 1 do
            Points[i-1] = Points[i]
        end
    end
    Points[table.getn(Points) + 1] = Pendulums[table.getn(Pendulums)].voardo
    GravityTextBox:update(dt)
    FrictionTextBox:update(dt)
    ApplyButton:update(dt)
end

function love.draw()
    GravityTextBox:draw()
    FrictionTextBox:draw()
    ApplyButton:draw()
    love.graphics.push()
    love.graphics.scale(Scale, Scale)
    love.graphics.setColor(1, 1, 1)
    for i = 1, table.getn(Pendulums) do
        love.graphics.line(Pendulums[i].origin.x, Pendulums[i].origin.y, Pendulums[i].voardo.x, Pendulums[i].voardo.y)
        love.graphics.circle('fill', Pendulums[i].voardo.x, Pendulums[i].voardo.y, PendulumCircleRadius)
    end
    for i = 1, table.getn(Points) do
        love.graphics.setColor(1, 1, 1, 0.1)
        love.graphics.circle('fill', Points[i].x, Points[i].y, 5)
    end
    love.graphics.pop()
end
