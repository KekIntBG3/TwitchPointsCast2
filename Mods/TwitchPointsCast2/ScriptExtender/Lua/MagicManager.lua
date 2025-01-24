local MagicManagers = {} -- { playerCharacterUUID: ManagerUUID }

-- local MAGIC_MANAGER_TEMPLATE_UUID = "d2af791e-0b75-4b1a-9842-d51b32de87bc" -- eye
-- local MAGIC_MANAGER_TEMPLATE_UUID = "68fd2a6c-1503-4e64-9aa8-a9e10e95834a" -- parrot
local MAGIC_MANAGER_TEMPLATE_UUID = "d39bb3c8-7748-42f1-961b-658470d6a488" -- pixie
PLAYER_MAGIC_MANAGER_KEY = "MAGIC_MANAGER_COMPATION"
MAGIC_MANAGER_PLAYER_KEY = "FOLLOWER"
local MAGIC_MAGANER_APPEARING_ANIMATION_UUID = "a164a018-22f3-a538-5acb-4aedf67358de"

local function GetAssylumPosition()
	-- return assylumPosotions.act1
	return { x = 999, y = -999, z = 999 }
end


local function CheckPlayerHasMagicManager(character)
	local UUID = getUUID(character)
	local MagicManagerUUID = MagicManagers[UUID];
	if (MagicManagerUUID == nil) then return false end
	return Osi.GetHitpoints(MagicManagerUUID) ~= nil and Osi.GetHitpoints(MagicManagerUUID) > 0
end


local function CreateMagicManager(character)

	local characterUUID = getUUID(character)
	local assylumPosition = GetAssylumPosition()
	local x, y, z = getRandomPositionAroundCharacter(character, 3)
	Osi.PlayEffectAtPosition(MAGIC_MAGANER_APPEARING_ANIMATION_UUID, x, y, z, 1)
	local magicManagerUUID = Osi.CreateAt(MAGIC_MANAGER_TEMPLATE_UUID, x, y, z, 0, 1, "")

	Osi.SetVarString(characterUUID, PLAYER_MAGIC_MANAGER_KEY, magicManagerUUID)
	Osi.SetVarString(magicManagerUUID, MAGIC_MANAGER_PLAYER_KEY, characterUUID)
	Osi.SetFaction(magicManagerUUID, 'b37bfd4c-baed-08f4-9866-290f8bb39e62')
	MagicManagers[characterUUID] = magicManagerUUID

	return magicManagerUUID
end



function SummonMagicManagerToPlayer(character, callback)
	GetPlayerMagicManager(character, function(MagicManagerUUID)
		local UUID = getUUID(character)
		if ((Osi.GetDistanceTo(UUID, MagicManagerUUID) > 5)) then
			local teleportData = nil
			if (Osi.GetDistanceTo(UUID, MagicManagerUUID) > 20) then
				teleportData = TeleportToTarget(MagicManagerUUID, UUID, MAGIC_MAGANER_APPEARING_ANIMATION_UUID)
				Ext.Timer.WaitFor(teleportData.animation_duration / 2, function()
					callback(MagicManagerUUID)
				end)
			else
				Osi.CharacterMoveTo(MagicManagerUUID, UUID, "Run", '', 1)
				Ext.Timer.WaitFor(2000, function()
					callback(MagicManagerUUID)
				end)
			end
			
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
		local assylumPosition = GetAssylumPosition()
		Osi.TeleportToPosition(character, assylumPosition.x, assylumPosition.y, assylumPosition.z, '', 0, 0, 0, 1, 1) -- act 1 assylum
	end)
end



-- Osi.TeleportToPosition(character, -155, 30, -390, '', 0, 0, 0, 1, 1) -- nautiloid asyylum
-- Osi.TeleportToPosition(character, -297, 0, 126, '', 0, 0, 0, 1, 1) -- act 1 assylum

--  Ext.Resource.Get(effectUUID, "Effect").Duration в общем )



--UsingSpell((GUIDSTRING)_Caster, (STRING)_Spell, (STRING)_SpellType, (STRING)_SpellElement, (INTEGER)_StoryActionID)