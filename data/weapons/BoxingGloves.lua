local WeaponType = require "util/WeaponType"
local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Boxing Gloves",
	desc = "Grants 'Pummel' skill.",
	type = ItemType.Weapon,
	subtype = WeaponType.Sword,
	usableBy = {"sonic"},
	sprite = "sword",
	color = {200,200,0,255},
	skill = require "data/battle/skills/Pummel",
	stats = {
		attack = 4,
		defense = 1
	}
}
