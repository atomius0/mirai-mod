--------------------------------------------------
-- Mir AI Patrol/Evade Movements
--------------------------------------------------
-- You can setup your own movements: please change the steps
-- (AAI_CIRC_Y and AAI_CIRC_X array) and don't forget to update
-- AAI_CIRC_MAXSTEP if you add or remove a step!

AAI_CIRC_RADIUS         = 4
AAI_NORTH               = AAI_CIRC_RADIUS
AAI_SOUTH               = -AAI_CIRC_RADIUS
AAI_EAST                = -AAI_CIRC_RADIUS
AAI_WEST                = AAI_CIRC_RADIUS
AAI_NORTH2              = AAI_CIRC_RADIUS / 2 + 1
AAI_SOUTH2              = -(AAI_CIRC_RADIUS / 2 + 1)
AAI_EAST2               = -(AAI_CIRC_RADIUS / 2 + 1)
AAI_WEST2               = AAI_CIRC_RADIUS /2 + 1

-- Circle Steps  --------
--         6
--   5          7
--
-- 4    TARGET     8
--
--   3          1
--         2
-------------------------

-- direction: SE          S          SW          W         NW          N          NE          E
AAI_CIRC_Y = {AAI_SOUTH2, AAI_SOUTH, AAI_SOUTH2, 0,        AAI_NORTH2, AAI_NORTH, AAI_NORTH2, 0}
AAI_CIRC_X = {AAI_EAST2,  0,         AAI_WEST2,  AAI_WEST, AAI_WEST2,  0,         AAI_EAST2,  AAI_EAST}
AAI_CIRC_MAXSTEP = 8