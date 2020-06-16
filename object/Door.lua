local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local SceneManager = require "scene/SceneManager"

local NPC = require "object/NPC"
local Door = class(NPC)

function Door:construct(scene, layer, object)
	self.prop = object.properties
	self.opensfx = object.properties.opensfx
	self.needFlag = object.properties.needFlag
	
	NPC.init(self)

	self:addHandler(
		"enter",
		SceneManager.pushScene,
		scene.sceneMgr,
		{
			class = "BasicScene",
			map = scene.maps["maps/"..tostring(object.properties.scene)],
			maps = scene.maps,
			images = scene.images,
			animations = scene.animations,
			audio = scene.audio,
			spawn_point = object.properties.spawn_point,
			cache = true
		}
	)
    self:addSceneHandler("keytriggered")
end

function Door:keytriggered(key, uni)
    if  self.state == self.STATE_TOUCHING and
		key == self.prop.key and
		(not self.needFlag or GameState:isFlagSet(self))
	then
		if self.opensfx then
			self.scene.audio:playSfx(self.opensfx)
		end
        self:invoke("enter")
    end
end


return Door
