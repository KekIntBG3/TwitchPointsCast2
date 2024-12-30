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
}
local oldStatuses = {
    "CHECK_TWITCH_REWARD_READY",
}

-- -------------------------------------------------------------------------- --
--                                 FUNCTION                                   --
-- -------------------------------------------------------------------------- --

local function AddModPassives(character)
    Osi.AddPassive(character, "Auto_Check_Twitch_Reward")
end

local function AutoPassive()
    for _, name in pairs(Osi["DB_Players"]:Get(nil)) do
        local player = name[1]
        AddModPassives(player)
    end
end

local function RemoveModPassivesStatuses(character)
    for passive, status in pairs(PassivesAndStatuses) do
        Osi.RemoveStatus(character, status)
        Osi.RemovePassive(character, passive)
    end
    for _, status in pairs(oldStatuses) do
        Osi.RemoveStatus(character, status)
    end
end

local function UninstallMOD()
    for _, name in pairs(Osi["DB_Players"]:Get(nil)) do
        local player = name[1]
        RemoveModPassivesStatuses(player)
    end
end


-- -------------------------------------------------------------------------- --
--                             EVENT LISTENER                                 --
-- -------------------------------------------------------------------------- --

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level, isEditor)
    if level == "SYS_CC_I" then
        return
    end
    AutoPassive()
    CheckRewards()
    UninstallMOD()
    
end)

STATUS_REWARD_IS_EXECUTING = false

local rewardsTexts = {
    "КУ-КУ ЕПТА",
    "ЗДАРОВА",
    "А ВОТ И Я",
    "НЕ ЖДАЛИ?"
}

local function EndRewardsExecution(character)
    STATUS_REWARD_IS_EXECUTING = false
    local magicManager = GetPlayerMagicManager(character)
    TeleportToAsylum(magicManager)
end

local function ExecuteReward(reward, character)
    STATUS_REWARD_IS_EXECUTING = true
    local effect = reward['effect']
    local requestData = reward['request_data']
    local rewardName = reward['reward_name']
    local magicManager = GetPlayerMagicManager(character)
 
    
    Ext.Timer.WaitFor(1000, function()
        if (requestData['message'] ~= nil and requestData['message'] ~= "") then
            sayMessageByCharacter(magicManager, requestData['message'])
        end

        if effect['type'] == "status" then
            local numberOfRaunds = (effect['number_of_rounds'] ~= nil and effect['number_of_rounds'] ~= 0) and effect['number_of_rounds'] or 1
            Osi.ApplyStatus(character, effect['name'], numberOfRaunds * 6)
        elseif effect['type'] == "spell" then
            Osi.UseSpell(magicManager, effect['name'], character)
        elseif effect['type'] == "summon" then
            UseSummonSummon(magicManager, effect['name'], character, requestData)
        elseif effect['type'] == "enemy" then
            local count = (effect['count'] ~= nil and effect['count'] ~= 0) and effect['count'] or 1
            UseSummonEnemy(magicManager, effect['name'], character, count, requestData)
        end

        Ext.Timer.WaitFor(2000, function()
            local nextReward = GetRewardToExecute()
            if (nextReward ~= nil) then
                ExecuteReward(nextReward, character)
            else
                EndRewardsExecution(character)
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
        -- if GetConfig("Start?") then
        --     if GetConfig("Type") then
        --         local Title = GetConfig('Title')

        --         local messageText_1 = GetConfig('TextForMessageDefault')
        --         local messageText_2 = GetConfig('TextForMessage')
        --         local messageText = messageText_1 .. messageText_2

        --         local messageId = 'hd1345309g5f85g4d2fg8d6ega8052dfc9873'

        --         local Type = GetConfig("Type")

        --         if Type == "status" then
        --             local NumberOfRounds = GetConfig('RoundNumber')
        --             local SpecialEffectSpell = GetConfig('SpecialEffectSpell')
        --             Osi.UseSpell(character, SpecialEffectSpell, character)
        --             Ext.Timer.WaitFor(2000, function()
        --                 Osi.ApplyStatus(character, Title, NumberOfRounds)
        --                 UpdateConfig("RoundNumber", nil)
        --                 UpdateConfig("SpecialEffectSpell", nil)
        --             end)
        --         elseif Type == "spell" then
        --             Osi.UseSpell(character, Title, character)
        --         end

        --         Osi.QuestMessageHide(messageId)
        --         Osi.ShowNotification(character, messageText)
        --         Osi.QuestMessageShow(messageId, messageText)
        --         Ext.Timer.WaitFor(10000, function()
        --             Osi.QuestMessageHide(messageId)
        --         end)

        --     end
        --     UpdateConfig("Start?", false)
        --     UpdateConfig("Type", nil)
        --     UpdateConfig("Title", nil)
        --     UpdateConfig("TextForMessage", nil)
        --     UpdateConfig("TextForMessageDefault", nil)
        -- end
        
        
        Osi.RemoveStatus(character, "NEED_CHECK_TWITCH_REWARD")
    end
    if (status == "NEED_CHECK_FOLLOWERS" and Osi.HasAppliedStatus(character, "NEED_CHECK_FOLLOWERS") == 1) then
        ProcessFriendlySummonsWhenCharacterMoved(character)
		Osi.RemoveStatus(character, "NEED_CHECK_FOLLOWERS")
	end
	if (status == "SUMMON_DETECTED") then
        ProcessDetectedSummon(character)
	end
end)

-- Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function (Caster, Target,Spell,SpellType,SpellElement,StoryActionID)
--     local string = "event:UsingSpellOnTarget|caster:" .. Caster .. "|target:" .. Target .. "|spell:" .. Spell .. "|spell_type:" .. SpellType .. "|spell_element:" .. SpellElement .. "|story_action_id:" .. StoryActionID
--     _P(string)
-- end)

-- -------------------------------------------------------------------------- --
--                                UNINSTALL                                   --
-- -------------------------------------------------------------------------- --
Ext.Events.ResetCompleted:Subscribe(UninstallMOD)