local MagicManagers = {} -- { playerCharacterUUID: ManagerUUID }

-- local MAGIC_MANAGER_TEMPLATE_UUID = "d2af791e-0b75-4b1a-9842-d51b32de87bc" -- eye
local MAGIC_MANAGER_TEMPLATE_UUID = "68fd2a6c-1503-4e64-9aa8-a9e10e95834a" 
PLAYER_MAGIC_MANAGER_KEY = "MAGIC_MANAGER_COMPATION"
MAGIC_MANAGER_PLAYER_KEY = "FOLLOWER"


local function CheckPlayerHasMagicManager(character)
	local UUID = getUUID(character)
	local MagicManagerUUID = MagicManagers[UUID];
	if (MagicManagerUUID == nil) then return false end
	return Osi.GetHitpoints(MagicManagerUUID) > 0
end


local function CreateMagicManager(character)

	local characterUUID = getUUID(character)
	local magicManagerUUID = Osi.CreateAt(MAGIC_MANAGER_TEMPLATE_UUID, -297, 0, 126, 0, 1, "")

	Osi.SetVarString(characterUUID, PLAYER_MAGIC_MANAGER_KEY, magicManagerUUID)
	Osi.SetVarString(magicManagerUUID, MAGIC_MANAGER_PLAYER_KEY, characterUUID)
	Osi.SetFaction(magicManagerUUID, 'b37bfd4c-baed-08f4-9866-290f8bb39e62')
	MagicManagers[characterUUID] = magicManagerUUID

	return magicManagerUUID
end



function SummonMagicManagerToPlayer(character, callback)
	GetPlayerMagicManager(character, function(MagicManagerUUID)
		local UUID = getUUID(character)
		if ((Osi.GetDistanceTo(UUID, MagicManagerUUID) > 20)) then
			local teleportData = TeleportToTarget(MagicManagerUUID, UUID, "a164a018-22f3-a538-5acb-4aedf67358de")
			Ext.Timer.WaitFor(teleportData.animation_duration / 2, function()
				callback(MagicManagerUUID)
			end)
		else
			callback(MagicManagerUUID)
		end
	end)
end


function GetPlayerMagicManager(character, callback)
	local delay = 0
	local MagicManagerUUID = nil;
	if (CheckPlayerHasMagicManager(character) == false) then
		MagicManagerUUID = CreateMagicManager(character)
		delay = 3000
	else
		MagicManagerUUID = MagicManagers[UUID]
	end

	Ext.Timer.WaitFor(delay, function()
		callback(MagicManagerUUID)
	end)
end

function TeleportToAsylum(character)
	local x, y, z = getRandomPositionAroundCharacter(character, 3)
	Osi.PlayEffect(character, "18a704ed-6fff-2aa4-781e-1ee8673193ab", '', 1)
	Ext.Timer.WaitFor(3000, function()
		Osi.TeleportToPosition(character, -297, 0, 126, '', 0, 0, 0, 1, 1) -- act 1 assylum
	end)
end
--  Ext.Resource.Get(effectUUID, "Effect").Duration в общем )

-- Ext.Osiris.RegisterListener("AnimationEvent", 3, "after", function (object, eventname, wasFromLoad)
-- 	_D(object)
-- 	_D(eventname)
-- end)