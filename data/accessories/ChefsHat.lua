local ItemType = require "util/ItemType"

return {
	name = "Chef's Hat",
	desc = "2x hp for healing items",
	type = ItemType.Accessory,
	usableBy = {"bunny", "antoine"},
	stats = {}
}
