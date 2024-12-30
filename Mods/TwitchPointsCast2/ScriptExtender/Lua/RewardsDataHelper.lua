local function ClearRewardRequestData(rewardName)
    Ext.IO.SaveFile("TwitchPointsCast2/rewards/" .. rewardName .. ".txt", "false")
end

local function GetRewardsToExecuteTable()
    local currentRewardState = Ext.IO.LoadFile("TwitchPointsCast2/rewards_to_execute.json")
    local rewardState = {}
    if (currentRewardState == nil or currentRewardState == "") then
        rewardState['rewards'] = {}
    else
        rewardState = Ext.Json.Parse(currentRewardState)
        if (rewardState['rewards'] == nil or rewardState['rewards'] == "") then
            rewardState = {}
            rewardState['rewards'] = {}
        end
    end
    return rewardState
end

local function SaveRewardsToExecuteTable(rewardState)
    local rewardStateJson = Ext.Json.Stringify(rewardState)
    Ext.IO.SaveFile("TwitchPointsCast2/rewards_to_execute.json", rewardStateJson)
end

local function AddRewardToExecute(rewardName, rewardRequestData, rewardEffectsList)
    local rewardState = GetRewardsToExecuteTable()

    randomEffect = rewardEffectsList[math.random(1, #rewardEffectsList)]

    table.insert(rewardState['rewards'], {
        ['reward_name'] = rewardName,
        ['request_data'] = rewardRequestData,
        ['effect'] = randomEffect,
    })
    SaveRewardsToExecuteTable(rewardState)
end

local function GetRewardEffectsList(rewardName)
    local rewardEffectsList = Ext.IO.LoadFile("TwitchPointsCast2/rewards/" .. rewardName .. ".json")
    if (rewardEffectsList == nil or rewardEffectsList == "") then return nil end
    rewardEffectsList = Ext.Json.Parse(rewardEffectsList)
    if (rewardEffectsList == nil or rewardEffectsList == "") then return nil end
    rewardEffectsList = rewardEffectsList[rewardName]
    if (rewardEffectsList == nil or rewardEffectsList == "") then return nil end
    return rewardEffectsList
end

local function GetRewardRequestData(rewardName)
    local rawRewardRequestData = Ext.IO.LoadFile("TwitchPointsCast2/rewards/" .. rewardName .. ".txt")
    if (rawRewardRequestData == nil or rawRewardRequestData == "" or rawRewardRequestData == "false") then return nil end
    local result = {}
    local rewardsRequestTable = splitLineBy(rawRewardRequestData, ";")
    for index, string in pairs(rewardsRequestTable) do
        if (index == 1) then
            result['is_active'] = string
            goto continue
        end
        local rewardObject = splitLineBy(string, ":")
        local key = rewardObject[1]:gsub("%s+", "") -- trim
        local value
        if (key == "message") then
            value = rewardObject[2]
        else
            value = rewardObject[2]:gsub("%s+", "") -- trim
        end
        result[key] = value
        ::continue::
    end
    return result
end



function CheckRewards()
    local rewardList = Ext.IO.LoadFile("TwitchPointsCast2/rewards_list.txt")
    for _, rewardName in pairs(splitLineBy(rewardList, "\n")) do
        rewardName = rewardName:gsub("%s+", "") -- trim
        if (rewardName == "" or rewardName == nil) then goto continue end
        local rewardRequestData = GetRewardRequestData(rewardName)
        if (rewardRequestData == nil or rewardRequestData['is_active'] ~= "true") then goto continue end
        local rewardEffectsList = GetRewardEffectsList(rewardName)
        if (rewardEffectsList == nil) then goto continue end
        AddRewardToExecute(rewardName, rewardRequestData, rewardEffectsList)
        ClearRewardRequestData(rewardName)
        ::continue::
    end
    Ext.Timer.WaitFor(6000, function()
        CheckRewards()
    end)
end

function GetRewardToExecute()
    local rewardState = GetRewardsToExecuteTable()
    if (#rewardState['rewards'] == 0) then return nil end
    local firstReward = rewardState['rewards'][1]
    table.remove(rewardState['rewards'], 1)
    SaveRewardsToExecuteTable(rewardState)
    return firstReward
end