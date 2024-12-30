local MagicManagers = {} -- { playerCharacterUUID: ManagerUUID }

local MAGIC_MANAGER_TEMPLATE_UUID = "d2af791e-0b75-4b1a-9842-d51b32de87bc"
PLAYER_MAGIC_MANAGER_KEY = "MAGIC_MANAGER_COMPATION"
MAGIC_MANAGER_PLAYER_KEY = "FOLLOWER"


local function CheckPlayerHasMagicManager(character)
	local UUID = getUUID(character)
	-- Osi.GetDistanceTo(object1, object2)
	return MagicManagers[UUID] ~= nil
end


local function CreateMagicManager(character)
	if (CheckPlayerHasMagicManager(character)) then return GetPlayerMagicManager(character) end

	local characterUUID = getUUID(character)
	local magicManagerUUID = Osi.CreateAtObject(MAGIC_MANAGER_TEMPLATE_UUID, characterUUID, 0, 1, "", 0)
	Osi.SetVarString(characterUUID, PLAYER_MAGIC_MANAGER_KEY, magicManagerUUID)
	Osi.SetVarString(magicManagerUUID, MAGIC_MANAGER_PLAYER_KEY, characterUUID)
	MagicManagers[characterUUID] = magicManagerUUID
	return GetPlayerMagicManager(character)
end

function GetPlayerMagicManager(character)
	if (CheckPlayerHasMagicManager(character) == false) then return CreateMagicManager(character) end
	local UUID = getUUID(character)
	local MagicManagerUUID = MagicManagers[UUID]
	if (Osi.GetHitpoints(MagicManagerUUID) > 0) then
		if (Osi.GetDistanceTo(UUID, MagicManagerUUID) > 10) then
			TeleportToTarget(MagicManagerUUID, UUID)
		end
	end
	return MagicManagerUUID
end

function TeleportToAsylum(character)
	Osi.TeleportToPosition(character, -297, 0, 126, '', 0, 0, 0, 1, 1) -- act 1 assylum
end
