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

function TeleportToTarget(character, target)
	Osi.TeleportTo(character, target, '', 0, 0, 0, 1, 1)
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