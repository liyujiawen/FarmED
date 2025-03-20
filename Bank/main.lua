function love.load()
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
    previousGameState = nil  -- 添加记录前一个状态的变量
    gameLevel = 1
    
    -- 游戏状态变量
    day = 1
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
    
    -- 玩家当前选择的工具
    selectedTool = "none"
    
    -- 基础作物数据（只添加UI，不实现功能）
    crops = {
        carrot = {name = "Carrot", growthTime = 6, waterNeed = 1, value = 100},
        wheat = {name = "Wheat", growthTime = 8, waterNeed = 2, value = 150},
        corn = {name = "Corn", growthTime = 10, waterNeed = 3, value = 130},
        banana = {name = "Banana", growthTime = 12, waterNeed = 4, value = 250}
    }
    
    -- 玩家拥有的种子和资金（从shop.lua中继承）
    player = {
        kes = 10000.00,
        inventory = {
            carrot_seed = 5,
            wheat_seed = 3,
            corn_seed = 0,
            banana_seed = 0,
            carrot = 0,
            wheat = 0,
            corn = 0,
            banana = 0
        }
    }
    
    -- 商品数据（从shop.lua中继承）
    shopItems = {
        { name = "carrot_seed", basePrice = 50.00 },
        { name = "wheat_seed",  basePrice = 80.00 },
        { name = "corn_seed",   basePrice = 70.00 },
        { name = "banana_seed", basePrice = 120.00 },
        { name = "carrot", basePrice = 100.00 },
        { name = "wheat",  basePrice = 150.00 },
        { name = "corn",   basePrice = 130.00 },
        { name = "banana", basePrice = 250.00 }
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
    
    -- 玩家拥有的水资源
    water = 20
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
        drawGame()
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
    elseif gameState == "shop" or gameState == "warehouse" then
        -- 商店和仓库的导航处理（从shop.lua继承）
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