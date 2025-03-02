function love.load()
    love.window.setTitle("FarmED - Welcome")
    love.graphics.setBackgroundColor(0.2, 0.6, 0.3) -- 绿色背景

    -- 加载背景图片
    background = love.graphics.newImage("arts/background1.png")

    font = love.graphics.newFont(30) -- 设置字体大小
    smallFont = love.graphics.newFont(20)
    gameState = "menu" -- 初始状态为菜单界面
end

function love.update(dt)
    -- 这里暂时没有需要更新的内容
end

function love.draw()
    -- 先绘制背景
    love.graphics.draw(background, 0, 0, 0, 
        love.graphics.getWidth() / background:getWidth(), 
        love.graphics.getHeight() / background:getHeight())

    if gameState == "menu" then
        love.graphics.setFont(font)
        love.graphics.printf("Welcome to FarmED", 0, 200, love.graphics.getWidth(), "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Start", 0, 300, love.graphics.getWidth(), "center")
    elseif gameState == "game" then
        love.graphics.printf("Game Started! (Placeholder Screen)", 0, 250, love.graphics.getWidth(), "center")
    end
end

function love.keypressed(key)
    if key == "return" then -- 按下 Enter 键
        gameState = "game" -- 切换到游戏界面
    end
end
