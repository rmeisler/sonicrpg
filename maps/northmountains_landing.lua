return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "1.1.5",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 25,
  height = 26,
  tilewidth = 32,
  tileheight = 32,
  nextobjectid = 6,
  properties = {
    ["onload"] = "actions/northmountains_landing.lua",
    ["regionName"] = "Northern Mountains",
    ["sectorName"] = "Summit"
  },
  tilesets = {
    {
      name = "forest2",
      firstgid = 1,
      filename = "forest2.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../art/tiles/greatforesttileset.png",
      imagewidth = 2208,
      imageheight = 2400,
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
      tilecount = 5175,
      tiles = {}
    },
    {
      name = "forest",
      firstgid = 5176,
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
      firstgid = 8660,
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
    }
  },
  layers = {
    {
      type = "imagelayer",
      name = "bg",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      image = "../art/parallax/northmountains.png",
      properties = {
        ["movespeed"] = 0
      }
    },
    {
      type = "tilelayer",
      name = "ground",
      x = 0,
      y = 0,
      width = 25,
      height = 26,
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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 191, 192, 196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 191, 262, 262, 262, 196, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 191, 192, 262, 262, 262, 262, 262, 192, 196, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 191, 262, 262, 262, 262, 262, 262, 262, 262, 265, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 191, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 195, 196, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 191, 192, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 196, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 260, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 195, 196, 0, 0,
        0, 0, 0, 0, 0, 260, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 265, 0, 0,
        0, 0, 0, 0, 191, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 265, 0, 0,
        0, 0, 0, 0, 260, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 196, 0,
        0, 0, 0, 0, 329, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 265, 0,
        0, 0, 0, 0, 198, 329, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 334, 0,
        0, 0, 0, 0, 0, 198, 399, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 334, 199, 0,
        0, 0, 0, 0, 0, 0, 468, 260, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 332, 402, 199, 0, 0,
        0, 0, 0, 0, 0, 0, 537, 260, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 265, 471, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 537, 260, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 265, 540, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 537, 260, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 265, 540, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 537, 260, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 262, 265, 540, 0, 0, 0
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
          id = 1,
          name = "FreedomStormer",
          type = "BasicNPC",
          shape = "rectangle",
          x = 64,
          y = 512,
          width = 352,
          height = 160,
          rotation = 0,
          gid = 8696,
          visible = true,
          properties = {
            ["align"] = "bottom_left",
            ["ghost"] = true,
            ["sprite"] = "../art/sprites/freedomstormer.png"
          }
        },
        {
          id = 2,
          name = "Spawn 1",
          type = "Player",
          shape = "rectangle",
          x = 416,
          y = 608,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 8696,
          visible = true,
          properties = {
            ["orientation"] = "up"
          }
        },
        {
          id = 4,
          name = "DownPath",
          type = "SceneEdge",
          shape = "rectangle",
          x = 224,
          y = 832,
          width = 448,
          height = 64,
          rotation = 0,
          gid = 10970,
          visible = true,
          properties = {
            ["ghost"] = true,
            ["key"] = "down",
            ["orientation"] = "up",
            ["scene"] = "northmountains_1.lua",
            ["spawn_point"] = "UpPath"
          }
        },
        {
          id = 5,
          name = "Save",
          type = "SavePoint",
          shape = "rectangle",
          x = 256,
          y = 576,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 10373,
          visible = true,
          properties = {
            ["nonight"] = true,
            ["sprite"] = "../art/sprites/save.png"
          }
        }
      }
    },
    {
      type = "imagelayer",
      name = "snowstorm",
      visible = true,
      opacity = 0.4,
      offsetx = 0,
      offsety = 0,
      image = "../art/parallax/snowstorm.png",
      properties = {
        ["speedx"] = 10,
        ["speedy"] = 10,
        ["type"] = "Parallax"
      }
    },
    {
      type = "tilelayer",
      name = "Collision",
      x = 0,
      y = 0,
      width = 25,
      height = 26,
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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 8119, 8119, 8119, 8119, 8119, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 8119, 0, 0, 0, 0, 8119, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 8119, 8119, 8119, 8119, 0, 0, 0, 0, 0, 8119, 8119, 8119, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 8119, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 8119, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 8119, 0, 8119, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 8119, 8119, 8119, 0, 0, 0,
        0, 0, 0, 0, 8119, 8119, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 0, 0, 0,
        0, 0, 0, 0, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 8119, 8119, 0,
        0, 0, 0, 0, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 0,
        0, 0, 0, 8119, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 0,
        0, 0, 0, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 8119,
        0, 0, 0, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119,
        0, 0, 0, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119,
        0, 0, 0, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119,
        0, 0, 0, 8119, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 8119,
        0, 0, 0, 0, 8119, 8119, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 8119,
        0, 0, 0, 0, 0, 0, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 8119, 8119, 8119,
        0, 0, 0, 0, 0, 0, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 8119, 8119, 0,
        0, 0, 0, 0, 0, 0, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 8119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8119, 0, 0, 0
      }
    }
  }
}
