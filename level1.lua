local Level1 = {
    -- 基础游戏设置
    initialMoney = 500,        -- 起始金币，比原来更合理的数值
    dayDuration = 40,          -- 白天持续时间
    nightDuration = 10,        -- 夜晚持续时间
    requiredCustomers = 1,     -- 需要服务的客户数

    -- 基础种植系统
    availableCrops = {
        lettuce = {
            name = "生菜",
            growthTime = 7,     -- 生长周期（天）
            cost = 20,          -- 种子成本
            sellPrice = 40,     -- 售价
            waterNeeded = 2,    -- 每天需水量
            droughtTolerance = 2, -- 能承受几天不浇水
            nutritionValue = 10 -- 营养价值
        },
        carrot = {
            name = "胡萝卜",
            growthTime = 14,    -- 生长周期（天）
            cost = 30,          -- 种子成本
            sellPrice = 70,     -- 售价
            waterNeeded = 1,    -- 每天需水量
            droughtTolerance = 3, -- 能承受几天不浇水
            nutritionValue = 15 -- 营养价值
        }
    },

    -- 起始农场资源
    startingResources = {
        seeds = {
            lettuce = 10,       -- 初始生菜种子数量
            carrot = 10         -- 初始胡萝卜种子数量
        },
        tools = {
            wateringCan = 1,    -- 浇水工具
            hoe = 1             -- 锄头
        },
        water = 100,            -- 初始水资源
        energy = 100            -- 玩家能量/体力
    },

    -- 农场布局
    farmLayout = {
        plots = {
            {x = 300, y = 200, status = "empty", crop = nil, plantedDay = 0, waterLevel = 0, dryDays = 0},
            {x = 350, y = 200, status = "empty", crop = nil, plantedDay = 0, waterLevel = 0, dryDays = 0}
        }
    },

    -- 时间系统
    timeSystem = {
        currentDay = 1,
        currentWeek = 1,
        dayTime = "day",        -- "day" 或 "night"
        weatherForecast = {     -- 简单的天气预报系统
            {day = 1, weather = "sunny"},
            {day = 2, weather = "sunny"},
            {day = 3, weather = "rainy"},
            {day = 4, weather = "sunny"},
            {day = 5, weather = "cloudy"},
            {day = 6, weather = "sunny"},
            {day = 7, weather = "sunny"}
        }
    },

    -- 关卡目标
    objectives = {
        harvestLettuce = 5,     -- 收获5个生菜
        harvestCarrots = 3,     -- 收获3个胡萝卜
        weeksSurvived = 1,      -- 维持1周的食物供应
        seedsRemaining = 5      -- 保留至少5颗种子
    },

    -- 游戏教程提示
    tutorials = {
        {id = "welcome", text = "Welcome to the Sustainable Farm Simulation Game! This is the first level: basic planting."},
        {id = "planting", text = "Choose a piece of land and use seeds to plant crops. Lettuce takes one week to mature, while carrots take two weeks."},
        {id = "watering", text = "Remember to water the crops every day! Different crops require varying amounts of water. If not watered for a long time, crops will wither and die!"},
        {id = "harvesting", text = "After the crops are ripe, click on harvest. You can use them to make food or sell."},
        {id = "objective", text = "Goal: Plant and harvest enough food to sustain for a week while retaining enough seeds."}
    }
}

function Level1:getDayInfo()
    return {
        day = self.timeSystem.currentDay,
        week = self.timeSystem.currentWeek,
        dayTime = self.timeSystem.dayTime,
        weather = self:getCurrentWeather()
    }
end

function Level1:getCurrentWeather()
    local dayIndex = (self.timeSystem.currentDay - 1) % 7 + 1
    return self.timeSystem.weatherForecast[dayIndex].weather
end

function Level1:advanceDay()
    self.timeSystem.currentDay = self.timeSystem.currentDay + 1
    if self.timeSystem.currentDay > 7 then
        self.timeSystem.currentDay = 1
        self.timeSystem.currentWeek = self.timeSystem.currentWeek + 1
    end
    
    -- 更新作物生长和水分状态
    self:updateCrops()
    
    -- 如果是下雨天，自动给所有地块增加水分
    local weather = self:getCurrentWeather()
    if weather == "rainy" then
        for i, plot in ipairs(self.farmLayout.plots) do
            if plot.status == "planted" then
                plot.waterLevel = plot.waterLevel + 3
                plot.dryDays = 0
            end
        end
    end
    
    -- 恢复玩家能量
    self.startingResources.energy = 100
    
    return self:getDayInfo()
end

function Level1:updateCrops()
    for i, plot in ipairs(self.farmLayout.plots) do
        if plot.status == "planted" and plot.crop then
            local cropType = plot.crop
            local daysGrown = self.timeSystem.currentDay - plot.plantedDay
            local cropInfo = self.availableCrops[cropType]
            
            -- 检查水分是否充足
            if plot.waterLevel < cropInfo.waterNeeded then
                -- 水分不足，记录干旱天数
                plot.dryDays = plot.dryDays + 1
                
                -- 检查是否超过作物的耐旱能力
                if plot.dryDays > cropInfo.droughtTolerance then
                    -- 作物枯萎
                    plot.status = "withered"
                    return
                end
                
                -- 作物因缺水生长缓慢
                daysGrown = daysGrown - 0.5
            else
                -- 消耗水分
                plot.waterLevel = plot.waterLevel - cropInfo.waterNeeded
                -- 重置干旱天数
                plot.dryDays = 0
            end
            
            -- 检查是否成熟
            if daysGrown >= cropInfo.growthTime then
                plot.status = "ready"
            end
        end
    end
end

function Level1:plantCrop(plotIndex, cropType)
    local plot = self.farmLayout.plots[plotIndex]
    
    -- 检查条件
    if plot.status ~= "empty" then
        return false, "This land has already been planted with crops"
    end
    
    if self.startingResources.seeds[cropType] <= 0 then
        return false, "Not enough seeds"
    end
    
    if self.startingResources.energy < 10 then
        return false, "Insufficient energy, unable to plant"
    end
    
    -- 种植作物
    plot.status = "planted"
    plot.crop = cropType
    plot.plantedDay = self.timeSystem.currentDay
    plot.waterLevel = 0
    plot.dryDays = 0
    
    -- 消耗资源
    self.startingResources.seeds[cropType] = self.startingResources.seeds[cropType] - 1
    self.startingResources.energy = self.startingResources.energy - 10
    
    return true, "Successfully planted" .. self.availableCrops[cropType].name
end

function Level1:waterCrop(plotIndex)
    local plot = self.farmLayout.plots[plotIndex]
    
    -- 检查条件
    if plot.status ~= "planted" then
        return false, "No crops need watering"
    end
    
    if self.startingResources.water <= 0 then
        return false, "Not enough water"
    end
    
    if self.startingResources.energy < 5 then
        return false, "Insufficient energy, unable to water"
    end
    
    -- 浇水
    plot.waterLevel = plot.waterLevel + 5
    -- 重置干旱天数
    plot.dryDays = 0
    
    -- 消耗资源
    self.startingResources.water = self.startingResources.water - 5
    self.startingResources.energy = self.startingResources.energy - 5
    
    return true, "Successfully watered the crops"
end

function Level1:harvestCrop(plotIndex)
    local plot = self.farmLayout.plots[plotIndex]
    
    -- 检查条件
    if plot.status ~= "ready" then
        return false, "The crops are not ready for harvest yet"
    end
    
    if self.startingResources.energy < 8 then
        return false, "The crops are not ready for harvest yet"
    end
    
    local cropType = plot.crop
    local harvestAmount = 1
    
    -- 消耗能量
    self.startingResources.energy = self.startingResources.energy - 8
    
    -- 重置地块
    plot.status = "empty"
    plot.crop = nil
    plot.plantedDay = 0
    plot.waterLevel = 0
    plot.dryDays = 0
    
    -- 获得种子和农作物
    if not self.inventory then self.inventory = {} end
    if not self.inventory[cropType] then self.inventory[cropType] = 0 end
    
    self.inventory[cropType] = self.inventory[cropType] + harvestAmount
    self.startingResources.seeds[cropType] = self.startingResources.seeds[cropType] + math.random(1, 2) -- 随机获得1-2颗种子
    
    return true, "Successfully harvested " .. harvestAmount .. " " .. self.availableCrops[cropType].name
end

function Level1:clearWitheredCrop(plotIndex)
    local plot = self.farmLayout.plots[plotIndex]
    
    if plot.status ~= "withered" then
        return false, "There are no withered crops on this land"
    end
    
    if self.startingResources.energy < 5 then
        return false, "Insufficient energy, unable to clean up"
    end
    
    -- 消耗能量
    self.startingResources.energy = self.startingResources.energy - 5
    
    -- 重置地块
    plot.status = "empty"
    plot.crop = nil
    plot.plantedDay = 0
    plot.waterLevel = 0
    plot.dryDays = 0
    
    return true, "Successfully cleared withered crops"
end

function Level1:checkObjectives()
    -- 检查是否达成目标
    local lettuceHarvested = (self.inventory and self.inventory.lettuce) or 0
    local carrotsHarvested = (self.inventory and self.inventory.carrot) or 0
    local weeksSurvived = self.timeSystem.currentWeek
    local lettuceSeeds = self.startingResources.seeds.lettuce
    local carrotSeeds = self.startingResources.seeds.carrot
    local totalSeeds = lettuceSeeds + carrotSeeds
    
    local completed = lettuceHarvested >= self.objectives.harvestLettuce and
                     carrotsHarvested >= self.objectives.harvestCarrots and
                     weeksSurvived >= self.objectives.weeksSurvived and
                     totalSeeds >= self.objectives.seedsRemaining
    
    return completed, {
        lettuceHarvested = lettuceHarvested,
        carrotsHarvested = carrotsHarvested,
        weeksSurvived = weeksSurvived,
        totalSeeds = totalSeeds,
        completed = completed
    }
end

-- 获取植物状态信息
function Level1:getCropStatus(plotIndex)
    local plot = self.farmLayout.plots[plotIndex]
    
    if plot.status == "empty" then
        return "open space"
    elseif plot.status == "planted" then
        local cropName = self.availableCrops[plot.crop].name
        local daysGrown = self.timeSystem.currentDay - plot.plantedDay
        local totalDays = self.availableCrops[plot.crop].growthTime
        local progress = math.floor((daysGrown / totalDays) * 100)
        
        local waterStatus = "sufficient moisture"
        if plot.waterLevel < self.availableCrops[plot.crop].waterNeeded then
            waterStatus = "Water shortage"
        end
        
        return cropName .. "(grow " .. progress .. "%," .. waterStatus .. ")"
    elseif plot.status == "ready" then
        return self.availableCrops[plot.crop].name .. "(Harvestable)"
    elseif plot.status == "withered" then
        return self.availableCrops[plot.crop].name .. "(Withered and withered)"
    end
    
    return "Unknown state"
end

return Level1