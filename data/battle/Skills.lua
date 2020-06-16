local TargetType = require "util/TargetType"

return {
	name = "Skills",
	target = TargetType.None,
	action = require "data/battle/actions/SkillsMenu"
}