local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Robotic Gloves",
	desc = "Gloves built from Swatbot parts.",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	usableBy = {"sonic", "sally", "antoine", "rotor", "logan"},
	sprite = "sword",
	color = {200,200,0,255},
	stats = {
		attack = 5,
		speed = -1
	}
}
