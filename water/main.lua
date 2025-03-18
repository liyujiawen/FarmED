function love.load()
    math.randomseed(os.time()) -- 初始化随机种子
    love.window.setTitle("FarmED - Welcome")
    love.graphics.setBackgroundColor(0.2, 0.6, 0.3) -- 绿色背景

    -- 加载背景图片
    background = love.graphics.newImage("art/background.png")
    land4 = love.graphics.newImage("art/land16.png")

    gamebackground = background

    -- 设置字体
    font = love.graphics.newFont(30)
    smallFont = love.graphics.newFont(20)
    tinyFont = love.graphics.newFont(15)

    -- 初始游戏状态
    gameState = "menu"
    isChoosingCrop = false -- 是否处于作物选择界面
    day = 1
    weather = "Sunny"

    -- 初始化水资源
    waterSystem = {
        currentWater = 100,
        maxWater = 100
    }

    -- 作物数据（修改后的水量消耗）
    crops = {
        {name = "Carrot (C)", cost = 5, key = "c"},
        {name = "Wheat (W)", cost = 10, key = "w"},
        {name = "Corn (M)", cost = 15, key = "m"},
        {name = "Banana (B)", cost = 20, key = "b"}
    }

    -- 存储雨滴
    raindrops = {}

    -- 初始化天气
    setNewDay()
end

-- **每天开始时设置天气**
function setNewDay()
    isChoosingCrop = false -- 进入新一天时关闭作物选择界面
    weather = math.random(1, 2) -- 1 = 晴天, 2 = 雨天

    if weather == 1 then
        waterSystem.currentWater = 80
        weatherText = "Sunny - Water: 80"
        raindrops = {} -- 清空雨滴
    else
        waterSystem.currentWater = 120
        weatherText = "Rainy - Water: 120"
    end

    print("New Day: " .. day .. " | " .. weatherText)
end

-- **作物浇水逻辑**
function waterCrop(crop)
    if waterSystem.currentWater >= crop.cost then
        waterSystem.currentWater = waterSystem.currentWater - crop.cost
        print("Watered " .. crop.name .. ", Remaining water: " .. waterSystem.currentWater)
        checkNextDay()
    else
        print("Not enough water to water " .. crop.name)
    end
end

-- **检测是否进入下一天**
function checkNextDay()
    if waterSystem.currentWater <= 0 then
        day = day + 1
        print("Water depleted. Moving to Day " .. day)
        setNewDay()
    end
end

function love.update(dt)
    if weather == 2 then -- 只有在雨天才更新雨滴
        updateRain(dt)
    end
end

-- **更新雨滴**
function updateRain(dt)
    -- 随机生成新的雨滴
    if math.random() < 0.2 then
        spawnRaindrop()
    end

    -- 移动现有雨滴
    for i = #raindrops, 1, -1 do
        local drop = raindrops[i]
        drop.y = drop.y + drop.speed * dt
        if drop.y > love.graphics.getHeight() then
            table.remove(raindrops, i) -- 移除超出屏幕的雨滴
        end
    end
end

-- **生成雨滴**
function spawnRaindrop()
    local raindrop = {
        x = math.random(0, love.graphics.getWidth()),
        y = -10,
        speed = math.random(200, 400)
    }
    table.insert(raindrops, raindrop)
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gamebackground, 0, 0, 0, 
        love.graphics.getWidth() / gamebackground:getWidth(), 
        love.graphics.getHeight() / gamebackground:getHeight())

    if gameState == "menu" then
        drawMenu()
    elseif gameState == "game" then
        drawGame()
    end
end

-- **绘制菜单界面**
function drawMenu()
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Welcome to FarmED", 0, 150, love.graphics.getWidth(), "center")
    love.graphics.setFont(smallFont)
    love.graphics.printf("Press ENTER to Start Game", 0, 300, love.graphics.getWidth(), "center")
end

-- **绘制游戏界面**
function drawGame()
    drawStatusBar()
    drawWaterUI()

    -- **绘制雨滴**
    if weather == 2 then
        drawRain()
    end

    -- 显示提示信息
    if not isChoosingCrop then
        love.graphics.print("Press [E] to select a crop for watering", 100, 150)
    else
        drawCropSelection()
    end
end

-- **绘制雨滴**
function drawRain()
    love.graphics.setColor(0.5, 0.5, 1) -- 设置雨滴颜色
    for _, drop in ipairs(raindrops) do
        love.graphics.rectangle("fill", drop.x, drop.y, 2, 10)
    end
    love.graphics.setColor(1, 1, 1) -- 恢复默认颜色
end

-- **绘制水资源 UI**
function drawWaterUI()
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", 50, 50, (waterSystem.currentWater / waterSystem.maxWater) * 200, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 50, 50, 200, 20)
    love.graphics.print("Water: " .. math.floor(waterSystem.currentWater) .. " / " .. waterSystem.maxWater, 60, 75)
    love.graphics.print(weatherText, 50, 100)
end

-- **绘制状态栏**
function drawStatusBar()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 50)

    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1)

    love.graphics.printf("Day " .. day, 10, 15, 200, "left")
    love.graphics.printf("Water: " .. waterSystem.currentWater, 220, 15, 200, "left")
    love.graphics.printf("Weather: " .. weatherText, 420, 15, 200, "left")
end

-- **绘制作物选择 UI**
function drawCropSelection()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Select a crop to water:", 100, 200)
    for i, crop in ipairs(crops) do
        love.graphics.print("[" .. crop.key:upper() .. "] " .. crop.name .. " - Uses " .. crop.cost .. " water", 100, 220 + i * 20)
    end
    love.graphics.print("[Q] Exit Crop Selection", 100, 320) -- 新增退出选项
end

-- **按键交互**
function love.keypressed(key)
    if key == "return" then -- 按下 Enter 进入游戏
        gameState = "game"
        gamebackground = land4
    elseif key == "e" and gameState == "game" then
        isChoosingCrop = true -- 进入作物选择界面
    elseif key == "q" and isChoosingCrop then
        isChoosingCrop = false -- 按 Q 退出作物选择界面
    elseif isChoosingCrop then
        for _, crop in ipairs(crops) do
            if key == crop.key then
                waterCrop(crop) -- 允许连续浇水
                break
            end
        end
    end
end
