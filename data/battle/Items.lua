local TargetType = require "util/TargetType"

return {
	name = "Items",
	target = TargetType.None,
	action = require "data/battle/actions/ItemMenu"
}