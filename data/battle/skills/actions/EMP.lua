local Action = require "actions/Action"
local MessageBox = require "actions/MessageBox"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local Animate = require "actions/Animate"
local Do = require "actions/Do"
local AudioFade = require "actions/AudioFade"
local PlayAudio = require "actions/PlayAudio"
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local Telegraph = require "data/monsters/actions/Telegraph"

return function(self, targets)
	local actions = {}
	local afterActions = {}
	for _, target in pairs(targets) do
		if target.isBot then
			table.insert(
				actions,
				Serial {
					Animate(target:getSprite(), "hurt"),
					Wait(0.1),
					Animate(function()
						local xform = Transform.from(target:getSprite().transform)
						xform.x = xform.x + target:getSprite().w
						xform.y = xform.y + target:getSprite().h
						return SpriteNode(self.scene, xform, nil, "lightning", nil, nil, "ui"), true
					end, "idle"),
					Do(function()
						target.state = target.STATE_IMMOBILIZED
					end),
					Wait(1),
					Animate(target:getSprite(), "idle")
				}
			)
		else
			table.insert(afterActions, Telegraph(target, "EMP had no impact on "..target.name, {255,255,255,50}))
		end
	end

	local empLt = SpriteNode(self.scene, Transform(0,0,2,2), {255,255,255,0}, "emp", nil, nil, "ui")
	empLt.transform.ox = empLt.w/2
	empLt.transform.oy = empLt.h/2
	empLt.transform.x = self.sprite.transform.x
	empLt.transform.y = self.sprite.transform.y
	
	local prevMusic = self.scene.audio:getCurrentMusic()
	return Serial {
		Animate(self.sprite, "focus"),
		Ease(empLt.color, 4, 255, 3),
		PlayAudio("sfx", "factoryspit", 1, true),
		Parallel(actions),
		Serial(afterActions),
		next(actions) ~= nil and MessageBox {message="All bots disabled!", rect=MessageBox.HEADLINER_RECT, textSpeed=8, closeAction=Wait(1)} or Action(),
		Ease(empLt.color, 4, 0, 3),
		Animate(self.sprite, "idle"),
	}
end