function love.load()
    love.window.setTitle("FarmED")
    love.graphics.setBackgroundColor(0.2, 0.6, 0.3)
    background = love.graphics.newImage("arts/background1.png")

    -- 字体设置（放大主界面字体）
    titleFont = love.graphics.newFont(24)
    menuFont = love.graphics.newFont(22)
    interfaceFont = love.graphics.newFont(20)
    
    -- 游戏状态机
    gameState = "menu"  -- menu/game/shop/warehouse

    -- 玩家数据
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

    -- 商品数据
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

    -- 动态按钮位置
    buttonArea = {
        x = 0, width = 320,  -- 总宽度=4按钮*80间距
        buttons = {
            {text = "-5", offset = 0},
            {text = "-1", offset = 40},
            {text = "+1", offset = 80},
            {text = "+5", offset = 120}
        }
    }
    selectedItem = 1
    quantity = 1
end

function love.update(dt)
    -- 计算居中位置
    local screenWidth = love.graphics.getWidth()
    buttonArea.x = (screenWidth - buttonArea.width) / 2
end

function love.draw()
    love.graphics.draw(background, 0, 0, 
        0, 
        love.graphics.getWidth()/background:getWidth(),
        love.graphics.getHeight()/background:getHeight())

    if gameState == "menu" then
        drawMenu()
    elseif gameState == "game" then
        drawGame()
    elseif gameState == "shop" then
        drawTransactionInterface("SHOP", true)
    elseif gameState == "warehouse" then
        drawTransactionInterface("WAREHOUSE", false)
    end
end

function love.keypressed(key)
    -- 状态转换逻辑
    if key == "escape" then
        if gameState == "shop" or gameState == "warehouse" then
            gameState = "game"
        elseif gameState == "game" then
            gameState = "menu"
        end
    end

    if (key == "return" or key == "kpenter") and gameState == "menu" then
        gameState = "game"
    end

    if gameState == "game" then
        if key == "b" then gameState = "shop" end
        if key == "w" then gameState = "warehouse" end
    end

    -- 导航控制
    if gameState == "shop" or gameState == "warehouse" then
        handleNavigation(key)
    end
end

function love.mousepressed(x, y)
    if gameState == "shop" or gameState == "warehouse" then
        -- 处理数量调整
        for _, btn in ipairs(buttonArea.buttons) do
            local btnX = buttonArea.x + btn.offset
            if x >= btnX and x <= btnX + 40 and y >= 400 and y <= 440 then
                adjustQuantity(btn.text)
            end
        end
    end
end

-- =====================
-- 核心绘制函数（修改版）
-- =====================
function drawMenu()
    love.graphics.setFont(titleFont)
    love.graphics.printf("FARM MANAGEMENT SIM", 0, 150, love.graphics.getWidth(), "center")
    love.graphics.setFont(menuFont)
    love.graphics.printf("Press ENTER to Start", 0, 250, love.graphics.getWidth(), "center")
end

function drawGame()
    love.graphics.setFont(interfaceFont)
    love.graphics.print("Balance: "..formatKES(player.kes), 30, 30)
    love.graphics.print("B - Buy Seeds", 30, 60)
    love.graphics.print("W - Sell Crops", 30, 90)
end

function drawTransactionInterface(title, isShop)
    -- 半透明背景面板
    love.graphics.setColor(0.1, 0.1, 0.1, 0.85)
    love.graphics.rectangle("fill", 50, 80, 700, 500, 10)

    -- 标题
    love.graphics.setColor(0.9, 0.9, 0.2)
    love.graphics.setFont(titleFont)
    love.graphics.printf(title, 50, 100, 700, "center")

    -- 商品列表
    love.graphics.setFont(interfaceFont)
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
end

function drawControlPanel(actionText)
    -- 按钮背景
    love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
    love.graphics.rectangle("fill", buttonArea.x-10, 390, buttonArea.width+20, 80, 5)

    -- 数量按钮
    love.graphics.setFont(interfaceFont)
    for _, btn in ipairs(buttonArea.buttons) do
        local btnX = buttonArea.x + btn.offset
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", btnX, 400, 40, 40, 3)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(btn.text, btnX, 410, 40, "center")
    end

    -- 数量显示
    love.graphics.printf("QUANTITY: "..quantity, buttonArea.x, 450, buttonArea.width, "center")
    love.graphics.printf(actionText.."\nESC - Cancel", buttonArea.x, 480, buttonArea.width, "center")
end

-- =====================
-- 核心逻辑函数
-- =====================
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

function processTransaction()
    local item = filterItems(gameState == "shop")[selectedItem]
    if gameState == "shop" then
        buyItem(item, quantity)
    else
        sellItem(item, quantity)
    end
    quantity = 1  -- 重置数量
end

function buyItem(item, qty)
    local total = item.basePrice * qty
    if player.kes >= total then
        player.kes = player.kes - total
        player.inventory[item.name] = (player.inventory[item.name] or 0) + qty
    end
end

function sellItem(item, qty)
    local stock = player.inventory[item.name] or 0
    if stock >= qty then
        player.kes = player.kes + (item.basePrice * 0.8 * qty)
        player.inventory[item.name] = stock - qty
    end
end

-- =====================
-- 工具函数
-- =====================
function formatKES(amount)
    return "KSh "..string.format("%.2f", amount):reverse():gsub("(%d%d%d)", "%1,"):reverse()
end

function filterItems(isShop)
    return (isShop 
        and {shopItems[1], shopItems[2], shopItems[3], shopItems[4]} 
        or {shopItems[5], shopItems[6], shopItems[7], shopItems[8]})
end

function adjustQuantity(btn)
    if btn == "-5" then quantity = math.max(1, quantity-5) end
    if btn == "-1" then quantity = math.max(1, quantity-1) end
    if btn == "+1" then quantity = quantity+1 end
    if btn == "+5" then quantity = quantity+5 end
end