local TargetType = require "util/TargetType"

return {
	name = "Top Hat",
	desc = "A dumpy old hat... why does Fleet have this?",
	target = TargetType.Party,
	icon = "icon_hat",
	--cost = 3,
	--subtype = "craft",
	usableFromMenu = false,
	usableFromBattle = false,
}
