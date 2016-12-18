--------------------------------------------------
-- Mir AI configuration file
--------------------------------------------------
CIRCLE_ON_IDLE        = 1     -- 0 = disabled
FOLLOW_AT_ONCE        = 1     -- 0 = disabled. Follow at once the owner if he/she moves away from the enemy
HELP_OWNER_1ST        = true  -- true = when the homunculus is in battle, he/she can switch target to help the owner
KILL_YOUR_ENEMIES_1ST = false -- true = the homunculus kills ALL his/her enemies before to help the owner
LONG_RANGE_SHOOTER    = false -- true = the homunculs doesn't go to monters and just casts long range attacks, until the monster come close
BOLTS_ON_CHASE_ST     = false -- true = alchemist can cast bolts when the omunculus is chasing/intercepting a monster
HP_PERC_DANGER        = 50    -- HP% below that value makes your homunculus to evade the monsters
HP_PERC_SAFE2ATK      = 75    -- The AI is not aggressive until the homunculus reaches this HP% (> 100 = never agressive)
OWNER_CLOSEDISTANCE   = 2     -- Distance to reach when the houmunculus goes to the owner
TOO_FAR_TARGET        = 14    -- Max interception range from the owner
SKILL_TIME_OUT        = 2000  -- The AI doesn't use aggressive skills if more than the specified milliseconds are passed
                              -- from the begin of the attack (unless the skill mode for this monster is "WITH_full_power")
NO_MOVING_TARGETS     = false -- true = the homunculus don't attack monsters that are on movement (ie monsters that are following other players)
ADV_MOTION_CHECK      = false -- true = it tries to detect frozen or trapped monster (for now this works for aggressive monsters only) and area spells

-- Alchemist Auto Attacks (AAA)-------------------
-- HP Range (no AAA when HP are out of this range)
AAA_MinHP   = 100   --\__ to disable limits: set AAA_MinHP = 0 and AAA_MaxHP = a very high value,
AAA_MaxHP   = 32000 --/   that your alchemist will never reach (eg. 32000)
-- Cart Revolution
ACR = {}
ACR.MinEnemies = 2  -- Minimum enemies (0=disabled, no Cart Revolution)
ACR.MinSP   = 20 -- Minimum SP to use Auto Cart Revolution
-- (single target) Weapon-based skill
AST = {}
AST.SkillID = 0  -- 0 = disabled, 5=Bash(Cultus), 14=Cold Bolt(Ice Falchion), 19 = Firebolt (Fireblend), 337 = Tomahawk Throwing (Tomahawk)
AST.MinSP   = 20 -- Minimum SP to use an Auto Single Target weapon-based attak
AST.Level   = 5

-- Auto-Aid Potion (AAP) -------------------------
CAN_DETECT_NOPOT = true
AAP = {}
AAP.Mode    = 3    -- set this to 0 to disable AAP
AAP.HP_Perc = 65   -- if the HP are below this percentage, an AAP (or Healing Touch) is casted
                   -- select a % that an AAP can returns HP above HOMUN_SAFE_HP_PERC
AAP.Level   = 2    -- lvl 2 throws orange potions

-- Homunculus skills -----------------------------
-- Here you can configure skill levels and the minimum SP amount required in order
-- to activate a skill (the AI will not cast that skill until your homunculus has
-- more SPs than the specified value).

-- Amistr
AS_AMI_BULW = {} -- Bulwark
AS_AMI_BULW.MinSP=40
AS_AMI_BULW.Level=5

AS_AMI_CAST = {} -- Castling
AS_AMI_CAST.MinSP=10
AS_AMI_CAST.Level=0 -- disabled

-- Filir
AS_FIL_MOON = {} -- Moonlight
AS_FIL_MOON.MinSP=20 -- set this to 90, to preserve 70 SP for flitting
AS_FIL_MOON.Level=5

AS_FIL_ACCL = {} -- Accelerated Flight
AS_FIL_ACCL.MinSP=70
AS_FIL_ACCL.Level=0 -- disabled

AS_FIL_FLTT = {} -- Flitting
AS_FIL_FLTT.MinSP=70
AS_FIL_FLTT.Level=5

-- Lif
AS_LIF_HEAL = {} -- Healing touch
AS_LIF_HEAL.MinSP=40
AS_LIF_HEAL.Level=5

AS_LIF_ESCP = {} -- Urgent escape
AS_LIF_ESCP.MinSP=40
AS_LIF_ESCP.Level=5

-- Vanilmirth
AS_VAN_CAPR = {} -- Caprice
AS_VAN_CAPR.MinSP=30
AS_VAN_CAPR.Level=5

AS_VAN_BLES = {} -- Chaotic Blessings
AS_VAN_BLES.MinSP=40
AS_VAN_BLES.Level=0 -- lvl 4 heals chances: 36% enemy, 60% self, 4% owner

-- Tact list: behaviour for each monster ---------
-- format: Tact[ID] = {"Name", behaviour, skill mode}
-- ID: please check ROEmpire database for more IDs: http://www.roempire.com/database/?page=monsters
-- Name: this is just for you, the AI only checks the ID
-- Behaviours and skill modes: you can find the list in Const.lua
DEFAULT_BEHA = BEHA_attack     -- \__ values assumed for any monster not listed below
DEFAULT_WITH = WITH_slow_power -- /
Tact = {}
Tact[1261] = {"Wild Rose", BEHA_react, WITH_full_power, 5, 0}
-- Orc Dungeon (lvl 50+ Settings)
Tact[1189] = {"Orc Archer", BEHA_react_1st, WITH_full_power, 5, 0}
Tact[1177] = {"Zenorc", BEHA_attack_1st, WITH_full_power, 5, 0}
Tact[1152] = {"Orc Skeleton", BEHA_react, WITH_one_skill, 5, 0}
Tact[1111] = {"Drainliar", BEHA_attack_weak, WITH_no_skill, 1, 0}
Tact[1042] = {"Steel Chonchon", BEHA_attack_last, WITH_one_skill, 1, 0}
-- Poring and Metaling fields
Tact[1368] = {"Geographer", BEHA_avoid, WITH_no_skill, 5, 0}
Tact[1118] = {"Flora", BEHA_coward, WITH_full_power, 5, 0}
Tact[1613] = {"Metaling", BEHA_react, WITH_one_skill, 5, 0}
Tact[1031] = {"Poporing", BEHA_react, WITH_one_skill, 5, 0}
Tact[1242] = {"Marin", BEHA_react, WITH_no_skill, 5, 0}
Tact[1113] = {"Drops", BEHA_attack, WITH_no_skill, 5, -1}
Tact[1002] = {"Poring", BEHA_attack_last, WITH_no_skill, 5, -1}
-- Eggs
Tact[1008] = {"Pupa", BEHA_attack_last, WITH_no_skill, 5, 0}
Tact[1048] = {"Thief Bug Egg", BEHA_attack_last, WITH_no_skill, 5, 0}
Tact[1047] = {"Peco Peco Egg", BEHA_attack_last, WITH_no_skill, 5, 0}
Tact[1097] = {"Ant Egg", BEHA_attack_last, WITH_no_skill, 5, 0}
-- Summoned Plants
Tact[1555] = {"Sm. Parasite", BEHA_avoid, WITH_no_skill, 5, 0}
Tact[1575] = {"Sm. Flora", BEHA_avoid, WITH_no_skill, 5, 0}
Tact[1579] = {"Sm. Hydra", BEHA_avoid, WITH_no_skill, 5, 0}
Tact[1589] = {"Sm. Mandragora", BEHA_avoid, WITH_no_skill, 5, 0}
Tact[1590] = {"Sm. Geographer", BEHA_avoid, WITH_no_skill, 5, 0}
-- WoE Guardians
Tact[1285] = {"WoE Guardian 1", BEHA_avoid, WITH_no_skill, 5, 0}
Tact[1286] = {"WoE Guardian 2", BEHA_avoid, WITH_no_skill, 5, 0}
Tact[1287] = {"WoE Guardian 3", BEHA_avoid, WITH_no_skill, 5, 0}
Tact[1288] = {"WoE Guardian 4", BEHA_avoid, WITH_no_skill, 5, 0}
-- Plants and mushrooms
Tact[1078] = {"Red Plant", BEHA_react, WITH_no_skill, 5, 0}
Tact[1079] = {"Blue Plant", BEHA_react, WITH_no_skill, 5, 0}
Tact[1080] = {"Green Plant", BEHA_react, WITH_no_skill, 5, 0}
Tact[1081] = {"Yellow Plant", BEHA_react, WITH_no_skill, 5, 0}
Tact[1082] = {"White Plant", BEHA_react, WITH_no_skill, 5, 0}
Tact[1083] = {"Shining Plant", BEHA_react, WITH_no_skill, 5, 0}
Tact[1084] = {"Black Mushroom", BEHA_react, WITH_no_skill, 5, 0}
Tact[1085] = {"Red Mushroom", BEHA_react, WITH_no_skill, 5, 0}
-- End Tact