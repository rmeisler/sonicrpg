local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Mirror",
	desc = "Press (z) to reflect laser attacks",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	usableBy = {"sonic", "sally", "antoine", "rotor"},
	sprite = "sword",
	color = {200,200,0,255},
	stats = {attack=2},
	event = {
		type = EventType.Z,
		action = function()
			return require "data/battle/actions/Reflect"
		end
	}
}
