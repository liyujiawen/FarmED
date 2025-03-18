local Level1 = {
    -- 基础游戏设置
    initialMoney = 500,        -- 起始金币
    dayDuration = 40,          -- 白天持续时间
    nightDuration = 20,        -- 夜晚持续时间
    requiredCustomers = 1,     -- 需要服务的客户数
    actionPointsPerDay = 10,   -- 每天的行动点数量

    -- 基础种植系统 - 修改后的水需求
    availableCrops = {
        wheat = {
            name = "Wheat",
            growthTime = 5,     -- 生长周期（天）
            cost = 15,          -- 种子成本
            sellPrice = 35,     -- 售价
            waterNeeded = 10,   -- 每天需水量 - 已修改
            droughtTolerance = 2, -- 能承受几天不浇水
            nutritionValue = 8  -- 营养价值
        },
        carrot = {
            name = "Carrot",
            growthTime = 10,    -- 生长周期（天）
            cost = 30,          -- 种子成本
            sellPrice = 70,     -- 售价
            waterNeeded = 5,    -- 每天需水量 - 已修改
            droughtTolerance = 3, -- 能承受几天不浇水
            nutritionValue = 15 -- 营养价值
        },
        corn = {
            name = "Corn",
            growthTime = 15,    -- 生长周期（天）
            cost = 40,          -- 种子成本
            sellPrice = 90,     -- 售价
            waterNeeded = 15,   -- 每天需水量 - 已修改
            droughtTolerance = 2, -- 能承受几天不浇水
            nutritionValue = 20 -- 营养价值
        },
        banana = {
            name = "Banana",
            growthTime = 20,    -- 生长周期（天）
            cost = 60,          -- 种子成本
            sellPrice = 120,    -- 售价
            waterNeeded = 20,   -- 每天需水量 - 已修改
            droughtTolerance = 1, -- 能承受几天不浇水
            nutritionValue = 25 -- 营养价值
        }
    },

    -- 起始农场资源
    startingResources = {
        seeds = {
            wheat = 10,         -- 初始小麦种子数量
            carrot = 10,        -- 初始胡萝卜种子数量
            corn = 5,           -- 初始玉米种子数量
            banana = 3          -- 初始香蕉种子数量
        },
        tools = {
            wateringCan = 1,    -- 浇水工具
            hoe = 1             -- 锄头
        },
        actionPoints = 10,      -- 当前行动点
    },

    -- 时间系统
    timeSystem = {
        currentDay = 1,
        currentWeek = 1,
        dayTime = "day",        -- "day" 或 "night"
    },

    -- 关卡目标
    objectives = {
        harvestWheat = 5,      -- 收获5个小麦
        harvestCarrots = 3,    -- 收获3个胡萝卜
        harvestCorn = 2,       -- 收获2个玉米
        harvestBanana = 1,     -- 收获1个香蕉
        seedsRemaining = 5     -- 保留至少5颗种子
    },

    -- 游戏教程提示
    tutorials = {
        {id = "welcome", text = "Welcome to the Sustainable Farm Simulation Game! This is the first level: basic planting."},
        {id = "planting", text = "Choose a plot of land and use seeds to plant crops. Wheat takes 5 days to mature, carrots take 10 days, corn takes 15 days, and bananas take 20 days."},
        {id = "watering", text = "Remember to water the crops every day! Different crops require varying amounts of water: wheat 10 points, carrots 5 points, corn 15 points, and bananas 20 points."},
        {id = "harvesting", text = "After the crops are ripe, click to harvest. You can use them to make food or sell them."},
        {id = "actionPoints", text = "You have 10 action points each day. Planting and watering each consume 1 action point. When you run out of action points, the day will advance automatically."},
        {id = "objective", text = "Goal: Plant and harvest enough food to sustain for a week while retaining enough seeds."}
    }
}

function Level1:getDayInfo()
    return {
        day = self.timeSystem.currentDay,
        week = self.timeSystem.currentWeek,
        dayTime = self.timeSystem.dayTime
    }
end

function Level1:advanceDay()
    self.timeSystem.currentDay = self.timeSystem.currentDay + 1
    if self.timeSystem.currentDay > 7 then
        self.timeSystem.currentDay = 1
        self.timeSystem.currentWeek = self.timeSystem.currentWeek + 1
    end
    
    -- 更新作物生长和水分状态
    self:updateCrops()
    
    -- 重置行动点
    self.startingResources.actionPoints = self.actionPointsPerDay
    
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
        return false, "This plot already has crops planted"
    end
    
    if self.startingResources.seeds[cropType] <= 0 then
        return false, "Not enough seeds"
    end
    
    if self.startingResources.actionPoints < 1 then
        return false, "Not enough action points to plant"
    end
    
    -- 种植作物
    plot.status = "planted"
    plot.crop = cropType
    plot.plantedDay = self.timeSystem.currentDay
    plot.waterLevel = 0
    plot.dryDays = 0
    
    -- 消耗资源
    self.startingResources.seeds[cropType] = self.startingResources.seeds[cropType] - 1
    self.startingResources.actionPoints = self.startingResources.actionPoints - 1
    
    -- 检查是否需要自动推进到下一天
    if self.startingResources.actionPoints <= 0 then
        self:advanceDay()
    end
    
    return true, "Successfully planted " .. self.availableCrops[cropType].name
end

function Level1:waterCrop(plotIndex)
    local plot = self.farmLayout.plots[plotIndex]
    
    -- 检查条件
    if plot.status ~= "planted" then
        return false, "No crops need watering"
    end
    
    if self.startingResources.actionPoints < 1 then
        return false, "Not enough action points to water"
    end
    
    -- 浇水
    local waterAmount = self.availableCrops[plot.crop].waterNeeded
    plot.waterLevel = plot.waterLevel + waterAmount
    -- 重置干旱天数
    plot.dryDays = 0
    
    -- 消耗行动点
    self.startingResources.actionPoints = self.startingResources.actionPoints - 1
    
    -- 检查是否需要自动推进到下一天
    if self.startingResources.actionPoints <= 0 then
        self:advanceDay()
    end
    
    return true, "Successfully watered the crops"
end

function Level1:harvestCrop(plotIndex)
    local plot = self.farmLayout.plots[plotIndex]
    
    -- 检查条件
    if plot.status ~= "ready" then
        return false, "The crops are not ready for harvest"
    end
    
    if self.startingResources.actionPoints < 1 then
        return false, "Not enough action points to harvest"
    end
    
    local cropType = plot.crop
    local harvestAmount = 1
    
    -- 消耗行动点
    self.startingResources.actionPoints = self.startingResources.actionPoints - 1
    
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
    
    -- 检查是否需要自动推进到下一天
    if self.startingResources.actionPoints <= 0 then
        self:advanceDay()
    end
    
    return true, "Successfully harvested " .. harvestAmount .. " " .. self.availableCrops[cropType].name
end

function Level1:clearWitheredCrop(plotIndex)
    local plot = self.farmLayout.plots[plotIndex]
    
    if plot.status ~= "withered" then
        return false, "There are no withered crops on this plot"
    end
    
    if self.startingResources.actionPoints < 1 then
        return false, "Not enough action points to clear"
    end
    
    -- 消耗行动点
    self.startingResources.actionPoints = self.startingResources.actionPoints - 1
    
    -- 重置地块
    plot.status = "empty"
    plot.crop = nil
    plot.plantedDay = 0
    plot.waterLevel = 0
    plot.dryDays = 0
    
    -- 检查是否需要自动推进到下一天
    if self.startingResources.actionPoints <= 0 then
        self:advanceDay()
    end
    
    return true, "Successfully cleared withered crops"
end

function Level1:checkObjectives()
    -- 检查是否达成目标
    local wheatHarvested = (self.inventory and self.inventory.wheat) or 0
    local carrotsHarvested = (self.inventory and self.inventory.carrot) or 0
    local cornHarvested = (self.inventory and self.inventory.corn) or 0
    local bananaHarvested = (self.inventory and self.inventory.banana) or 0
    local weeksSurvived = self.timeSystem.currentWeek
    local totalSeeds = 0
    
    -- 计算总种子数
    for cropType, amount in pairs(self.startingResources.seeds) do
        totalSeeds = totalSeeds + amount
    end
    
    local completed = wheatHarvested >= self.objectives.harvestWheat and
                     carrotsHarvested >= self.objectives.harvestCarrots and
                     cornHarvested >= self.objectives.harvestCorn and
                     bananaHarvested >= self.objectives.harvestBanana and
                     weeksSurvived >= self.objectives.weeksSurvived and
                     totalSeeds >= self.objectives.seedsRemaining
    
    return completed, {
        wheatHarvested = wheatHarvested,
        carrotsHarvested = carrotsHarvested,
        cornHarvested = cornHarvested,
        bananaHarvested = bananaHarvested,
        weeksSurvived = weeksSurvived,
        totalSeeds = totalSeeds,
        completed = completed
    }
end

-- 获取植物状态信息
function Level1:getCropStatus(plotIndex)
    local plot = self.farmLayout.plots[plotIndex]
    
    if plot.status == "empty" then
        return "Empty plot"
    elseif plot.status == "planted" then
        local cropName = self.availableCrops[plot.crop].name
        local daysGrown = self.timeSystem.currentDay - plot.plantedDay
        local totalDays = self.availableCrops[plot.crop].growthTime
        local progress = math.floor((daysGrown / totalDays) * 100)
        
        local waterStatus = "sufficient water"
        if plot.waterLevel < self.availableCrops[plot.crop].waterNeeded then
            waterStatus = "needs water"
        end
        
        return cropName .. " (Growing " .. progress .. "%, " .. waterStatus .. ")"
    elseif plot.status == "ready" then
        return self.availableCrops[plot.crop].name .. " (Ready to harvest)"
    elseif plot.status == "withered" then
        return self.availableCrops[plot.crop].name .. " (Withered)"
    end
    
    return "Unknown status"
end

-- 获取当前行动点
function Level1:getActionPoints()
    return self.startingResources.actionPoints
end

-- 手动结束当天
function Level1:endDay()
    return self:advanceDay()
end

return Level1