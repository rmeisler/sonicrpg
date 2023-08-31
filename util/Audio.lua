--[[
    Audio controller, helps provide nicer features to love audio
	- Priority of sfx over all other sound (Ambient sound and music duck under sfx)
	- Snappy sfx, stop all playing sfx to play the sfx currently requested
]]
local Parallel = require "actions/Parallel"
local Ease = require "actions/Ease"
local Do = require "actions/Do"

local Audio = class()

Audio.MUSIC_DUCK_FACTOR = 2.0
Audio.AMBIENT_DUCK_FACTOR = 2.0

function Audio:construct(sfx, music, ambient)
	-- Registries
	self.sfx = sfx or {} -- Top pri
	self.music = music or {} -- Med pri
	self.ambient = ambient or {} -- Lowest pri
	
	self.ducking = false -- Are we currently ducking?
	self.allowDucking = true
	
	-- Currently playing
	self.current = {}
end

function Audio:registerAs(category, name, sound)
	self[category][name] = sound
end

function Audio:update(dt, scene)
	if self.current.music then
		--if love.keyboard.isDown("f") then
		--	self.current.music:setPitch(2.0)
		--else
			self.current.music:setPitch(1.0)
		--end
	end

	--[[if  self.current.sfx and
		not self.current.sfx:isPlaying() and
		self.ducking and
		self.allowDucking
	then
		self.current.sfx = nil
		self.ducking = false

		-- Increase volume of bgm + ambient sound if sfx not playing
		self.curMusicVolume = self.current.music and self.current.music:getVolume() or 0
		self.curAmbientVolume = self.current.ambient and self.current.ambient:getVolume() or 0
		scene:run {
			Parallel {
				Ease(self, "curMusicVolume", self.musicVolume, 2),
				Ease(self, "curAmbientVolume", self.ambientVolume, 2),
				Do(function()
					if self.current.music then
						self.current.music:setVolume(self.curMusicVolume)
					end
					if self.current.ambient then
						self.current.ambient:setVolume(self.curAmbientVolume)
					end
				end)
			}
		}
	end]]
end

function Audio:isFinished(stype)
	return not self.current[stype] or not self.current[stype]:isPlaying()
end

function Audio:play(stype, ...)
	if stype == "music" then
		self:playMusic(...)
	elseif stype == "sfx" then
		self:playSfx(...)
	elseif stype == "ambient" then
		self:playAmbient(...)
	else
		print("Invalid sound choice "..stype)
	end
end

function Audio:setLooping(stype, loop)
	if self.current[stype] then
		self.current[stype]:setLooping(loop)
	end
end

function Audio:getVolume(stype)
	if self.current[stype] then
		return self.current[stype]:getVolume()
	else
		return 0
	end
end

function Audio:setVolume(stype, volume)
	if self.current[stype] then
		self.current[stype]:setVolume(volume)
	end
end

function Audio:getVolumeFor(stype, name)
	local sfx = self[stype][name]
	if sfx then
		sfx:getVolume()
	else
		return 0
	end
end

function Audio:setVolumeFor(stype, name, volume)
	local sfx = self[stype][name]
	if sfx then
		sfx:setVolume(volume)
	end
end

function Audio:setPitch(stype, pitch)
	if self.current[stype] then
		self.current[stype]:setPitch(pitch)
	end
end

function Audio:playSfx(name, volume, stopCurrent)
	local sfx = self.sfx[name]
	if stopCurrent then
		love.audio.stop(sfx)
	elseif sfx:isPlaying() then
		return
	end
	
	self.current.sfx = sfx
	if volume then
		self:setVolume("sfx", volume)
	end
	love.audio.play(self.current.sfx)
end

function Audio:stopSfx(name)
	if not name then
		if self.current.sfx then
			love.audio.stop(self.current.sfx)
		end
	else
		local sfx = self.sfx[name]
		if sfx then
			love.audio.stop(sfx)
		end
	end
end

function Audio:getCurrentMusic()
	for k,v in pairs(self.music) do
		if v == self.current.music then
			return k
		end
	end
	return nil
end

function Audio:isMusicPlaying()
	return self.current.music:isPlaying()
end

function Audio:playMusic(name, volume, stopCurrent, skipSecs)
	local music = self.music[name]
	if self.current.music == music then
		return
	elseif stopCurrent == nil or stopCurrent == true then
		self:stopMusic()
	elseif music:isPlaying() then
		return
	end
	
	self.current.music = music
	if volume then
		self:setVolume("music", volume)
	end
	love.audio.play(self.current.music)

	if skipSecs then
		music:seek(skipSecs, "seconds")
	end
end

function Audio:stopMusic()
	if self.current.music then
		love.audio.stop(self.current.music)
		self.current.music = nil
	end
end

function Audio:getMusicVolume()
	if self.current.music then
		return self.current.music:getVolume()
	else
		return 0
	end
end

function Audio:setMusicVolume(volume)
	if self.current.music then
		self.current.music:setVolume(volume)
	end
end

function Audio:getAmbientVolume()
	if self.current.ambient then
		return self.current.ambient:getVolume()
	else
		return 0
	end
end

function Audio:setAmbientVolume(volume)
	if self.current.ambient then
		self.current.ambient:setVolume(volume)
	end
end

function Audio:playAmbient(name, volume, stopCurrent)
	local ambient = self.ambient[name]
	if stopCurrent then
		love.audio.stop(ambient)
	elseif ambient:isPlaying() then
		return
	end
	
	self.current.ambient = ambient
	if volume then
		self:setVolume("ambient", volume)
	end
	love.audio.play(self.current.ambient)
end

function Audio:stopAmbient()
	if self.current.ambient then
		love.audio.stop(self.current.ambient)
		self.current.ambient = nil
	end
end

function Audio:cleanup()
	self.sfx = {}
	self.music = {}
	self.ambient = {}
	self.current = {}
end

function Audio:stopAll()
	love.audio.stop()
	self.current = {}
end


return Audio