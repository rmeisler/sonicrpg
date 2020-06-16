local ItemType = require "util/ItemType"

return {
	name = "Red Cape",
	desc = "A dark red cape, made of woodwyrm silk.",
	type = ItemType.Accessory,
	icon = "icon_accessory",
	cost = {
		plant = 10,
		gear = 10
	},
	stats = {
		defense = 2,
		speed = 2,
	}
}
