local MESSAGE_STATUS_UUID = "h1705b4e2ga520g4292ga2d6g2f7beb3831f0"

function sayMessageByCharacter(character, message)
	local characterUUID = getUUID(character)
	Ext.Loca.UpdateTranslatedString(MESSAGE_STATUS_UUID, "")
	Osi.RemoveStatus(characterUUID, "MESSAGE_FROM_CHAT")
	Ext.Timer.WaitFor(100, function()
		Ext.Loca.UpdateTranslatedString(MESSAGE_STATUS_UUID, message)
		Osi.ApplyStatus(characterUUID, "MESSAGE_FROM_CHAT", -1)
	end)
	

	Ext.Timer.WaitFor(3000, function()
		Ext.Loca.UpdateTranslatedString(MESSAGE_STATUS_UUID, "")
		Osi.RemoveStatus(characterUUID, "MESSAGE_FROM_CHAT")
	end)
end