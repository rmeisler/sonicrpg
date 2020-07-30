local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"

return {
	name = "Bot Head",
	desc = "This could be useful...",
	type = ItemType.Accessory,
	usableBy = {"antoine", "sally", "sonic", "rotor", "bunny"},
	stats = {
		defense = 1,
		speed = -1,
	},

	onEquip = function(member, player)
		if  GameState:isEquipped(member, ItemType.Accessory, "Bot Head") and
			GameState:isEquipped(member, ItemType.Armor, "Bot Torso") and
			GameState:isEquipped(member, ItemType.Weapon, "Bot Arm")
		then
			player.isSwatbot[member] = true
			player:updateSpriteForMember(member, "swatbot")
			player:updateSprite()
		end
	end,
	onUnequip = function(member, player)
		player.isSwatbot[member] = nil
		player:updateSpriteForMember(member, member)
		player:updateSprite()
	end
}
