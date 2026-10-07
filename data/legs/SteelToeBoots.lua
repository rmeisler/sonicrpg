local ItemType = require "util/ItemType"

return {
	name = "Steel Toe Boots",
	desc = "Packs a punch, but slows you down.",
	type = ItemType.Legs,
	color = {50,50,50,255},
	usableBy = {"sally"},
	stats = {
		attack = 6,
		defense = 1,
		speed = -2
	},
	onEquip = function(member, player)
		player.partyMovespeed[member] = 3
	end,
	onUnequip = function(member, player)
		player.partyMovespeed[member] = nil
	end
}
