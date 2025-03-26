function love.load()
    love.window.setTitle("FarmED - Welcome")
    love.graphics.setBackgroundColor(0.2, 0.6, 0.3) -- 绿色背景

    waterMode = false  -- 是否处于浇水模式
    weatherTypes = {"Sunny", "Rainy"}  -- 可能的天气

    

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
    previousGameState = nil  -- 添加记录前一个状态的变量
    gameLevel = 1
    
    -- 游戏状态变量
    day = 1
    money = 100
    actionPoints = 10 -- 第一阶段有10个行动点
    weather = weatherTypes[math.random(1, #weatherTypes)] -- 随机天气
    if weather == "Sunny" then
    water = 80
    elseif weather == "Rainy" then
    water = 120
    end


    
    -- 农场网格（第一阶段4格）
    gridSize = 4 -- 4x4 的网格
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
        Cabbage = {name = "Cabbage", growthTime = 6, waterNeed = 1, value = 100},
        Sweet_Potatoe = {name = "Sweet Potatoes", growthTime = 8, waterNeed = 2, value = 150},
        Maize = {name = "Maize", growthTime = 10, waterNeed = 3, value = 130},
        Beans = {name = "Beans", growthTime = 12, waterNeed = 4, value = 250}
    }
    
    -- 玩家拥有的种子和资金（从shop.lua中继承）
    player = {
        kes = 10000.00,
        inventory = {
            Cabbage_seed = 5,
            Sweet_Potatoe_seed = 3,
            Maize_seed = 0,
            Beans_seed = 0,
            Cabbage = 0,
            Sweet_Potatoe = 0,
            Maize = 0,
            Beans = 0
        }
   }
    
    -- 商品数据（从shop.lua中继承）
    shopItems = {
        { name = "Cabbage_seed", basePrice = 50.00 },
        { name = "Sweet_Potatoe_Zseed",  basePrice = 80.00 },
        { name = "Maize_seed",   basePrice = 70.00 },
        { name = "Beans_seed", basePrice = 120.00 },
        { name = "Cabbage", basePrice = 100.00 },
        { name = "Sweet_Potatoe",  basePrice = 150.00 },
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
    
end

function love.update(dt)
    -- 计算居中位置（从shop.lua中继承）
    local screenWidth = love.graphics.getWidth()
    buttonArea.x = (screenWidth - buttonArea.width) / 2
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
            if waterMode then
                drawWateringMode() -- 进入浇水界面
            else
                drawGame()
            end
        elseif gameState == "shop" then
            drawTransactionInterface("SHOP", true)
        elseif gameState == "warehouse" then
            drawTransactionInterface("WAREHOUSE", false)
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
    love.graphics.printf("Balance: " .. formatKES(player.kes), itemWidth, 15, itemWidth, "center")
    love.graphics.printf("Action Points: " .. actionPoints .. "/10", itemWidth*2, 15, itemWidth, "center")
    love.graphics.printf("Weather: " .. weather, itemWidth*3, 15, itemWidth, "center")
    love.graphics.printf("Water: " .. water, itemWidth*4, 15, itemWidth, "center")
end

function drawGrid()
    local gridStartX = 300
    local gridStartY = 203
    local cellSize = 40 
    local padding = 10 
    local gridSize = 4  

    love.graphics.setFont(tinyFont)
    
    -- 绘制统一的提示信息(在格子上方)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Click an empty plot to plant", gridStartX, gridStartY - 35, gridSize * (cellSize + padding), "center")

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
            
            -- 显示作物状态（不再显示“Click to plant”）
            love.graphics.setColor(1, 1, 1)
            if grid[x][y].status ~= "empty" then
                love.graphics.printf(grid[x][y].status .. "\nClick to view", cellX, cellY + cellSize/3, cellSize, "center")
            end
        end
    end
end


-- function drawToolbar()
--     local toolbarX = 600
--     local toolbarY = 100
--     local toolbarWidth = 180
--     local buttonHeight = 40
--     local padding = 10
    
--     -- 工具栏背景
--     love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
--     love.graphics.rectangle("fill", toolbarX, toolbarY, toolbarWidth, 300)
    
--     -- 工具栏标题
--     love.graphics.setFont(smallFont)
--     love.graphics.setColor(1, 1, 1)
--     love.graphics.printf("Tools", toolbarX, toolbarY + 10, toolbarWidth, "center")
    
--     -- 工具按钮
--     love.graphics.setFont(tinyFont)
--     local buttonY = toolbarY + 50
    
--     -- 种植工具
--     if selectedTool == "plant" then
--         love.graphics.setColor(0.3, 0.8, 0.3)
--     else
--         love.graphics.setColor(0.5, 0.5, 0.5)
--     end
--     love.graphics.rectangle("fill", toolbarX + 10, buttonY, toolbarWidth - 20, buttonHeight)
--     love.graphics.setColor(1, 1, 1)
--     love.graphics.printf("Plant [1]", toolbarX + 10, buttonY + 10, toolbarWidth - 20, "center")
    
--     -- 浇水工具
--     buttonY = buttonY + buttonHeight + padding
--     if selectedTool == "water" then
--         love.graphics.setColor(0.3, 0.3, 0.8)
--     else
--         love.graphics.setColor(0.5, 0.5, 0.5)
--     end
--     love.graphics.rectangle("fill", toolbarX + 10, buttonY, toolbarWidth - 20, buttonHeight)
--     love.graphics.setColor(1, 1, 1)
--     love.graphics.printf("Water [2]", toolbarX + 10, buttonY + 10, toolbarWidth - 20, "center")
    
--     -- 收获工具
--     buttonY = buttonY + buttonHeight + padding
--     if selectedTool == "harvest" then
--         love.graphics.setColor(0.8, 0.6, 0.3)
--     else
--         love.graphics.setColor(0.5, 0.5, 0.5)
--     end
--     love.graphics.rectangle("fill", toolbarX + 10, buttonY, toolbarWidth - 20, buttonHeight)
--     love.graphics.setColor(1, 1, 1)
--     love.graphics.printf("Harvest [3]", toolbarX + 10, buttonY + 10, toolbarWidth - 20, "center")
    
--     -- 种子选择（当选择种植工具时显示）
--     if selectedTool == "plant" then
--         buttonY = buttonY + buttonHeight + padding * 2
--         love.graphics.setColor(0.2, 0.6, 0.2)
--         love.graphics.rectangle("fill", toolbarX + 10, buttonY, toolbarWidth - 20, 100)
        
--         love.graphics.setColor(1, 1, 1)
--         love.graphics.printf("Seeds Available:", toolbarX + 10, buttonY + 10, toolbarWidth - 20, "center")
--         love.graphics.printf("Lettuce: " .. seeds.lettuce .. " [Q]", toolbarX + 10, buttonY + 40, toolbarWidth - 20, "left")
--         love.graphics.printf("Carrot: " .. seeds.carrot .. " [W]", toolbarX + 10, buttonY + 65, toolbarWidth - 20, "left")
--     end
-- end

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
    love.graphics.printf("[W] Warehouse", 340, barY + 15, 150, "left")
    
    -- 帮助按钮
    love.graphics.printf("[H] Help", 500, barY + 15, 150, "left")

    --浇水
    love.graphics.printf("[T] Enter Watering Mode", 610, barY + 15, 200, "left")

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
    love.graphics.printf("S: SweetPotatoes (-5 Water)", 0, startY, love.graphics.getWidth(), "center")
    love.graphics.printf("B: Beans (-10 Water)", 0, startY + spacing, love.graphics.getWidth(), "center")
    love.graphics.printf("C: Cabbage (-15 Water)", 0, startY + spacing * 2, love.graphics.getWidth(), "center")
    love.graphics.printf("M: Maize (-20 Water)", 0, startY + spacing * 3, love.graphics.getWidth(), "center")

   
    

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
        love.graphics.printf("Water: " .. water .. " / 120", 0, barY - 25, love.graphics.getWidth(), "center")
     -- 退出提示
    love.graphics.setColor(1, 0.7, 0.7)
    love.graphics.printf("Press Q to Exit", 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
end


function love.keypressed(key)
    if gameState == "menu" then
        if key == "return" then
            gameState = "game"
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
            day = day + 1
            -- 随机天气（防止连续重复）
            local newWeather = weatherTypes[math.random(1, #weatherTypes)]
            while newWeather == weather do
                newWeather = weatherTypes[math.random(1, #weatherTypes)]
            end
            weather = newWeather
            if weather == "Sunny" then
                water = 80
            elseif weather == "Rainy" then
                water = 120
            end

        elseif key == "s" or key == "S" then
            gameState = "shop"
        elseif key == "w" or key == "W" then
            gameState = "warehouse"
        elseif key == "h" or key == "H" then
            previousGameState = gameState
            gameState = "help"
            print("Help screen opened from game")  -- 调试信息
        elseif key == "escape" and day == 1 then
            -- 关闭教程提示（可选实现）

        elseif key == "t" or key == "T" then
            waterMode = not waterMode  -- 切换浇水模式
            if waterMode then
                print("Entered Watering Mode")  -- 调试信息
            else
                print("Exited Watering Mode") -- 调试信息
            end
        end

        -- 处理浇水逻辑
        if waterMode then
            if key == "s" or key == "S" then
                if water >= 5 then water = water - 5 end
            elseif key == "b" or key == "B" then
                if water >= 10 then water = water - 10 end
            elseif key == "c" or key == "C" then
                if water >= 15 then water = water - 15 end
            elseif key == "m" or key == "M" then
                if water >= 20 then water = water - 20 end
            elseif key == "q" or key == "Q" then
                waterMode = false -- 退出浇水模式
            end
        end

        -- 如果水用完，则进入下一天
        if water <= 0 then
            day = day + 1
            local newWeather = weatherTypes[math.random(1, #weatherTypes)]
            while newWeather == weather do
                newWeather = weatherTypes[math.random(1, #weatherTypes)]
            end
            weather = newWeather
            if weather == "Sunny" then
                water = 80
            elseif weather == "Rainy" then
                water = 120
            end
            waterMode = false -- 退出浇水模式
        end

    elseif gameState == "shop" or gameState == "warehouse" then
        if key == "escape" then
            gameState = "game"
        else
            handleNavigation(key)
        end

    elseif gameState == "help" then
        if key == "escape" then
            -- 从帮助界面返回到之前的状态
            if previousGameState then
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

-- 从shop.lua继承的导航处理函数
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
    if gameState == "shop" then
        buyItem(item, quantity)
    else
        sellItem(item, quantity)
    end
    quantity = 1  -- 重置数量
end

-- 从shop.lua继承的购买函数
function buyItem(item, qty)
    local total = item.basePrice * qty
    if player.kes >= total then
        player.kes = player.kes - total
        player.inventory[item.name] = (player.inventory[item.name] or 0) + qty
    end
end

-- 从shop.lua继承的销售函数
function sellItem(item, qty)
    local stock = player.inventory[item.name] or 0
    if stock >= qty then
        player.kes = player.kes + (item.basePrice * 0.8 * qty)
        player.inventory[item.name] = stock - qty
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
        -- 检测点击农场网格
        local gridStartX = 100
        local gridStartY = 100
        local cellSize = 120
        local padding = 10
        
        for gridX = 1, gridSize do
            for gridY = 1, gridSize do
                local cellX = gridStartX + (gridX-1) * (cellSize + padding)
                local cellY = gridStartY + (gridY-1) * (cellSize + padding)
                
                if x >= cellX and x <= cellX + cellSize and
                   y >= cellY and y <= cellY + cellSize then
                    -- 这里只添加UI提示，不实现实际功能
                    if selectedTool == "plant" and grid[gridX][gridY].status == "empty" then
                        -- 种植逻辑的UI提示
                        grid[gridX][gridY].status = "Seedling"
                        actionPoints = actionPoints - 1
                    elseif selectedTool == "water" and grid[gridX][gridY].status ~= "empty" then
                        -- 浇水逻辑的UI提示
                        grid[gridX][gridY].status = grid[gridX][gridY].status .. " (Watered)"
                        actionPoints = actionPoints - 1
                        water = water - 1
                    elseif selectedTool == "harvest" and grid[gridX][gridY].status ~= "empty" then
                        -- 收获逻辑的UI提示
                        grid[gridX][gridY].status = "empty"
                        actionPoints = actionPoints - 1
                    end
                    return
                end
            end
        end
    elseif (gameState == "shop" or gameState == "warehouse") and button == 1 then
        -- 处理数量调整按钮点击（从shop.lua继承）
        for _, btn in ipairs(buttonArea.buttons) do
            local btnX = buttonArea.x + btn.offset
            if x >= btnX and x <= btnX + 40 and y >= 400 and y <= 440 then
                adjustQuantity(btn.text)
            end
        end
   end
end
