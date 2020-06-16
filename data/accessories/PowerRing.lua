local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Power Ring",
	desc = "Single use; Increases Sonic's speed.",
	type = ItemType.Accessory,
	stats = {
		speed = 20,
	}
}
