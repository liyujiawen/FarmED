function love.load()
    love.window.setTitle("FarmED - Welcome")
    love.graphics.setBackgroundColor(0.2, 0.6, 0.3) -- 绿色背景

    -- 加载背景图片
    background = love.graphics.newImage("art/background.png")
    land4 = love.graphics.newImage("art/land4.png")

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
    gridSize = 2 -- 2x2 的网格
    grid = {}
    for x = 1, gridSize do
        grid[x] = {}
        for y = 1, gridSize do
            grid[x][y] = {status = "empty"} -- 初始状态为空地
        end
    end 
    
    -- 玩家当前选择的工具
    selectedTool = "none"
    
    -- 基础作物数据（只添加UI，不实现功能）
    crops = {
        wheat = {name = "Wheat", growthTime = 5, waterNeed = 10, value = 25},
        carrot = {name = "Carrot", growthTime = 6, waterNeed = 5, value = 30},
        corn = {name = "Corn", growthTime = 8, waterNeed = 15, value = 40},
        banana = {name = "Banana", growthTime = 10, waterNeed = 20, value = 50}
    }
    
    -- 玩家拥有的种子
    seeds = {
        wheat = 2,
        carrot = 3,
        corn = 2,
        banana = 1
    }
    
    -- 玩家拥有的水资源
    water = 20
end

function love.update(dt)
    -- 这里暂时没有需要更新的内容
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
    
    -- 侧边工具栏
    -- drawToolbar()
    
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
end

function drawGrid()
    --startX/Y是花田地的起始坐标，
    local gridStartX = 100
    local gridStartY = 100
    -- 格子大小
    local cellSize = 120
    -- 格子间距
    local padding = 10
    
    love.graphics.setFont(tinyFont)
    
    for x = 1, gridSize do
        for y = 1, gridSize do
            local cellX = gridStartX + (x-1) * (cellSize + padding)
            local cellY = gridStartY + (y-1) * (cellSize + padding)
            
            -- 绘制土地格子
            if grid[x][y].status == "empty" then
                love.graphics.setColor(0.6, 0.4, 0.2)
            else
                love.graphics.setColor(0.4, 0.7, 0.3) -- 种植后的颜色
            end
            
            love.graphics.rectangle("fill", cellX, cellY, cellSize, cellSize)
            love.graphics.setColor(0.3, 0.2, 0.1)
            love.graphics.rectangle("line", cellX, cellY, cellSize, cellSize)
            
         --显示网格提示信息
             love.graphics.setColor(1, 1, 1)
            if grid[x][y].status == "empty" then
                love.graphics.printf("Empty\nClick to plant", cellX, cellY + cellSize/3, cellSize, "center")
            else
                love.graphics.printf(grid[x][y].status .. "\nClick to view", cellX, cellY + cellSize/3, cellSize, "center")
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
    
    love.graphics.printf("Lettuce Seeds - $10/pack [Q to buy]", 0, startY, love.graphics.getWidth(), "center")
    startY = startY + lineHeight
    
    love.graphics.printf("Carrot Seeds - $15/pack [W to buy]", 0, startY, love.graphics.getWidth(), "center")
    startY = startY + lineHeight
    
    love.graphics.printf("Water - $5/unit [E to buy]", 0, startY, love.graphics.getWidth(), "center")
    startY = startY + lineHeight * 2
    
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
    
    love.graphics.printf("Lettuce - 0 units ($20/unit to sell) [Q to sell]", 0, startY, love.graphics.getWidth(), "center")
    startY = startY + lineHeight
    
    love.graphics.printf("Carrot - 0 units ($30/unit to sell) [W to sell]", 0, startY, love.graphics.getWidth(), "center")
    startY = startY + lineHeight * 2
    
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
            -- 仅在这里修改背景图片
            gamebackground = land4
            print("Changed background to land4") -- 调试信息
        elseif key == "h" or key == "H" then  -- 添加对大写H的支持
            previousGameState = gameState
            gameState = "help"
            print("Help screen opened from menu")  -- 调试信息
        end
    elseif gameState == "game" then
        if key == "1" then
            selectedTool = "plant"
        elseif key == "2" then
            selectedTool = "water"
        elseif key == "3" then
            selectedTool = "harvest"
        elseif key == "n" or key == "N" then
            -- 这里只有UI提示，实际功能未实现
            day = day + 1
            actionPoints = 10 -- 重置行动点
        elseif key == "s" or key == "S" then
            gameState = "shop"
        elseif key == "w" or key == "W" then
            gameState = "warehouse"
        elseif key == "h" or key == "H" then
            previousGameState = gameState
            gameState = "help"
            print("Help screen opened from game")  -- 调试信息
        elseif key == "escape" and day == 1 then
            -- 关闭教程提示
        end
    elseif gameState == "shop" or gameState == "warehouse" or gameState == "help" then
        if key == "escape" then
            -- 从帮助界面返回到之前的状态
            if gameState == "help" and previousGameState then
                gameState = previousGameState
                print("Returning to previous state: " .. previousGameState)  -- 调试信息
            else
                gameState = "game"
                print("Returning to game state")  -- 调试信息
            end
        end
    end
    
    -- 添加调试打印当前状态
    print("Current gameState: " .. gameState)
end

function plantCrop(x, y, cropType)
    if grid[x][y].status == "empty" and seeds[cropType] and seeds[cropType] > 0 then
        grid[x][y].status = "planted"
        grid[x][y].crop = cropType
        grid[x][y].waterProgress = 0
        grid[x][y].growthProgress = 0
        seeds[cropType] = seeds[cropType] - 1
    end
end

function waterCrop(x, y)
    if grid[x][y].status == "planted" then
        local cropType = grid[x][y].crop
        if water >= crops[cropType].waterNeed then
            grid[x][y].waterProgress = grid[x][y].waterProgress + 1
            water = water - crops[cropType].waterNeed
        end
    end
end

function updateGrowth()
    for x = 1, gridSize do
        for y = 1, gridSize do
            if grid[x][y].status == "planted" and grid[x][y].waterProgress > 0 then
                grid[x][y].growthProgress = grid[x][y].growthProgress + 1
                if grid[x][y].growthProgress >= crops[grid[x][y].crop].growthTime then
                    grid[x][y].status = "mature"
                end
            end
        end
    end
end

function harvestCrop(x, y)
    if grid[x][y].status == "mature" then
        local cropType = grid[x][y].crop
        money = money + crops[cropType].value
        grid[x][y] = {status = "empty", crop = nil, waterProgress = 0, growthProgress = 0}
    end
end

function love.mousepressed(x, y, button)
    if gameState == "game" and button == 1 then
        local gridStartX = 100
        local gridStartY = 100
        local cellSize = 120
        local padding = 10
        
        for gridX = 1, gridSize do
            for gridY = 1, gridSize do
                local cellX = gridStartX + (gridX-1) * (cellSize + padding)
                local cellY = gridStartY + (gridY-1) * (cellSize + padding)
                
                if x >= cellX and x <= cellX + cellSize and y >= cellY and y <= cellY + cellSize then
                    if selectedTool == "plant" and grid[gridX][gridY].status == "empty" then
                        print("Planting at", gridX, gridY)
                        plantCrop(gridX, gridY, "wheat") 
                        actionPoints = actionPoints - 1
                    elseif selectedTool == "water" and grid[gridX][gridY].status == "planted" then
                        print("Watering at", gridX, gridY)
                        waterCrop(gridX, gridY)
                        actionPoints = actionPoints - 1
                    elseif selectedTool == "harvest" and grid[gridX][gridY].status == "mature" then
                        print("Harvesting at", gridX, gridY)
                        harvestCrop(gridX, gridY)
                        actionPoints = actionPoints - 1
                    end
                    return
                end
            end
        end
    end
end
