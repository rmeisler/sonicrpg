local Ease = require "actions/Ease"
local Wait = require "actions/Wait"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local TypeText = require "actions/TypeText"

local BouncyText = class(TypeText)

function BouncyText:construct(transform, color, font, text, speed, noFastForward, outline)
    -- Pause before showing number movement
	self.text = "{p2}"..self.text
	self.color[4] = 0
	
	self.action = Serial {
		Parallel {
			-- Text rises up and fades in
			Ease(self.transform, "y", self.transform.y - 40, 2, "quad"),
			Ease(self.color, 4, 255, 2)
		},
		Parallel {
			-- Text bounces once before completion
			Serial {
				Ease(self.transform, "y", self.transform.y+20, 2, "quad"),
				Ease(self.transform, "y", self.transform.y, 3),
				Ease(self.transform, "y", self.transform.y+20, 3, "quad"),
			},
			Wait(2)
		},
		Ease(self.color, 4, 0, 2)
	}
	
	self.type = "BouncyText"
end

function BouncyText:isDone()
	return self.action:isDone()
end

function BouncyText:reset()
	TypeText.reset(self)
	self.action:reset()
end

function BouncyText:setScene(scene)
	TypeText.setScene(self, scene)
	scene:addHandler("update", BouncyText.update, self)
end

function BouncyText:update(dt)
	self.action:update(dt)
end


return BouncyText
