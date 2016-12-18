--------------------------------------------------
-- Const.lua for Mir AI
--------------------------------------------------

-- C functions
--[[
function TraceAI (string) end
function MoveToOwner (id) end
function Move (id,x,y) end
function Attack (id,id) end
function GetV (V_,id) end
function GetActors () end
function GetTick () end
function GetMsg (id) end
function GetResMsg (id) end
function SkillObject (id,level,skill,target) end
function SkillGround (id,level,skill,x,y) end
function IsMonster (id) end
--]]

--------------------------------------------------
-- Combat Directives
--------------------------------------------------
-- N.B.: the config. utility loads and display those strings (so they are written in an unconventional way)
-- Constant      |Value|Description
BEHA_avoid       = 0 -- Escape everytime and don't even help the owner
BEHA_coward      = 1 -- Escape when hit, but come to help the owner
BEHA_react_1st   = 2 -- Defend only (highest priority) or cooperate
BEHA_react       = 3 -- Defend only (medium priority) or cooperate
BEHA_react_last  = 4 -- Defend only (low priority) or cooperate
BEHA_attack_1st  = 5 -- Aggressive (when HPs are OK), highest priority
BEHA_attack      = 6 -- Aggressive (when HPs are OK), medium priority
BEHA_attack_last = 7 -- Aggressive (when HPs are OK), low priority
BEHA_attack_weak = 8 -- Aggressive (weak monster: ignore his attacks), low priority

WITH_no_skill    = 0 -- don't waste SPs for skills
WITH_one_skill   = 1 -- only one skill in the beginning of the attack
WITH_two_skills  = 2 -- only two skill in the beginning of the attack
WITH_max_skills  = 3 -- use skills, until the time out expires
WITH_full_power  = 4 -- use skills, until there are enough SPs
WITH_slow_power  = 5 -- use skills after a small delay

--------------------------------------------------
-- Get Info
--------------------------------------------------
V_OWNER            =  0
V_POSITION         =  1
V_TYPE             =  2
V_MOTION           =  3
V_ATTACKRANGE      =  4
V_TARGET           =  5
V_SKILLATTACKRANGE =  6
V_HOMUNTYPE        =  7
V_HP               =  8
V_SP               =  9
V_MAXHP            = 10
V_MAXSP            = 11
------------------- tactics
V_TACTBEHAV   = 2
V_TACTSKILL   = 3
V_TACTLEVEL   = 4
V_TACTALCHE   = 5

--------------------------------------------------
-- Weapon Based Skill
--------------------------------------------------
WBS_BASH = 5
WBS_ICE  = 14
WBS_FIRE = 19
WBS_TOMA = 337

--------------------------------------------------
-- Homunculus ID
--------------------------------------------------
LIF             = 1
AMISTR          = 2
FILIR           = 3
VANILMIRTH      = 4
LIF2            = 5
AMISTR2         = 6
FILIR2          = 7
VANILMIRTH2     = 8
LIF_H           = 9
AMISTR_H        = 10
FILIR_H         = 11
VANILMIRTH_H    = 12
LIF_H2          = 13
AMISTR_H2       = 14
FILIR_H2        = 15
VANILMIRTH_H2   = 16

-- Homunculus S --
EIRA			= 48
BAYERI			= 49
SERA			= 50
DIETER			= 51
ELEANOR			= 52

--------------------------------------------------
-- "Motion" status
--------------------------------------------------
MOTION_STAND    = 0
MOTION_MOVE     = 1
MOTION_ATTACK   = 2
MOTION_DEAD     = 3
MOTION_HIT      = 4
MOTION_PICKUP   = 5
MOTION_SIT      = 6
MOTION_SKILL    = 7
MOTION_CAST     = 8
MOTION_ATTACK2  = 9

--------------------------------------------------
-- Command
--------------------------------------------------
NONE_CMD          = 0
MOVE_CMD          = 1
STOP_CMD          = 2
ATTACK_OBJECT_CMD = 3
ATTACK_AREA_CMD   = 4
PATROL_CMD        = 5
HOLD_CMD          = 6
SKILL_OBJECT_CMD  = 7
SKILL_AREA_CMD    = 8
FOLLOW_CMD        = 9

--------------------------------------------------
--[[ I can't read korean text T_T
MOVE_CMD    {명령번호,X좌표,Y좌표}
STOP_CMD    {명령번호}
ATTACK_OBJECT_CMD   {명령번호,목표ID}
ATTACK_AREA_CMD {명령번호,X좌표,Y좌표}
PATROL_CMD  {명령번호,X좌표,Y좌표}
HOLD_CMD    {명령번호}
SKILL_OBJECT_CMD    {명령번호,선택레벨,종류,목표ID}
SKILL_AREA_CMD  {명령번호,선택레벨,종류,X좌표,Y좌표}
FOLLOW_CMD  {명령번호}
--]]

