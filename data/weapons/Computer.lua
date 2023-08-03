local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Computer",
	desc = "This thing is ancient, but expertly maintained.",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	sprite = "sword",
	usableBy = {"logan"},
	color = {200,200,0,255},
	stats = {
		attack = 4
	}
}
