local ItemType = require "util/ItemType"

return {
	name = "Rocket Boots",
	desc = "Increases movement speed",
	type = ItemType.Legs,
	color = {50,50,50,255},
	usableBy = {"sally", "antoine", "rotor", "logan"},
	stats = {
		defense = 1
	},
	onEquip = function(member, player)
		player.baseMoveSpeed = 5
		player.movespeed = player.baseMoveSpeed
	end,
	onUnequip = function(member, player)
		player.baseMoveSpeed = 4
		player.movespeed = player.baseMoveSpeed
	end
}
