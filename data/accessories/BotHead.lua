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
		local SpriteNode = require "object/SpriteNode"
		local Transform = require "util/Transform"
		player:addVisual(
			member,
			"head",
			"BotHead",
			SpriteNode(
				player.scene,
				Transform(0, 0, 2, 2),
				nil,
				"factorybothelmet",
				nil,
				nil,
				"objects"
			),
			Transform(14, 14, 1.3, 1.3)
		)
	end,
	onUnequip = function(member, player)
		player:removeVisual(member, "head", "BotHead")
	end
}
