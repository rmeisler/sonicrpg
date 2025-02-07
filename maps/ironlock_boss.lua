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
  nextobjectid = 29,
  properties = {
    ["battlebg"] = "../art/backgrounds/ironlockbg2.png",
    ["onload"] = "actions/ironlock_boss.lua"
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
        17236, 17237, 17234, 17235, 17236, 17237, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17234, 17235, 17236, 17237, 17234, 17235, 17236,
        17306, 17307, 17304, 17305, 17306, 17307, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17304, 17305, 17306, 17307, 17304, 17305, 17306,
        17376, 17377, 17374, 17375, 17376, 17377, 0, 0, 18424, 18424, 18077, 0, 0, 0, 0, 0, 0, 0, 17374, 17375, 17376, 17377, 17374, 17375, 17376,
        17446, 17447, 17444, 17445, 17446, 17447, 0, 0, 18424, 18424, 18147, 0, 0, 0, 0, 0, 0, 0, 17444, 17445, 17446, 17447, 17444, 17445, 17446,
        17516, 17517, 17514, 17515, 17516, 17517, 0, 0, 18424, 18424, 0, 0, 0, 0, 0, 0, 0, 0, 17514, 17515, 17516, 17517, 17514, 17515, 17516,
        17586, 17587, 17584, 17585, 17586, 17587, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17584, 17585, 17586, 17587, 17584, 17585, 17586,
        17236, 17237, 17234, 17235, 17236, 17237, 17234, 17235, 17236, 17237, 17234, 17235, 17236, 17237, 17234, 17235, 17236, 17237, 17234, 17235, 17236, 17237, 17234, 17235, 17236,
        17306, 17307, 17304, 17305, 17306, 17307, 17304, 17305, 17306, 17307, 17304, 17305, 17306, 17307, 17304, 17305, 17306, 17307, 17304, 17305, 17306, 17307, 17304, 17305, 17306,
        17376, 17377, 17374, 17375, 17376, 17377, 17374, 17375, 17376, 17377, 17374, 17375, 17376, 17377, 17374, 17375, 17376, 17377, 17374, 17375, 17376, 17377, 17374, 17375, 17376,
        17446, 17447, 17444, 17445, 17446, 17447, 17444, 17445, 17446, 17447, 17444, 17445, 17446, 17447, 17444, 17445, 17446, 17447, 17444, 17445, 17446, 17447, 17444, 17445, 17446,
        17516, 17517, 17514, 17515, 17516, 17517, 17514, 17515, 17516, 17517, 17514, 17515, 17516, 17517, 17514, 17515, 17516, 17517, 17514, 17515, 17516, 17517, 17514, 17515, 17516,
        17586, 17587, 17584, 17585, 17586, 17587, 17584, 17585, 17586, 17587, 17584, 17585, 17586, 17587, 17584, 17585, 17586, 17587, 17584, 17585, 17586, 17587, 17584, 17585, 17586,
        17236, 17237, 17234, 17235, 17236, 17237, 17234, 17235, 17236, 17237, 17234, 17235, 17236, 17237, 17234, 17235, 17236, 17237, 17234, 17235, 17236, 17237, 17234, 17235, 17236,
        17306, 17307, 17304, 17305, 17306, 17307, 17304, 17305, 17306, 17307, 17304, 17305, 17306, 17307, 17304, 17305, 17306, 17307, 17304, 17305, 17306, 17307, 17304, 17305, 17306,
        17376, 17377, 17374, 17375, 17376, 17377, 17374, 17375, 17376, 17377, 17374, 17375, 17376, 17377, 17374, 17375, 17376, 17377, 17374, 17375, 17376, 17377, 17374, 17375, 17376,
        17446, 17447, 17444, 17445, 17446, 17447, 17444, 17445, 17446, 17447, 17444, 17445, 17446, 17447, 17444, 17445, 17446, 17447, 17444, 17445, 17446, 17447, 17444, 17445, 17446,
        17516, 17517, 17514, 17515, 17516, 17517, 17514, 17515, 17516, 17517, 17514, 17515, 17516, 17517, 17514, 17515, 17516, 17517, 17514, 17515, 17516, 17517, 17514, 17515, 17516,
        17586, 17587, 17584, 17585, 17586, 17587, 17584, 17585, 17586, 17587, 17584, 17585, 17586, 17587, 17584, 17585, 17586, 17587, 17584, 17585, 17586, 17587, 17584, 17585, 17586
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
        14773, 14774, 14775, 14776, 14773, 14774, 14775, 14776, 14773, 14774, 14775, 14776, 14773, 14774, 14775, 14776, 14773, 14774, 14775, 14776, 14773, 14774, 14775, 14776, 14773,
        14843, 14844, 14845, 14846, 14843, 14844, 14845, 14846, 14843, 14844, 14845, 14846, 14843, 14844, 14845, 14846, 14843, 14844, 14845, 14846, 14843, 14844, 14845, 14846, 14843,
        14913, 14914, 14915, 14916, 14913, 14914, 14915, 14916, 14913, 14914, 14915, 14916, 14913, 14914, 14915, 14916, 14913, 14914, 14915, 14916, 14913, 14914, 14915, 14916, 14913,
        14633, 14634, 14635, 14636, 14633, 14634, 14635, 14636, 14633, 14634, 14635, 14636, 14633, 14634, 14635, 14636, 14633, 14634, 14635, 14636, 14633, 14634, 14635, 14636, 14633,
        14703, 14704, 14705, 14706, 14703, 14704, 14705, 14706, 14703, 14704, 14705, 14706, 14703, 14704, 14705, 14706, 14703, 14704, 14705, 14706, 14703, 14704, 14705, 14706, 14703,
        14773, 14774, 14775, 14776, 14773, 14774, 14775, 14776, 14773, 14774, 14775, 14776, 14773, 14774, 14775, 14776, 14773, 14774, 14775, 14776, 14773, 14774, 14775, 14776, 14773,
        14843, 14844, 14845, 14846, 14843, 14844, 14845, 14846, 14843, 14844, 14845, 14846, 14843, 14844, 14845, 14846, 14843, 14844, 14845, 14846, 14843, 14844, 14845, 14846, 14843,
        14913, 14914, 14915, 14916, 14913, 14914, 14915, 14916, 14913, 14914, 14915, 14916, 14913, 14914, 14915, 14916, 14913, 14914, 14915, 14916, 14913, 14914, 14915, 14916, 14913,
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
          id = 23,
          name = "Boss",
          type = "BasicNPC",
          shape = "rectangle",
          x = -224,
          y = 448,
          width = 96,
          height = 96,
          rotation = 0,
          gid = 4565,
          visible = true,
          properties = {
            ["align"] = "bottom_left",
            ["alphaOverride"] = 0,
            ["defaultAnim"] = "idle",
            ["ghost"] = true,
            ["sprite"] = "../art/sprites/cyclops.png"
          }
        },
        {
          id = 24,
          name = "Sonic",
          type = "BasicNPC",
          shape = "rectangle",
          x = 288,
          y = -160,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 6242,
          visible = true,
          properties = {
            ["defaultAnim"] = "shock",
            ["nocollision"] = true,
            ["sprite"] = "../art/sprites/sonic.png"
          }
        },
        {
          id = 25,
          name = "Sally",
          type = "BasicNPC",
          shape = "rectangle",
          x = 352,
          y = -96,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 6242,
          visible = true,
          properties = {
            ["defaultAnim"] = "shock",
            ["nocollision"] = true,
            ["sprite"] = "../art/sprites/sally.png"
          }
        },
        {
          id = 26,
          name = "Antoine",
          type = "BasicNPC",
          shape = "rectangle",
          x = 416,
          y = -160,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 6242,
          visible = true,
          properties = {
            ["defaultAnim"] = "shock",
            ["nocollision"] = true,
            ["sprite"] = "../art/sprites/antoine.png"
          }
        },
        {
          id = 27,
          name = "Spawn 1",
          type = "Player",
          shape = "rectangle",
          x = 352,
          y = 384,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 6242,
          visible = true,
          properties = {
            ["ghost"] = true,
            ["orientation"] = "up"
          }
        },
        {
          id = 28,
          name = "King",
          type = "BasicNPC",
          shape = "rectangle",
          x = 544,
          y = 352,
          width = 64,
          height = 64,
          rotation = 0,
          gid = 6242,
          visible = true,
          properties = {
            ["alphaOverride"] = 0,
            ["defaultAnim"] = "king_idle",
            ["nocollision"] = true,
            ["sprite"] = "../art/sprites/p.png"
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
