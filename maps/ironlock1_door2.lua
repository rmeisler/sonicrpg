return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "1.1.5",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 25,
  height = 20,
  tilewidth = 32,
  tileheight = 32,
  nextobjectid = 26,
  properties = {
    ["battlebg"] = "../art/backgrounds/ironlockbg.png",
    ["onload"] = "actions/ironlock_roomload.lua",
    ["regionName"] = "Iron Lock",
    ["sectorName"] = "1F"
  },
  tilesets = {
    {
      name = "knotholehut",
      firstgid = 1,
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../art/tiles/knotholehutinterior.png",
      imagewidth = 950,
      imageheight = 1170,
      transparentcolor = "#000000",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      tilecount = 1044,
      tiles = {}
    },
    {
      name = "forest",
      firstgid = 1045,
      filename = "knothole.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../art/tiles/knotholeexterior.png",
      imagewidth = 1664,
      imageheight = 2144,
      transparentcolor = "#b326c3",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      tilecount = 3484,
      tiles = {}
    },
    {
      name = "robotropolis",
      firstgid = 4529,
      filename = "robotropolis.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../art/tiles/robotropolis2.png",
      imagewidth = 1120,
      imageheight = 3200,
      transparentcolor = "#000000",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      tilecount = 3500,
      tiles = {}
    },
    {
      name = "cave",
      firstgid = 8029,
      filename = "cave.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../art/tiles/caves.png",
      imagewidth = 1120,
      imageheight = 2144,
      transparentcolor = "#b326bd",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      tilecount = 2345,
      tiles = {}
    },
    {
      name = "knotholeindoors",
      firstgid = 10374,
      filename = "knotholeindoors.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../art/tiles/knotholeinterior.png",
      imagewidth = 1696,
      imageheight = 1088,
      transparentcolor = "#b326bd",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      tilecount = 1802,
      tiles = {}
    },
    {
      name = "ironlock",
      firstgid = 12176,
      filename = "ironlock.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../art/tiles/ironlock.png",
      imagewidth = 2240,
      imageheight = 3200,
      transparentcolor = "#904f94",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      tilecount = 7000,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "floor",
      x = 0,
      y = 0,
      width = 25,
      height = 20,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16885, 16885, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16885, 16885, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16885, 16885, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 17234, 17235, 17236, 17237, 17234, 17235, 17236, 17237, 17234, 17235, 17236, 17237, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 17304, 17305, 17306, 17307, 17304, 17305, 17306, 17307, 17304, 17305, 17306, 17307, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 17374, 17375, 17376, 17377, 17374, 17375, 17376, 17377, 17374, 17375, 17376, 17377, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 17444, 17445, 17446, 17447, 17444, 17445, 17446, 17447, 17444, 17445, 17446, 17447, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 17514, 17515, 17516, 17517, 17514, 17515, 17516, 17517, 17514, 17515, 17516, 17517, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 17584, 17585, 17586, 17587, 17584, 17585, 17586, 17587, 17584, 17585, 17586, 17587, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 17234, 17235, 17236, 17237, 17234, 17235, 17236, 17237, 17234, 17235, 17236, 17237, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 17304, 17305, 17306, 17307, 17304, 17305, 17306, 17307, 17304, 17305, 17306, 17307, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      name = "above",
      x = 0,
      y = 0,
      width = 25,
      height = 20,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 16782, 16783, 16720, 16721, 16720, 16720, 16721, 16720, 16790, 16791, 16784, 16785, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 16712, 16713, 16790, 16791, 16790, 16790, 16791, 16721, 16791, 16721, 16714, 16715, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 16782, 16783, 16791, 16720, 16721, 16717, 16718, 16719, 16790, 16791, 16784, 16785, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 16712, 16713, 16719, 16790, 16791, 16787, 16788, 16789, 16721, 16719, 16714, 16715, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 18007, 18007, 18007, 18007, 18007, 18286, 18287, 18007, 18007, 18007, 18007, 18007, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 18147, 18147, 18077, 18147, 18147, 18356, 18357, 18147, 18147, 18147, 18147, 18147, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 18217, 18217, 18217, 18217, 18217, 18426, 18427, 18217, 18217, 18217, 18217, 18217, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 17164, 17165, 17166, 17166, 17165, 17166, 17166, 17166, 17165, 17166, 17165, 17167, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      name = "objects",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 2,
          name = "Door",
          type = "Door",
          shape = "rectangle",
          x = 352,
          y = 512,
          width = 64,
          height = 32,
          rotation = 0,
          gid = 6839,
          visible = true,
          properties = {
            ["align"] = "bottom_left",
            ["alignOffsetX"] = -20,
            ["ghost"] = true,
            ["key"] = "down",
            ["orientation"] = "up",
            ["scene"] = "ironlock1.lua",
            ["spawn_point"] = "Door2",
            ["spawn_point_offset_x"] = 16,
            ["spawn_point_offset_y"] = 40,
            ["sprite"] = "../art/sprites/door6.png"
          }
        },
        {
          id = 21,
          name = "Save",
          type = "SavePoint",
          shape = "rectangle",
          x = 369,
          y = 324,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 6242,
          visible = true,
          properties = {
            ["align"] = "bottom_left",
            ["nonight"] = true,
            ["sprite"] = "../art/sprites/save.png"
          }
        },
        {
          id = 22,
          name = "EyesTrap1",
          type = "BasicNPC",
          shape = "rectangle",
          x = 320,
          y = 288,
          width = 128,
          height = 32,
          rotation = 0,
          gid = 6839,
          visible = true,
          properties = {
            ["ghost"] = true,
            ["onInit"] = "return function(self)\n    if GameState:isFlagSet(\"ironlocksave.Arm1\") then\n        self:remove()\n    end\nend",
            ["whileColliding"] = "local Animate = require \"actions/Animate\"\nlocal Wait = require \"actions/Wait\"\nlocal Do = require \"actions/Do\"\nlocal Ease = require \"actions/Ease\"\nlocal While = require \"actions/While\"\nlocal Serial = require \"actions/Serial\"\nlocal Parallel = require \"actions/Parallel\"\n\nreturn function(self, player, prevState)\n    local arm = self.scene.objectLookup.Arm1\n    local eyes = self.scene.objectLookup.Eyes1\n    if GameState:isFlagSet(\"ironlocksave.Arm1\") then\n        return\n    end\n    if prevState == self.STATE_IDLE and arm.hidden then\n        eyes.hidden = false\n        eyes:run(While(\n            function()\n                return not arm:isRemoved() and not eyes:isRemoved()\n            end,\n            Serial {\n                Animate(eyes.sprite, \"forward\"),\n                Wait(0.5),\n                Animate(eyes.sprite, \"smile\"),\n                Wait(0.5),\n                Do(function()\n                    arm.hidden = false\n                    arm.x = eyes.x - 60\n                    arm.y = eyes.y\n                end),\n                Ease(arm, \"y\", function() return arm.y + 40 end, 4),\n                Do(function()\n                    arm.object.y = arm.y\n                    arm:updateCollision()\n                end),\n                Wait(2),\n                Parallel {\n                    Ease(arm, \"y\", function() return arm.y - 40 end, 2),\n                    Ease(arm.sprite.color, 4, 0, 4)\n                },\n                Do(function()\n                    if not arm:isRemoved() and not eyes:isRemoved() then\n                        arm.sprite.color[4] = 255\n                        arm.object.y = arm.y - 200\n                        arm:updateCollision()\n                        arm.hidden = true\n                        eyes.sprite:setAnimation(\"forwardblink\")\n                    end\n                end)\n            },\n            Do(function() end)\n        ))\n    end\nend"
          }
        },
        {
          id = 23,
          name = "Arm1",
          type = "BasicNPC",
          shape = "rectangle",
          x = 352,
          y = 96,
          width = 64,
          height = 160,
          rotation = 0,
          gid = 6839,
          visible = true,
          properties = {
            ["battle"] = "../data/monsters/phantom.lua",
            ["battleInitiative"] = "opponent",
            ["battleOnCollide"] = true,
            ["disappearAfterBattle"] = true,
            ["flagOverride"] = "ironlocksave.Arm1",
            ["ghost"] = true,
            ["isBot"] = true,
            ["onInit"] = "return function(self)\n    self.hidden = true\n    if GameState:isFlagSet(\"ironlocksave.Arm1\") then\n        self:remove()\n    end\nend",
            ["sprite"] = "../art/sprites/phantomgrab.png"
          }
        },
        {
          id = 25,
          name = "Eyes1",
          type = "BasicNPC",
          shape = "rectangle",
          x = 352,
          y = 224,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 6839,
          visible = true,
          properties = {
            ["ghost"] = true,
            ["isBot"] = true,
            ["onInit"] = "return function(self)\n    self.hidden = true\n    if GameState:isFlagSet(\"ironlocksave.Arm1\") then\n        self:remove()\n    end\nend",
            ["sprite"] = "../art/sprites/phantomface.png"
          }
        }
      }
    },
    {
      type = "tilelayer",
      name = "top",
      x = 0,
      y = 0,
      width = 25,
      height = 20,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      name = "Collision",
      x = 0,
      y = 0,
      width = 25,
      height = 20,
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16887, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 16887, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      name = "BunnyExtCollision",
      x = 0,
      y = 0,
      width = 25,
      height = 20,
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}
