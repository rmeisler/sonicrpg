return {
    image = "rotorpad.png",
    starting = "inactive",
    w = 64,
    h = 48,

    animations = {
        inactive = {
            frames = {{0,0}}
        },
		activate = {
            frames = {{1,0},{2,0},{3,0},{4,0}},
			speed = 0.05
        },
		active = {
            frames = {{12,0},{11,0},{10,0},{9,0},{8,0},{7,0},{6,0},{5,0},{4,0}},
			speed = 0.05
        },
    }
}