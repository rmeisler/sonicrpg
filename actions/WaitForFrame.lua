local WaitForFrame = class(require "actions/Action")

function WaitForFrame:construct(sprite, frame)
	self.sprite = sprite
	self.frame = frame
	self.type = "WaitForFrame"
end

function WaitForFrame:isDone()
	return self.sprite.animations[self.sprite.selected].position == self.frame
end


return WaitForFrame
