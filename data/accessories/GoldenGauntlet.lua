local ItemType = require "util/ItemType"
local EventType = require "util/EventType"
local StatBoost = require "data/battle/actions/StatBoost"

return {
	name = "Golden Gauntlet",
	desc = "Charges attack when blocking",
	type = ItemType.Accessory,
	event = {
		type = EventType.Z,
		action = StatBoost({attack=1}, "nextatt")
	},
	stats = {}
}
