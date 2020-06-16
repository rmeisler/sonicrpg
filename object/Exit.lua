local SceneManager = require "scene/SceneManager"

local Exit = class(require "object/NPC")

function Exit:construct(scene, layer, object)
	self.key = object.properties.key
	self:addHandler("exit", SceneManager.popScene, scene.sceneMgr, {spawn_point=object.properties.spawn_point})
    self:addSceneHandler("keytriggered")
end

function Exit:keytriggered(key, uni)
    if self.state == self.STATE_TOUCHING and key == self.key then
        self:invoke("exit")
    end
end


return Exit
