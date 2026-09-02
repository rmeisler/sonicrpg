local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"

return {
	name = "Swatbot Helmet",
	desc = "Metal helmet worn by Swatbots.",
	type = ItemType.Accessory,
	usableBy = {"antoine", "sally", "sonic", "rotor", "bunny", "logan"},
	stats = {
		defense = 3,
		speed = -1,
	},

	onEquip = function(member, player)
		if  GameState:isEquipped(member, ItemType.Accessory, "Swatbot Helmet") and
			GameState:isEquipped(member, ItemType.Armor, "Swatbot Armor") and
			GameState:isEquipped(member, ItemType.Weapon, "Swatbot Gauntlet") and
			GameState:isEquipped(member, ItemType.Legs, "Swatbot Boots")
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
