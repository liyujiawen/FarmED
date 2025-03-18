function love.load()
    love.window.setTitle("FarmED - Farming Game")
    love.graphics.setBackgroundColor(0.2, 0.6, 0.3)
    background = love.graphics.newImage("arts/background1.png")
    font = love.graphics.newFont(30)
    smallFont = love.graphics.newFont(20)
    gameState = "menu"
    
    -- 农场数据
    farm = {money = 100, land = 1, crops = {}}
    
    -- 定义不同的作物类型
    cropTypes = {
        {name = "Wheat", growTime = 5, price = 10},
        {name = "Corn", growTime = 8, price = 20},
        {name = "Carrot", growTime = 6, price = 15}
    }
end

function love.update(dt)
    -- 这里可以触发画面刷新，确保更新可见
    for _, crop in ipairs(farm.crops) do
        if not crop.harvested then
            crop.timer = crop.timer - dt
            if crop.timer <= 0 then
                crop.harvested = true
            end
        end
    end
end

function love.draw()
    love.graphics.clear()  -- 清空屏幕，确保更新可见
    love.graphics.draw(background, 0, 0, 0, love.graphics.getWidth() / background:getWidth(), love.graphics.getHeight() / background:getHeight())
    if gameState == "menu" then
        love.graphics.setFont(font)
        love.graphics.printf("Welcome to FarmED", 0, 200, love.graphics.getWidth(), "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Start", 0, 300, love.graphics.getWidth(), "center")
    elseif gameState == "game" then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Money: $" .. farm.money, 10, 10, 200, "left")
        love.graphics.printf("Land: " .. farm.land, 10, 40, 200, "left")
        
        -- 绘制作物信息
        for i, crop in ipairs(farm.crops) do
            love.graphics.printf(crop.name .. (crop.harvested and " (Ready!)" or " Growing..."), 10, 70 + i * 20, 300, "left")
        end
    end
end

function love.keypressed(key)
    if key == "return" then
        gameState = "game"
    elseif key == "l" and gameState == "game" then
        if farm.money >= 50 then
            farm.money = farm.money - 50
            farm.land = farm.land + 1
        end
    elseif key == "s" and gameState == "game" then
        if #farm.crops < farm.land then
            local cropType = cropTypes[math.random(#cropTypes)]
            table.insert(farm.crops, {name = cropType.name, timer = cropType.growTime, price = cropType.price, harvested = false})
        end
    elseif key == "h" and gameState == "game" then
        for i = #farm.crops, 1, -1 do
            if farm.crops[i].harvested then
                farm.money = farm.money + farm.crops[i].price
                table.remove(farm.crops, i)
            end
        end
    end
end
