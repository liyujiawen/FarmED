Animation = {}

function Animation:load()
    self.anim8 = require 'anim8'
    self.player = {}
    self.player.x = 550
    self.player.y = 400
    self.player.speed = 1.5
    self.player.sprite = love.graphics.newImage("art/NewSprite.png")
    
    -- 计算每一帧的尺寸
    local frameWidth = self.player.sprite:getWidth()/3
    local frameHeight = math.floor(self.player.sprite:getHeight()/4)
    self.player.grid = self.anim8.newGrid(frameWidth, frameHeight, 
                                         self.player.sprite:getWidth(), 
                                         self.player.sprite:getHeight(), 2, 5)
    
    -- 计算缩放因子，使最终尺寸为64×64
    self.player.scaleX = 45 / frameWidth
    self.player.scaleY = 45 / frameHeight
    
    self.player.animations = {}
    self.player.animations.up = self.anim8.newAnimation(self.player.grid('1-3', 2), 0.2)
    self.player.animations.left = self.anim8.newAnimation(self.player.grid('1-3', 4), 0.2)
    self.player.animations.down = self.anim8.newAnimation(self.player.grid('1-3', 1), 0.2)
    self.player.animations.right = self.anim8.newAnimation(self.player.grid('1-3', 3), 0.2)
    self.player.anim = self.player.animations.left
end

function Animation:update(dt)
    local px, py = self.player.x, self.player.y
    local speed = self.player.speed
    local isMoving = false

    if love.keyboard.isDown("right") then
        if px + speed + 16 < love.graphics.getWidth() then
            self.player.x = px + speed
        end
        self.player.anim = self.player.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("left") then
        if px - speed > 0 then
            self.player.x = px - speed
        end
        self.player.anim = self.player.animations.left
        isMoving = true
    end

    if love.keyboard.isDown("down") then
        if py + speed + 24 < love.graphics.getHeight() then
            self.player.y = py + speed
        end
        self.player.anim = self.player.animations.down
        isMoving = true
    end

    if love.keyboard.isDown("up") then
        if py - speed > 0 then
            self.player.y = py - speed
        end
        self.player.anim = self.player.animations.up
        isMoving = true
    end

    if isMoving == false then
        self.player.anim:gotoFrame(1)
    end

    self.player.anim:update(dt)
end

function Animation:draw(scale)
    scale = scale or 1
    self.player.anim:draw(self.player.sprite, self.player.x, self.player.y, nil, 
                          self.player.scaleX * scale, self.player.scaleY * scale)
end

function Animation:keypressed(key, doorX, doorY, doorRadius, scale)
    scale = scale or 1
    if key == "space" then
        local dx = self.player.x - doorX
        local dy = self.player.y - doorY
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance <= doorRadius then
            return true
        end
    end
    return false
end

return Animation
