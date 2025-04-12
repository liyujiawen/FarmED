function love.load()
    love.window.setTitle("FarmED - Welcome")
    love.graphics.setBackgroundColor(0.2, 0.6, 0.3) -- 绿色背景

    waterMode = false  -- 是否处于浇水模式
    weatherTypes = {"Sunny", "Rainy"}  -- 可能的天气

    -- 加载背景图片
    background = love.graphics.newImage("art/background.png")
    land4 = love.graphics.newImage("art/land16.png")

    -- 加载作物图片
    cropImages = {
        Cabbage_seed = love.graphics.newImage("art/cabbage.png"),
        Beans_seed = love.graphics.newImage("art/beans.png"),
        Maize_seed = love.graphics.newImage("art/maize.png"),
        Sweet_Potato_seed = love.graphics.newImage("art/sweetpotato.png")
    }

    gamebackground = background

    -- 加载角色图片和属性
    characterData = {
        img = love.graphics.newImage("art/character.png"),
        x = 350,
        y = 250,
        speed = 120,
        width = 64,
        height = 64,
        scale = 0.0625,  -- 64/1024 = 0.0625
        direction = "down",
        moving = false,
        minX = 50,
        maxX = love.graphics.getWidth() - 114,
        minY = 70,
        maxY = love.graphics.getHeight() - 130
    }

    -- 设置字体
    font = love.graphics.newFont(30)
    smallFont = love.graphics.newFont(20)
    tinyFont = love.graphics.newFont(10)
    
    -- 初始游戏状态
    gameState = "menu"
    previousGameState = nil  -- 添加记录前一个状态的变量
    gameLevel = 1

    -- 厨房相关变量
    kitchenIconX = 650  -- 厨房图标X坐标
    kitchenIconY = 150  -- 厨房图标Y坐标
    showKitchenPopup = false -- 是否显示厨房弹窗
    nearKitchen = false -- 是否靠近厨房

    -- 厨房菜单数据
    kitchenMenu = {
        dailyMeal = "Vegetable Soup"  -- 今日午餐，默认值
    }

    -- 简化的菜单
    possibleMeals = {
        "Vegetable Soup",   -- 蔬菜汤
        "Corn Porridge",    -- 玉米粥
        "Roasted Sweet Potato",  -- 烤红薯
        "Bean Stew",        -- 豆子炖菜
    }
    
    
    levelRequirements = {
        {4, 1},  -- 第一关：4种作物各1个
        {4, 3},  -- 第二关：4种作物各3个
        {4, 5}   -- 第三关：4种作物各5个
    }
    
    levelPopupText = ""     -- 关卡弹窗文本

    -- 游戏状态变量
    day = 1
    money = 100
    actionPoints = 20 -- 第一阶段有20个行动点
    -- 交互提示相关变量
    interactionTip = ""  -- 当前显示的交互提示
    showInteractionTip = false  -- 是否显示交互提示
    nearSeedBar = false  -- 是否靠近种子栏
    nearPlot = false  -- 是否靠近地块
    nearPlotX = 0  -- 靠近的地块X坐标
    nearPlotY = 0  -- 靠近的地块Y坐标
    weather = weatherTypes[math.random(1, #weatherTypes)] -- 随机天气
    
    if weather == "Sunny" then
        water = 80
    elseif weather == "Rainy" then
        water = 100
        maxWater = 100
    end
    
    -- 农场网格（第一阶段4格）
    gridSize = 4 -- 4x4 的网格
    grid = {}
    for x = 1, gridSize do
        grid[x] = {}
        for y = 1, gridSize do
            -- 左上角四格
            if x >= 1 and x <= 2 and y >= 1 and y <= 2 then
                grid[x][y] = {
                    status = "empty",-- 初始状态为空地
                    wateringLimit = 0,  -- 每天浇水上限
                    dailyWateringCount = 0  -- 当天已浇水次数
                }
            else
                grid[x][y] = {
                    status = "locked",  -- 新增状态：锁定
                    wateringLimit = 0,
                    dailyWateringCount = 0
                }
            end
        end
    end 
    
    -- 基础作物数据（只添加UI，不实现功能）
    crops = {
        Cabbage_seed = {name = "Cabbage", growthTime = 2, waterNeed = 4, value = 15, dailyWateringLimit = 4},
        Beans_seed = {name = "Beans", growthTime = 3, waterNeed = 2, value = 30, dailyWateringLimit = 2},
        Maize_seed = {name = "Maize", growthTime = 4, waterNeed = 6, value = 50, dailyWateringLimit = 6},
        Sweet_Potato_seed = {name = "Sweet Potato", growthTime = 5, waterNeed = 8, value = 70, dailyWateringLimit = 8}
    }
    
    selectedSeed = "Cabbage_seed" -- 默认选择卷心菜种子

    -- 玩家拥有的种子和资金（从shop.lua中继承）
    player = {
        kes = 10000.00,
        inventory = {
            Cabbage_seed = 5,
            Sweet_Potato_seed = 3,
            Maize_seed = 0,
            Beans_seed = 0,
            Cabbage = 0,
            Sweet_Potato = 0,
            Maize = 0,
            Beans = 0
        }
    }
    
    -- 商品数据（从shop.lua中继承）
    shopItems = {
        { name = "Cabbage_seed", basePrice = 50.00 },
        { name = "Sweet_Potato_seed",  basePrice = 80.00 }, -- 修正拼写错误
        { name = "Maize_seed",   basePrice = 70.00 },
        { name = "Beans_seed", basePrice = 120.00 },
        { name = "Cabbage", basePrice = 100.00 },
        { name = "Sweet_Potato",  basePrice = 150.00 },
        { name = "Maize",   basePrice = 130.00 },
        { name = "Beans", basePrice = 250.00 }
    }
    
    -- 动态按钮位置（从shop.lua中继承）
    buttonArea = {
        x = 0, width = 320,  -- 总宽度=4按钮*80间距
        buttons = {
            {text = "-5", offset = 0},
            {text = "-1", offset = 70},
            {text = "+1", offset = 140},
            {text = "+5", offset = 210}
        }
    }
    selectedItem = 1
    quantity = 1
    
    -- 弹窗系统变量
    showDayPopup = false     -- 是否显示天数弹窗
    showLevelPopup = false  -- 是否显示关卡弹窗
    showWinPopup = false     -- 是否显示通关弹窗
    popupTimer = 0           -- 弹窗计时器
    popupDuration = 2        -- 弹窗持续时间(秒)
    newDayNumber = 1         -- 要在弹窗中显示的天数
    popupAlpha = 0           -- 用于淡入淡出效果
    popupFadeIn = true       -- 是否处于淡入阶段

    -- 雨滴粒子初始化
    raindrops = {}
    for i = 1, 100 do
        table.insert(raindrops, {
            x = math.random(0, love.graphics.getWidth()),
            y = math.random(0, love.graphics.getHeight()),
            speed = math.random(200, 400)
        })
    end

    -- 如果关卡弹窗激活，在最上层绘制
    if showLevelPopup then
        drawLevelPopup()
    end
end

function love.update(dt)
    -- 计算居中位置（从shop.lua中继承）
    local screenWidth = love.graphics.getWidth()
    buttonArea.x = (screenWidth - buttonArea.width) / 2

    -- Character movement logic - ADD THIS PART
    if gameState == "game" and not waterMode and not showDayPopup and not showLevelPopup and not showWinPopup then
        local dx, dy = 0, 0
        characterData.moving = false
        
        -- Check WASD keys
        if love.keyboard.isDown("up") then
            dy = -characterData.speed * dt
            characterData.direction = "up"
            characterData.moving = true
        end
        if love.keyboard.isDown("down") then
            dy = characterData.speed * dt
            characterData.direction = "down"
            characterData.moving = true
        end
        if love.keyboard.isDown("left") then
            dx = -characterData.speed * dt
            characterData.direction = "left"
            characterData.moving = true
        end
        if love.keyboard.isDown("right") then
            dx = characterData.speed * dt
            characterData.direction = "right"
            characterData.moving = true
        end
        
        -- Apply movement with boundaries
        if characterData.moving then
            characterData.x = math.max(characterData.minX, math.min(characterData.x + dx, characterData.maxX))
            characterData.y = math.max(characterData.minY, math.min(characterData.y + dy, characterData.maxY))
        end
    end
-- 检查是否靠近种子栏
        if gameState == "game" and not showDayPopup and not showLevelPopup and not showWinPopup then

        
        local inventoryY = love.graphics.getHeight() - 90  -- 种子栏的Y坐标
        nearSeedBar = (characterData.y > inventoryY - 50 and characterData.y < inventoryY + 30)
        
        -- 检查是否靠近地块
        local gridStartX = 250
        local gridStartY = 245
        local cellSize = 40
        local padding = 35
        
        nearPlot = false  -- 重置靠近地块状态
        
        for gridX = 1, gridSize do
            for gridY = 1, gridSize do
                local cellX = gridStartX + (gridX-1) * (cellSize + padding)
                local cellY = gridStartY + (gridY-1) * (cellSize + padding)
                
                local distance = math.sqrt((characterData.x - (cellX + cellSize/2))^2 + 
                                          (characterData.y - (cellY + cellSize/2))^2)
                
                if distance < 30 then  -- 如果角色距离地块中心小于50像素
                    nearPlot = true
                    nearPlotX = gridX
                    nearPlotY = gridY
                    break
                end
            end
            if nearPlot then break end
        end
        
        -- 检查是否靠近厨房图标
        local kitchenDistance = math.sqrt((characterData.x - kitchenIconX)^2 + 
                                         (characterData.y - kitchenIconY)^2)
        nearKitchen = (kitchenDistance < 50)
        
        -- 更新交互提示
        if nearKitchen then
            interactionTip = "Press K to view Kitchen Menu"
            showInteractionTip = true
        elseif nearSeedBar then
            interactionTip = "Press space to pick up seeds"
            showInteractionTip = true
        elseif nearPlot then
            local plot = grid[nearPlotX][nearPlotY]
            
            if plot.status == "empty" then
                interactionTip = "Press the space to plant"
                showInteractionTip = true
            elseif plot.status == "planted" then
                interactionTip = "Press F to water"
                showInteractionTip = true
            elseif plot.status == "matured" then
                interactionTip = "Press space to harvest"
                showInteractionTip = true
            elseif plot.status == "locked" then
                interactionTip = "This lot is unlocked"
                showInteractionTip = true
            else
                showInteractionTip = false
            end
        else
            showInteractionTip = false
        end
    end


    -- 处理 Day 弹窗计时和淡入淡出效果
    if showDayPopup then
        popupTimer = popupTimer + dt

        if popupTimer < 0.5 and popupFadeIn then
            popupAlpha = popupTimer / 0.5
        elseif popupTimer > popupDuration - 0.5 and not popupFadeIn then
            popupAlpha = (popupDuration - popupTimer) / 0.5
        else
            popupAlpha = 1
        end

        if popupTimer >= popupDuration and not popupFadeIn then
            showDayPopup = false
            popupTimer = 0
        end
    end

    -- 处理关卡弹窗计时和淡入淡出效果
    if showLevelPopup then
        popupTimer = popupTimer + dt

        if popupTimer < 0.5 and popupFadeIn then
            popupAlpha = popupTimer / 0.5
        elseif popupTimer > popupDuration - 0.5 and not popupFadeIn then
            popupAlpha = (popupDuration - popupTimer) / 0.5
        else
            popupAlpha = 1
        end

        if popupTimer >= popupDuration and not popupFadeIn then
            showLevelPopup = false
            popupTimer = 0
        end
    end

    -- 处理通关弹窗计时和淡入淡出效果
    if showWinPopup then
        popupTimer = popupTimer + dt

        if popupTimer < 0.5 and popupFadeIn then
            popupAlpha = popupTimer / 0.5
        elseif popupTimer > popupDuration - 0.5 and not popupFadeIn then
            popupAlpha = (popupDuration - popupTimer) / 0.5
        else
            popupAlpha = 1
        end

        if popupTimer >= popupDuration and not popupFadeIn then
            showWinPopup = false
            popupTimer = 0
        end
    end

    -- 雨滴动画逻辑（Rainy 天气）
    if weather == "Rainy" and raindrops then
        for _, drop in ipairs(raindrops) do
            drop.y = drop.y + drop.speed * dt
            if drop.y > love.graphics.getHeight() then
                drop.y = 0
                drop.x = math.random(0, love.graphics.getWidth())
            end
        end
    end
end



function love.draw()
    -- 先绘制背景
    love.graphics.setColor(1, 1, 1) -- 确保背景图片颜色正确
    love.graphics.draw(gamebackground, 0, 0, 0, 
    love.graphics.getWidth() / gamebackground:getWidth(), 
    love.graphics.getHeight() / gamebackground:getHeight())

    if gameState == "menu" then
        drawMenu()
    elseif gameState == "game" then
        if waterMode then
            drawWateringMode() -- 进入浇水界面
        else
            drawGame()
            
            if gameState == "game" and not waterMode and showInteractionTip then
                drawInteractionTip()
            end
        end
    elseif gameState == "shop" then
        drawTransactionInterface("SHOP", true)
    elseif gameState == "warehouse" then
        drawTransactionInterface("WAREHOUSE", false)
    elseif gameState == "help" then
        drawHelp()
    end
    
    -- 在最上层绘制厨房弹窗
    if showKitchenPopup then
        drawKitchenPopup()
    end
        
    -- 如果弹窗激活，在最上层绘制弹窗
    if showDayPopup then
        drawDayPopup()
    end
    -- 如果关卡弹窗激活，在最上层绘制
    if showLevelPopup then
    drawLevelPopup()
    end
    -- 如果通关弹窗激活，在最上层绘制
    if showWinPopup then
        drawWinPopup()
    end

    -- 如果是雨天则绘制雨滴
    if gameState == "game" and weather == "Rainy" then
        love.graphics.setColor(1, 1, 1, 0.4)
        for _, drop in ipairs(raindrops) do
            love.graphics.line(drop.x, drop.y, drop.x, drop.y + 10)
        end
    end
    -- 雨天整体暗色滤镜
    if gameState == "game" and weather == "Rainy" then
        love.graphics.setColor(0, 0, 0, 0.4)  -- 半透明黑色遮罩
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end  

--     -- 🌟 画出每颗已种植作物的可浇水范围（半透明圆）
-- for gridX = 1, gridSize do
--     for gridY = 1, gridSize do
--         local plot = grid[gridX][gridY]
--         if plot.status == "planted" then
--             local gridStartX = 250
--             local gridStartY = 245
--             local cellSize = 40
--             local padding = 35

--             local centerX = gridStartX + (gridX - 1) * (cellSize + padding) + cellSize / 2
--             local centerY = gridStartY + (gridY - 1) * (cellSize + padding) + cellSize / 2

--             love.graphics.setColor(1, 1, 1, 0.08) -- ✅ 半透明白色（A 越小越透明）
--             love.graphics.circle("fill", centerX, centerY, 30) -- ✅ 30 为你设定的 F 键浇水判定范围
--             love.graphics.setColor(1, 1, 1, 1) -- 恢复颜色以避免影响其他元素
--         end
--     end
-- end

end


function drawMenu()
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Welcome to FarmED", 0, 150, love.graphics.getWidth(), "center")
    
    love.graphics.setFont(smallFont)
    love.graphics.printf("Sustainable Agriculture Education Game", 0, 220, love.graphics.getWidth(), "center")
    
    -- 菜单选项
    love.graphics.setColor(1, 0.9, 0.7)
    love.graphics.printf("Press ENTER to Start Game", 0, 300, love.graphics.getWidth(), "center")
    love.graphics.printf("Press H for Help", 0, 340, love.graphics.getWidth(), "center")
    
    -- 版本信息
    love.graphics.setFont(tinyFont)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Current Version: Stage 1 - Basic Farming", 0, 450, love.graphics.getWidth(), "center")
end

function drawGame()
    -- 顶部状态栏
    drawStatusBar()
    
    -- 农场网格
    drawGrid()

    -- Draw character
    drawCharacter()

     -- 绘制厨房图标（简单的方块）
     love.graphics.setColor(0.9, 0.8, 0.5) -- 淡黄色厨房图标
     love.graphics.rectangle("fill", kitchenIconX, kitchenIconY, 40, 40)
     love.graphics.setColor(0.6, 0.5, 0.3) -- 棕色边框
     love.graphics.rectangle("line", kitchenIconX, kitchenIconY, 40, 40)
     love.graphics.setFont(tinyFont)
     love.graphics.setColor(0.3, 0.2, 0.1) -- 深棕色文字
     love.graphics.printf("Kitchen", kitchenIconX, kitchenIconY + 15, 40, "center")
    
    -- 底部控制栏
    drawControlBar()
end

function drawStatusBar()
    -- 增加状态栏高度到50像素，使其更宽敞
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 70)
    
    -- 设置字体和颜色
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1)
    
    -- 计算每个状态项的宽度
    local screenWidth = love.graphics.getWidth()
    local itemWidth = screenWidth / 5
    
    -- 均匀分布五个状态项，使用居中对齐
    love.graphics.printf("Day " .. day, 0, 15, itemWidth, "center")
    love.graphics.printf("Balance: " .. formatKES(player.kes), itemWidth, 15, itemWidth, "center")
    love.graphics.printf("Action Points: " .. actionPoints .. "/20", itemWidth*2, 15, itemWidth, "center")
    love.graphics.printf("Weather: " .. weather, itemWidth*3, 15, itemWidth, "center")
    love.graphics.printf("Water: " .. water, itemWidth*4, 15, itemWidth, "center")
end

function drawGrid()
    local gridStartX = 250
    local gridStartY = 245
    local cellSize = 40 
    local padding = 35
    local gridSize = 4  

    love.graphics.setFont(tinyFont)
    
    -- 绘制统一的提示信息(在格子上方)
    --love.graphics.setColor(1, 1, 1)
    --love.graphics.printf("Click an empty plot to plant", gridStartX, gridStartY - 35, gridSize * (cellSize + padding), "center")

    for x = 1, gridSize do
        for y = 1, gridSize do
            local cellX = gridStartX + (x-1) * (cellSize + padding)
            local cellY = gridStartY + (y-1) * (cellSize + padding)
            
            -- 绘制土地格子
            if grid[x][y].status == "empty" then
                love.graphics.setColor(0.6, 0.4, 0.2)  -- 可种植的土地
            elseif grid[x][y].status == "locked" then
                love.graphics.setColor(0.3, 0.3, 0.3)  -- 锁定的土地，显示为深灰色
            else
                love.graphics.setColor(0.6, 0.4, 0.2)
            end
            
            love.graphics.rectangle("fill", cellX, cellY, cellSize, cellSize)
            love.graphics.setColor(0.3, 0.2, 0.1)
            love.graphics.rectangle("line", cellX, cellY, cellSize, cellSize)
            
            -- 作物和进度条绘制
            if grid[x][y].status == "planted" or grid[x][y].status == "matured" then  
                local plot = grid[x][y]
                local cropKey = plot.crop

                -- 绘制作物图片
                if cropKey and cropImages[cropKey] then
                    local img = cropImages[cropKey]
                    local imgScale = (cellSize * 1.2) / math.max(img:getWidth(), img:getHeight())
                    local drawX = cellX + (cellSize - img:getWidth() * imgScale) / 2
                    local drawY = cellY + (cellSize - img:getHeight() * imgScale) / 2
                    
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(img, drawX, drawY, 0, imgScale, imgScale)
                end

                -- 绘制双进度条（调整到格子顶部边缘）
                local cropData = crops[cropKey]
                if cropData then
                    local barWidth = cellSize - 4
                    local barHeight = 3
                    local barX = cellX + 2
                    local barY = cellY - 8  -- 移到格子外顶部

                    -- 水分进度条（蓝色，带半透明背景）
                    love.graphics.setColor(0, 0, 0, 0.5)
                    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
                    love.graphics.setColor(0.2, 0.5, 1)
                    -- 使用 wateringProgress 来显示浇水进度
                    love.graphics.rectangle("fill", barX, barY, barWidth * math.min(plot.wateringProgress / cropData.dailyWateringLimit, 1), barHeight)

                    -- 成熟进度条（绿色，在上方）
                    love.graphics.setColor(0, 0, 0, 0.5)
                    love.graphics.rectangle("fill", barX, barY - 5, barWidth, barHeight)
                    love.graphics.setColor(0.3, 0.9, 0.3)
                    love.graphics.rectangle("fill", barX, barY - 5, barWidth * math.min(plot.growth / cropData.growthTime, 1), barHeight)
                end
            end
        end
    end
end


function drawControlBar()
    -- 确保barY有值，通过本地定义而不是依赖全局变量
    local barY = love.graphics.getHeight() - 60
    
    -- 控制栏背景
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, barY, love.graphics.getWidth(), 60)
    
    -- 控制按钮
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1)
    
    -- 下一天按钮
    love.graphics.printf("[N] Next Day", 20, barY + 15, 150, "left")
    
    -- 商店按钮
    love.graphics.printf("[S] Shop", 200, barY + 15, 150, "left")
    
    -- 仓库按钮
    love.graphics.printf("[C] Warehouse", 320, barY + 15, 150, "left")
    
    -- 帮助按钮
    love.graphics.printf("[H] Help", 500, barY + 15, 150, "left")

    --浇水
    love.graphics.printf("[T] Enter Watering Mode", 610, barY + 15, 200, "left")
    
    -- 种子库存栏
    local inventoryY = barY - 30
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, inventoryY, love.graphics.getWidth(), 30)
    
    -- 种子图标和数量
    local seedKeys = {"Cabbage_seed", "Beans_seed", "Maize_seed", "Sweet_Potato_seed"}
    local seedLabels = {"[Q] Cabbage", "[W] Beans", "[E] Maize", "[R] Sweet Potato"}
    local startX = 20
    local iconSpacing = 160
    
    for i, key in ipairs(seedKeys) do
        -- 高亮当前选中的种子
        if key == selectedSeed then
            love.graphics.setColor(1, 0.8, 0, 0.6)
            love.graphics.rectangle("fill", startX + (i-1) * iconSpacing - 5, inventoryY, 150, 30)
        end
        
        -- 显示种子图标
        if cropImages and cropImages[key] then
            love.graphics.setColor(1, 1, 1)
            local iconSize = 20
            local imgScale = iconSize / cropImages[key]:getWidth()
            love.graphics.draw(cropImages[key], startX + (i-1) * iconSpacing, inventoryY + 5, 0, imgScale, imgScale)
        end
        
        -- 显示种子名称和数量
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(tinyFont)
        love.graphics.print(seedLabels[i] .. ": " .. (player.inventory[key] or 0), startX + (i-1) * iconSpacing + 25, inventoryY + 8)
    end
end

-- 从shop.lua继承的交易界面函数
function drawTransactionInterface(title, isShop)
    -- 半透明背景面板
    love.graphics.setColor(0.1, 0.1, 0.1, 0.85)
    love.graphics.rectangle("fill", 50, 80, 700, 500, 10)

    -- 标题
    love.graphics.setColor(0.9, 0.9, 0.2)
    love.graphics.setFont(font)
    love.graphics.printf(title, 50, 100, 700, "center")

    -- 商品列表
    love.graphics.setFont(smallFont)
    local items = filterItems(isShop)
    for i, item in ipairs(items) do
        local yPos = 160 + (i-1)*55
        -- 选中高亮
        love.graphics.setColor(i == selectedItem and {1,0.8,0,0.3} or {0,0,0,0})
        love.graphics.rectangle("fill", 60, yPos-5, 680, 45, 5)
        
        -- 商品信息
        love.graphics.setColor(1,1,1)
        local displayName = item.name:gsub("_", " "):upper()
        love.graphics.printf(displayName, 80, yPos, 300, "left")
        love.graphics.printf(formatKES(isShop and item.basePrice or item.basePrice*0.8), 400, yPos, 200, "right")
        love.graphics.printf("Stock: "..(player.inventory[item.name] or 0), 620, yPos, 100, "right")
    end

    -- 居中控制面板
    drawControlPanel(isShop and "B - Confirm Buy" or "S - Confirm Sell")
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.9, 0.9, 0.2)
    local balanceText = "Balance: "..formatKES(player.kes)
    love.graphics.printf(balanceText, 60, 520, 300, "left")  -- 位置：X60,Y520
end

-- 从shop.lua继承的控制面板函数
function drawControlPanel(actionText)
    -- 按钮背景
    love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
    love.graphics.rectangle("fill", buttonArea.x-10, 390, buttonArea.width+20, 80, 5)

    -- 数量按钮
    love.graphics.setFont(smallFont)
    for _, btn in ipairs(buttonArea.buttons) do
        local btnX = buttonArea.x + btn.offset
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", btnX, 400, 60, 40, 3)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(btn.text, btnX, 410, 60, "center")
    end

    -- 数量显示
    love.graphics.printf("QUANTITY: "..quantity, buttonArea.x, 450, buttonArea.width, "center")
    love.graphics.printf(actionText.."\nESC - Cancel", buttonArea.x, 480, buttonArea.width, "center")
end

function drawHelp()
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 20, 20, love.graphics.getWidth() - 40, love.graphics.getHeight() - 40)
    
    -- 标题
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Game Help", 0, 70, love.graphics.getWidth(), "center")
    
    -- 设置更大的字体
    local helpFont = love.graphics.newFont(15)  -- 创建一个更大的字体用于帮助文本
    
    -- 左右两栏的位置设置
    local leftColumnX = 120
    local rightColumnX = love.graphics.getWidth() / 2 + 100
    local startY = 170
    local lineHeight = 30  -- 增加行高
    
    -- 左侧栏 - 按键控制
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 0.8)
    love.graphics.printf("KEY CONTROLS:", leftColumnX - 50, 130, 300, "left")
    
    love.graphics.setFont(helpFont)
    love.graphics.setColor(1, 1, 1)
    
    -- 按键控制说明
    love.graphics.printf("Arrow Keys: Move Character", leftColumnX, startY, 300, "left")
    love.graphics.printf("Q: Select Cabbage Seed", leftColumnX, startY + lineHeight, 300, "left")
    love.graphics.printf("W: Select Beans Seed", leftColumnX, startY + lineHeight*2, 300, "left")
    love.graphics.printf("E: Select Maize Seed", leftColumnX, startY + lineHeight*3, 300, "left")
    love.graphics.printf("R: Select Sweet Potato Seed", leftColumnX, startY + lineHeight*4, 300, "left")
    love.graphics.printf("N: Advance to Next Day", leftColumnX, startY + lineHeight*5, 300, "left")
    love.graphics.printf("S: Open Shop", leftColumnX, startY + lineHeight*6, 300, "left")
    love.graphics.printf("C: Open Warehouse", leftColumnX, startY + lineHeight*7, 300, "left")
    love.graphics.printf("H: Help Screen", leftColumnX, startY + lineHeight*8, 300, "left")
    love.graphics.printf("ESC: Return/Close Screen", leftColumnX, startY + lineHeight*9, 300, "left")
    love.graphics.printf("SPACE: Plant/Harvest", leftColumnX, startY + lineHeight*10, 300, "left")
    love.graphics.printf("F: Water Plants", leftColumnX, startY + lineHeight*11, 300, "left")
    
    -- 右侧栏 - 游戏关卡
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 0.8)
    love.graphics.printf("GAME LEVELS:", rightColumnX - 50, 130, 300, "left")
    
    love.graphics.setFont(helpFont)
    love.graphics.setColor(1, 1, 1)
    
    -- 游戏关卡说明
    love.graphics.printf("Level 1:", rightColumnX, startY, 300, "left")
    love.graphics.printf("  4 plots, harvest 1 of each crop", rightColumnX, startY + lineHeight, 300, "left")
    
    love.graphics.printf("Level 2:", rightColumnX, startY + lineHeight*3, 300, "left")
    love.graphics.printf("  9 plots, harvest 3 of each crop", rightColumnX, startY + lineHeight*4, 300, "left")
    
    love.graphics.printf("Level 3:", rightColumnX, startY + lineHeight*6, 300, "left")
    love.graphics.printf("  16 plots, harvest 5 of each crop", rightColumnX, startY + lineHeight*7, 300, "left")
    
    -- 交互提示说明
    love.graphics.printf("Interaction Tips:", rightColumnX, startY + lineHeight*9, 300, "left")
    love.graphics.printf("  Move near plots or seed bar", rightColumnX, startY + lineHeight*10, 300, "left")
    love.graphics.printf("  for on-screen action hints", rightColumnX, startY + lineHeight*11, 300, "left")

    -- 返回游戏提示
    love.graphics.setColor(1, 0.7, 0.7)
    love.graphics.printf("Press ESC to return", 0, love.graphics.getHeight() - 46, love.graphics.getWidth(), "center")
end

function drawDayPopup()
    -- 半透明背景遮罩覆盖整个屏幕
    love.graphics.setColor(0, 0, 0, 0.7 * popupAlpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- 弹窗尺寸和位置
    local popupWidth = 300
    local popupHeight = 150
    local popupX = (love.graphics.getWidth() - popupWidth) / 2
    local popupY = (love.graphics.getHeight() - popupHeight) / 2
    
    -- 绘制弹窗框和边框
    love.graphics.setColor(0.2, 0.2, 0.4, 0.9 * popupAlpha)
    love.graphics.rectangle("fill", popupX, popupY, popupWidth, popupHeight, 10, 10)
    love.graphics.setColor(0.8, 0.8, 1, popupAlpha)
    love.graphics.rectangle("line", popupX, popupY, popupWidth, popupHeight, 10, 10)
    
    -- 弹窗标题文字
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, popupAlpha)
    love.graphics.printf("Welcome to Day " .. newDayNumber, popupX, popupY + 30, popupWidth, "center") 
    
    -- 根据天气显示附加信息
    love.graphics.setFont(smallFont)
    local weatherMessage = ""
    if weather == "Sunny" then
        weatherMessage = "Sunny Day! (80 water)"
    elseif weather == "Rainy" then
        weatherMessage = "Rainy Day! (100 water)"
    end
    love.graphics.printf(weatherMessage, popupX, popupY + 80, popupWidth, "center")
    
    -- 继续提示
    love.graphics.setFont(tinyFont)
    love.graphics.setColor(0.9, 0.9, 0.2, math.sin(love.timer.getTime() * 5) * 0.5 + 0.5 * popupAlpha)
    love.graphics.printf("Press any key to continue", popupX, popupY + 115, popupWidth, "center")
end

function drawLevelPopup()
    -- 半透明背景遮罩
    love.graphics.setColor(0, 0, 0, 0.7 * popupAlpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- 弹窗框
    local popupWidth = 400
    local popupHeight = 200
    local popupX = (love.graphics.getWidth() - popupWidth) / 2
    local popupY = (love.graphics.getHeight() - popupHeight) / 2
    
    love.graphics.setColor(0.3, 0.5, 0.2, 0.9 * popupAlpha)
    love.graphics.rectangle("fill", popupX, popupY, popupWidth, popupHeight, 10)
    love.graphics.setColor(0.8, 1, 0.7, popupAlpha)
    love.graphics.rectangle("line", popupX, popupY, popupWidth, popupHeight, 10)
    
    -- 弹窗内容
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, popupAlpha)
    love.graphics.printf(levelPopupText, popupX, popupY + 40, popupWidth, "center")
    
    -- 解锁信息
    love.graphics.setFont(smallFont)
    local unlockText = ""
    if gameLevel == 2 then
        unlockText = "Unlocked 3x3 land!"
    elseif gameLevel == 3 then
        unlockText = "Unlocked 4x4 land!"
    end
    love.graphics.printf(unlockText, popupX, popupY + 100, popupWidth, "center")
    
    -- 继续提示
    love.graphics.setFont(tinyFont)
    love.graphics.setColor(0.9, 0.9, 0.2, math.sin(love.timer.getTime() * 5) * 0.5 + 0.5 * popupAlpha)
    love.graphics.printf("Press any key to continue", popupX, popupY + 150, popupWidth, "center")
end

function drawWinPopup()
    -- 半透明背景遮罩
    love.graphics.setColor(0, 0, 0, 0.7 * popupAlpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- 弹窗框
    local popupWidth = 500
    local popupHeight = 250
    local popupX = (love.graphics.getWidth() - popupWidth) / 2
    local popupY = (love.graphics.getHeight() - popupHeight) / 2
    
    love.graphics.setColor(0.3, 0.5, 0.2, 0.9 * popupAlpha)
    love.graphics.rectangle("fill", popupX, popupY, popupWidth, popupHeight, 10)
    love.graphics.setColor(0.8, 1, 0.7, popupAlpha)
    love.graphics.rectangle("line", popupX, popupY, popupWidth, popupHeight, 10)
    
    -- 弹窗内容
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, popupAlpha)
    love.graphics.printf("CONGRATULATIONS!", popupX, popupY + 40, popupWidth, "center")
    love.graphics.printf("You have completed all levels!", popupX, popupY + 90, popupWidth, "center")
    
    -- 继续提示
    love.graphics.setFont(tinyFont)
    love.graphics.setColor(0.9, 0.9, 0.2, math.sin(love.timer.getTime() * 5) * 0.5 + 0.5 * popupAlpha)
    love.graphics.printf("Press any key to continue", popupX, popupY + 180, popupWidth, "center")
end

function drawKitchenPopup()
    -- 半透明黑色背景覆盖整个屏幕
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- 厨房弹窗尺寸和位置
    local popupWidth = 400
    local popupHeight = 300
    local popupX = (love.graphics.getWidth() - popupWidth) / 2
    local popupY = (love.graphics.getHeight() - popupHeight) / 2
    
    -- 弹窗背景 - 淡黄色
    love.graphics.setColor(1, 0.95, 0.7) -- 淡黄色背景
    love.graphics.rectangle("fill", popupX, popupY, popupWidth, popupHeight, 10)
    
    -- 弹窗边框
    love.graphics.setColor(0.8, 0.7, 0.4) -- 深一点的黄色边框
    love.graphics.rectangle("line", popupX, popupY, popupWidth, popupHeight, 10)
    
    -- 标题背景
    love.graphics.setColor(0.9, 0.8, 0.5) -- 中等黄色标题背景
    love.graphics.rectangle("fill", popupX, popupY, popupWidth, 50, 10, 10, 0, 0)
    
    -- 标题文字
    love.graphics.setFont(font)
    love.graphics.setColor(0.6, 0.5, 0.3) -- 棕色文字
    love.graphics.printf("Kitchen", popupX, popupY + 10, popupWidth, "center")
    
    -- 今日菜单标题
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.6, 0.5, 0.3)
    love.graphics.printf("Today's Special Meal:", popupX, popupY + 70, popupWidth, "center")
    
    -- 菜品名称
    love.graphics.setFont(font)
    love.graphics.setColor(0.5, 0.4, 0.2) -- 深棕色文字
    love.graphics.printf(kitchenMenu.dailyMeal, popupX + 20, popupY + 110, popupWidth - 40, "center")
    
    -- 食材需求信息
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.6, 0.5, 0.3)
    love.graphics.printf("Made with farm-fresh ingredients", popupX, popupY + 180, popupWidth, "center")
    
    -- 退出提示
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.7, 0.6, 0.3)
    love.graphics.printf("Press ESC to close", popupX, popupY + 250, popupWidth, "center")
end

function drawWateringMode()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 50, 50, love.graphics.getWidth() - 100, love.graphics.getHeight() - 100)

    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Watering Mode", 0, 70, love.graphics.getWidth(), "center")

    love.graphics.setFont(smallFont)
    love.graphics.printf("Click to Water, Select Crop:", 0, 130, love.graphics.getWidth(), "center")

    -- 显示作物选项
    love.graphics.setFont(tinyFont)
    local startY = 180
    local spacing = 40
    love.graphics.printf("S: SweetPotatos (-3 Water)", 0, startY, love.graphics.getWidth(), "center")
    love.graphics.printf("B: Beans (-5 Water)", 0, startY + spacing, love.graphics.getWidth(), "center")
    love.graphics.printf("C: Cabbage (-7 Water)", 0, startY + spacing * 2, love.graphics.getWidth(), "center")
    love.graphics.printf("M: Maize (-9 Water)", 0, startY + spacing * 3, love.graphics.getWidth(), "center")

    -- **水条参数**
    local barWidth = 300 -- 水条的最大宽度
    local barHeight = 20 -- 水条高度
    local barX = love.graphics.getWidth() / 2 - barWidth / 2 -- 水条位置
    local barY = startY + spacing * 5 -- 水条位置（放在作物选项下方）
    
    -- **绘制水条背景**
    love.graphics.setColor(0.2, 0.2, 0.2) -- 灰色背景
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
    -- **绘制当前水量**
    local waterRatio = math.max(water / 120, 0) -- 计算水量比例（最大 120）
    love.graphics.setColor(0.0, 0.7, 1.0) -- 蓝色水条
    love.graphics.rectangle("fill", barX, barY, barWidth * waterRatio, barHeight)
    
    -- **显示水量数值**
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Water: " .. water .. " / 100", 0, barY - 25, love.graphics.getWidth(), "center")
    
    -- 退出提示
    love.graphics.setColor(1, 0.7, 0.7)
    love.graphics.printf("Press ESC to Exit", 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
end

function love.keypressed(key)
    -- 关卡弹窗关闭
    if showLevelPopup and popupTimer > 0.5 then
        showLevelPopup = false
        popupTimer = 0
        popupFadeIn = true
        return
    end

    -- 天数弹窗关闭逻辑
    if showDayPopup and popupTimer > 0.5 then
        showDayPopup = false
        popupTimer = 0
        popupFadeIn = true
        return
    end

    -- 通关弹窗关闭
    if showWinPopup and popupTimer > 0.5 then
        showWinPopup = false
        popupTimer = 0
        popupFadeIn = true
        return
    end

    -- 厨房弹窗关闭逻辑
    if showKitchenPopup and key == "escape" then
        showKitchenPopup = false
        return
    end

    if gameState == "menu" then
        if key == "return" then
            gameState = "game"
            gamebackground = land4
            levelPopupText = "Welcome to Level 1"
            showLevelPopup = true
            popupTimer = 0
            popupAlpha = 0
            popupFadeIn = true
        elseif key == "h" or key == "H" then
            previousGameState = gameState
            gameState = "help"
        end

    elseif gameState == "game" then
        -- 👇直接处理 F 键浇水，不再需要 waterMode
        if key == "f" or key == "F" then
            if nearPlot then
                local plot = grid[nearPlotX][nearPlotY]
                if plot.status == "planted" and plot.crop and crops[plot.crop] then
                    local cropData = crops[plot.crop]
                    local waterCost = 1
                    if plot.crop == "Sweet_Potato_seed" then
                        waterCost = 3
                    elseif plot.crop == "Beans_seed" then
                        waterCost = 5
                    elseif plot.crop == "Cabbage_seed" then
                        waterCost = 7
                    elseif plot.crop == "Maize_seed" then
                        waterCost = 9
                    end

                    if water >= waterCost and actionPoints > 0 and plot.dailyWateringCount < plot.wateringLimit then
                        plot.waterLevel = plot.waterLevel + 1
                        plot.wateringProgress = plot.wateringProgress + 1

                        if plot.wateringProgress >= cropData.dailyWateringLimit then
                            plot.growth = plot.growth + 1
                            plot.wateringProgress = 0
                            if plot.growth >= cropData.growthTime then
                                plot.status = "matured"
                            end
                        end

                        water = water - waterCost
                        actionPoints = actionPoints - 1
                        plot.dailyWateringCount = plot.dailyWateringCount + 1

                        if actionPoints <= 0 then
                            advanceToNextDay()
                        end
                    end
                end
            end

        elseif key == "k" or key == "K" then
            if nearKitchen then
                showKitchenPopup = true
            end
        elseif key == "q" then
            selectedSeed = "Cabbage_seed"
        elseif key == "w" then
            selectedSeed = "Beans_seed"
        elseif key == "e" then
            selectedSeed = "Maize_seed"
        elseif key == "r" then
            selectedSeed = "Sweet_Potato_seed"
        elseif key == "n" or key == "N" then
            advanceToNextDay()
            local newWeather = weatherTypes[math.random(1, #weatherTypes)]
            while newWeather == weather do
                newWeather = weatherTypes[math.random(1, #weatherTypes)]
            end
            weather = newWeather
            if weather == "Sunny" then
                water = 80
                maxWater = 100
            elseif weather == "Rainy" then
                water = 100
                maxWater = 100
            end
        elseif key == "s" or key == "S" then
            gameState = "shop"
        elseif key == "C" or key == "c" then
            gameState = "warehouse"
        elseif key == "h" or key == "H" then
            previousGameState = gameState
            gameState = "help"
        elseif key == "escape" and day == 1 then
            -- 可选：关闭教程
        elseif key == "t" or key == "T" then
            waterMode = not waterMode
        elseif key == "space" then
            if nearSeedBar then
                if actionPoints > 0 then
                    local availableSeeds = {"Cabbage_seed", "Beans_seed", "Maize_seed", "Sweet_Potato_seed"}
                    local randomSeed = availableSeeds[math.random(1, #availableSeeds)]
                    player.inventory[randomSeed] = player.inventory[randomSeed] + 1
                    actionPoints = actionPoints - 1
                    if actionPoints <= 0 then
                        advanceToNextDay()
                    end
                end
            elseif nearPlot then
                local plot = grid[nearPlotX][nearPlotY]
                if plot.status == "empty" then
                    if player.inventory[selectedSeed] and player.inventory[selectedSeed] > 0 and actionPoints > 0 then
                        grid[nearPlotX][nearPlotY] = {
                            status = "planted",
                            crop = selectedSeed,
                            growth = 0,
                            waterLevel = 0,
                            wateringLimit = crops[selectedSeed].dailyWateringLimit,
                            dailyWateringCount = 0,
                            wateringProgress = 0
                        }
                        player.inventory[selectedSeed] = player.inventory[selectedSeed] - 1
                        actionPoints = actionPoints - 1
                        if actionPoints <= 0 then
                            advanceToNextDay()
                        end
                    end
                elseif plot.status == "matured" then
                    if actionPoints > 0 then
                        local cropKey = plot.crop
                        local cropName = cropKey:gsub("_seed", "")
                        player.inventory[cropName] = (player.inventory[cropName] or 0) + 1
                        grid[nearPlotX][nearPlotY] = {
                            status = "empty",
                            crop = nil,
                            growth = 0,
                            waterLevel = 0,
                            wateringLimit = 0,
                            dailyWateringCount = 0,
                            wateringProgress = 0
                        }
                        actionPoints = actionPoints - 1
                        if actionPoints <= 0 then
                            advanceToNextDay()
                        end
                        checkLevelUp()
                    end
                end
            end
        end

        -- 如果水用完则进入下一天
        if water <= 0 then
            day = day + 1
            local newWeather = weatherTypes[math.random(1, #weatherTypes)]
            while newWeather == weather do
                newWeather = weatherTypes[math.random(1, #weatherTypes)]
            end
            weather = newWeather
            if weather == "Sunny" then
                water = 80
                maxWater = 100
            elseif weather == "Rainy" then
                water = 100
                maxWater = 100
            end
            waterMode = false
            showDayPopup = true
            popupTimer = 0
            newDayNumber = day
            popupAlpha = 0
            popupFadeIn = true
        end
    elseif gameState == "shop" or gameState == "warehouse" then
        if key == "escape" then
            gameState = "game"
        else
            handleNavigation(key)
        end
    elseif gameState == "help" then
        if key == "escape" then
            if previousGameState then
                gameState = previousGameState
            else
                gameState = "game"
            end
        end
    end

    print("Current gameState: " .. gameState)
end




function handleNavigation(key)
    local items = filterItems(gameState == "shop")
    if key == "up" then
        selectedItem = math.max(1, selectedItem-1)
    elseif key == "down" then
        selectedItem = math.min(#items, selectedItem+1)
    elseif (key == "b" and gameState == "shop") or (key == "s" and gameState == "warehouse") then
        processTransaction()
    end
end

-- 从shop.lua继承的交易处理函数
function processTransaction()
    local item = filterItems(gameState == "shop")[selectedItem]
    
    -- 提前检查行动点，避免无意义操作
    if actionPoints > 0 then
        if gameState == "shop" then
            buyItem(item, quantity)
        else
            sellItem(item, quantity)
        end
        quantity = 1
    else
        print("Insufficient action points, please press N to enter the next day!")
    end
end

-- 从shop.lua继承的购买函数
function buyItem(item, qty)
    -- 检查金钱和行动点是否足够
    local total = item.basePrice * qty
    if player.kes >= total and actionPoints > 0 then
        player.kes = player.kes - total
        player.inventory[item.name] = (player.inventory[item.name] or 0) + qty
        actionPoints = actionPoints - 1  -- 扣除1点行动点
        print("Purchase successful, remaining action points:", actionPoints)
        
        -- 如果行动点用完，自动进入下一天
        if actionPoints <= 0 then
            advanceToNextDay()
        end
    else
        -- 提示失败原因
        if actionPoints <= 0 then
            print("Not enough action points!")
        else
            print("Not enough money!")
        end
    end
end

-- 从shop.lua继承的销售函数
function sellItem(item, qty)
    -- 检查库存和行动点
    local stock = player.inventory[item.name] or 0
    if stock >= qty and actionPoints > 0 then
        local earnings = item.basePrice * 0.8 * qty
        player.kes = player.kes + earnings
        player.inventory[item.name] = stock - qty
        actionPoints = actionPoints - 1  -- 扣除1点行动点
        print("Purchase successful, remaining action points:", actionPoints)
        
        -- 行动点归零时进入下一天
        if actionPoints <= 0 then
            advanceToNextDay()
        end
    else
        if actionPoints <= 0 then
            print("Not enough action points!")
        else
            print("Not enough money!")
        end
    end
end

-- 从shop.lua继承的货币格式化函数
function formatKES(amount)
    return "KSh "..string.format("%.2f", amount):reverse():gsub("(%d%d%d)", "%1,"):reverse()
end

-- 从shop.lua继承的商品过滤函数
function filterItems(isShop)
    return (isShop 
        and {shopItems[1], shopItems[2], shopItems[3], shopItems[4]} 
        or {shopItems[5], shopItems[6], shopItems[7], shopItems[8]})
end

-- 从shop.lua继承的数量调整函数
function adjustQuantity(btn)
    if btn == "-5" then quantity = math.max(1, quantity-5) end
    if btn == "-1" then quantity = math.max(1, quantity-1) end
    if btn == "+1" then quantity = quantity+1 end
    if btn == "+5" then quantity = quantity+5 end
end

function love.mousepressed(x, y, button)
    if gameState == "game" and button == 1 then
        local gridStartX = 250
        local gridStartY = 245
        local cellSize = 40
        local padding = 35

        for gridX = 1, gridSize do
            for gridY = 1, gridSize do
                local cellX = gridStartX + (gridX-1) * (cellSize + padding)
                local cellY = gridStartY + (gridY-1) * (cellSize + padding)

                if x >= cellX and x <= cellX + cellSize and
                   y >= cellY and y <= cellY + cellSize then

                    if grid[gridX][gridY].status ~= "locked" then
                        -- 空地种植
                        if grid[gridX][gridY].status == "empty" then
                            if player.inventory[selectedSeed] and player.inventory[selectedSeed] > 0 and actionPoints > 0 then
                                grid[gridX][gridY] = {
                                    status = "planted",
                                    crop = selectedSeed,
                                    growth = 0,
                                    waterLevel = 0,
                                    wateringLimit = crops[selectedSeed].dailyWateringLimit,
                                    dailyWateringCount = 0,
                                    wateringProgress = 0
                                }
                                player.inventory[selectedSeed] = player.inventory[selectedSeed] - 1
                                actionPoints = actionPoints - 1
                                print("Planted:", crops[selectedSeed].name, "at", gridX, gridY)

                                if actionPoints <= 0 then
                                    advanceToNextDay()
                                end
                            end

                        -- -- 浇水
                        -- elseif grid[gridX][gridY].status == "planted" then
                        --     if water < 3 then
                        --         print("Water too low. Automatically advancing to next day.")
                        --         advanceToNextDay()
                        --         return
                        --     end

                        --     local plot = grid[gridX][gridY]
                        --     local cropData = crops[plot.crop]

                        --     local waterCost = 1
                        --     if plot.crop == "Sweet_Potato_seed" then
                        --         waterCost = 3
                        --     elseif plot.crop == "Beans_seed" then
                        --         waterCost = 5
                        --     elseif plot.crop == "Cabbage_seed" then
                        --         waterCost = 7
                        --     elseif plot.crop == "Maize_seed" then
                        --         waterCost = 9
                        --     end

                        --     if water >= waterCost and actionPoints > 0 and plot.dailyWateringCount < plot.wateringLimit then
                        --         plot.waterLevel = plot.waterLevel + 1
                        --         plot.wateringProgress = plot.wateringProgress + 1

                        --         if plot.wateringProgress >= cropData.dailyWateringLimit then
                        --             plot.growth = plot.growth + 1
                        --             plot.wateringProgress = 0
                        --             if plot.growth >= cropData.growthTime then
                        --                 plot.status = "matured"
                        --                 print(cropData.name .. " matured at grid [" .. gridX .. "," .. gridY .. "]")
                        --             end
                        --         end

                        --         water = water - waterCost
                        --         actionPoints = actionPoints - 1
                        --         plot.dailyWateringCount = plot.dailyWateringCount + 1

                        --         print("Watered:", gridX, gridY,
                        --             "Water level:", plot.waterLevel,
                        --             "/", cropData.waterNeed,
                        --             "Daily watering count:", plot.dailyWateringCount,
                        --             "/", plot.wateringLimit,
                        --             "Cost:", waterCost)

                        --         if actionPoints <= 0 then
                        --             advanceToNextDay()
                        --         end
                        --     else
                        --         if plot.dailyWateringCount >= plot.wateringLimit then
                        --             print("Daily watering limit reached for this crop!")
                        --         elseif water < waterCost then
                        --             print("Not enough water!")
                        --         else
                        --             print("No action points left!")
                        --         end
                        --     end

                        -- 成熟作物收割
                        elseif grid[gridX][gridY].status == "matured" and actionPoints > 0 then
                            local cropKey = grid[gridX][gridY].crop
                            local cropName = cropKey:gsub("_seed", "")
                            player.inventory[cropName] = (player.inventory[cropName] or 0) + 1
                        
                            -- 检查是否满足通关条件（所有作物各5个）
                            local allComplete = true
                            for _, crop in ipairs({"Cabbage", "Beans", "Maize", "Sweet_Potato"}) do
                                if (player.inventory[crop] or 0) < 5 then
                                    allComplete = false
                                    break
                                end
                            end
                        
                            if allComplete then
                                -- 显示通关弹窗
                                showWinPopup = true
                                popupTimer = 0
                                popupAlpha = 0
                                popupFadeIn = true
                            else
                                -- 检查是否满足关卡升级条件
                                if checkLevelUp() then
                                    gameLevel = gameLevel + 1
                                    levelPopupText = "Welcome to Level " .. gameLevel
                                    showLevelPopup = true
                                    popupTimer = 0
                                    popupAlpha = 0
                                    popupFadeIn = true
                                    
                                    -- 根据关卡解锁土地
                                    if gameLevel == 2 then
                                        for x = 1, gridSize do
                                            for y = 1, gridSize do
                                                if x <= 3 and y <= 3 and grid[x][y].status == "locked" then
                                                    grid[x][y].status = "empty"
                                                end
                                            end
                                        end
                                    elseif gameLevel == 3 then
                                        for x = 1, gridSize do
                                            for y = 1, gridSize do
                                                if grid[x][y].status == "locked" then
                                                    grid[x][y].status = "empty"
                                                end
                                            end
                                        end
                                    end
                                else
                                 
                                end
                            end
                        
                            -- 清除格子
                            grid[gridX][gridY] = {
                                status = "empty",
                                crop = nil,
                                growth = 0,
                                waterLevel = 0,
                                wateringLimit = 0,
                                dailyWateringCount = 0,
                                wateringProgress = 0
                            }
                        
                            actionPoints = actionPoints - 1
                            print("Harvested:", cropName, "at", gridX, gridY)
                        
                            if actionPoints <= 0 then
                                advanceToNextDay()
                            end
                            return
                        end
                    end
                end
            end
        end

    elseif (gameState == "shop" or gameState == "warehouse") and button == 1 then
        if buttonArea and buttonArea.buttons then
            for _, btn in ipairs(buttonArea.buttons) do
                local btnX = buttonArea.x + btn.offset
                if x >= btnX and x <= btnX + 40 and y >= 400 and y <= 440 then
                    adjustQuantity(btn.text)
                end
            end
        end
    end
end


-- 新增函数：推进到下一天的逻辑
function advanceToNextDay()
    -- 保存当前天数（用于弹窗显示）
    local oldDay = day
    
    day = day + 1
    
    -- 随机更换今日午餐（新增这一行）
    kitchenMenu.dailyMeal = possibleMeals[math.random(1, #possibleMeals)]
    
    -- 重置行动点
    actionPoints = 20
    
    -- 随机天气
    local newWeather = weatherTypes[math.random(1, #weatherTypes)]
    while newWeather == weather do
        newWeather = weatherTypes[math.random(1, #weatherTypes)]
    end
    weather = newWeather
    
    -- 根据天气调整水量
    if weather == "Sunny" then
        water = 80
    elseif weather == "Rainy" then
        water = 100
    end
    
    -- 作物生长和成熟逻辑
    for x = 1, gridSize do
        for y = 1, gridSize do
            local plot = grid[x][y]
            if plot.status == "planted" then
                local cropData = crops[plot.crop]
                
                -- 重置每天的浇水计数和浇水上限
                plot.dailyWateringCount = 0
                plot.wateringLimit = cropData.dailyWateringLimit

            end
        end
    end
    
    -- 检查是否满足升级条件
        -- 检查是否满足升级条件
        if checkLevelUp() then
            gameLevel = gameLevel + 1
            levelPopupText = "Welcome to Level " .. gameLevel
            showLevelPopup = true
            popupTimer = 0
            popupAlpha = 0
            popupFadeIn = true
    
            -- 根据关卡解锁土地
            if gameLevel == 2 then
                for x = 1, gridSize do
                    for y = 1, gridSize do
                        if x <= 3 and y <= 3 and grid[x][y].status == "locked" then
                            grid[x][y].status = "empty"
                        end
                    end
                end
            elseif gameLevel == 3 then
                for x = 1, gridSize do
                    for y = 1, gridSize do
                        if grid[x][y].status == "locked" then
                            grid[x][y].status = "empty"
                        end
                    end
                end
            end
    
            return  -- 避免显示 Day 弹窗
        end
    
        -- 否则显示普通天数弹窗
        showDayPopup = true
        popupTimer = 0
        newDayNumber = day
        popupAlpha = 0
        popupFadeIn = true
    
    print("Advanced to Day " .. day .. ", Weather: " .. weather)
end

function checkLevelUp()
    if gameLevel >= #levelRequirements then 
        -- 检查是否满足最终通关条件（累计收获）
        local reqCrops, reqCount = unpack(levelRequirements[#levelRequirements])
        local cropNames = {"Cabbage", "Beans", "Maize", "Sweet_Potato"}
        
        for _, crop in ipairs(cropNames) do
            if (player.inventory[crop] or 0) < reqCount then
                return false
            end
        end
        
        -- 满足最终通关条件
        showWinPopup = true
        popupTimer = 0
        popupAlpha = 0
        popupFadeIn = true
        return false -- 不再升级关卡
    end

    -- 正常关卡升级检查
    local reqCrops, reqCount = unpack(levelRequirements[gameLevel])
    local cropNames = {"Cabbage", "Beans", "Maize", "Sweet_Potato"}

    for _, crop in ipairs(cropNames) do
        if (player.inventory[crop] or 0) < reqCount then
            return false
        end
    end
    
    return true -- 允许升级到下一关
end

-- New function to draw the character
function drawCharacter()
    -- Draw the character
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        characterData.img,
        characterData.x,
        characterData.y,
        0,
        characterData.scale,
        characterData.scale
    )
    
    -- Debug info (remove in final version)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(tinyFont)
    love.graphics.print("Position: " .. math.floor(characterData.x) .. ", " .. math.floor(characterData.y), 10, 80)
    love.graphics.print("Direction: " .. characterData.direction, 10, 100)
end

function drawInteractionTip()
    -- 绘制交互提示
    if showInteractionTip and interactionTip ~= "" then
        local tipX = characterData.x
        local tipY = characterData.y - 30
        
        -- 提示背景
        love.graphics.setColor(0, 0, 0, 0.7)
        local textWidth = tinyFont:getWidth(interactionTip) + 10
        love.graphics.rectangle("fill", tipX - textWidth/2, tipY - 15, textWidth, 25, 5, 5)
        
        -- 提示文字
        love.graphics.setFont(tinyFont)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(interactionTip, tipX - textWidth/2, tipY - 10, textWidth, "center")
    end
end


function getNearestPlantableCellFromPosition(x, y, maxDistance)

    local gridStartX = 250

    local gridStartY = 245

    local cellSize = 40

    local padding = 35

    local closestDist = math.huge

    local closestX, closestY = nil, nil


    for gridX = 1, gridSize do

        for gridY = 1, gridSize do

            local plot = grid[gridX][gridY]

            if plot.status == "planted" then

                local centerX = gridStartX + (gridX - 1) * (cellSize + padding) + cellSize / 2

                local centerY = gridStartY + (gridY - 1) * (cellSize + padding) + cellSize / 2

                local dist = math.sqrt((x - centerX)^2 + (y - centerY)^2)

                print(string.format("检查地块[%d,%d]，距离 %.2f", gridX, gridY, dist))


                if dist < closestDist and dist <= maxDistance then

                    closestDist = dist

                    closestX = gridX

                    closestY = gridY

                end

            end

        end

    end

    return closestX, closestY

end
