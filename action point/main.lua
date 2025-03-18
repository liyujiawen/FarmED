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
        lettuce = {name = "Lettuce", growthTime = 4, waterNeed = 2, value = 20},
        carrot = {name = "Carrot", growthTime = 6, waterNeed = 1, value = 30}
    }

    -- 玩家拥有的种子
    seeds = {
        lettuce = 5,
        carrot = 3
    }

    -- 玩家拥有的水资源
    water = 20

    -- 加载 level1.lua
    Level1 = require("level1")

    -- 初始化 Level1 数据
    gameLevelData = Level1
    gameLevelData.farmLayout = {plots = {
        {status = "empty"}, {status = "empty"},
        {status = "empty"}, {status = "empty"}
    }}
end


-- 处理 level1.lua 的作物生长、浇水、收获逻辑
function updatePlotStatus()
    for i, plot in ipairs(gameLevelData.farmLayout.plots) do
        local cropStatus = gameLevelData:getCropStatus(i)
        local col = (i - 1) % gridSize + 1
        local row = math.floor((i - 1) / gridSize) + 1
        if cropStatus == "ready" then
            grid[col][row].status = "Harvest Ready"
        elseif cropStatus == "withered" then
            grid[col][row].status = "Withered"
        elseif cropStatus:find("Growing") then
            grid[col][row].status = "Growing"
        end
    end
end

-- 在 love.update() 中更新作物状态
local originalUpdate = love.update
function love.update(dt)
    if originalUpdate then
        originalUpdate(dt)
    end
    if gameState == "game" then
        updatePlotStatus()
    end
end

-- 处理鼠标点击事件来更新 level1 的状态
local originalMousepressed = love.mousepressed
function love.mousepressed(x, y, button)
    if originalMousepressed then
        originalMousepressed(x, y, button)
    end

    if gameState == "game" and button == 1 then
        local gridStartX = 100
        local gridStartY = 100
        local cellSize = 120
        local padding = 10

        for i, plot in ipairs(gameLevelData.farmLayout.plots) do
            local col = (i - 1) % gridSize + 1
            local row = math.floor((i - 1) / gridSize) + 1
            local cellX = gridStartX + (col - 1) * (cellSize + padding)
            local cellY = gridStartY + (row - 1) * (cellSize + padding)

            if x >= cellX and x <= cellX + cellSize and
               y >= cellY and y <= cellY + cellSize then

                if selectedTool == "plant" and grid[col][row].status == "empty" then
                    local success, message = gameLevelData:plantCrop(i, "wheat")
                    print(message)
                elseif selectedTool == "water" and grid[col][row].status ~= "empty" then
                    local success, message = gameLevelData:waterCrop(i)
                    print(message)
                elseif selectedTool == "harvest" and grid[col][row].status == "Harvest Ready" then
                    local success, message = gameLevelData:harvestCrop(i)
                    print(message)
                end
                return
            end
        end
    end
end
