local function ClearRewardRequests()
    Ext.IO.SaveFile("TwitchPointsCast2/requests.txt", "")
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

local function selectRandomReward(rewardList)
    return weightedRandomSelection(rewardList)
end

local function AddRewardToExecute(rewardRequestData, rewardEffectsList)
    local rewardState = GetRewardsToExecuteTable()

    randomEffect = selectRandomReward(rewardEffectsList)
    if (randomEffect['type'] == 'status') then
        randomEffect['special_effect'] = getRandomSpecialEffect()
    end

    table.insert(rewardState['rewards'], {
        ['reward_name'] = rewardRequestData['__reward_name__'],
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

local function GetRewardRequestData(rewardRequestLine)
    if (rewardRequestLine == nil or rewardRequestLine == "") then return nil end
    local result = {}
    local rewardsRequestTable = splitLineBy(rewardRequestLine, ";")
    for index, string in pairs(rewardsRequestTable) do
        if (index == 1) then
            result['__reward_name__'] = string
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
    local requestsList = Ext.IO.LoadFile("TwitchPointsCast2/requests.txt")
    for _, rewardRequestLine in pairs(splitLineBy(requestsList, "\n")) do
        rewardRequestLine = rewardRequestLine:gsub("%s+", "") -- trim
        _P(rewardRequestLine)
        if (rewardRequestLine == "" or rewardRequestLine == nil) then goto continue end
        local rewardRequestData = GetRewardRequestData(rewardRequestLine)
        if (rewardRequestData == nil or rewardRequestData['__reward_name__'] == nil) then goto continue end
        local rewardEffectsList = GetRewardEffectsList(rewardRequestData['__reward_name__'])
        if (rewardEffectsList == nil) then goto continue end
        AddRewardToExecute(rewardRequestData, rewardEffectsList)
        ::continue::
    end
    ClearRewardRequests()
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

