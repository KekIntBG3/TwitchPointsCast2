-- -------------------------------------------------------------------------- --
--                                VARIABLE                                    --
-- -------------------------------------------------------------------------- --
local config = {}
local configPath = "TwitchPointsCast/Result.json"
local configkeys = {
    "Start?",
    "Type",
    "Title",
    "RoundNumber",
    "SpecialEffectSpell",
    "TextForMessage",
    "TextForMessageDefault"
}


-- -------------------------------------------------------------------------- --
--                                FUNCTION                                    --
-- -------------------------------------------------------------------------- --
local function checkKeysExist(table, keys)
    for _, key in pairs(keys) do
        if table[key] == nil then
            return false
        end
    end
    return true
end

function FreshConfig()
    config["Start?"] = false
    config["Type"] = nil
    config["Title"] = nil
    config["RoundNumber"] = nil
    config["SpecialEffectSpell"] = nil
    config["TextForMessage"] = nil
    config["TextForMessageDefault"] = nil
    Ext.IO.SaveFile(configPath, Ext.Json.Stringify(config))
end

function UpdateConfig(key, value)
    config[key] = value
    Ext.IO.SaveFile(configPath, Ext.Json.Stringify(config))
end

function CheckConfig()
    local configExist = Ext.IO.LoadFile(configPath)
    if not configExist then
        FreshConfig()
    else
        config = Ext.Json.Parse(Ext.IO.LoadFile(configPath))
        if not checkKeysExist(config, configkeys) then
            FreshConfig()
        end
    end
end

function GetConfig(option)
    CheckConfig()
    return config[option]
end
