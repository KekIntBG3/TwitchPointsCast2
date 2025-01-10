function splitLineBy(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end
-- VFX_Script_Raphael_Poof_TeleportOut_01_8186a3ba-1f1d-33a4-005a-36607680f5a5 - korilla animation out
-- 80bd6b0d-0fc6-d9f3-37b9-5b3d667180e3 - korilla animation in
-- VFX_Script_Spider_EggHatch_Exploding_01_8331601c-3ca5-b359-91fb-e36933af5755 - spider egg haching
-- VFX_Script_Tentacle_Teleport_01_3f4d2a5d-1772-9550-6ea6-05d733d102c0 -- vzhuh effect
-- VFX_Script_CONT_GEN_SecretChest_01_a164a018-22f3-a538-5acb-4aedf67358de - красивая голубенькая анимация
-- VFX_Environment_Fireworks_Explosion_03_023ebfb0-8067-8cd5-0237-82d9e8bb3922 - микро взрывчик
-- VFX_Enemies_Mimic_Transition_01_be4c9332-269a-0e45-8406-96409500e841 -- пузырьки
-- VFX_Script_Waypoint_Teleport_Out_417b85a5-5899-7dc1-4f3c-ddc3d09177ea -- медленное исчезновение
-- 3772280c-c094-0b63-602e-2ad6045ec800 - фиолетовый пукич
-- 71273c6a-1396-616e-713d-153fb9e77c76 кровавый взрыв
-- 134d1d6b-1bd7-8cea-8d6e-8f3db2a14b32 - большой суровый пукич
-- 039ec0ce-33cb-8304-50c3-c814536ab546 - звук смерти тени в курсе
-- 0ac2f2ac-1d48-f00a-8f50-b538c6f45c20 - бабах от горна
-- 0be30891-e85f-d21d-31ea-8f294c951187 - жесткий бабах
-- 18a704ed-6fff-2aa4-781e-1ee8673193ab - сфера на исчезновение
function TeleportToTarget(character, target, animationUUID)
	local x, y, z = getRandomPositionAroundCharacter(target, 3)
	Osi.TeleportToPosition(character, x, y, z, "", 0, 0, 0, 1, 1)
	local result = {
		x = x,
		y = y,
		z = z,
		animation_duration = 0
	}

	if (animationUUID ~= nil) then
		Osi.PlayEffectAtPosition(animationUUID, x, y, z, 1)
		local duration = Ext.Resource.Get(animationUUID, "Effect").Duration
		if (duration ~= nil) then
			result['animation_duration'] = duration * 1000
		end
	end
	return result
end


function getRandomPositionAroundCharacter(character, radius)
	local x, y, z = Osi.GetPosition(character)
	local positionX, positionY, positionZ = getRandomPosition(x, y, z, radius)
	return positionX, positionY, positionZ
end

function getUUID(characterUUID)
	UUID = string.sub(characterUUID, -36)
	return UUID
end


function getRandomPosition(x, y, z, radius)
	local xMin = math.floor(x - radius)
	local zMin = math.floor(z - radius)
	local xMax = math.floor(x + radius)
	local zMax = math.floor(z + radius)
	local randomX = math.random(xMin, xMax)
	local randomZ = math.random(zMin, zMax)
	return Osi.FindValidPosition(randomX, y, randomZ, 1000, '', 0)
end

-- Функция для выбора случайного элемента по весам
function weightedRandomSelection(items)
    -- Подсчитаем общий вес
    local totalWeight = 0
    for _, item in ipairs(items) do
		local weight = item.weight or 1
        totalWeight = totalWeight + weight
    end

    -- Случайное число в диапазоне от 1 до totalWeight
    local randomWeight = math.random() * totalWeight

    -- Найдем элемент, соответствующий случайному числу
    local cumulativeWeight = 0
    for _, item in ipairs(items) do
		local weight = item.weight or 1
        cumulativeWeight = cumulativeWeight + weight
        if randomWeight <= cumulativeWeight then
            return item
        end
    end
end


local specialEffects = {
	'Spell_specialEffect_01',
	'Spell_specialEffect_02',
	'Spell_specialEffect_03',
	'Spell_specialEffect_04',
	'Spell_specialEffect_05',
	'Spell_specialEffect_06',
	'Spell_specialEffect_07'
}

function getRandomSpecialEffect()
	return specialEffects[math.random(#specialEffects)]
end