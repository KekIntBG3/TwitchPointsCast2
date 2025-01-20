---@diagnostic disable: undefined-global
Ext.Require("BootstrapClient.lua")
Ext.Require("Config.lua")
Ext.Require("RewardsDataHelper.lua")
Ext.Require("Helpers.lua")
Ext.Require("MagicManager.lua")
Ext.Require("Messages.lua")
Ext.Require("Summons.lua")
-- -------------------------------------------------------------------------- --
--                                VARIABLE                                    --
-- -------------------------------------------------------------------------- --

local PassivesAndStatuses = {
    Auto_Check_Twitch_Reward = "NEED_CHECK_TWITCH_REWARD",
    Auto_Event_Character_Moved = "NEED_CHECK_FOLLOWERS",
    Auto_Detect_Summons_Aura = "SUMMON_DETECTION_AURA"
}

-- -------------------------------------------------------------------------- --
--                                 FUNCTION                                   --
-- -------------------------------------------------------------------------- --

local function AddModPassives(character)
    Osi.AddPassive(character, "Auto_Check_Twitch_Reward")
    Osi.AddPassive(character, "Auto_Event_Character_Moved")
    Osi.AddPassive(character, "Auto_Detect_Summons_Aura")
end

local function AutoPassive()
    for _, name in pairs(Osi["DB_Players"]:Get(nil)) do
        local player = name[1]
        Ext.Timer.WaitFor(1000, function()
            AddModPassives(player)
        end)
    end
end

local function RemoveModPassivesStatuses(character)
    for passive, status in pairs(PassivesAndStatuses) do
        Osi.RemoveStatus(character, status)
        Osi.RemovePassive(character, passive)
    end
end

local function UninstallMOD()
    for _, name in pairs(Osi["DB_Players"]:Get(nil)) do
        local player = name[1]
        RemoveModPassivesStatuses(player)
    end
end

---Osi.GetActiveModStartupLevel()

-- -------------------------------------------------------------------------- --
--                             EVENT LISTENER                                 --
-- -------------------------------------------------------------------------- --

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level, isEditor)
    if level == "SYS_CC_I" then
        return
    end
    UninstallMOD()
    AutoPassive()
    CheckRewards()
end)

STATUS_REWARD_IS_EXECUTING = false

local function EndRewardsExecution(character)
    STATUS_REWARD_IS_EXECUTING = false
    GetPlayerMagicManager(character, TeleportToAsylum)
end

local currentExecutingReward = {
    character = nil,
    reward = nil,
    magicManager = nil
}

local function SetCurrentExecutingReward(reward, character, magicManager)
    currentExecutingReward['character'] = character
    currentExecutingReward['reward'] = reward
    currentExecutingReward['magicManager'] = magicManager
end

local function GetCurrentExecutingRewardMagicManager()
    return currentExecutingReward['magicManager']
end

local function ConfirmCurrentRewardExecution()
    currentExecutingReward['character'] = nil
    currentExecutingReward['reward'] = nil
    currentExecutingReward['magicManager'] = nil
end

local function ExecuteReward(reward, character)
    STATUS_REWARD_IS_EXECUTING = true
    local effect = reward['effect']
    local requestData = reward['request_data']
    local rewardName = reward['reward_name']

    SummonMagicManagerToPlayer(character, function(magicManager)

        SetCurrentExecutingReward(reward, character, magicManager)

        if (Osi.IsInForceTurnBasedMode(character) == 1) then
            -- wait until turn base is stopped
            Ext.Timer.WaitFor(2000, function()
                ExecuteReward(reward, character)
            end)
            return
        end

        if (requestData['message'] ~= nil and requestData['message'] ~= "") then
            sayMessageByCharacter(magicManager, requestData['message'])
        end

        if (effect['special_effect'] ~= nil and effect['special_effect'] ~= "") then
            Osi.UseSpell(magicManager, effect['special_effect'], character)
        end

        if effect['type'] == "status" then
            Ext.Timer.WaitFor(750, function()
                local numberOfRaunds = (effect['number_of_rounds'] ~= nil and effect['number_of_rounds'] ~= 0) and effect['number_of_rounds'] or 1
                Osi.ApplyStatus(character, effect['name'], numberOfRaunds * 6)
            end)
        elseif effect['type'] == "spell" then
            Osi.UseSpell(magicManager, effect['name'], character)
        elseif effect['type'] == "summon" then
            UseSummonSummon(magicManager, effect['name'], character, requestData)
        elseif effect['type'] == "enemy" then
            local count = (effect['count'] ~= nil and effect['count'] ~= 0) and effect['count'] or 1
            UseSummonEnemy(magicManager, effect['name'], character, count, requestData)
        end

        Ext.Timer.WaitFor(3000, function()
            if (GetCurrentExecutingRewardMagicManager() ~= nil) then
                _P('Cannot execute reward, try again')
                return ExecuteReward(reward, character)
            end

            local nextReward = GetRewardToExecute()
            if (nextReward ~= nil) then
                ExecuteReward(nextReward, character)
            else
                Ext.Timer.WaitFor(2000, function()
                    EndRewardsExecution(character)
                end)
            end
        end)
    end)
end


Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(character, status, _, _)
    if (status == "NEED_CHECK_TWITCH_REWARD" and Osi.HasAppliedStatus(character, "NEED_CHECK_TWITCH_REWARD") == 1) then
        if (STATUS_REWARD_IS_EXECUTING == false) then
            local reward = GetRewardToExecute()
            if (reward ~= nil) then
                ExecuteReward(reward, character)
            end
        end

        Osi.RemoveStatus(character, "NEED_CHECK_TWITCH_REWARD")
    end
    -- if (status == "NEED_CHECK_FOLLOWERS" and Osi.HasAppliedStatus(character, "NEED_CHECK_FOLLOWERS") == 1) then
    if (status == "NEED_CHECK_FOLLOWERS") then
        ProcessFriendlySummonsWhenCharacterMoved(character)
		Osi.RemoveStatus(character, "NEED_CHECK_FOLLOWERS")
	end
	if (status == "SUMMON_DETECTED") then
        ProcessDetectedSummon(character)
	end
end)

Ext.Osiris.RegisterListener("UsingSpell", 5, "before", function (caster, spell, spellType, spellElement, storyActionID)
    if (STATUS_REWARD_IS_EXECUTING == true) then
        if (GetCurrentExecutingRewardMagicManager() == getUUID(caster)) then
            ConfirmCurrentRewardExecution()
        end
    end
	
end)
-- -------------------------------------------------------------------------- --
--                                UNINSTALL                                   --
-- -------------------------------------------------------------------------- --
Ext.Events.ResetCompleted:Subscribe(UninstallMOD)


-- Ext.Osiris.RegisterListener("AnimationEvent", 3, "after", function (object, eventname, wasFromLoad)
--     _D(object)
--     _D(eventname)
-- end)