return {
	{
        type = "map",
        file = "maps/forgotten_ep6intro.lua",
		primary = true -- REAL
    },
	
	{
		type = "gradient",
		name = "mboxgradient",
		args = string.dump(function()
			return {
				direction = 'horizontal',
				{20, 0, 255},
				{20, 0, 255},
				{20, 0, 255},
				{20, 0, 255},
				{5, 0, 100}
			}
		end)
	},
	{
		type = "image",
		file = "art/sprites/cursor.png"
	},

	{
		type = "image",
		file = "art/sprites/sonic.png"
	},
	{
		type = "image",
		file = "art/sprites/b.png"
	},
	{
		type = "image",
		file = "art/sprites/dropshadow.png"
	},
	{
		type = "image",
		file = "art/sprites/pressx.png"
	},
	{
		type = "image",
		file = "art/sprites/arrow.png"
	},
	{
		type = "sound",
		file = "audio/music/bleaves.ogg",
		category = "music"
	},
	{
		type = "sound",
		file = "audio/music/bleaves2.ogg",
		category = "music"
	},
	{
		type = "sound",
		file = "audio/sfx/choose.wav",
		category = "sfx"
	},
	{
		type = "sound",
		file = "audio/sfx/cursor.wav",
		category = "sfx"
	},
	{
		type = "sound",
		file = "audio/sfx/levelup.ogg",
		category = "sfx"
	}
}