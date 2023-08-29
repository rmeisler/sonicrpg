local TargetType = require "util/TargetType"

return {
	name = "Call Yeti",
	target = TargetType.AllOpponents,
	cost = 15,
	desc = "Call for help from your new friend...",
	action = require "data/battle/skills/actions/CallYeti"
}