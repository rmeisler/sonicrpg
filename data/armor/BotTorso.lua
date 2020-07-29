local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"

return {
	name = "Bot Torso",
	desc = "This could be useful...",
	type = ItemType.Armor,
	usableBy = {"antoine", "sally", "sonic", "rotor", "bunny"},
	stats = {
		defense = 2,
		speed = -1,
	},

	onEquip = function(member, player)
		if  GameState:isEquipped(member, ItemType.Accessory, "Bot Head") and
			GameState:isEquipped(member, ItemType.Armor, "Bot Torso") and
			GameState:isEquipped(member, ItemType.Weapon, "Bot Arm")
		then
			player.isSwatbot[member] = true
			player:updateSpriteForMember(member, "swatbot")
		end
	end,
	onUnequip = function(member, player)
		player:updateSpriteForMember(member, member)
		player.isSwatbot[member] = nil
	end
}
