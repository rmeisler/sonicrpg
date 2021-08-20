local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Reflector Mecha",
	desc = "Can reflect laser attacks with (z)",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	sprite = "sword",
	usableBy = {"bunny"},
	color = {200,200,0,255},
	stats = {
		attack = 4,
		defense = 4
	},
	event = {
		type = EventType.Z,
		action = require "data/battle/actions/Reflect"
	}
}
