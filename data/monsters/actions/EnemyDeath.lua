return function(self, target)
	return Serial {
		PlayAudio("sfx", "oppdeath", 1.0),
		
		-- Fade out with red and play sound
		Parallel {
			Ease(self.sprite.color, 1, 800, 5),
			Ease(self.sprite.color, 4, 0, 2)
		},
		
		Do(function() self.sprite:remove() end)
	}
end
