return {
    image = "robotnikchair.png",
    starting = "faceup",
    w = 146,
    h = 113,

    animations = {
        faceup = {
            frames = {{5,0}}
        },
		spinaround = {
            frames = {{5,0},{6,0},{7,0}},
			speed = 0.2
        },
		facedown = {
            frames = {{7,0}}
        },
		facedownsmile = {
            frames = {{8,0}}
        },
		facedowngrin = {
            frames = {{9,0}}
        },
		facedownfrown = {
            frames = {{10,0}}
        },
		facedownangry = {
            frames = {{11,0}}
        }
    }
}