function love.load()
    love.window.setTitle("FarmED - Welcome")
    love.graphics.setBackgroundColor(0.2, 0.6, 0.3) -- 绿色背景

    -- 加载背景图片
    background = love.graphics.newImage("art/background.png")
    land4 = love.graphics.newImage("art/land16.png")
    -- 加载作物图片
    cropImages = {
        wheat = love.graphics.newImage("art/wheat.png"),
        carrot = love.graphics.newImage("art/carrot.png"),
        corn = love.graphics.newImage("art/corn.png"),
        banana = love.graphics.newImage("art/banana.png")
    }
    
    gamebackground = background

    -- 设置字体
    font = love.graphics.newFont(30)
    smallFont = love.graphics.newFont(20)
    tinyFont = love.graphics.newFont(15)
    
    -- 初始游戏状态
    gameState = "menu"
    previousGameState = nil  -- 添加记录前一个状态的变量
    gameLevel = 1
    
    -- 游戏状态变量
    day = 1
    money = 100
    actionPoints = 10 -- 第一阶段有10个行动点
    weather = "Sunny"
    
    -- 农场网格（第一阶段4格）
    gridSize = 4 -- 4x4 的网格
    grid = {}
    for x = 1, gridSize do
        grid[x] = {}
        for y = 1, gridSize do
            grid[x][y] = {status = "empty"} -- 初始状态为空地
        end
    end 
    
    -- 基础作物数据（只添加UI，不实现功能）
    crops = {
        wheat = {name = "Wheat", growthTime = 5, waterNeed = 2, value = 15},
        carrot = {name = "Carrot", growthTime = 6, waterNeed = 1, value = 30},
        corn = {name = "Corn", growthTime = 8, waterNeed = 3, value = 50},
        banana = {name = "Banana", growthTime = 10, waterNeed = 4, value = 70}
    }
    
    -- 玩家拥有的种子
    seeds = {
        wheat = 5,
        carrot = 3,
        corn = 2,
        banana = 1
    }

    -- 当前选中的种子，默认为小麦
    selectedSeed = "wheat"
    
    -- 玩家拥有的水资源
    water = 20
end

function love.update(dt)
    for x = 1, gridSize do
        for y = 1, gridSize do
            local plot = grid[x][y]
            if plot.status == "planted" then
                local crop = crops[plot.crop]
                if plot.waterLevel >= crop.waterNeed then
                    plot.growth = plot.growth + dt  -- 只在有足够水分时生长
                end
                if plot.growth >= crop.growthTime then
                    plot.status = "matured"
                end
            end
        end
    end    
end

function love.draw()
    -- 先绘制背景（保持整个代码中只有这一处修改）
    love.graphics.setColor(1, 1, 1) -- 确保背景图片颜色正确
    love.graphics.draw(gamebackground, 0, 0, 0, 
        love.graphics.getWidth() / gamebackground:getWidth(), 
        love.graphics.getHeight() / gamebackground:getHeight())

    if gameState == "menu" then
        drawMenu()
    elseif gameState == "game" then
        drawGame()
    elseif gameState == "shop" then
        drawShop()
    elseif gameState == "warehouse" then
        drawWarehouse()
    elseif gameState == "help" then
        drawHelp()
    end
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
    
    
    -- 底部控制栏
    drawControlBar()
    
    -- 如果是游戏开始的第一天，显示提示
    -- if day == 1 and gameLevel == 1 then
    --     drawTutorialTip()
    -- end
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
    love.graphics.printf("Money: $" .. money, itemWidth, 15, itemWidth, "center")
    love.graphics.printf("Action Points: " .. actionPoints .. "/10", itemWidth*2, 15, itemWidth, "center")
    love.graphics.printf("Weather: " .. weather, itemWidth*3, 15, itemWidth, "center")
    love.graphics.printf("Water: " .. water, itemWidth*4, 15, itemWidth, "center")
    love.graphics.printf("Selected Seed: " .. crops[selectedSeed].name, itemWidth*5, 15, itemWidth, "center")
end

function drawGrid() 
    local gridStartX = 300
    local gridStartY = 207
    local cellSize = 40
    local padding = 10
    local gridSize = 4  

    love.graphics.setFont(tinyFont)
    
    for x = 1, gridSize do
        for y = 1, gridSize do
            local cellX = gridStartX + (x-1) * (cellSize + padding)
            local cellY = gridStartY + (y-1) * (cellSize + padding)
            
            -- 绘制土地格子
            if grid[x][y].status == "empty" then
                love.graphics.setColor(0.6, 0.4, 0.2)
            else
                love.graphics.setColor(0.4, 0.7, 0.3)
            end
            love.graphics.rectangle("fill", cellX, cellY, cellSize, cellSize)
            love.graphics.setColor(0.3, 0.2, 0.1)
            love.graphics.rectangle("line", cellX, cellY, cellSize, cellSize)
            
            -- 作物和进度条绘制
            if grid[x][y].status == "planted" or grid[x][y].status == "matured" then  
                local plot = grid[x][y]
                local crop = plot.crop

                -- 绘制作物图片
                if crop and cropImages[crop] then
                    local img = cropImages[crop]
                    local imgScale = (cellSize * 1.2) / math.max(img:getWidth(), img:getHeight())
                    local drawX = cellX + (cellSize - img:getWidth() * imgScale) / 2
                    local drawY = cellY + (cellSize - img:getHeight() * imgScale) / 2
                    
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(img, drawX, drawY, 0, imgScale, imgScale)
                end

                -- 绘制双进度条（调整到格子顶部边缘）
                local cropData = crops[crop]
                if cropData then
                    local barWidth = cellSize - 4
                    local barHeight = 3
                    local barX = cellX + 2
                    local barY = cellY - 8  -- 移到格子外顶部

                    -- 水分进度条（蓝色，带半透明背景）
                    love.graphics.setColor(0, 0, 0, 0.5)
                    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
                    love.graphics.setColor(0.2, 0.5, 1)
                    love.graphics.rectangle("fill", barX, barY, barWidth * math.min(plot.waterLevel / cropData.waterNeed, 1), barHeight)

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
    love.graphics.printf("[W] Warehouse", 380, barY + 15, 150, "left")
    
    -- 帮助按钮
    love.graphics.printf("[H] Help", 560, barY + 15, 150, "left")
end

function drawTutorialTip()
    -- 显示新手教程提示
    local tipX = 100
    local tipY = 400
    local tipWidth = 400
    local tipHeight = 150
    
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", tipX, tipY, tipWidth, tipHeight)
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("line", tipX, tipY, tipWidth, tipHeight)
    
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 0)
    love.graphics.printf("Welcome to FarmED!", tipX + 10, tipY + 10, tipWidth - 20, "center")
    
    love.graphics.setFont(tinyFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("1. Select planting tool from toolbar\n2. Choose seed type\n3. Click empty plot to plant\n4. Remember to water regularly\n5. Harvest crops when mature\n\nPress ESC to close this tip", tipX + 10, tipY + 50, tipWidth - 20, "left")
end

function drawShop()
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 100, 100, love.graphics.getWidth() - 200, love.graphics.getHeight() - 200)
    
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Shop", 0, 120, love.graphics.getWidth(), "center")
    
    love.graphics.setFont(smallFont)
    love.graphics.printf("Buy Seeds and Tools", 0, 170, love.graphics.getWidth(), "center")
    
    -- 商店商品列表（仅UI提示）
    love.graphics.setFont(tinyFont)
    local startY = 220
    local lineHeight = 40

    love.graphics.printf("Wheat Seeds - $10/pack [Q to buy]", 0, startY, love.graphics.getWidth(), "center")
    startY = startY + lineHeight

    love.graphics.printf("Carrot Seeds - $15/pack [W to buy]", 0, startY, love.graphics.getWidth(), "center")
    startY = startY + lineHeight

    love.graphics.printf("Corn Seeds - $20/pack [E to buy]", 0, startY, love.graphics.getWidth(), "center")
    startY = startY + lineHeight

    love.graphics.printf("Banana Seeds - $25/pack [R to buy]", 0, startY, love.graphics.getWidth(), "center")
    startY = startY + lineHeight * 2  -- 间隔调整

    love.graphics.printf("Water - $5/unit [T to buy]", 0, startY, love.graphics.getWidth(), "center")

    
    -- 返回游戏提示
    love.graphics.setColor(1, 0.7, 0.7)
    love.graphics.printf("Press ESC to return to game", 0, love.graphics.getHeight() - 150, love.graphics.getWidth(), "center")
end

function drawWarehouse()
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 100, 100, love.graphics.getWidth() - 200, love.graphics.getHeight() - 200)
    
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Warehouse", 0, 120, love.graphics.getWidth(), "center")
    
    love.graphics.setFont(smallFont)
    love.graphics.printf("Manage Your Harvested Crops", 0, 170, love.graphics.getWidth(), "center")
    
    -- 仓库内容（仅UI提示）
    love.graphics.setFont(tinyFont)
    local startY = 220
    local lineHeight = 40

    love.graphics.printf("Wheat - 0 units ($15/unit to sell) [Q to sell]", 0, startY, love.graphics.getWidth(), "center")
    startY = startY + lineHeight

    love.graphics.printf("Carrot - 0 units ($30/unit to sell) [W to sell]", 0, startY, love.graphics.getWidth(), "center")
    startY = startY + lineHeight

    love.graphics.printf("Corn - 0 units ($50/unit to sell) [E to sell]", 0, startY, love.graphics.getWidth(), "center")
    startY = startY + lineHeight

    love.graphics.printf("Banana - 0 units ($70/unit to sell) [R to sell]", 0, startY, love.graphics.getWidth(), "center")

    
    -- 返回游戏提示
    love.graphics.setColor(1, 0.7, 0.7)
    love.graphics.printf("Press ESC to return to game", 0, love.graphics.getHeight() - 150, love.graphics.getWidth(), "center")
end

function drawHelp()
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 50, 50, love.graphics.getWidth() - 100, love.graphics.getHeight() - 100)
    
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Game Help", 0, 70, love.graphics.getWidth(), "center")
    
    -- 添加按键操作说明
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 0.8)
    love.graphics.printf("KEY CONTROLS:", 0, 130, love.graphics.getWidth(), "center")
    
    love.graphics.setFont(tinyFont)
    love.graphics.setColor(1, 1, 1)
    local controlsX = love.graphics.getWidth() / 2 - 150
    local startY = 180
    local lineHeight = 30
    
    love.graphics.printf("1: Select Planting Tool", controlsX, startY, 300, "left")
    love.graphics.printf("2: Select Watering Tool", controlsX, startY + lineHeight, 300, "left")
    love.graphics.printf("3: Select Harvesting Tool", controlsX, startY + lineHeight*2, 300, "left")
    love.graphics.printf("Q/W: Select Seed Type (when planting)", controlsX, startY + lineHeight*3, 300, "left")
    love.graphics.printf("N: Advance to Next Day", controlsX, startY + lineHeight*4, 300, "left")
    love.graphics.printf("S: Open Shop", controlsX, startY + lineHeight*5, 300, "left")
    love.graphics.printf("W: Open Warehouse", controlsX, startY + lineHeight*6, 300, "left")
    love.graphics.printf("H: Help Screen", controlsX, startY + lineHeight*7, 300, "left")
    love.graphics.printf("ESC: Return/Close Current Screen", controlsX, startY + lineHeight*8, 300, "left")
    
    -- 添加游戏玩法信息
    startY = startY + lineHeight * 10
    love.graphics.setColor(0.8, 1, 0.8)
    love.graphics.printf("How to Play:", 100, startY, love.graphics.getWidth() - 200, "left")
    startY = startY + lineHeight
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("1. Plant crops: Select planting tool (1), choose seed type (Q/W), then click on empty plot", 100, startY, love.graphics.getWidth() - 200, "left")
    startY = startY + lineHeight
    
    love.graphics.printf("2. Water: Select watering tool (2), then click on planted crop", 100, startY, love.graphics.getWidth() - 200, "left")
    startY = startY + lineHeight
    
    love.graphics.printf("3. Harvest: Select harvest tool (3), then click on mature crop", 100, startY, love.graphics.getWidth() - 200, "left")
    startY = startY + lineHeight * 2
    
    love.graphics.printf("Stage 1 Goal: Successfully manage your farm for 14 days and harvest at least 10 crops", 100, startY, love.graphics.getWidth() - 200, "left")
    
    -- 返回游戏提示
    love.graphics.setColor(1, 0.7, 0.7)
    love.graphics.printf("Press ESC to return", 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
end

function love.keypressed(key)
    if gameState == "menu" then
        if key == "return" then
            gameState = "game"
            gamebackground = land4
            print("Changed background to land4") -- 调试信息
        elseif key == "h" or key == "H" then
            previousGameState = gameState
            gameState = "help"
            print("Help screen opened from menu") -- 调试信息
        end
    elseif gameState == "game" then
        if key == "q" then
            selectedSeed = "wheat"
        elseif key == "w" then
            selectedSeed = "carrot"
        elseif key == "e" then
            selectedSeed = "corn"
        elseif key == "r" then
            selectedSeed = "banana"
        elseif key == "n" or key == "N" then
            day = day + 1
            actionPoints = 10 -- 重置行动点
        elseif key == "s" or key == "S" then
            gameState = "shop"
        elseif key == "w" or key == "W" then
            gameState = "warehouse"
        elseif key == "h" or key == "H" then
            previousGameState = gameState
            gameState = "help"
            print("Help screen opened from game") -- 调试信息
        end
    elseif gameState == "shop" or gameState == "warehouse" or gameState == "help" then
        if key == "escape" then
            if gameState == "help" and previousGameState then
                gameState = previousGameState
                print("Returning to previous state: " .. previousGameState)
            else
                gameState = "game"
                print("Returning to game state")
            end
        end
    end

    print("Current gameState: " .. gameState)
end

function love.mousepressed(x, y, button)
    if gameState == "game" and button == 1 then
        local gridStartX = 300
        local gridStartY = 207
        local cellSize = 40
        local padding = 10

        for gridX = 1, gridSize do
            for gridY = 1, gridSize do
                local cellX = gridStartX + (gridX - 1) * (cellSize + padding)
                local cellY = gridStartY + (gridY - 1) * (cellSize + padding)

                if x >= cellX and x <= cellX + cellSize and
                   y >= cellY and y <= cellY + cellSize then

                    -- 如果是空地，种植作物
                    if grid[gridX][gridY].status == "empty" then
                        if seeds[selectedSeed] and seeds[selectedSeed] > 0 then
                            grid[gridX][gridY] = {
                                status = "planted",
                                crop = selectedSeed,
                                growth = 0,
                                waterLevel = 0
                            }
                            seeds[selectedSeed] = seeds[selectedSeed] - 1
                            actionPoints = actionPoints - 1
                            print("Planted:", crops[selectedSeed].name, "at", gridX, gridY)
                        end
                    
                    -- 如果是已种植作物，浇水
                    elseif grid[gridX][gridY].status == "planted" then
                        if water > 0 and actionPoints > 0 then
                            grid[gridX][gridY].waterLevel = grid[gridX][gridY].waterLevel + 1
                            water = water - 1
                            actionPoints = actionPoints - 1
                            print("Watered:", gridX, gridY, 
                                  "Water level:", grid[gridX][gridY].waterLevel,
                                  "/", crops[grid[gridX][gridY].crop].waterNeed)
                        else
                            print(water > 0 and "No action points left!" or "Not enough water!")
                        end
                    
                    -- 如果是成熟作物，收割（待实现）
                    elseif grid[gridX][gridY].status == "matured" then
                        -- 这里可以添加收割逻辑
                        print("Crop matured! Ready to harvest.")
                    end
                    return
                end
            end
        end
    end
end
