local Animation = require("animation")

function love.load()
    love.window.setTitle("FarmED - Welcome")
    love.graphics.setBackgroundColor(0.2, 0.6, 0.3) -- background

    waterMode = false  -- Whether in watering mode or not
    weatherTypes = {"Sunny", "Rainy"}  -- Possible weather
    -- Make the game start (day 1) with a fixed sunny day
    weather = "Sunny"
    water = 80
    maxWater = 100

    -- Load background image
    background = love.graphics.newImage("art/background.png")
    land4 = love.graphics.newImage("art/land16.png")

    -- Load Crop Pictures, Load Three Stage Pictures
    cropImages = {
        -- CABBAGE
        Cabbage_seed = love.graphics.newImage("art/cabbage_seed.png"),
        Cabbage_mid = love.graphics.newImage("art/cabbage_mid.png"),
        Cabbage = love.graphics.newImage("art/cabbage.png"),
        -- BEANS
        Beans_seed = love.graphics.newImage("art/beans_seed.png"),
        Beans_mid = love.graphics.newImage("art/beans_mid.png"),
        Beans = love.graphics.newImage("art/beans.png"),
        -- MAIZE
        Maize_seed = love.graphics.newImage("art/maize_seed.png"),
        Maize_mid = love.graphics.newImage("art/maize_mid.png"),
        Maize = love.graphics.newImage("art/maize.png"),
        -- SWEET POTATO
        Sweet_Potato_seed = love.graphics.newImage("art/sweetpotato_seed.png"),
        Sweet_Potato_mid = love.graphics.newImage("art/sweetpotato_mid.png"),
        Sweet_Potato = love.graphics.newImage("art/sweetpotato.png")
    }
    gamebackground = background

    -- Load character images and attributes
    Animation:load()

    -- Setting fonts
    font = love.graphics.newFont(30)
    smallFont = love.graphics.newFont(20)
    tinyFont = love.graphics.newFont(10)
    
    -- Initial game status
    gameState = "menu"
    previousGameState = nil  -- Add variable to record previous state
    gameLevel = 1

    -- Kitchen-related variables
    kitchenIconX = 650  -- Kitchen icon x-coordinate
    kitchenIconY = 150  -- Kitchen icon y-coordinate
    showKitchenPopup = false -- Whether to show kitchen pop-ups
    nearKitchen = false -- Is it near the kitchen

    -- Kitchen menu data
    kitchenMenu = {
        dailyMeal = "Vegetable Soup"  -- Lunch today, default
    }

    -- menu
    possibleMeals = {
        "Vegetable Soup",   
        "Corn Porridge",    
       "Roasted Sweet Potato",  
        "Bean Stew",       
    }
    
    levelRequirements = {
        {4, 1},  -- Level 1: 1 each of 4 crops
        {4, 3},  -- Level 2: 3 each of 4 crops
        {4, 5}   -- Level 3: 5 each of 4 crops
    }
    
    levelPopupText = ""     -- Level popup text

    -- game state variable
    day = 1
    money = 100
    actionPoints = 20 -- Phase I has 20 action points
    -- Interactive Cue Related Variables
    interactionTip = ""  -- Currently displayed interaction prompts
    showInteractionTip = false  -- Whether or not to show interactive prompts
    nearSeedBar = false  -- Proximity to the seed bar
    nearPlot = false  -- Proximity to parcels
    nearPlotX = 0  -- X-coordinates
    nearPlotY = 0  -- Y-coordinates
   -- weather = weatherTypes[math.random(1, #weatherTypes)] -- random weather
    
    if weather == "Sunny" then
        water = 80
    elseif weather == "Rainy" then
        water = 100
        maxWater = 100
    end
    
    -- Farm Grid (Phase I, 4 Grids)
    gridSize = 4 -- 4x4 Grids
    grid = {}
    for x = 1, gridSize do
        grid[x] = {}
        for y = 1, gridSize do
            -- Upper Left Quad
            if x >= 1 and x <= 2 and y >= 1 and y <= 2 then
                grid[x][y] = {
                    status = "empty",
                    wateringLimit = 0,  
                    dailyWateringCount = 0  
                }
            else
                grid[x][y] = {
                    status = "locked",  -- locked
                    wateringLimit = 0,
                    dailyWateringCount = 0
                }
            end
        end
    end 
    
    -- Basic crop data (only UI)
    crops = {
        Cabbage_seed = {name = "Cabbage", growthTime = 2, waterNeed = 4, value = 15, dailyWateringLimit = 4},
        Beans_seed = {name = "Beans", growthTime = 3, waterNeed = 2, value = 30, dailyWateringLimit = 2},
        Maize_seed = {name = "Maize", growthTime = 4, waterNeed = 6, value = 50, dailyWateringLimit = 6},
        Sweet_Potato_seed = {name = "Sweet Potato", growthTime = 5, waterNeed = 8, value = 70, dailyWateringLimit = 8}
    }
    
    selectedSeed = "Cabbage_seed" -- Default choice of cabbage seed

    -- Player-owned seeds and money 
    player = {
        kes = 10000.00,
        health = 100,
        maxHealth = 100,
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
    
    -- Product data 
    shopItems = {
        { name = "Cabbage_seed", basePrice = 50.00 },
        { name = "Sweet_Potato_seed",  basePrice = 80.00 }, 
        { name = "Maize_seed",   basePrice = 70.00 },
        { name = "Beans_seed", basePrice = 120.00 },
        { name = "Cabbage", basePrice = 100.00 },
        { name = "Sweet_Potato",  basePrice = 150.00 },
        { name = "Maize",   basePrice = 130.00 },
        { name = "Beans", basePrice = 250.00 }
    }
    
    -- Dynamic button positions
    buttonArea = {
        x = 0, width = 320,  -- Total width = 4 buttons * 80 spacing
        buttons = {
            {text = "-5", offset = 0},
            {text = "-1", offset = 70},
            {text = "+1", offset = 140},
            {text = "+5", offset = 210}
        }
    }
    selectedItem = 1
    quantity = 1
    
    -- popup system variable
    showDayPopup = false     
    showLevelPopup = false  
    showWinPopup = false     
    popupTimer = 0           
    popupDuration = 2        
    newDayNumber = 1         
    popupAlpha = 0           
    popupFadeIn = true      

    -- Raindrop particle initialization
    raindrops = {}
    for i = 1, 100 do
        table.insert(raindrops, {
            x = math.random(0, love.graphics.getWidth()),
            y = math.random(0, love.graphics.getHeight()),
            speed = math.random(200, 400)
        })
    end
    --  Add recipe data  --
    recipes = {
        ["Vegetable Soup"] = {
            ingredients = { Cabbage = 1 },
            baseHealth = 20
        },
        ["Bean Stew"] = {
            ingredients = { Beans = 2 },
            baseHealth = 30
        },
        ["Corn Porridge"] = {
            ingredients = { Maize = 1 },
            baseHealth = 25
        },
        ["Roasted Sweet Potato"] = {
            ingredients = { Sweet_Potato = 1 },
            baseHealth = 40
        }
    }
    --  Recipe data added --
    helpSection = nil  -- Currently selected help section
    helpTopicHover = nil  -- Current Mouse Hover Theme

    -- If the level popup is active, draw at the topmost level
    if showLevelPopup then
        drawLevelPopup()
    end
end

function love.update(dt)
    -- Calculate center position 
    local screenWidth = love.graphics.getWidth()
    buttonArea.x = (screenWidth - buttonArea.width) / 2

       -- Check if the health value is 0, if so clear the action points
       if player.health <= 0 then
        actionPoints = 0
    end

    if gameState == "game" and not waterMode and not showDayPopup and not showLevelPopup and not showWinPopup then
        local dx, dy = 0, 0
        Animation:update(dt)
    end
-- Check for proximity to the seed bar
        if gameState == "game" and not showDayPopup and not showLevelPopup and not showWinPopup then

        local inventoryY = love.graphics.getHeight() - 90  
        nearSeedBar = (Animation.player.y > inventoryY - 30 and Animation.player.y < inventoryY + 10)
        
        -- Check for proximity to plots
        local gridStartX = 250
        local gridStartY = 245
        local cellSize = 40
        local padding = 35
        
        nearPlot = false  -- Reset near parcel status
        
        for gridX = 1, gridSize do
            for gridY = 1, gridSize do
                local cellX = gridStartX + (gridX-1) * (cellSize + padding)
                local cellY = gridStartY + (gridY-1) * (cellSize + padding)
                
                local distance = math.sqrt((Animation.player.x - (cellX + cellSize/2))^2 + 
                                          (Animation.player.y - (cellY + cellSize/2))^2)
                
                if distance < 30 then  -- If the character is less than 30 pixels from the center of the plot
                    nearPlot = true
                    nearPlotX = gridX
                    nearPlotY = gridY
                    break
                end
            end
            if nearPlot then break end
        end
        
        -- Check for proximity to kitchen icons
        local kitchenDistance = math.sqrt((Animation.player.x - kitchenIconX)^2 + 
                                         (Animation.player.y - kitchenIconY)^2)
        nearKitchen = (kitchenDistance < 50)
        
        -- Interactive Tips
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
             -- Check if you have watered enough
        if plot.dailyWateringCount >= plot.wateringLimit then
            interactionTip = "It's watered enough"
            showInteractionTip = true
        else
            interactionTip = "Press F to water"
            showInteractionTip = true
        end
            elseif plot.status == "matured" then
                interactionTip = "Press space to harvest"
                showInteractionTip = true
            elseif plot.status == "locked" then
                interactionTip = "This lot is locked"
                showInteractionTip = true
            else
                showInteractionTip = false
            end
        else
            showInteractionTip = false
        end
    end

    -- Processing Day pop-up window timing and fade-in/out effects
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

    -- Handling level popup timing and fade-in/fade-out effects
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

    -- Handling pass popup timing and fade-in/fade-out effects
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

    -- Raindrop Animation Logic (Rainy Weather)
    if weather == "Rainy" and raindrops then
        for _, drop in ipairs(raindrops) do
            drop.y = drop.y + drop.speed * dt
            if drop.y > love.graphics.getHeight() then
                drop.y = 0
                drop.x = math.random(0, love.graphics.getWidth())
            end
        end
    end
    --  If water is less than 5, automatically skip to the next day
    if gameState == "game" and not showDayPopup and not showLevelPopup and not showWinPopup and water < 5 then
        advanceToNextDay()
    end

end

function love.draw()
    -- draw background
    love.graphics.setColor(1, 1, 1) 
    love.graphics.draw(gamebackground, 0, 0, 0, 
    love.graphics.getWidth() / gamebackground:getWidth(), 
    love.graphics.getHeight() / gamebackground:getHeight())


    if gameState == "menu" then
        drawMenu()
    elseif gameState == "game" then
        if waterMode then
            drawWateringMode() -- Enter the watering screen
        else
            drawGame()

            Animation:draw()
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
    
    -- Draw kitchen popup on top layer
    if showKitchenPopup then
        drawKitchenPopup()
    end
        
   -- If popup is active, draw it on top layer
    if showDayPopup then
        drawDayPopup()
    end
    -- If level popup is active, draw it on top layer
    if showLevelPopup then
    drawLevelPopup()
    end
    -- If win popup is active, draw it on top layer
    if showWinPopup then
        drawWinPopup()
    end

    -- Draw raindrops if it's rainy
    if gameState == "game" and weather == "Rainy" then
        love.graphics.setColor(1, 1, 1, 0.4)
        for _, drop in ipairs(raindrops) do
            love.graphics.line(drop.x, drop.y, drop.x, drop.y + 10)
        end
    end
    -- Apply overall dark filter for rainy weather
    if gameState == "game" and weather == "Rainy" then
        love.graphics.setColor(0, 0, 0, 0.4)  -- Semi-transparent black overlay
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end 
end

function drawMenu()
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Welcome to FarmED", 0, 150, love.graphics.getWidth(), "center")
    
    love.graphics.setFont(smallFont)
    love.graphics.printf("Sustainable Agriculture Education Game", 0, 220, love.graphics.getWidth(), "center")
    
    -- Menu options
    love.graphics.setColor(1, 0.9, 0.7)
    love.graphics.printf("Press ENTER to Start Game", 0, 300, love.graphics.getWidth(), "center")
    love.graphics.printf("Press H for Help", 0, 340, love.graphics.getWidth(), "center")
    
    -- Version information
    love.graphics.setFont(tinyFont)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Current Version: Stage 1 - Basic Farming", 0, 450, love.graphics.getWidth(), "center")
end

function drawGame()
    -- Top status bar
    drawStatusBar()
    
    -- Farm grid
    drawGrid()

    -- Draw character
    -- drawCharacter()

     -- Draw kitchen icon (simple block)
     love.graphics.setColor(0.9, 0.8, 0.5) -- Light yellow kitchen icon
     love.graphics.rectangle("fill", kitchenIconX, kitchenIconY, 40, 40)
     love.graphics.setColor(0.6, 0.5, 0.3) -- Brown border
     love.graphics.rectangle("line", kitchenIconX, kitchenIconY, 40, 40)
     love.graphics.setFont(tinyFont)
     love.graphics.setColor(0.3, 0.2, 0.1) -- Dark brown text
     love.graphics.printf("Kitchen", kitchenIconX, kitchenIconY + 15, 40, "center")
    
    -- Bottom control bar
    drawControlBar()
end

function drawStatusBar()
    -- Increase status bar height to 50 pixels to make it more spacious
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 70)
    
    -- Set font and color
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1)
    
    -- Calculate width for each status item
    local screenWidth = love.graphics.getWidth()
    local itemWidth = screenWidth / 5
    
    -- Evenly distribute five status items, using center alignment
    love.graphics.printf("Day " .. day, 0, 15, itemWidth, "center")
    love.graphics.printf("Balance: " .. formatKES(player.kes), itemWidth, 15, itemWidth, "center")
    love.graphics.printf("Action Points: " .. actionPoints .. "/20", itemWidth*2, 15, itemWidth, "center")
    love.graphics.printf("Weather: " .. weather, itemWidth*3, 15, itemWidth, "center")
    love.graphics.printf("Water: " .. water, itemWidth*4, 15, itemWidth, "center")
      -- Health display - set different colors based on health value
      if player.health <= 0 then
        love.graphics.setColor(1, 0, 0) -- Red indicates severe hunger
    elseif player.health < 30 then
        love.graphics.setColor(1, 0.5, 0) -- Orange indicates warning
    else
        love.graphics.setColor(0.2, 1, 0.2) -- Green indicates health
    end
    love.graphics.printf("Health: " .. player.health, 0, 40, itemWidth, "center")  -- X=0对齐Day，Y=40
    
    -- If health is 0, display hunger warning
    if player.health <= 0 then
        love.graphics.setColor(1, 0, 0) 
        love.graphics.printf("STARVING! CANNOT TAKE ACTIONS!", 0, 70, screenWidth, "center")
    end
    love.graphics.setColor(1, 1, 1)  -- Restore default white color
end

function drawGrid()
    local gridStartX = 250
    local gridStartY = 245
    local cellSize = 40 
    local padding = 35
    local gridSize = 4  

    love.graphics.setFont(tinyFont)

     -- Preload lock icon (only load on first run)
     if not lockIcon then
        lockIcon = love.graphics.newImage("art/lock.png")
        -- Dynamically calculate lock icon scaling ratio
        lockIconScale = math.min(
            (cellSize * 1.3) / lockIcon:getWidth(),  -- According to width ratio
            (cellSize * 1.3) / lockIcon:getHeight()  -- According to height ratio
        )
    end

    for x = 1, gridSize do
        for y = 1, gridSize do
            local cellX = gridStartX + (x-1) * (cellSize + padding)
            local cellY = gridStartY + (y-1) * (cellSize + padding)
            
            -- Draw land grid
            -- Unified setting: all land grids completely transparent (no base color or border)
            -- Only locked land displays lock icon
            if grid[x][y].status == "locked" then
                -- Calculate lock icon center position (accurate to pixel)
                local lockW = lockIcon:getWidth() * lockIconScale
                local lockH = lockIcon:getHeight() * lockIconScale
                local lockX = cellX + (cellSize - lockW) / 2
                local lockY = cellY + (cellSize - lockH) / 2
                
                -- Draw lock icon (light gray, 60% transparency)
                love.graphics.setColor(0.8, 0.8, 0.8, 0.6)
                love.graphics.draw(lockIcon, lockX, lockY, 0, lockIconScale, lockIconScale)
            end
            
            -- Crop and progress bar drawing
            if grid[x][y].status == "planted" or grid[x][y].status == "matured" then  
                local plot = grid[x][y]
                local cropKey = plot.crop

                -- Draw crop image
                if cropKey and cropImages then
                    local img
                    local plot = grid[x][y]
                    
                    -- Select different images based on growth stage
                    if plot.status == "matured" then
                        -- Mature stage uses image name without "_seed" suffix
                        img = cropImages[cropKey:gsub("_seed", "")]
                    elseif plot.growth / crops[cropKey].growthTime >= 0.5 then
                        -- Middle stage uses image name with "_mid" suffix
                        img = cropImages[cropKey:gsub("_seed", "_mid")]
                    else
                        -- Seed stage uses original image
                        img = cropImages[cropKey]
                    end
                    
                    if img then
                        local imgScale = (cellSize * 1.2) / math.max(img:getWidth(), img:getHeight())
                        local drawX = cellX + (cellSize - img:getWidth() * imgScale) / 2
                        local drawY = cellY + (cellSize - img:getHeight() * imgScale) / 2
                        
                        love.graphics.setColor(1, 1, 1)
                        love.graphics.draw(img, drawX, drawY, 0, imgScale, imgScale)
                    end
                end

                -- Draw dual progress bars (adjusted to the top edge of the grid)
                local cropData = crops[cropKey]
                if cropData then
                    local barWidth = cellSize - 4
                    local barHeight = 3
                    local barX = cellX + 2
                    local barY = cellY - 8  

                    -- Water progress bar (blue, with semi-transparent background)
                    love.graphics.setColor(0, 0, 0, 0.5)
                    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
                    love.graphics.setColor(0.2, 0.5, 1)
                    -- Use wateringProgress to display watering progress
                    love.graphics.rectangle("fill", barX, barY, barWidth * math.min(plot.wateringProgress / cropData.dailyWateringLimit, 1), barHeight)

                    -- Maturity progress bar (green, above)
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
    -- Ensure barY has a value, defined locally rather than depending on global variables
    local barY = love.graphics.getHeight() - 60
    
    -- Control bar background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, barY, love.graphics.getWidth(), 60)
    
    -- Control buttons
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1)
    
    -- Next day button
    love.graphics.printf("[N] Next Day", 20, barY + 15, 150, "left")
    
    -- Shop button
    love.graphics.printf("[S] Shop", 200, barY + 15, 150, "left")
    
    -- Warehouse button
    love.graphics.printf("[C] Warehouse", 320, barY + 15, 150, "left")
    
    -- Help button
    love.graphics.printf("[H] Help", 500, barY + 15, 150, "left")

    -- Watering
    love.graphics.printf("[T] Enter Watering Mode", 610, barY + 15, 200, "left")
    
    -- Seed inventory bar
    local inventoryY = barY - 30
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, inventoryY, love.graphics.getWidth(), 30)
    
    -- Seed icons and quantities
    local seedKeys = {"Cabbage_seed", "Beans_seed", "Maize_seed", "Sweet_Potato_seed"}
    local seedLabels = {"[Q] Cabbage", "[W] Beans", "[E] Maize", "[R] Sweet Potato"}
    local startX = 20
    local iconSpacing = 160
    
    for i, key in ipairs(seedKeys) do
        -- Highlight currently selected seed
        if key == selectedSeed then
            love.graphics.setColor(1, 0.8, 0, 0.6)
            love.graphics.rectangle("fill", startX + (i-1) * iconSpacing - 5, inventoryY, 150, 30)
        end
        
        -- Display seed icon
        if cropImages and cropImages[key] then
            love.graphics.setColor(1, 1, 1)
            local iconSize = 20
            local imgScale = iconSize / cropImages[key]:getWidth()
            love.graphics.draw(cropImages[key], startX + (i-1) * iconSpacing, inventoryY + 5, 0, imgScale, imgScale)
        end
        
        -- Display seed name and quantity
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(tinyFont)
        love.graphics.print(seedLabels[i] .. ": " .. (player.inventory[key] or 0), startX + (i-1) * iconSpacing + 25, inventoryY + 8)
    end
end

-- Transaction interface function inherited from shop.lua
function drawTransactionInterface(title, isShop)
    -- Semi-transparent background panel
    love.graphics.setColor(0.1, 0.1, 0.1, 0.85)
    love.graphics.rectangle("fill", 50, 80, 700, 500, 10)

    -- Title
    love.graphics.setColor(0.9, 0.9, 0.2)
    love.graphics.setFont(font)
    love.graphics.printf(title, 50, 100, 700, "center")

    -- Item list
    love.graphics.setFont(smallFont)
    local items = filterItems(isShop)
    for i, item in ipairs(items) do
        local yPos = 160 + (i-1)*55
        -- Selection highlight
        love.graphics.setColor(i == selectedItem and {1,0.8,0,0.3} or {0,0,0,0})
        love.graphics.rectangle("fill", 60, yPos-5, 680, 45, 5)
        
        -- Item information
        love.graphics.setColor(1,1,1)
        local displayName = item.name:gsub("_", " "):upper()
        love.graphics.printf(displayName, 80, yPos, 300, "left")
        love.graphics.printf(formatKES(isShop and item.basePrice or item.basePrice*0.8), 400, yPos, 200, "right")
        love.graphics.printf("Stock: "..(player.inventory[item.name] or 0), 620, yPos, 100, "right")
    end

    -- Centered control panel
    drawControlPanel(isShop and "B - Confirm Buy" or "S - Confirm Sell")
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.9, 0.9, 0.2)
    local balanceText = "Balance: "..formatKES(player.kes)
    love.graphics.printf(balanceText, 60, 540, 300, "left")  -- Position: X60,Y520
end

-- Inherited control panel function from shop.lua
function drawControlPanel(actionText)
    -- Button background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
    love.graphics.rectangle("fill", buttonArea.x-30, 390, buttonArea.width+10, 65, 5)

    -- Quantity buttons
    love.graphics.setFont(smallFont)
    for _, btn in ipairs(buttonArea.buttons) do
        local btnX = buttonArea.x + btn.offset
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", btnX, 400, 60, 40, 3)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(btn.text, btnX, 410, 60, "center")
    end

    -- Quantity display
    love.graphics.printf("QUANTITY: "..quantity, buttonArea.x, 470, buttonArea.width, "center")
    love.graphics.printf(actionText.."\nESC - Cancel", buttonArea.x, 490, buttonArea.width, "center")
end

function drawHelp()
    -- Create dark semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 20, 20, love.graphics.getWidth() - 40, love.graphics.getHeight() - 40, 10)
    
    -- Title
    love.graphics.setFont(font) -- Use existing main font
    love.graphics.setColor(1, 1, 0.8)
    love.graphics.printf("FarmED - Game Guide", 0, 40, love.graphics.getWidth(), "center")
    
    -- Return to game prompt
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 0.7, 0.7)
    love.graphics.printf("Press ESC to return to game", 0, love.graphics.getHeight() - 50, love.graphics.getWidth(), "center")
    
    if helpSection == nil then
        -- Display topic list
        drawHelpTopics()
    else
        -- Display content of selected topic
        drawHelpContent(helpSection)
        
        -- Back button
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.9, 0.8, 0.3)
        love.graphics.printf("Press BACKSPACE to return to topics", 0, love.graphics.getHeight() - 80, love.graphics.getWidth(), "center")
    end
end

-- Draw help topic list
function drawHelpTopics()
    local topics = {
        {title = "1. How to Play", id = "howtoplay"},
        {title = "2. Basic Controls", id = "controls"},
        {title = "3. Interface Controls", id = "interface"},
        {title = "4. Seed Selection", id = "seeds"},
        {title = "5. Game Levels", id = "levels"},
        {title = "6. Crop Information", id = "crops"},
        {title = "7. Game Tips", id = "tips"}
    }
    
    -- Define font and color
    local headerFont = love.graphics.newFont(24)
    love.graphics.setFont(headerFont)
    
    -- Centered layout
    local centerX = love.graphics.getWidth() / 2
    local startY = 120
    local lineHeight = 50
    
    -- Draw topic list
    for i, topic in ipairs(topics) do
        -- Check if mouse is hovering over this topic
        local textWidth = headerFont:getWidth(topic.title)
        local textX = centerX - textWidth / 2
        local textY = startY + (i-1) * lineHeight
        local mouseX, mouseY = love.mouse.getPosition()
        
        if mouseX >= textX and mouseX <= textX + textWidth and 
           mouseY >= textY and mouseY <= textY + headerFont:getHeight() then
            -- 鼠标悬停时高亮显示
            love.graphics.setColor(1, 1, 0)
            
            -- 更新悬停的主题ID，用于点击处理
            helpTopicHover = topic.id
        else
            love.graphics.setColor(0.9, 0.9, 0.7)
        end
        
        -- 绘制主题文本
        love.graphics.printf(topic.title, 0, textY, love.graphics.getWidth(), "center")
    end
    
    -- 提示文本
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.7, 0.7, 0.9)
    love.graphics.printf("Click on a topic to view details", 0, startY + #topics * lineHeight + 20, love.graphics.getWidth(), "center")
end

-- 绘制特定主题的内容
function drawHelpContent(section)
    local headerFont = love.graphics.newFont(20)
    local contentFont = love.graphics.newFont(16)
    love.graphics.setFont(headerFont)
    
    -- 各部分内容
    if section == "howtoplay" then
        -- 如何游戏部分
        love.graphics.setColor(1, 1, 0.3)
        love.graphics.printf("How to Play", 0, 100, love.graphics.getWidth(), "center")
        
        love.graphics.setFont(contentFont)
        love.graphics.setColor(1, 1, 1)
        local startY = 150
        local lineHeight = 35
        
        local steps = {
            "1. Plant seeds in empty plots",
            "2. Water your plants daily",
            "3. Harvest mature crops",
            "4. Sell crops at the warehouse",
            "5. Buy new seeds at the shop",
            "6. Cook meals in the kitchen to restore health"
        }
        
        for i, step in ipairs(steps) do
            love.graphics.printf(step, 100, startY + (i-1) * lineHeight, love.graphics.getWidth() - 200, "left")
        end
        
    elseif section == "controls" then
        -- 基本控制部分
        love.graphics.setColor(1, 1, 0.3)
        love.graphics.printf("Basic Controls", 0, 100, love.graphics.getWidth(), "center")
        
        love.graphics.setFont(contentFont)
        love.graphics.setColor(1, 1, 1)
        local startY = 150
        local lineHeight = 40
        
        local controls = {
            {"Movement:", "Arrow Keys"},
            {"Plant/Harvest:", "SPACE"},
            {"Water Plant:", "F"},
            {"Next Day:", "N"},
            {"Kitchen Menu:", "K"}
        }
        
        for i, control in ipairs(controls) do
            love.graphics.printf(control[1], 200, startY + (i-1) * lineHeight, 200, "left")
            love.graphics.printf(control[2], 400, startY + (i-1) * lineHeight, 200, "left")
        end
        
    elseif section == "interface" then
        -- 界面控制部分
        love.graphics.setColor(1, 1, 0.3)
        love.graphics.printf("Interface Controls", 0, 100, love.graphics.getWidth(), "center")
        
        love.graphics.setFont(contentFont)
        love.graphics.setColor(1, 1, 1)
        local startY = 150
        local lineHeight = 40
        
        local controls = {
            {"Shop:", "S"},
            {"Warehouse:", "C"},
            {"Help Screen:", "H"},
            {"Back/Cancel:", "ESC"},
            {"Watering Mode:", "T"}
        }
        
        for i, control in ipairs(controls) do
            love.graphics.printf(control[1], 200, startY + (i-1) * lineHeight, 200, "left")
            love.graphics.printf(control[2], 400, startY + (i-1) * lineHeight, 200, "left")
        end
        
    elseif section == "seeds" then
        -- 种子选择部分
        love.graphics.setColor(1, 1, 0.3)
        love.graphics.printf("Seed Selection", 0, 100, love.graphics.getWidth(), "center")
        
        love.graphics.setFont(contentFont)
        love.graphics.setColor(1, 1, 1)
        local startY = 150
        local lineHeight = 40
        
        local seeds = {
            {"Cabbage:", "Q"},
            {"Beans:", "W"},
            {"Maize:", "E"},
            {"Sweet Potato:", "R"}
        }
        
        for i, seed in ipairs(seeds) do
            love.graphics.printf(seed[1], 200, startY + (i-1) * lineHeight, 200, "left")
            love.graphics.printf(seed[2], 400, startY + (i-1) * lineHeight, 200, "left")
        end
        
    elseif section == "levels" then
        -- 游戏关卡部分
        love.graphics.setColor(1, 1, 0.3)
        love.graphics.printf("Game Levels", 0, 100, love.graphics.getWidth(), "center")
        
        love.graphics.setFont(contentFont)
        love.graphics.setColor(1, 1, 1)
        local startY = 150
        local lineHeight = 35
        
        -- Level 1
        love.graphics.setColor(0.9, 0.9, 0.4)
        love.graphics.printf("Level 1", 100, startY, 300, "left")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("• 2x2 grid (4 plots)", 120, startY + lineHeight, 600, "left")
        love.graphics.printf("• Goal: Harvest 1 of each crop", 120, startY + lineHeight*2, 600, "left")
        
        -- Level 2
        love.graphics.setColor(0.9, 0.9, 0.4)
        love.graphics.printf("Level 2", 100, startY + lineHeight*3.5, 300, "left")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("• 3x3 grid (9 plots)", 120, startY + lineHeight*4.5, 600, "left")
        love.graphics.printf("• Goal: Harvest 3 of each crop", 120, startY + lineHeight*5.5, 600, "left")
        
        -- Level 3
        love.graphics.setColor(0.9, 0.9, 0.4)
        love.graphics.printf("Level 3", 100, startY + lineHeight*7, 300, "left")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("• 4x4 grid (16 plots)", 120, startY + lineHeight*8, 600, "left")
        love.graphics.printf("• Goal: Harvest 5 of each crop", 120, startY + lineHeight*9, 600, "left")
        
    elseif section == "crops" then
        -- 作物信息部分
        love.graphics.setColor(1, 1, 0.3)
        love.graphics.printf("Crop Information", 0, 100, love.graphics.getWidth(), "center")
        
        love.graphics.setFont(contentFont)
        love.graphics.setColor(1, 1, 1)
        local startY = 150
        local lineHeight = 35
        
        local cropInfo = {
            "• Cabbage: Fast growth (2 days), medium water needs (4), value: 15",
            "• Beans: Medium growth (3 days), low water needs (2), value: 30",
            "• Maize: Slow growth (4 days), high water needs (6), value: 50",
            "• Sweet Potato: Slowest growth (5 days), highest water needs (8), value: 70"
        }
        
        for i, info in ipairs(cropInfo) do
            love.graphics.printf(info, 100, startY + (i-1) * lineHeight*1.5, love.graphics.getWidth() - 200, "left")
        end
        
        -- 增加浇水提示
        love.graphics.setColor(0.7, 1, 0.7)
        love.graphics.printf("Remember to water plants according to their needs!", 100, startY + #cropInfo * lineHeight*1.5 + 20, love.graphics.getWidth() - 200, "left")
        love.graphics.printf("Each crop has a daily watering limit. Overwatering wastes resources.", 100, startY + #cropInfo * lineHeight*1.5 + 60, love.graphics.getWidth() - 200, "left")
        
    elseif section == "tips" then
        -- 游戏提示部分
        love.graphics.setColor(1, 1, 0.3)
        love.graphics.printf("Game Tips", 0, 100, love.graphics.getWidth(), "center")
        
        love.graphics.setFont(contentFont)
        love.graphics.setColor(1, 1, 1)
        local startY = 150
        local lineHeight = 35
        
        local tips = {
            "• Each action costs 1 point",
            "• Rainy days provide more water (100 vs 80 on sunny days)",
            "• Health decreases by 5 points each day",
            "• Low health (below 30) reduces action points to 10",
            "• At 0 health, you cannot take any actions",
            "• Cook meals in the kitchen to restore health",
            "• The daily recommended meal provides 20% more health restoration",
            "• Water will be used up faster with high-water-need crops",
            "• When water depletes below 5, you automatically advance to next day"
        }
        
        for i, tip in ipairs(tips) do
            love.graphics.printf(tip, 100, startY + (i-1) * lineHeight, love.graphics.getWidth() - 200, "left")
        end
    end
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
    love.graphics.printf("Great job planting and harvesting! Keep growing—food security starts with you!", popupX, popupY + 90, popupWidth, "center")
    
    -- 继续提示
    love.graphics.setFont(tinyFont)
    love.graphics.setColor(0.9, 0.9, 0.2, math.sin(love.timer.getTime() * 5) * 0.5 + 0.5 * popupAlpha)
    love.graphics.printf("Press any key to continue", popupX, popupY + 230, popupWidth, "center")
end

function drawKitchenPopup()
    -- 弹窗尺寸设置 (600x500)
    local popupWidth = 600
    local popupHeight = 500
    local popupX = (love.graphics.getWidth() - popupWidth) / 2
    local popupY = (love.graphics.getHeight() - popupHeight) / 2

    -- 字体设置（标题/内容/小字）
    local titleFont = love.graphics.newFont(24)
    local contentFont = love.graphics.newFont(18)
    local smallFont = love.graphics.newFont(16)

    -- 绘制黄色背景
    love.graphics.setColor(1, 0.95, 0.7)
    love.graphics.rectangle("fill", popupX, popupY, popupWidth, popupHeight, 10)
    love.graphics.setColor(0.6, 0.5, 0.3)
    love.graphics.rectangle("line", popupX, popupY, popupWidth, popupHeight, 10)

    -- 主标题
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.3, 0.2, 0.1)
    love.graphics.printf("KITCHEN", popupX, popupY + 20, popupWidth, "center")

    -- 今日特餐
    love.graphics.setFont(contentFont)
    love.graphics.printf("Today’s Recommended Menu:", popupX, popupY + 70, popupWidth, "center")
    love.graphics.setColor(0.7, 0.3, 0.1)
    love.graphics.printf(kitchenMenu.dailyMeal, popupX, popupY + 100, popupWidth, "center")

    -- 配方列表
    love.graphics.setFont(contentFont)
    local startY = popupY + 150
    local lineSpacing = 35

    for i, mealName in ipairs(possibleMeals) do
        local recipe = recipes[mealName]
        local ingredientsText = ""
        local canCraft = true

        -- 生成材料需求文本
        for item, amount in pairs(recipe.ingredients) do
            ingredientsText = ingredientsText .. item .. " x" .. amount .. "  "
            if (player.inventory[item] or 0) < amount then
                canCraft = false
            end
        end

        -- 设置文字颜色
        local textColor = canCraft and {0.2, 0.5, 0.2} or {0.5, 0.5, 0.5}
        local healthValue = recipe.baseHealth

        -- 当日特餐加成
        if kitchenMenu.dailyMeal == mealName then
            healthValue = healthValue * 1.2
        end

        -- 左列：配方编号和名称
        love.graphics.setColor(textColor)
        love.graphics.printf(i .. ". " .. mealName, popupX + 30, startY, 300, "left")

        -- 右列：材料需求和恢复值
        love.graphics.printf(ingredientsText .. "+" .. math.floor(healthValue) .. " HP", 
            popupX + 300, startY, 250, "right")

        startY = startY + lineSpacing
    end

    -- 库存显示
    love.graphics.printf(
    "Food Inventory:\n"..
    "Cabbage: " .. (player.inventory.Cabbage or 0) .. "  " ..
    "Sweet Potato: " .. (player.inventory.Sweet_Potato or 0) .. "  " ..
    "Maize: " .. (player.inventory.Maize or 0) .. "  " ..
    "Beans: " .. (player.inventory.Beans or 0),
    popupX + 30, popupY + 400, popupWidth - 60, "left"
)

    -- 健康值显示
    love.graphics.setFont(contentFont)
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.printf("HEALTH: " .. player.health .. "/" .. player.maxHealth, 
        popupX, popupY + 440, popupWidth, "center")

    -- 关闭提示
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.4, 0.3, 0.2)
    love.graphics.printf("Press ESC to close", popupX, popupY + 470, popupWidth, "center")
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
    love.graphics.setFont(smallFont)
    local startY = 180
    local spacing = 40
    love.graphics.printf("SweetPotatos (-3 Water)", 0, startY, love.graphics.getWidth(), "center")
    love.graphics.printf("Beans (-5 Water)", 0, startY + spacing, love.graphics.getWidth(), "center")
    love.graphics.printf("Cabbage (-7 Water)", 0, startY + spacing * 2, love.graphics.getWidth(), "center")
    love.graphics.printf("Maize (-9 Water)", 0, startY + spacing * 3, love.graphics.getWidth(), "center")

    -- **水条参数**
    local barWidth = 300 -- 水条的最大宽度
    local barHeight = 20 -- 水条高度
    local barX = love.graphics.getWidth() / 2 - barWidth / 2 -- 水条位置
    local barY = startY + spacing * 5 -- 水条位置（放在作物选项下方）
    
    -- **绘制水条背景**
    love.graphics.setColor(0.2, 0.2, 0.2) -- 灰色背景
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
    -- **绘制当前水量**
    local waterRatio = math.max(water / 100, 0) -- 计算水量比例（最大 100）
    love.graphics.setColor(0.0, 0.7, 1.0) -- 蓝色水条
    love.graphics.rectangle("fill", barX, barY, barWidth * waterRatio, barHeight)
    
    -- **显示水量数值**
    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Water: " .. water .. " / 100", 0, barY + 40, love.graphics.getWidth(), "center")
    
    -- 退出提示
    love.graphics.setColor(1, 0.7, 0.7)
    love.graphics.printf("Press ESC to Exit", 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
end

function love.keypressed(key)
    if waterMode and key == "escape" then
        waterMode = false
        return
    end
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
        -- 新增食物制作逻辑 --
        if showKitchenPopup then
            if key >= "1" and key <= "4" then
                local index = tonumber(key)
                local mealName = possibleMeals[index]
                if mealName and recipes[mealName] then
                    local recipe = recipes[mealName]
                    local canCraft = true
                    
                    -- 检查材料
                    for item, amount in pairs(recipe.ingredients) do
                        if (player.inventory[item] or 0) < amount then
                            canCraft = false
                            break
                        end
                    end
                    
                    if canCraft then
                        -- 扣除材料
                        for item, amount in pairs(recipe.ingredients) do
                            if (player.inventory[item] or 0) < amount then
                                canCraft = false
                                break
                            end
                        end
                        -- 消耗食材
                        for item, amount in pairs(recipe.ingredients) do
                            player.inventory[item] = player.inventory[item] - amount
                        end
                        -- 计算恢复值并更新健康--
                        local healthGain = recipe.baseHealth
                        if kitchenMenu.dailyMeal == mealName then
                            healthGain = math.floor(healthGain * 1.2)
                        end
                        -- 添加健康上限限制
                        player.health = math.min(player.maxHealth, player.health + healthGain)
                    else
                        print("Not enough ingredients!")
                    end
                end
            end
            return  -- 阻止其他按键处理
        end
        -- 逻辑结束 --

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
        -- 直接处理 F 键浇水，不再需要 waterMode
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
            local r = math.random()  -- 返回 0~1 的随机小数
            if r < 0.2 then         -- 20% 的概率雨天
                weather = "Rainy"
            else                   -- 80% 的概率晴天
                weather = "Sunny"
            end
            
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
             -- 如果健康值为0，不允许任何消耗行动点的操作
    if player.health <= 0 then
        return
    end
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
                            end
                        end
                        
                        -- 清除格子
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
            if helpSection ~= nil then
                -- 如果在章节页面，按ESC返回主题列表
                helpSection = nil
            else
                -- 如果在主题列表，按ESC返回游戏
                if previousGameState then
                    gameState = previousGameState
                else
                    gameState = "game"
                end
            end
        elseif key == "backspace" and helpSection ~= nil then
            -- 按Backspace键也可以返回主题列表
            helpSection = nil
        end
    end

    print("Current gameState: " .. gameState)
end

function handleNavigation(key)
    local items = filterItems(gameState == "shop") -- 获取当前商品列表（商店或仓库）
    
    -- 上下键选择商品
    if key == "up" then
        selectedItem = math.max(1, selectedItem - 1)
    elseif key == "down" then
        selectedItem = math.min(#items, selectedItem + 1)
    
    -- 商店购买/仓库出售
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
      -- 添加帮助界面的鼠标点击处理
      if gameState == "help" and button == 1 then
        if helpSection == nil and helpTopicHover ~= nil then
            -- 如果在主题列表页面点击了某个主题
            helpSection = helpTopicHover
        end
    end
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

                        -- 成熟作物收割
                        elseif grid[gridX][gridY].status == "matured" and actionPoints > 0 then
                            local cropKey = grid[gridX][gridY].crop
                            local cropName = cropKey:gsub("_seed", "")
                            player.inventory[cropName] = (player.inventory[cropName] or 0) + 1  -- 直接存入作物
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
    --  每日健康减少  --
    player.health = math.max(0, player.health - 5)  -- 每天减少5点健康值
    
        --  修改特餐设置  --
    -- 随机选择当日特餐
    kitchenMenu.dailyMeal = possibleMeals[math.random(1, #possibleMeals)]
    -- 重置所有配方加成
    for _, recipe in pairs(recipes) do
        recipe.health = recipe.baseHealth  -- 清除之前的加成
    end
    -- 设置当日特餐加成
    if recipes[kitchenMenu.dailyMeal] then
        recipes[kitchenMenu.dailyMeal].health = recipes[kitchenMenu.dailyMeal].baseHealth * 1.2
    end
    
    -- 重置行动点
    actionPoints = 20
    
     -- 根据健康值调整行动点
     if player.health <= 0 then
        actionPoints = 0  -- 健康值为0时无法行动
        player.maxHealth = 100  -- 重置最大健康值（防止修改）
    elseif player.health <= 30 then
        actionPoints = 10  -- 健康值过低时行动点上限为10
        player.maxHealth = 100  -- 重置最大健康值（防止修改）
    else
        actionPoints = 20  -- 正常行动点
    end
    
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

function drawInteractionTip()
    -- 绘制交互提示
    if showInteractionTip and interactionTip ~= "" then
        local tipX = Animation.player.x
        local tipY = Animation.player.y - 30
        
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
                print(string.format("Check the plot[%d,%d],distance %.2f", gridX, gridY, dist))

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
