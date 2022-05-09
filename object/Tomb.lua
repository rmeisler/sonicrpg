local BlockPlayer = require "actions/BlockPlayer"
local MessageBox = require "actions/MessageBox"
local NameScreen = require "actions/NameScreen"
local PlayAudio = require "actions/PlayAudio"
local AudioFade = require "actions/AudioFade"
local Spawn = require "actions/Spawn"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Serial = require "actions/Serial"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local YieldUntil = require "actions/YieldUntil"
local IfElse = require "actions/IfElse"

local NPC = require "object/NPC"

local Tomb = class(NPC)

function Tomb:construct(scene, layer, object)
	self.expected = object.properties.expected
	self.riddle = object.properties.riddle
	self.benefit = object.properties.benefit
	if object.properties.onBenefit then
		self.onBenefit = assert(loadstring(object.properties.onBenefit))()
	end
	
	NPC.init(self)

	self:addInteract(Tomb.investigate)
end

function Tomb:investigate()
	if GameState.leader == "sally" then
        self.scene:run(BlockPlayer {
            MessageBox {message="Sally: Hmmm...{p60}these look like ancient Mobian hieroglyphs..."},
			Do(function()
				self:refreshKeyHint()
			end),
        })
    elseif GameState.leader == "sonic" then
        self.scene:run(BlockPlayer {
			MessageBox {message="Sonic: This hedgehog flunked all his ancient Mobian script classes, so..."},
			Do(function()
				self:refreshKeyHint()
			end),
        })
    elseif GameState.leader == "antoine" then
        self.scene:run(BlockPlayer {
            MessageBox {message="Antoine: Ah yes! {p60}It is elementary to me! {p60}What does it say...?"},
			Do(function() self.scene.player.state = "pose" end),
			MessageBox {message="Antoine: Well it says what is says{p60}, what more can be said, eh?"},
			Do(function()
				self.scene.player.state = "idleup"
				self:refreshKeyHint()
			end)
        })
    end
end

function Tomb:onScan()
    local prevMusic = self.scene.audio:getCurrentMusic()
	self.gogogo = false
    local riddle = NameScreen {
        prompt = "What am I?",
        expected = self.expected,
        success = Serial {
            AudioFade("music", 1.0, 0.0, 2),
            Wait(1),
			MessageBox{message="Nicole: The tomb appears to be reacting to your answer, Sally...", textSpeed=3},
            Spawn(Serial {
                PlayAudio("music", "trialcomplete", 1.0, true),
				Wait(30),
				AudioFade("music", 1.0, 0.0, 1),
                PlayAudio("music", prevMusic, 1.0, true, true)
            }),
            Parallel {
                Serial {
                    Wait(4),
                    MessageBox{message="Nicole: The tomb is attempting to upload software into my databank...", textSpeed=2, closeAction=Wait(2)}
                },
                Ease(self.sprite.color, 1, 800, 0.2),
                Ease(self.sprite.color, 2, 800, 0.2),
                Ease(self.sprite.color, 3, 800, 0.2)
            },
            Do(function() self.scene.player.ignoreLightingEffects = true end),
            Parallel {
                Ease(self.scene.player.sprite.color, 1, 800, 0.4),
                Ease(self.scene.player.sprite.color, 2, 800, 0.4),
                Ease(self.scene.player.sprite.color, 3, 800, 0.4)
            },
			Wait(1),
			MessageBox{message="Nicole: I am... {p60}learning...", textSpeed=2, closeAction=Wait(1.5)},
            Wait(4),
            Do(function()
                self:run{
                    Parallel {
                        Ease(self.scene.player.sprite.color, 1, 255, 0.4),
                        Ease(self.scene.player.sprite.color, 2, 255, 0.4),
                        Ease(self.scene.player.sprite.color, 3, 255, 0.4),
                        Ease(self.sprite.color, 4, 0, 0.2)
                    },
                    Do(function() self.gogogo = true end)
                }
            end),
            YieldUntil(function() return self.gogogo end),
            Do(function() self.scene.player.sprite:setAnimation("pose") end),
            MessageBox{message=self.benefit, sfx = "levelup"},
            Do(function()
				self.onBenefit(self)
                self.scene.player.sprite:setAnimation("idledown")
                self:removeCollision()
            end)
        }
    }
    return BlockPlayer {
        MessageBox {message="Nicole: Translating hieroglyphs{p40}, Sally.", textSpeed = 3, sfx = "nicolebeep"},
        AudioFade("music", 1.0, 0.0, 2),
        PlayAudio("music", "ringlake", 1.0, true, true),
        MessageBox {message="Nicole: The tomb reads{p40}, '" .. self.riddle .. "'...", textSpeed = 3},
        Parallel {
            riddle,
            MessageBox {message="Nicole: The tomb reads, '" .. self.riddle .. "'...",
						textSpeed = 100,
						closeAction=YieldUntil(function() return self.gogogo or riddle.closing end) }
        },
		IfElse(
			function() return self.gogogo end,
			Do(function() end),
			Spawn(Serial {
				AudioFade("music", 1.0, 0.0, 2),
				PlayAudio("music", prevMusic, 1.0, true, true)
			})
		)
    }
end


return Tomb
