local nonControllableSummons = {}
local nextSummonParams = {}

function ProcessFriendlySummonsWhenCharacterMoved(character)
	for UUID, leader in pairs(nonControllableSummons) do
		if (leader) then
			inCombat = Osi.IsInCombat(UUID)
			template = Osi.GetTemplate(UUID)
			if (inCombat == 0 and template ~= "DarkVine_Tentacle_GraspingVine_dcbaa902-e45c-41fa-b238-19541402961e" and template ~= "Construct_GuardianOfFaith_Neutral_d243badc-a763-4d9e-8037-2da9c3e39d5e") then
				if (Osi.GetDistanceTo(UUID, leader) > 30) then
					TeleportToTarget(UUID, leader)
				else
					Osi.CharacterMoveTo(UUID, leader, "Run", '')
				end
			end
		end
	end
end

local function addNonControllableSummon(summon, playerCharacter)
	UUID = getUUID(summon)
	Osi.ApplyStatus(UUID, "SUMMON_ADDED_TO_TRACKING", -1)
	Osi.SetOwner(UUID, playerCharacter)
	PlayerFaction = Osi.GetFaction(playerCharacter)
	Osi.SetFaction(UUID, 'b37bfd4c-baed-08f4-9866-290f8bb39e62')
	nonControllableSummons[UUID] = playerCharacter
	if (nextSummonParams["user"] ~= nil) then
		Osi.SetStoryDisplayName(UUID, nextSummonParams['user'])
		nextSummonParams = {}
	end
end

local function GetPlayerUUIDIfSummonIsFromTheMagicManager(character)
	local summonUUID = getUUID(character)
	local magicManagerUUID = Osi.CharacterGetOwner(summonUUID)
	if (magicManagerUUID == nil) then return nil end
	local playerUUID = Osi.GetVarString(magicManagerUUID, MAGIC_MANAGER_PLAYER_KEY)
	if (playerUUID == nil) then return nil end
	return playerUUID
end

function ProcessDetectedSummon(character)
	if Osi.HasAppliedStatus(character, "SUMMON_ADDED_TO_TRACKING") == 0 then
		local playerCharacterUUID = GetPlayerUUIDIfSummonIsFromTheMagicManager(character)
		if playerCharacterUUID ~= nil then
			addNonControllableSummon(character, playerCharacterUUID)
		end
	end
end

function UseSummonSummon(character, spellName, target, requestData)
	if (requestData["user"]) then
		nextSummonParams["user"] = requestData["user"]
	end
	local x, y, z = Osi.GetPosition(target)
	local positionX, positionY, positionZ = getRandomPosition(x, y, z, 3)
	Osi.UseSpellAtPosition(character, spellName, positionX, positionY, positionZ, 1)
end

function UseSummonEnemy(character, enemy, target, count, requestData)
	local enemiesTemplates = {}
	if (type(enemy) == "string") then
		table.insert(enemiesTemplates, enemy)
	elseif (type(enemy) == "table") then
		enemiesTemplates = enemy
	end
	

	local x, y, z = Osi.GetPosition(target)
	_P('count', count)
	for i = 1, count do
		_P('SPAWN ENEMY')
		local positionX, positionY, positionZ = getRandomPosition(x, y, z, 10)
		local enemyTemplate = enemiesTemplates[math.random(1, #enemiesTemplates)]
		_P(enemyTemplate)
		local enemy = Osi.CreateAt(enemyTemplate, positionX, positionY, positionZ, 1, 1, "")
		Osi.SetFaction(enemy, '4be9261a-e481-8d9d-3528-f36956a19b17')
		Osi.SetCanJoinCombat(enemy, 1)

		if (requestData["user"]) then
			Osi.SetStoryDisplayName(enemy, requestData["user"])
		end
	end
end