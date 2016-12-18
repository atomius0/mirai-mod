--------------------------------------------------
-- Mir AI v1.2.2 mod v2.0
--------------------------------------------------
MIRAI_VER = 122

dofile("./AI/USER_AI/Const.lua")
dofile("./AI/USER_AI/Util.lua")
dofile("./AI/USER_AI/Config.lua") -- configuration file
dofile("./AI/USER_AI/PassiveDB.lua")
dofile("./AI/USER_AI/Patrol.lua")
dofile("./AI/USER_AI/SelectedMod.lua") -- 3rd party changes

--------------------------------------------------
-- State
--------------------------------------------------
-- from default AI
IDLE_ST              = 0
FOLLOW_ST            = 1
CHASE_ST             = 2
ATTACK_ST            = 3
MOVE_CMD_ST          = 4
STOP_CMD_ST          = 5
ATTACK_OBJECT_CMD_ST = 6
ATTACK_AREA_CMD_ST   = 7
PATROL_CMD_ST        = 8
HOLD_CMD_ST          = 9
SKILL_OBJECT_CMD_ST  = 10
SKILL_AREA_CMD_ST    = 11
FOLLOW_CMD_ST        = 12

-- Mir AI addings
EVADE_ST             = 50
BUGPOSI_ST           = 51
EVADE_COMEBACK       = 2

-- Mir AI "Output movements" (they notify the user about some events):
OUTMOVE_NEWFRIEND_ST = 60 -- The choosen player has been added to the friend-list
OUTMOVE_DELFRIEND_ST = 61 -- " has been removed

--------------------------------------------------
-- Global variable (dafault AI)
--------------------------------------------------
MyState      = IDLE_ST
MyEnemy      = 0
MyDestX      = 0
MyDestY      = 0
MyPatrolX    = 0
MyPatrolY    = 0
ResCmdList   = List.new()
MyID         = 0
MySkill      = 0
MySkillLevel = 0

--------------------------------------------------
-- Global variable (extra)
--------------------------------------------------

-- Init (please look at AI() function, init section)
Initialized = false
OwnerID     = 0
HomunType   = 0
HomunS      = false -- added for Homunculus S support
LRASID      = 0     -- Long Range Attack Skill ID
StartupTime = 0
isCircling  = false

-- Current status
CircleDir       = 1 -- Current circle-move direction
CircleBlockTime = 0 -- Time when position started to not change (obstacle encountered?)
CircleBlockStep = 0 -- 0 = all ok; 1 = obstacle? Check a second; 2 = obstacle detected
Evade_ComeBackTime = 0
vHomunX         = 0 --\_ I'm really moving?
vHomunY         = 0 --/
vHomunHP        = 0 ---- hit while chasing?
vOwnerX         = 0 --\_ used in follow at once
vOwnerY         = 0 --/
OwnerX          = 0
OwnerY          = 0
MyX             = 0
MyY             = 0
IdleStartTime   = 0
AtkStartTime    = 0
LastLRAtkTime   = 0 -- time of last long ranged attack (see OnCHASE_ST)
LastLRAtkID     = 0
AtkSkillDoneCount = 0
LastLogTime     = 0
OwnerMoveTime   = 0 -- see follow st

HTact = {}
HTact.Behav     = -1
HTact.Skill     = -1
HTact.Level     = 0
HTact.Alche     = 0

-- Blocked movements
AltAngle        = 0
BlockTime       = 0
BlockFound      = 0
BlockCount      = 0
BlockedPathToEnemyID = 0

BugPosiTime     = 0

-- Output movements
OutMoveTime     = 0
OutMoveTarget   = 0

--------------------------------------------------
-- Skills
--------------------------------------------------
CastDelayEnd = 0

DELAY_SLOW_POWER = 2000 -- for slow_power skill mode

-- Alchemist automatic skills
ACR.SkillID = 153 -- Auto Cart Revolution
DELAY_AAA   = 500 -- Cart Revolution and Bash (Cutlus)
DELAY_AAA_BOLT = 3000 -- extra delay for weapon bolts
CanDoAAANow = true
AAA_Engaged = false -- Alchemist auto-attack: can be cart revolution (multiple target) or weapon based skill (single targets)
AAA_TimeOut = 0
AAP.MaxAttempts = 3
AAP.MinInc  = 100 -- we assume that if the increment is less than this, it was natural HP regen
AAP.SkillID = 231
AAP.HowLast = 600
AAP.MinSP   = 1
AAP.Failures= 0
AAP.OldHP   = 0

-- AmiStr
AS_AMI_BULW.SkillID = 8006
AS_AMI_BULW.HowLast = (45 - (AS_AMI_BULW.Level * 5)) * 1000
AS_AMI_BULW.Engaged = false
AS_AMI_BULW.TimeOut = 0

-- Filir
AS_FIL_MOON.SkillID = 8009
AS_FIL_MOON.HowLast = 1000
AS_FIL_MOON.Engaged = false
AS_FIL_MOON.TimeOut = 0

AS_FIL_ACCL.SkillID = 8011
if AS_FIL_ACCL.Level == 5 then
   AS_FIL_ACCL.HowLast = 120000
else
	AS_FIL_ACCL.HowLast = (5 + AS_FIL_ACCL.Level) * 10000
end
AS_FIL_ACCL.Engaged = false
AS_FIL_ACCL.TimeOut = 0

AS_FIL_FLTT.SkillID = 8010
if AS_FIL_FLTT.Level == 5 then
	AS_FIL_FLTT.HowLast = 120000
else
	AS_FIL_FLTT.HowLast = (5 + AS_FIL_FLTT.Level) * 10000
end
AS_FIL_FLTT.Engaged = false
AS_FIL_FLTT.TimeOut = 0

-- Lif
AS_LIF_ESCP.SkillID = 8002
AS_LIF_ESCP.HowLast = (45 - (AS_LIF_ESCP.Level * 5)) * 1000
AS_LIF_ESCP.Engaged = false
AS_LIF_ESCP.TimeOut = 0

AS_LIF_HEAL.SkillID = 8001
AS_LIF_HEAL.HowLast = 1000
AS_LIF_HEAL.Engaged = false
AS_LIF_HEAL.TimeOut = 0

-- Vanilmirth
AS_VAN_CAPR.SkillID = 8013
AS_VAN_CAPR.HowLast = 100
AS_VAN_CAPR.Engaged = false
AS_VAN_CAPR.TimeOut = 0

AS_VAN_BLES.SkillID = 8014
AS_VAN_BLES.HowLast = 5000
AS_VAN_BLES.Engaged = false
AS_VAN_BLES.TimeOut = 0

--------------------------------------------------
-- ############ COMMAND PROCESS ###########
--------------------------------------------------

--------------------------------------------------
function OnMOVE_CMD(x, y)
--------------------------------------------------
	Log("OnMOVE_CMD")
	isCircling = false
	if (x == MyDestX and y == MyDestY and MOTION_MOVE == GetV(V_MOTION, MyID)) then
		return
	end

	-- are you adding/removing a friend? ----------
	local actors = GetActors()
	for i,v in ipairs(actors) do
		if (v ~= OwnerID and v ~= MyID) then
			if (0 == IsMonster(v)) then
				local PlayerX, PlayerY = GetV(V_POSITION, v)
				if (PlayerX == x) and (math.abs(PlayerY-y) <=1) then
					FriendList_Switch(v) -- update friend list
					OutMoveTime = GetTick() -- notify user
					OutMoveTarget = v
					if isNotFriend(v) then
						MyState = OUTMOVE_DELFRIEND_ST
					else
						MyState = OUTMOVE_NEWFRIEND_ST
					end
					MyDestX = x
					MyDestY = y
					MyEnemy = 0
					MySkill = 0
					return
				end
			end
		end
	end

	if (math.abs(x-MyX) + math.abs(y-MyY) > 15) then
		List.pushleft (ResCmdList,{MOVE_CMD,x,y})
		x = math.floor((x+MyX)/2)
		y = math.floor((y+MyY)/2)
	end

	Move(MyID, x, y)

	MyState = MOVE_CMD_ST
	MyDestX = x
	MyDestY = y
	MyEnemy = 0
	MySkill = 0
end

--------------------------------------------------
function OnSTOP_CMD()
--------------------------------------------------
	Log("OnSTOP_CMD")
	isCircling = false
	if (GetV(V_MOTION,MyID) ~= MOTION_STAND) then
		StopHere("Stop request by user")
	end
end

--------------------------------------------------
function OnATTACK_OBJECT_CMD(id)
--------------------------------------------------
	Log("OnATTACK_OBJECT_CMD")
	isCircling = false
	MySkill = 0
	MyEnemy = id
	vOwnerX, vOwnerY = OwnerX, OwnerY
	MyState = CHASE_ST
end

--------------------------------------------------
function OnATTACK_AREA_CMD(x, y)
--------------------------------------------------
	Log("OnATTACK_AREA_CMD")
	isCircling = false
	if (x ~= MyDestX or y ~= MyDestY or MOTION_MOVE ~= GetV(V_MOTION, MyID)) then
		Move(MyID, x, y)
	end
	MyDestX = x
	MyDestY = y
	MyEnemy = 0
	MyState = ATTACK_AREA_CMD_ST
end

--------------------------------------------------
function OnPATROL_CMD(x, y)
--------------------------------------------------
	Log ("OnPATROL_CMD")
	isCircling = false
	MyPatrolX , MyPatrolY = MyX, MyY
	MyDestX = x
	MyDestY = y
	Move(MyID,x,y)
	MyState = PATROL_CMD_ST
end

--------------------------------------------------
function OnHOLD_CMD()
--------------------------------------------------
	Log("OnHOLD_CMD")
	isCircling = false
	MyDestX = 0
	MyDestY = 0
	MyEnemy = 0
	MyState = HOLD_CMD_ST
end

--------------------------------------------------
function OnSKILL_OBJECT_CMD(level, skill, id)
--------------------------------------------------
	Log("OnSKILL_OBJECT_CMD")
	isCircling = false
	MySkillLevel = level
	MySkill = skill
	MyEnemy = id
	vOwnerX, vOwnerY = OwnerX, OwnerY
	MyState = CHASE_ST
end

--------------------------------------------------
function OnSKILL_AREA_CMD(level, skill, x, y)
--------------------------------------------------
	Log("OnSKILL_AREA_CMD")
	isCircling = false
	Move(MyID,x,y)
	MyDestX = x
	MyDestY = y
	MySkillLevel = level
	MySkill = skill
	MyState = SKILL_AREA_CMD_ST
end

--------------------------------------------------
function OnFOLLOW_CMD()
--------------------------------------------------
	isCircling = false
	if (MyState ~= FOLLOW_CMD_ST) then
		local file = io.open("AI/USER_AI/follow.lck", "wb")
		if file then file:close() end
		MoveToOwner(MyID)
		MyState = FOLLOW_CMD_ST
		MyDestX, MyDestY = OwnerX, OwnerY
		MyEnemy = 0
		MySkill = 0
		Log("OnFOLLOW_CMD")
	else
		if FileExists("AI/USER_AI/follow.lck") then
			os.remove("AI/USER_AI/follow.lck")
		end
		MyState = IDLE_ST
		IdleStartTime = GetTick()
		MyEnemy = 0
		MySkill = 0
		Log("FOLLOW_CMD_ST --> IDLE_ST")
	end
end

--------------------------------------------------
function ProcessCommand(msg)
--------------------------------------------------
	if 	(msg[1] == MOVE_CMD) then
		OnMOVE_CMD(msg[2], msg[3])
		Log("MOVE_CMD")
	elseif (msg[1] == STOP_CMD) then
		OnSTOP_CMD()
		Log("STOP_CMD")
	elseif (msg[1] == ATTACK_OBJECT_CMD) then
		OnATTACK_OBJECT_CMD(msg[2])
		Log("ATTACK_OBJECT_CMD")
	elseif (msg[1] == ATTACK_AREA_CMD) then
		OnATTACK_AREA_CMD(msg[2], msg[3])
		Log("ATTACK_AREA_CMD")
	elseif (msg[1] == PATROL_CMD) then
		OnPATROL_CMD(msg[2], msg[3])
		Log("PATROL_CMD")
	elseif (msg[1] == HOLD_CMD) then
		OnHOLD_CMD()
		Log("HOLD_CMD")
	elseif (msg[1] == SKILL_OBJECT_CMD) then
		OnSKILL_OBJECT_CMD(msg[2], msg[3], msg[4], msg[5])
		Log("SKILL_OBJECT_CMD")
	elseif (msg[1] == SKILL_AREA_CMD) then
		OnSKILL_AREA_CMD(msg[2], msg[3], msg[4], msg[5])
		Log ("SKILL_AREA_CMD")
	elseif (msg[1] == FOLLOW_CMD) then
		OnFOLLOW_CMD()
		Log("FOLLOW_CMD")
	end
end

--------------------------------------------------
-- ############# STATE PROCESS ############
--------------------------------------------------

--------------------------------------------------
function OnIDLE_ST()
--------------------------------------------------
	-- Log("OnIDLE_ST")

	local cmd = List.popleft(ResCmdList)
	if (cmd ~= nil) then
		ProcessCommand(cmd)
		return
	end

	AtkStartTime = 0
	AtkSkillDoneCount = 0
	HTact.Behav = -1
	HTact.Skill = -1

	local CurrTime = GetTick()

	local HomunHP = GetV(V_HP, MyID)
	local HomunMaxHP = GetV(V_MAXHP, MyID)
	local HomunHPPerc = (HomunHP / HomunMaxHP) * 100
	local HomunSP = GetV(V_SP, MyID)
	local HomunMaxSP = GetV(V_MAXSP, MyID)
	OwnerMotion = GetV(V_MOTION, OwnerID)

	-- Heal wounds
	--[[
	if(HomunType == VANILMIRTH  or HomunType == VANILMIRTH_H
	or HomunType == VANILMIRTH2 or HomunType == VANILMIRTH_H2) then
		if GetV(V_HP, OwnerID) < GetV(V_MAXHP, OwnerID) - 100 then
			DoSkill(AS_VAN_BLES, OwnerID) -- [...] it seems disabled for AIs
		end
	end
	--]]
	if HomunHP < HomunMaxHP then
		if HomunHPPerc <= AAP.HP_Perc then
			if (AAP.Mode == 4) and (CurrTime - IdleStartTime > 2000) then
				DoSkill_AAP(HomunHP)
				HomunHPPerc = (HomunHP / HomunMaxHP) * 100
			end
		end
	end

	if (LONG_RANGE_SHOOTER ~= true) and (CIRCLE_ON_IDLE > 0) and (isCircling == false) then
		if (HomunHP == HomunMaxHP) and (HomunSP == HomunMaxSP) then
			if (OwnerMotion == MOTION_STAND or OwnerMotion == MOTION_SIT) and isCloseToOwner() then
				isCircling = true
			end
		end
	end

	-- Is there a new target? -> chase_st
	if CurrTime - StartupTime > 600 then
		local NextTarget = GetMyNextTarget(HomunHPPerc)
		if NextTarget ~=0 then
			isCircling = false
			MyEnemy = NextTarget
			local Ex, Ey = GetV(V_POSITION, MyEnemy)
			if (math.abs(Ex - MyX) <= 1) and (math.abs(Ey - MyY) <= 1) then
				MyState = ATTACK_ST
				Attack(MyID, MyEnemy)
				AtkStartTime = 0
				Log(string.format("[IDLE_ST -> ATTACK_ST] Target(%d) already near, switch directly to combat", MyEnemy))
			else
				MyState = CHASE_ST
				Log(string.format("[IDLE_ST -> CHASE_ST] Intercepting new target(%d)", MyEnemy))
			end
			vOwnerX, vOwnerY = OwnerX, OwnerY
			return
		else
			if MyState == EVADE_ST then
				isCircling = false
				return
			end
		end
	end

   -- Patrol when HP and SP are full
	if (OwnerMotion ~= MOTION_STAND) and (OwnerMotion ~= MOTION_SIT) then
		isCircling = false
	end
	if isCircling then
		CircleAroundTarget(OwnerID)
	else
		-- Switch to follow if Owner is on movement or far
		if (not isCloseToOwner()) or (owner_dst == -1) then
			FollowOwner("[IDLE_ST -> FOLLOW_ST] owner is far from me")
			return
		end
	end

end

--------------------------------------------------
function OnFOLLOW_ST()
--------------------------------------------------
	-- Log("OnFOLLOW_ST")

	OwnerMotion = GetV(V_MOTION, OwnerID)
	local CurrTime = GetTick()
	if (OwnerMotion ~= MOTION_STAND) and (OwnerMotion ~= MOTION_SIT) then
		OwnerMoveTime = CurrTime
	end

	-- Owner reached? -> idle
	if isCloseToOwner() then
		if (OwnerMotion == MOTION_STAND) or (OwnerMotion == MOTION_SIT) then -- don't stop until the owner stops
			StopHere("[FOLLOW_ST -> IDLE_ST] Owner reached")
		elseif (OwnerMotion == MOTION_ATTACK) or (OwnerMotion == MOTION_ATTACK2) then
			object = GetV(V_TARGET, OwnerID)
			if (object ~= 0) then
				HTact = GetFullTact(GetV(V_HOMUNTYPE, object))
				if (HTact.Behav ~= BEHA_avoid) then
					MyState = CHASE_ST
					MyEnemy = object
					AtkStartTime = 0
					AtkSkillDoneCount = 0
					vOwnerX, vOwnerY = OwnerX, OwnerY
					Log("[FOLLOW_ST -> CHASE_ST] Cooperative attack")
				end
			end
		else
			--local angle = math.rad(math.mod(GetTick()/8, 360))
			MyDestX = OwnerX + 1 --math.cos(angle)
			MyDestY = OwnerY --+ math.sin(angle)
			Move(MyID, MyDestX, MyDestY)
		end
		return
	end

	-- Am I bloked?
	if (math.abs(vHomunX - MyX) == 0)
	and(math.abs(vHomunY - MyY) == 0) then  -- if there is no movement
		if (BlockFound == 0) then
			BlockTime = GetTick() + 300		 -- time-out
			BlockFound = 1
		elseif (BlockFound == 1 and GetTick () > BlockTime) then
			if (OwnerMotion == MOTION_STAND) or (OwnerMotion == MOTION_SIT) then
				local HomunHP = GetV(V_HP, MyID)
				local HomunMaxHP = GetV(V_MAXHP, MyID)
				local HomunHPPerc = (HomunHP / HomunMaxHP) * 100
				local NextTarget = GetMyNextTarget(HomunHPPerc)
				if NextTarget ~= 0 then
					isCircling = false
					MyState = CHASE_ST
					MyEnemy = NextTarget
					vOwnerX, vOwnerY = OwnerX, OwnerY
					Log(string.format("[FOLLOW_ST -> CHASE_ST] Blocked, but target(%d) found", MyEnemy))
					return
				else
					if MyState == EVADE_ST then
						Log("[FOLLOW_ST -> EVADE_ST]")
						return
					end
				end
			end
			BlockFound = 0
			BlockCount = BlockCount + 1
			if BlockCount >= 3 then
				Log("Can't follow in this direction")
				AltAngle = math.rad(math.mod(GetTick(), 360))
				local radius = 12
				MyDestX = MyX + math.cos(AltAngle) * radius
				MyDestY = MyY + math.sin(AltAngle) * radius
				while (radius > 0) and (GetDistance(OwnerX, OwnerY, MyDestX, MyDestY) > TOO_FAR_TARGET) do
					radius = radius - 1
					MyDestX = MyX + math.cos(AltAngle) * radius
					MyDestY = MyY + math.sin(AltAngle) * radius
				end
				if radius > 0 then
					Move(MyID, MyDestX, MyDestY)
					BlockCount = 0
					Log("Can't follow: trying alternate path")
				end
			else
				BlockFound = 0
				MyDestX = OwnerX
				MyDestY = OwnerY
				Move(MyID, OwnerX, OwnerY)
				Log("Can't follow: trying again")
			end
		end
	else
		BlockFound = 0
		BlockCount = 0

		if (CurrTime - OwnerMoveTime > 500) and ((OwnerMotion == MOTION_STAND) or (OwnerMotion == MOTION_SIT)) then
			local HomunHP = GetV(V_HP, MyID)
			local HomunMaxHP = GetV(V_MAXHP, MyID)
			local HomunHPPerc = (HomunHP / HomunMaxHP) * 100
			local NextTarget = GetMyNextTarget(HomunHPPerc)
			if NextTarget ~= 0 then
				isCircling = false
				MyState = CHASE_ST
				MyEnemy = NextTarget
				vOwnerX, vOwnerY = OwnerX, OwnerY
				Log(string.format("[FOLLOW_ST -> CHASE_ST] intercepting target(%d)", MyEnemy))
				return
			else
				if MyState == EVADE_ST then
					Log("[FOLLOW_ST -> EVADE_ST]")
					return
				end
			end
		end

		--local angle = math.rad(math.mod(GetTick()/8, 360))
		MyDestX = OwnerX + 1--math.cos(angle)
		MyDestY = OwnerY --+ math.sin(angle)
		Move(MyID, MyDestX, MyDestY)
	end
	vHomunX = MyX
	vHomunY = MyY

end

--------------------------------------------------
function OnCHASE_ST()
--------------------------------------------------
	-- Log ("OnCHASE_ST")

	if isToFollowAtOnce() then return end

	-- Target is still OK?
	local isBadTarget = false
	local Ex, Ey = GetV(V_POSITION, MyEnemy)
	if (Ex == -1) then
		Log("Target lost")
		isBadTarget = true
	elseif GetDistance(Ex, Ey, OwnerX, OwnerY) >= TOO_FAR_TARGET then
		Log("Target too far")
		isBadTarget = true
	elseif isKS() or not isMobMotionOK(MyEnemy, nil) then
		Log("Target is KS or has suspect motion")
		isBadTarget = true
	end

	-- Get a new target if it's necessary
	local HomunHP = GetV(V_HP, MyID)
	local HomunMaxHP = GetV(V_MAXHP, MyID)
	local HomunHPPerc = (HomunHP / HomunMaxHP) * 100
	local NextTarget = GetMyNextTarget(HomunHPPerc)
	if not isBadTarget and NextTarget ~= 0 then
		local EnemyDst = GetDistance2(MyEnemy, MyID)
                if (EnemyDst <= 2) or (EnemyDst <= GetDistance2(NextTarget, MyID)) then
                	NextTarget = 0
		end
	end
	if NextTarget ~= 0 then
		MyEnemy = NextTarget
		vOwnerX, vOwnerY = OwnerX, OwnerY
		AtkStartTime = 0
		AtkSkillDoneCount = 0
		Log(string.format("Intercepting new target(%d)", MyEnemy))
	else
		if isBadTarget and MyState ~= EVADE_ST then
			StopHere("[CHASE_ST -> IDLE_ST] no alternative target found")
			return
		end
	end

	-- Homunculus long range attack
	local CurrTime = GetTick()
	if LRASID ~=0 then
		if (AtkStartTime == 0) then
			AtkStartTime = CurrTime
		end
		if CanDoAtkSkillsNow() then
			if DoSkill(LRASID, MyEnemy) then -- ##### AGGRESSIVE SKILL #####
				AtkSkillDoneCount = AtkSkillDoneCount + 1
				LastLRAtkTime = CurrTime
				LastLRAtkID = MyEnemy
			end
		end
	end
	-- Alchemist long range attack
	if (BOLTS_ON_CHASE_ST == true) and (GetDistance2(MyEnemy, OwnerID) <= 9) and (AST.SkillID > 5) and (HTact.Alche >= 0) then
		if DoSkill_AutoAttack(AST.SkillID) then
			LastLRAtkTime = CurrTime
			LastLRAtkID = MyEnemy
		end
	end

	-- Am I in close combat position? -> attack_st
	if (math.abs(Ex - MyX) <= 1) and (math.abs(Ey - MyY) <= 1) then
		MyState = ATTACK_ST
		if AtkSkillDoneCount == 0 then
			AtkStartTime = 0
		end
		Attack(MyID, MyEnemy)
		Log(string.format("[CHASE_ST -> ATTACK_ST] Target(%d) reached, switch to close combat", MyEnemy))
		return
	end

	if LONG_RANGE_SHOOTER == true then
		if isCloseToOwner() then
			Attack(MyID, MyEnemy)
		else
			Log("Pushed away from owner: coming back")
			-- Besides skills that push your homunculus away, there is a Gravity's bug too: even with an empty AI script,
			-- the homunculus moves to arches whom hit him/her
			MyDestX = OwnerX + 1
			MyDestY = OwnerY
			Move(MyID, MyDestX, MyDestY)
		end
	else
		-- Am I bloked?
		if (math.abs(vHomunX - MyX) == 0)
		and(math.abs(vHomunY - MyY) == 0) then -- if there is no movement
			if (BlockFound == 0) then
				BlockTime = CurrTime + 1000 -- time-out
				BlockFound = 1
			elseif BlockFound == 1 then
				if CurrTime > BlockTime then
					BlockedPathToEnemyID = MyEnemy
					FollowOwner("[CHASE_ST -> FOLLOW_ST] Path to target seems blocked, searching for another target")
					return
				elseif CurrTime > BlockTime - 600 then
					Attack(MyID, MyEnemy) -- it could be a bug position
				end
			end
		else
			BlockFound = 0
			BlockCount = 0
		end

		-- Move to target
		vHomunX = MyX; vHomunY = MyY
		MyDestX = Ex; MyDestY = Ey
		Move(MyID, MyDestX, MyDestY)
	end
end

--------------------------------------------------
function OnATTACK_ST()
--------------------------------------------------
	-- Log("OnATTACK_ST")

	if isToFollowAtOnce() then return
	end

	if MyEnemy == 0 then
		StopHere("[ATTACK_ST -> IDLE_ST] no enemy to attack")
		return
	end

	-- Get current status information
	local HomunHP		= GetV(V_HP, MyID)
	local HomunMaxHP	= GetV(V_MAXHP, MyID)
	local HomunHPPerc = (HomunHP / HomunMaxHP) * 100
	local EnemyTarget = GetV(V_TARGET, MyEnemy)

   local CurrTime = GetTick()

	-- Heal the homunculus with AAP, if he/she is in danger
	CanDoAAANow = true
	if HomunHPPerc <= AAP.HP_Perc then
		if (AAP.Mode == 2) or (AAP.Mode == 3) or (AAP.Mode == 4) then
			DoSkill_AAP(HomunHP)
			HomunHPPerc = (HomunHP / HomunMaxHP) * 100
			CanDoAAANow = false
		end
	end

	-- Survival Instinct
	if ((EnemyTarget == MyID) and (HomunHPPerc < HP_PERC_DANGER))
	or (HTact.Behav == BEHA_avoid)
	then
		MyState = EVADE_ST
		Evade_ComeBackTime = EVADE_COMEBACK
		Log("[ATTACK_ST -> EVADE_ST] HP < HP_PERC_DANGER or beha=avoid")
		return
	end

	-- Make sure no other monsters are attacking the owner
	if HELP_OWNER_1ST == true then
		local NewTarget = 0
		NewTarget = GetEnemyOf(OwnerID)
		if NewTarget == MyEnemy then
			NewTarget = 0
		end
		if (NewTarget ~= 0) and (NewTarget ~= MyEnemy) then -- if a threat has been detected
			MyEnemy = NewTarget -- change target
			AtkSkillDoneCount = 0
			AtkStartTime = GetTick() -- a new attack starts (usually this reset is in ON_IDLE_ST)
			HTact = GetFullTact(GetV(V_HOMUNTYPE, NewTarget))
			local Ex, Ey = GetV(V_POSITION, MyEnemy)
			if (math.abs(Ex - MyX) > 1) or (math.abs(Ey - MyY) > 1) then
				Log("[ATTACK_ST -> CHASE_ST] Switch target -> my owner enemy")
				MyState = CHASE_ST
				if LONG_RANGE_SHOOTER ~= true then
					MyDestX, MyDestY = GetV(V_POSITION, MyEnemy)
					Move(MyID, MyDestX, MyDestY)
				end
				Attack(MyID, MyEnemy)
			else
				Log("Switch target -> my owner enemy (already in close combat position)")
				DoCombat()
			end
			vOwnerX, vOwnerY = OwnerX, OwnerY
			return
		end
	end

	-- Change target when the enemy is dead or lost
	local Ex, Ey = GetV(V_POSITION, MyEnemy)
	if (Ex == -1) or (MOTION_DEAD == GetV(V_MOTION, MyEnemy)) then
		Log(string.format("MyEnemy(%d) lost or dead. Searching for next target", MyEnemy))
		local NextTarget = GetMyNextTarget(HomunHPPerc)
		if NextTarget ~=0 then
			MyEnemy = NextTarget
			AtkSkillDoneCount = 0
			AtkStartTime = GetTick() -- a new attack starts (usually this reset is in ON_IDLE_ST)
		else
			if MyState ~= EVADE_ST then
				StopHere("[ATTACK_ST -> IDLE_ST] No more immediate targets")
			end
			return
		end
	end

	-- Intercept the enemy when he/she moves
	if LONG_RANGE_SHOOTER ~= true then
		if (math.abs(Ex - MyX) > 1) or (math.abs(Ey - MyY) > 1) then
			Log(string.format("[ATTACK_ST -> CHASE_ST] Enemy(%d) moved to (%d, %d), while I was at (%d, %d)", MyEnemy, Ex, Ey, MyX, MyY))
			MyState = CHASE_ST
			MyDestX = Ex; MyDestY = Ey
			Move(MyID, MyDestX, MyDestY)
			Attack(MyID, MyEnemy)
			return
		end
	end

	DoCombat()

	-- bug position check
	if (CurrTime - AtkStartTime > 20000) -- after 20"
	and (GetV(V_MOTION, MyID) == MOTION_STAND) -- this don't seem actually to work [...]
	then
		if BugPosiTime == 0 then
			BugPosiTime = CurrTime
			Log("Bug position check has been started")
		end
		-- Log(string.format("Bug position check: my motion = %d", GetV(V_MOTION, MyID)))
		if CurrTime - BugPosiTime > 1000 then
			MyState = BUGPOSI_ST
			AtkStartTime = GetTick()
			AtkSkillDoneCount = 0
			Log("[ATTACK_ST -> BUGPOSI_ST] I'm doing no attack movement (Move=%d): starting anti bug position motion")
			return
		end
	else
		BugPosiTime = 0
	end

	return
end

--------------------------------------------------
function OnEVADE_ST()
--------------------------------------------------
	Log ("OnEVADE_ST")

	-------- evasion-end conditions ---------------

	-- 1: if the enemy changes target
	local EnemyTarget = GetV(V_TARGET, MyEnemy)
	if (EnemyTarget ~= MyID) then
		StopHere("[EVADE_ST -> IDLE] Enemy no longer aims at me")
		return
	end

	-- 2: if the enemy is out of sight
	if (true == IsOutOfSight(MyID, MyEnemy)) then
		StopHere("[EVADE_ST -> IDLE] Enemy out of sight")
		return
	end

	-- 3: if the enemy is dead
	if (MOTION_DEAD == GetV(V_MOTION, MyEnemy)) then
		StopHere("[EVADE_ST -> IDLE] Enemy dead")
		return
	end

	-- 4: if HP are OK now
	local HomunHP = GetV(V_HP, MyID)
	local HomunMaxHP = GetV(V_MAXHP, MyID)
	local HomunHPPerc = (HomunHP / HomunMaxHP) * 100
	if (HomunHPPerc > HP_PERC_DANGER) then
		if (HTact.Behav ~= BEHA_avoid) and (HTact.Behav ~= BEHA_coward) then
			MyState = ATTACK_ST
			AtkStartTime = 0
			AtkSkillDoneCount = 0
			vOwnerX, vOwnerY = OwnerX, OwnerY
		 	Log("[EVADE_ST -> ATTACK] HPs are ok now")
		  	return
		end
	end

	------- Evading skills ------------------------
	local HomunSP = GetV(V_SP, MyID)

	if(HomunType == AMISTR	or HomunType == AMISTR_H
	or HomunType == AMISTR2 or HomunType == AMISTR_H2
	or (HomunS == true and OldHomunType == AMISTR)) then
		DoSkill(AS_AMI_BULW, MyID) -- Amistr: Bulwark
	elseif(HomunType == LIF  or HomunType == LIF_H
	or 	 HomunType == LIF2 or HomunType == LIF_H2
	or (HomunS == true and OldHomunType == LIF)) then
		DoSkill(AS_LIF_ESCP, MyID) -- Lif: Urgent Escape
	elseif(HomunType == VANILMIRTH  or HomunType == VANILMIRTH_H
	or 	 HomunType == VANILMIRTH2 or HomunType == VANILMIRTH_H2
	or (HomunS == true and OldHomunType == VANILMIRTH)) then
		DoSkill(AS_VAN_CAPR, MyEnemy) -- Vani: Caprice (long range)
		-- if GetV(V_HP, OwnerID) <= AAA_MinHP then
		-- 	DoSkill(AS_VAN_BLES, OwnerID) -- [...] it seems disabled for AIs
		-- end
	end
	CanDoAAANow = true
	if (HomunHPPerc <= AAP.HP_Perc) then
		if (AAP.Mode == 1) or (AAP.Mode == 3) or (AAP.Mode == 4) then
			CanDoAAANow = false
			if GetTick() > AAA_TimeOut then
				DoSkill_AAP(HomunHP)
				HomunHPPerc = (HomunHP / HomunMaxHP) * 100
			end
		end
	end

	------- Evading maneuvres ---------------------
	CircleAroundTarget(OwnerID)
	CheckForAutoAtk()
	return
end

--------------------------------------------------
function OnBUGPOSI_ST()
--------------------------------------------------
	local HomunHP		= GetV(V_HP, MyID)
	local HomunMaxHP	= GetV(V_MAXHP, MyID)
	local HomunHPPerc = (HomunHP / HomunMaxHP) * 100
   local CurrTime = GetTick()

	-- Heal the homunculus with AAP, if he/she is in danger
	CanDoAAANow = true
	if HomunHPPerc <= AAP.HP_Perc then
		DoSkill_AAP(HomunHP)
		HomunHPPerc = (HomunHP / HomunMaxHP) * 100
		CanDoAAANow = false
	end

	local CurrTime = GetTick()
	MoveToOwner(MyID)
	if (CurrTime - AtkStartTime > 1500) or (GetDistance2(OwnerID, MyID) <= 1) then
		StopHere("[BUGPOSI_ST -> IDLE_ST] Bugposi movement is over")
	end
end

--------------------------------------------------
-- ############ OUTPUT MOVEMENTS ##########
--------------------------------------------------

--------------------------------------------------
function OnOUTMOVE_NEWFRIEND_ST()
--------------------------------------------------
	local CurrTime = GetTick() - OutMoveTime
	if CurrTime > 3000 then
		FollowOwner("[ -> FOLLOW_ST] Output movement done")
		return
	else
		local OutMoveX, OutMoveY = GetV(V_POSITION, OutMoveTarget)
		local angle = math.rad(math.mod(CurrTime/4, 360))
		local X = OutMoveX + math.cos(angle) * 3
		local Y = OutMoveY + math.sin(angle) * 3
		Move(MyID, X, Y)
		MyDestX = X
		MyDestY = Y
	end
end

--------------------------------------------------
function OnOUTMOVE_DELFRIEND_ST()
--------------------------------------------------
	local CurrTime = GetTick() - OutMoveTime
	if CurrTime > 3000 then
		FollowOwner("[ -> FOLLOW_ST] Output movement done")
		return
	else
		local OutMoveX, OutMoveY = GetV(V_POSITION, OutMoveTarget)
		local angle = math.rad(math.mod(CurrTime/4, 360))
		local X = OutMoveX + math.cos(angle) * 3
		local Y = OutMoveY
		Move(MyID, X, Y)
		MyDestX = X
		MyDestY = Y
	end
end

--------------------------------------------------
-- ############# COMMAND STATUS ###########
--------------------------------------------------

--------------------------------------------------
function OnMOVE_CMD_ST()
--------------------------------------------------
	Log("OnMOVE_CMD_ST")

	if (MyX == MyDestX and MyY == MyDestY) then
		StopHere("destination reached")
	else
		Move(MyID, MyDestX, MyDestY)
	end
end

--------------------------------------------------
function OnSTOP_CMD_ST()
--------------------------------------------------
end

--------------------------------------------------
function OnATTACK_OBJECT_CMD_ST()
--------------------------------------------------
end

--------------------------------------------------
function OnATTACK_AREA_CMD_ST()
--------------------------------------------------
	Log ("OnATTACK_AREA_CMD_ST")

	local	object = GetEnemyOf(OwnerID)
	if (object == 0) then
		object = GetMyEnemy_AnyNoKS(MyID)
	end

	if (object ~= 0) then -- MYOWNER_ATTACKED_IN or ATTACKED_IN
		MyState = CHASE_ST
		MyEnemy = object
		vOwnerX, vOwnerY = OwnerX, OwnerY
		return
	end

	if (MyX == MyDestX and MyY == MyDestY) then -- DESTARRIVED_IN
		MyState = IDLE_ST
		IdleStartTime = GetTick()
		MyEnemy = 0
	end

end

--------------------------------------------------
function OnPATROL_CMD_ST()
--------------------------------------------------
	Log("OnPATROL_CMD_ST")

	local	object = GetEnemyOf(OwnerID)
	if (object == 0) then
		object = GetMyEnemy_AnyNoKS(MyID)
	end

	if (object ~= 0) then -- MYOWNER_ATTACKED_IN or ATTACKED_IN
		MyState = CHASE_ST
		MyEnemy = object
		vOwnerX, vOwnerY = OwnerX, OwnerY
		Log("[PATROL_CMD_ST -> CHASE_ST] ATTACKED_IN")
		return
	end

	if (MyX == MyDestX and MyY == MyDestY) then -- DESTARRIVED_IN
		MyDestX = MyPatrolX
		MyDestY = MyPatrolY
		MyPatrolX = x
		MyPatrolY = y
	end
   Move(MyID,MyDestX,MyDestY)

end

--------------------------------------------------
function OnHOLD_CMD_ST ()
--------------------------------------------------
	Log("OnHOLD_CMD_ST")

	if (MyEnemy ~= 0) then
		local d = GetDistance(MyEnemy,MyID)
		if (d ~= -1 and d <= GetV(V_ATTACKRANGE,MyID)) then
			Attack (MyID,MyEnemy)
		else
			MyEnemy = 0
		end
		return
	end

	local	object = GetEnemyOf(OwnerID)
	if (object == 0) then
		object = GetMyEnemy_AnyNoKS(MyID)
		if (object == 0) then
			return
		end
	end

	MyEnemy = object

end

--------------------------------------------------
function OnSKILL_OBJECT_CMD_ST()
--------------------------------------------------
end

--------------------------------------------------
function OnSKILL_AREA_CMD_ST()
--------------------------------------------------
	Log("OnSKILL_AREA_CMD_ST")

	if (GetDistance(MyX, MyY, MyDestX, MyDestY) <= GetV(V_SKILLATTACKRANGE, MyID, MySkill)) then -- DESTARRIVED_IN
		SkillGround (MyID, MySkillLevel, MySkill, MyDestX, MyDestY)
		MyState = IDLE_ST
		IdleStartTime = GetTick()
		MySkill = 0
	end

end

--------------------------------------------------
function OnFOLLOW_CMD_ST ()
--------------------------------------------------
	Log("OnFOLLOW_CMD_ST")

	OwnerMotion = GetV(V_MOTION, OwnerID)
	if not isCloseToOwner()	and (OwnerMotion ~= MOTION_STAND) and (OwnerMotion ~= MOTION_SIT)
	then
		--local angle = math.rad(math.mod(GetTick()/8, 360))
		MyDestX = OwnerX + 1--math.cos(angle)
		MyDestY = OwnerY --+ math.sin(angle)
		Move(MyID, MyDestX, MyDestY)
	end

end

--------------------------------------------------
-- ############# MORE FUNCTIONS ###########
--------------------------------------------------

--------------------------------------------------
function GetMyNextTarget(HomunHPPerc)
--------------------------------------------------
	local object = 0

	-- 1: SAFETY FIRSTY! Is the homunculus is under attack?
	local Agressor = GetMyEnemy_AttackingMe(MyID) -- get TactData too
	local AgBehav, AgSkill, AgLevel, AgAlche
	if Agressor ~= 0 then
		if (HomunHPPerc < HP_PERC_DANGER) or (HTact.Behav == BEHA_avoid) or (HTact.Behav == BEHA_coward) then
			MyState = EVADE_ST -- flee away if HP < secure level
			MyEnemy = Agressor
			Evade_ComeBackTime = EVADE_COMEBACK
			Log(string.format("[ -> EVADE_ST] GetMyNextTarget() attacked by enemy(%d) (avoid/coward mode or while HP < HP_PERC_DANGER)", MyEnemy))
			return 0
		else -- we are not in danger for now: save these data and let's check for other threats first
         AgBehav = HTact.Behav
         AgSkill = HTact.Skill
         AgLevel = HTact.Level
         AgAlche = HTact.Alche
         if KILL_YOUR_ENEMIES_1ST == true then -- ... unless KILL_YOUR_ENEMIES_1ST is enabled
				Log(string.format("GetMyNextTarget() <defensive scan + KILL_YOUR_ENEMIES_1ST> attacked by enemy(%d)", Agressor))
		      HTact.Behav = AgBehav
		      HTact.Skill = AgSkill
		      HTact.Level = AgLevel
		      HTact.Alche = AgAlche
				return Agressor
			end
		end
	end

	-- 2: if the owner or a friend is under attack, help him/her
	object = GetEnemyOf(OwnerID)
	if object ~= 0 then
		if GetV(V_MOTION, object) == MOTION_DEAD then
			object = 0
		end
	end
	if object == 0 then
		for i,v in pairs(Friends) do
			object = GetEnemyOf(v)
			if GetV(V_MOTION, object) == MOTION_DEAD then
				object = 0
			end
			if object ~= 0 then
				break
			end
		end
	end
	if object ~= 0 then
		Log(string.format("GetMyNextTarget() the owner or a friend is attacked by enemy(%d):", object))
		HTact = GetFullTact(GetV(V_HOMUNTYPE, object))
		if (HTact.Behav ~= BEHA_avoid) then
			return object
		end
	end

	-- 3: if the homunculus is under attack (and his/her life is not in danger, see priority 1)
	if Agressor ~= 0 then
		Log(string.format("GetMyNextTarget() <defensive scan> attacked by enemy(%d)", Agressor))
		HTact.Behav = AgBehav
		HTact.Skill = AgSkill
  		HTact.Level = AgLevel
    		HTact.Alche = AgAlche
		return Agressor
	end

	-- 4: if the owner or a friend is attacking --> cooperate
	local OwnerMotion = GetV(V_MOTION, OwnerID)
	local CooTarget = 0
	object = GetV(V_TARGET, OwnerID)
	if (object ~= 0) and (OwnerMotion == MOTION_ATTACK or OwnerMotion == MOTION_ATTACK2) then
	   CooTarget = object
	end
	if CooTarget == 0 then -- Owner is not attacking. Maybe a friend?
		local FriendMotion = 0
		for i,v in pairs(Friends) do
			object = GetV(V_TARGET, v)
			FriendMotion = GetV(V_MOTION, v)
			if (object ~= 0) and (FriendMotion == MOTION_ATTACK or FriendMotion == MOTION_ATTACK2) then
				CooTarget = object
				break
			end
		end
	end
	if CooTarget ~= 0 then
		Log(string.format("GetMyNextTarget() cooperative target(%d) found:", CooTarget))
		HTact = GetFullTact(GetV(V_HOMUNTYPE, CooTarget))
		if (HTact.Behav ~= BEHA_avoid) then
			return CooTarget
		end
	end

	-- 5: aggressive, if HPs are OK and a target is near
	if HomunHPPerc > HP_PERC_SAFE2ATK
	then
		object = GetMyEnemy_AnyNoKS(MyID) -- get TactData too
		if (object ~= 0) then
			Log(string.format("GetMyNextTarget() <aggressive scan> target(%d) found", object))
			return object
		end
	end

	return 0
end

--------------------------------------------------
function isToFollowAtOnce()
-- used in OnCHASE_ST() and in OnATTACK_ST()
--------------------------------------------------
	if GetV(V_MOTION, OwnerID) == MOTION_MOVE then
		if FOLLOW_AT_ONCE > 0 then
			local MyEnX, MyEnY = GetV(V_POSITION, MyEnemy)
			local ExtraDst = 0
			if GetDistance(OwnerX, OwnerY, MyX, MyY) < 4 then ExtraDst = 1 end
			if GetDistance(OwnerX, OwnerY, MyEnX, MyEnY) > GetDistance(vOwnerX,vOwnerY, MyEnX, MyEnY) + ExtraDst then
				FollowOwner("[ -> FOLLOW_ST] Owner is moving away")
				return true
			end
		else -- don't follow at once, keep the homunculus in range
			if GetDistance(OwnerX, OwnerY, MyX, MyY) > TOO_FAR_TARGET - 3 then
				FollowOwner("[ -> FOLLOW_ST] Owner is moving away")
				return true
			end
		end
		vOwnerX = OwnerX; vOwnerY = OwnerY
	end
	return false
end

--------------------------------------------------
function isMobMotionOK(MobID, PlayerList)
-- before to engage in combat with this monster (that seems free because he/she targets nobody and nobody seems to target
-- her/him) check his/her motion. N.B.: the "Get" functions provided by Gravity are very limited, so we can do little for
-- this and the homunculus in many cases can only try to guess what is happening. I hope Gravity will improve/extend them
--------------------------------------------------
	if 0 == IsMonster(MobID) then return true; end; -- for PvP mods

	local CurrTime = GetTick()
	local mob_motion = GetV(V_MOTION, MobID)
	local mob_type = GetV(V_HOMUNTYPE, MobID)

--MOTION_MOVE: is he/she following another player?
	if mob_motion == MOTION_MOVE then
		if NO_MOVING_TARGETS == true then
			isCircling = false
			Log("---mob is moving")
			return false -- This option is good also to wait until the monsters come close to you
		else
			return true -- [...] (to do: find a way to determine if the moster is following someone in order to make the AI
			-- more kind and friendly) N.B.: tecnically it's not KS to intercept a monster before someone else (the combat
			-- is not yet started and who "mob" just make longer this phase), but it looks quite unfriendly to many players.
		end
--MOTION_STAND: is he/she trapped or frozen?
	elseif mob_motion == MOTION_STAND then
		if ADV_MOTION_CHECK == true then
			-- this is optional, because it's not reliable and gives false positives
			if NoAggroMob[mob_type] == nil then -- is this an immobile or passive monster?
				Log("---mob trapped")
				return false -- mobile/aggro mob = trapped, frozen or obstacled (exceptions: [...] temporary passive mode, archers)
			else
				return true -- immobile/passive mob. [...] (to do: find a way to chek if it's trapped) that's tricky: passive
				-- monsters stands at regular intervals and immobile mobs stands all the time, but even them could get trapped
				-- (e.g. Clocks) or frozen (e.g. Zenorks); also archers are usually immobile. Maybe we could check the distance from
				-- other players, but for example Zenork are looters and so distance has not great meaning.
			end
		else
			return true
		end
-- MOTION_HIT: who hit him/her?
	elseif mob_motion == MOTION_HIT and MyState ~= ATTACK_ST then
		if ADV_MOTION_CHECK == true then
			-- this is optional, because it's not reliable and gives false positives
			if (CurrTime - LastLRAtkTime < 2000) and (LastLRAtkID == MobID) then
				return true -- happened shortly after our long ranged attack at this monster: it's our hit. But [...] it could
				-- happen that someone hits our target in the meantime.
			else
				Log("---mob hit by area atk")
				return false -- it seems an hit from another player, maybe an area attack
			end
		else
			return true
		end
-- MOTION_DEAD
	elseif mob_motion == MOTION_DEAD then
		Log("---mob dead")
		return false
	end

-- MOTION_ATTACK, MOTION_ATTACK2, MOTION_SKILL, MOTION_CAST should require some targetings (unless they are area attacks) and so detected before
-- MOTION_PICKUP and MOTION_SIT shouldn't be in monsters

	return true
end

--------------------------------------------------
function isKS()
-- used in OnCHASE_ST()
--------------------------------------------------
	if 0 == IsMonster(MyEnemy) then return false; end -- for PvP mods

	-- look at monster target
	local mob_target = GetV(V_TARGET, MyEnemy)
	if mob_target > 0 then
		if not IsMonster2(mob_target) then
			if (mob_target == MyID) or (mob_target == OwnerID) or (Friends[mob_target] ~= nil) then
				return false
			else
				Log("MyEnemy was already in battle, action aborted (anti-KS)")
				return true
			end
		end
	end

	-- look at (not friend) player targets
	local actors = GetActors()
	for i,v in ipairs(actors) do
		if (v ~= OwnerID) and (v ~= MyID) then
			if 0 == IsMonster(v) then -- if it is a player
				if isNotFriend(v) then -- and not a friend
					if GetV(V_TARGET, v) == MyEnemy then
						Log("Another player is aiming at MyEnemy, action aborted (anti-KS)")
						return true
					end
				end
			end
		end
	end

	return false
end

--------------------------------------------------
function StopHere(s)
--------------------------------------------------
	MyState = IDLE_ST
	MyEnemy = 0
	MySkill = 0
	IdleStartTime = GetTick()
	if LONG_RANGE_SHOOTER ~= true and not (MyDestX == OwnerX + 1 and MyDestY == OwnerY) then
		MyDestX, MyDestY = MyX, MyY
		Move(MyID, MyDestX, MyDestY) -- stop at once
	else
		MyDestX, MyDestY = MyX, MyY
	end
	Log("#STOP#" .. s)
end

--------------------------------------------------
function FollowOwner(s)
--------------------------------------------------
	MyState = FOLLOW_ST
	MyEnemy = 0
	MySkill = 0
	BlockFound = 0
	MyDestX, MyDestY = OwnerX, OwnerY
	MoveToOwner(MyID)
	Log(s)
end

--------------------------------------------------
function DoCombat()
--------------------------------------------------
	if (AtkStartTime == 0) then
		AtkStartTime = GetTick()
	end
	if (MySkill == 0) then
		Attack(MyID, MyEnemy)

		local EnemyType = GetV(V_HOMUNTYPE, MyEnemy)
		if (EnemyType < 1078 or EnemyType > 1085) then -- don't waste SP on plants and mushrooms

			-- Amistr ----------------------------------
			if(HomunType == AMISTR	or HomunType == AMISTR_H
			or HomunType == AMISTR2 or HomunType == AMISTR_H2
			or (HomunS == true and OldHomunType == AMISTR)) then
			--------------------------------------------

				DoSkill(AS_AMI_BULW, MyID)

			-- Lif -------------------------------------
			elseif(HomunType == LIF  or HomunType == LIF_H
			or     HomunType == LIF2 or HomunType == LIF_H2
			or (HomunS == true and OldHomunType == LIF)) then
			--------------------------------------------

				-- Heal the Owner, when him/her HPs are low (<= AAP.HP_Perc)
				if ((GetV(V_HP, OwnerID) / GetV(V_MAXHP, OwnerID)) * 100 <= AAP.HP_Perc) then
					DoSkill(AS_LIF_HEAL, OwnerID) -- Lif: Healing Touch
				end

				DoSkill(AS_LIF_ESCP, MyID)

			-- Filir -----------------------------------
			elseif (HomunType == FILIR  or HomunType == FILIR_H
			or      HomunType == FILIR2 or HomunType == FILIR_H2
			or (HomunS == true and OldHomunType == FILIR)) then
			--------------------------------------------

				DoSkill(AS_FIL_FLTT, MyID)
				DoSkill(AS_FIL_ACCL, MyID) -- this seems buggy on RO

				if CanDoAtkSkillsNow() then -- Moonlight ##### AGGRESSIVE SKILL #####
					if DoSkill(AS_FIL_MOON, MyEnemy) then
						AtkSkillDoneCount = AtkSkillDoneCount + 1
					end
				end

			-- Vanilmirth ------------------------------
			elseif(HomunType == VANILMIRTH  or HomunType == VANILMIRTH_H
			or     HomunType == VANILMIRTH2 or HomunType == VANILMIRTH_H2
			or (HomunS == true and OldHomunType == VANILMIRTH)) then
			--------------------------------------------

				-- if ((GetV(V_HP, OwnerID) / GetV(V_MAXHP, OwnerID)) * 100 <= AAP.HP_Perc) then
				-- 	DoSkill(AS_VAN_BLES, OwnerID) -- [...] it seems disabled for AIs
				-- end

				if CanDoAtkSkillsNow() then -- Caprice -- ##### AGGRESSIVE SKILL #####
					if DoSkill(AS_VAN_CAPR, MyEnemy) then
						AtkSkillDoneCount = AtkSkillDoneCount + 1
					end
				end

			end

		end

	end
	if (MySkill ~= 0) then
		SkillObject(MyID, MySkillLevel, MySkill, MyEnemy)
		MySkill = 0
	end

	CheckForAutoAtk()
end

--------------------------------------------------
function CheckForAutoAtk()
--------------------------------------------------
	-- Alchemist auto attacks ---------------------
	-- Cart Revolution will be engaged if there are 2 or more enemy close to the owner
	local NOE = CountEnemiesCloseToOwner() -- Near Owner Enemies
	-- Log(string.format("Enemies close to owner: %d", NOE))
	-- if (GetTick() - AtkStartTime > 500) then
		if NOE > 0 then
			if (ACR.MinEnemies > 0 and NOE >= ACR.MinEnemies) then
				DoSkill_AutoAttack(ACR.SkillID)
			else
				if (AST.SkillID > 0) and (HTact.Alche >= 0) then DoSkill_AutoAttack(AST.SkillID) end
			end
		else
			if (GetDistance2(MyEnemy, OwnerID) <= 9) and (AST.SkillID > 5) and (HTact.Alche >= 0) then
				DoSkill_AutoAttack(AST.SkillID) -- long range attack
			end
		end
	-- end
end

--------------------------------------------------
function CanDoAtkSkillsNow()
-- is it the right time for an aggressive skill?
--------------------------------------------------
	local result = true
	local CurrTime = GetTick()
	local TimeOutElapsed = CurrTime - AtkStartTime > SKILL_TIME_OUT
	if (HTact.Skill == WITH_no_skill) then
		result = false
	elseif HTact.Skill == WITH_one_skill then
		-- Log(string.format("AtkSkillDoneCount = %d, CurrTime - AtkStartTime = %d", AtkSkillDoneCount, CurrTime - AtkStartTime))
		if (AtkSkillDoneCount > 1) or  TimeOutElapsed then
			result = false
		end
	elseif HTact.Skill == WITH_two_skills then
		if (AtkSkillDoneCount > 2) then
			result = false
		end
	elseif HTact.Skill == WITH_max_skills then
		if TimeOutElapsed then
			result = false
		end
	elseif HTact.Skill == WITH_slow_power then
		if (LONG_RANGE_SHOOTER ~= true) and (CurrTime - AtkStartTime < DELAY_SLOW_POWER) then
			result = false
		end
	end
	return result
end

--------------------------------------------------
function DoSkill(Skill, Target)
--------------------------------------------------
	if Skill.Level == 0 then return false; end
	local CurrTime = GetTick()
	if CastDelayEnd > CurrTime then return false; end
	local HomunSP = GetV(V_SP, MyID)
	local result = false
	if Skill.Engaged then -- if the skill is already active (or in delay time), wait until it goes OFF
		if CurrTime > Skill.TimeOut then
			Skill.Engaged = false
		end
	else -- if the skill is OFF, activate it
		if HomunSP >= Skill.MinSP then -- if there are enough SP left
			MySkill = Skill.SkillID
			if ( (MySkill == AS_FIL_MOON.SkillID) or (MySkill == AS_VAN_CAPR.SkillID) )
			and (HTact.Level ~=-1) then
				MySkillLevel = HTact.Level
			--[[
			-- [...] Chaotic Blessing seems disabled for AIs
			elseif (MySkill == AS_VAN_BLES.SkillID) then
				if     Target == OwnerID then
					MySkillLevel = 3 -- lvl 3 heal rate: enemy=25%, self=25%, owner=50%
				elseif Target == MyID then
					MySkillLevel = 4 -- lvl 4 heal rate: enemy=36%, self=60%, owner=4%
				else
					MySkillLevel = Skill.Level
				end
			--]]
			else
				MySkillLevel = Skill.Level
			end
			Skill.TimeOut = CurrTime + Skill.HowLast
			Skill.Engaged = true
			SkillObject(MyID, MySkillLevel, MySkill, Target)
			Log(string.format("Done skill %d lvl %d on target %d", MySkill, MySkillLevel, Target))
			CastDelayEnd = CurrTime + 1000
			result = true
			MySkill = 0
		end
	end
	return result
end

--------------------------------------------------
function DoSkill_AAP(CurrHPVar)
--------------------------------------------------
	if GetDistance2(MyID, OwnerID) > 9 then
		return
	end

	local CurrTime = GetTick()

	-- wait until AAP delay ends
	if AAA_Engaged then -- if an AAA skill was just casted, wait for a little
		if (GetTick() > AAA_TimeOut) then
			AAA_Engaged = false
		end

	else -- it's the right time to cast AAP

		-- make sure that it is not the first AAP since initialization
		-- and that not too much time is passed since last AAP
		if (AAP.OldHP > 0) and (CurrTime < AAA_TimeOut + 500) then

			if CAN_DETECT_NOPOT == true then

				-- if HPs are still the same or less, we assume it was a failure
				if CurrHPVar <= AAP.OldHP then
   	         --[[
					-- maybe there were too many enemies and AAP was just unsufficient:
					-- so whe count how many enemies are hitting the homunculus
					-- [...] easy monsters can do 1 dmg: it's hard to figure it out
					local actors = GetActors()
					local aggr = 0
					for i,v in ipairs(actors) do
						if GetV(V_MOTION, v) ~= MOTION_DEAD then
							if (v ~= OwnerID) and (v ~= MyID) then
								if GetV(V_TARGET, v) == MyID then
									aggr = aggr + 1
								end
							end
						end
					end
					--]]
					AAP.Failures = AAP.Failures + 1
					Log(string.format("AAP: failure #%d detected", AAP.Failures))
					if AAP.Failures >= AAP.MaxAttempts then
						AAP.Mode = 0
						Log("AAP: out of potion detected. AAP disabled")
					end

				-- if HPs have been increased, it was a success (unless it was natural regen [...])
				elseif CurrHPVar > AAP.OldHP + AAP.MinInc then
					AAP.Failures = 0
					Log("AAP: HP increased, it seems it worked")
				else
					Log("AAP: HP increased, but it could be nat. regen.")
				end

			end

		else
			AAP.Failures = 0
			Log("AAP: first time or too much time elapsed to compare HPs")
		end

		if AAP.Mode > 0 then
			AAP.OldHP = CurrHPVar
			MySkill = AAP.SkillID
			MySkillLevel = AAP.Level
			AAA_TimeOut = CurrTime + AAP.HowLast
			AAA_Engaged = true
			SkillObject(MyID, MySkillLevel, MySkill, MyID)
			MySkill = 0
			Log("AAP: SkillObject() called")
		end
	end

end

--------------------------------------------------
function DoSkill_AutoAttack(SkillID)
--------------------------------------------------
	local OwnerSP = GetV(V_SP, OwnerID)
	local OwnerHP = GetV(V_HP, OwnerID)
	local result = false -- it returns true if SkillObject has been called

	if AAA_Engaged then -- if an AAA skill was just casted, wait for a little
		if (GetTick() > AAA_TimeOut) then
			AAA_Engaged = false
		end
	else -- else it is the time to cast it
		if (OwnerHP > AAA_MinHP) and (OwnerHP < AAA_MaxHP) then
			if ( (SkillID ~= ACR.SkillID) and (OwnerSP >= AST.MinSP) )
			or ( (SkillID == ACR.SkillID) and (OwnerSP >= ACR.MinSP) )
			then

				local EnemyType = GetV(V_HOMUNTYPE, MyEnemy)
				if (CanDoAAANow == true) and (EnemyType < 1078 or EnemyType > 1085) then -- don't waste SP on plants and mushrooms

					local ExtraDelay = 0
					if SkillID == ACR.SkillID then -- it not Cart Revo.
						MySkillLevel = 1
					else
						if HTact.Alche == 0 then
							MySkillLevel = AST.Level
						else
							MySkillLevel = HTact.Alche
						end
						if (SkillID == WBS_FIRE) or (SkillID == WBS_ICE) then
							ExtraDelay = ExtraDelay + DELAY_AAA_BOLT -- add more delay for fire/ice bolts (they have some cast time)
						end
					end

					AAA_TimeOut = GetTick() + DELAY_AAA + ExtraDelay
					AAA_Engaged = true

					MySkill = SkillID
					SkillObject(MyID, MySkillLevel, MySkill, MyEnemy)
					result = true
					Log(string.format("Done autoattack skill %d on enemy %d, type %d", SkillID, MyEnemy, EnemyType))
					MySkill = 0
				end

			end
		end
	end
	return result
end

--------------------------------------------------
function CircleAroundTarget(TrgID)
--------------------------------------------------
	Log("### CIRCLE START ###")
	-- Log(string.format("Step move=%d, Evade_ComeBackTime=%d, CircleBlockStep=%d", CircleDir, Evade_ComeBackTime, CircleBlockStep))

	local TrgX, TrgY		= GetV(V_POSITION, TrgID)

	--------------- current destination -----------
	if (Evade_ComeBackTime == EVADE_COMEBACK) or (CircleBlockStep == 2) then
		local angle = math.rad(math.mod(GetTick()/8, 360))
		MyDestX = OwnerX + math.cos(angle)
		MyDestY = OwnerY + math.sin(angle)
	else
		MyDestX = TrgX + AAI_CIRC_X[CircleDir] -- direction defined by the circle step
		MyDestY = TrgY + AAI_CIRC_Y[CircleDir]
	end

	--------------- obstacle detection ------------
	if (math.abs(vHomunX - MyX) == 0)
	and(math.abs(vHomunY - MyY) == 0) then -- if there is no movement
		if (CircleBlockStep == 0) then
			CircleBlockTime = GetTick() + 700 -- time-out
			CircleBlockStep = 1
		elseif (CircleBlockStep == 1) then -- it is in wait mode until the time out expires
			if (GetTick () > CircleBlockTime) then -- if it expires
				CircleBlockStep = 2 -- we assume that an obstacle was found in the current direction
			end
		end
	else
		CircleBlockStep = 0
	end

	--------------- position reached? -------------
	if  (math.abs(MyDestX - MyX) < 1)
	and (math.abs(MyDestY - MyY) < 1) -- yes!
	then									  -- select next direction
		if (MyState == EVADE_ST) then
			if CircleBlockStep == 2 then
				CircleDir = CircleDir + 1
				Evade_ComeBackTime = 0
			else
				if (Evade_ComeBackTime == EVADE_COMEBACK) then
					if (GetDistance2(MyEnemy, OwnerID) <=1) then
						CircleDir = CircleDir + 2 -- the monster shoud reach the owner, so he/she can help
						Evade_ComeBackTime = 0
					end
				else
					CircleDir = CircleDir + 2
					Evade_ComeBackTime = Evade_ComeBackTime + 1
				end
			end
		else
			CircleDir = CircleDir + 1
			Evade_ComeBackTime = 0
		end
		if (CircleDir > AAI_CIRC_MAXSTEP) then
			CircleDir = 1
		end
	end

	----- record curren position and move on ------
	vHomunX = MyX
	vHomunY = MyY
	Move(MyID, MyDestX, MyDestY)
	Log("=== CIRCLE END ===")
	return
end

--------------------------------------------------
function GetEnemyOf(id) -- this function is not for PvP Mods
--------------------------------------------------
	local result = 0
	local actors = GetActors()
	local enemies = {}
	local index = 1
	local target
	for i,v in ipairs(actors) do
		if (v ~= OwnerID and v ~= myid) then
			if (IsMonster(v) == 1) then
				if GetV(V_MOTION, v) ~= MOTION_DEAD then
					target = GetV(V_TARGET, v)
					if (target == id) then
						enemies[index] = v
						index = index + 1
					end
				end
			end
		end
	end

	local min_dis = 100
	local dis
	for i,v in ipairs(enemies) do
		dis = GetDistance2(MyID, v)
		if (dis < min_dis) then
			result = v
			min_dis = dis
		end
	end

	return result
end

--------------------------------------------------
function CountEnemiesCloseToOwner()
--------------------------------------------------
	local ecount = 0
	local actors = GetActors()
	for i,v in ipairs(actors) do
		if 1 == IsMonster(v) then
			if (GetDistance2(OwnerID, v) <= 1) and (MOTION_DEAD ~= GetV(V_MOTION, v)) then
				ecount = ecount + 1
			end
		end
	end
	return ecount
end

--------------------------------------------------
function GetMyEnemy_AttackingMe(myid)
--------------------------------------------------
	-- Log(string.format("---- DEFENSIVE SCAN STARTED for ID (%d)", myid))
	local result = 0
	local actors = GetActors()
	local enemy_1st = {} -- primary targets
	local index_1st = 1
	local enemy_std = {} -- normal targets
	local index_std = 1
	local enemy_lss = {} -- last targets
	local index_lss = 1
	local enemy_wkk = {} -- weak targets
	local index_wkk = 1
	local mob_type, mob_target, mobBehav, ListedType

	-- Fill a list of enemies who have me as target
	for i,v in ipairs(actors) do
		if GetV(V_MOTION, v) ~= MOTION_DEAD then
			if (v ~= OwnerID) and (v ~= MyID) then
				mob_target = GetV(V_TARGET, v)
				if mob_target == MyID then
					mob_type = GetV(V_HOMUNTYPE, v) -- get tact data
					mobBehav = GetTact(V_TACTBEHAV, mob_type)
					if    (mobBehav == BEHA_avoid)
					or    (mobBehav == BEHA_coward) then
						result = v
						break -- this monster is too dangerous: evade from him/her at once!
					elseif (mobBehav == BEHA_attack_1st) or (mobBehav == BEHA_react_1st) then
						enemy_1st[index_1st] = v
						index_1st = index_1st + 1
					elseif (mobBehav == BEHA_attack_last) or (mobBehav == BEHA_react_last) then
						enemy_lss[index_lss] = v
						index_lss = index_lss + 1
					elseif mobBehav == BEHA_attack_weak then
						enemy_wkk[index_wkk] = v
						index_wkk = index_wkk + 1
					else
						enemy_std[index_std] = v
						index_std = index_std + 1
					end
   			end
			end
		end
	end

	-- Search for the closest aggressor -----------
	if result == 0 then
		-- Log("No mob to avoid")
   	result = GetClosest(enemy_1st)
   end
	if result == 0 then
		-- Log("No primary target in range")
		result = GetClosest(enemy_std)
	end
	if result == 0 then
		-- Log("No standard target in range")
		result = GetClosest(enemy_lss)
	end
	if result == 0 then
		-- Log("No low priority target in range")
		local nearest_weak = GetClosest(enemy_wkk)
		if (nearest_weak ~= 0) and (MyState == IDLE_ST) then
			local HomunHP = GetV(V_HP, MyID)
			local HomunMaxHP = GetV(V_MAXHP, MyID)
			local HomunHPPerc = (HomunHP / HomunMaxHP) * 100
			if (HomunHPPerc <= HP_PERC_SAFE2ATK) then
				-- No real threats were found, but some weak (= BEHA_attack_weak) enemies are hitting me: usually the
				-- aggressive scan (GetMyEnemy_AnyNoKS function) takes care of them (in the correct priority order), but
				-- now the homunculus HPs are under the safe level, so he/she is in defensive-only mode: no agressive
				-- scan will be started at this time! So it's ok to attack now this low priority monster
				result = nearest_weak
			end
		end
	end
	if result == 0 then
		-- Log("No (serious) enemy is attacking me")
	else
		Log(string.format("<defensive scan> Target found (ID %d):", result))
		HTact = GetFullTact(GetV(V_HOMUNTYPE, result))
	end

	-- Log("---- END OF DEFENSIVE SCAN")
	return result
end

--------------------------------------------------
function GetMyEnemy_AnyNoKS(myid)
--------------------------------------------------
	-- Log(string.format("---- AGGRESSIVE SCAN STARTED for ID (%d)", myid))
	local result = 0
	local actors = GetActors ()
	local players = {}
	local player_idx = 1
	local enemy_1st = {} -- primary targets
	local index_1st = 1
	local enemy_std = {} -- normal targets
	local index_std = 1
	local enemy_lss = {} -- last targets
	local index_lss = 1
	local mob_type, mob_target, mobBehav, ListedType
	local EnemyMaxHP
	local HomunMaxHP = GetV(V_MAXHP, MyID)

	for i,v in ipairs(actors) do -- fill the (not "friend") player list
		if (v ~= OwnerID and v ~= MyID) then
			if (0 == IsMonster(v)) then
				if isNotFriend(v) then
					players[player_idx] = v
					player_idx = player_idx + 1
				end
			end
		end
	end

	for i,v in ipairs(actors) do
		if (v ~= OwnerID) and (v ~= MyID) then 	  -- owner and homunculus aren't valid target, of course
			if (IsMonster(v) == 1) and (BlockedPathToEnemyID ~= v) then -- if target is a (reachable) monster

				local isOKToAttack = false
				mob_type = GetV(V_HOMUNTYPE, v)		  -- get tact data
				mobBehav = GetTact(V_TACTBEHAV, mob_type)
				if( (mobBehav == BEHA_attack_1st)
				or  (mobBehav == BEHA_attack)
				or  (mobBehav == BEHA_attack_last)
				or  (mobBehav == BEHA_attack_weak)
				) then										  -- OK, this a type of monster to attack
					if isMobMotionOK(v, players) then
						mob_target = GetV(V_TARGET, v)  -- check for the monster's target
						if (mob_target == 0) then	-- if the monster is not in battle
							isOKToAttack = true	-- he/she can be attacked, unless...
							for i2,v2 in ipairs(players) do
								if (v == GetV(V_TARGET, v2)) then
									isOKToAttack = false   -- ...another player is already aiming at him/her (anti-KS)
									break
								end
							end
						else									  -- else, if the monster is already in battle
							if (mob_target == MyID)
							or (mob_target == OwnerID)
							or (not isNotFriend(mob_target))
							or IsMonster2(mob_target) then
								isOKToAttack = true		  -- but with me/my owner/a friend, it's OK (anti-KS)
							end
						end
					end
				end

				if isOKToAttack then
					if (mobBehav == BEHA_attack_1st) then
						enemy_1st[index_1st] = v
						index_1st = index_1st + 1
						-- Log(string.format(" added to (1st) as enemyID %d", v))
					elseif (mobBehav == BEHA_attack) then
						enemy_std[index_std] = v
						index_std = index_std + 1
						-- Log(string.format(" added to (std) as enemyID %d", v))
					else -- BEHA_attack_last, BEHA_attack_weak
						enemy_lss[index_lss] = v
						index_lss = index_lss + 1
						-- Log(string.format(" added to (lss) as enemyID %d", v))
					end
				end

			end
		end
	end

	-- Searches for nearest target ---------------
	result = GetClosest(enemy_1st)
	if (result == 0) then
		-- Log("No primary target in range")
		result = GetClosest(enemy_std)
	end
	if (result == 0) then
		-- Log("No standard target in range")
		result = GetClosest(enemy_lss)
	end
	if (result == 0) then
		-- Log("No target in range")
	else
		Log(string.format("<aggressive scan> Target found (ID %d):", result))
		HTact = GetFullTact(GetV(V_HOMUNTYPE, result))
	end

	BlockedPathToEnemyID = 0
	-- Log("---- END OF AGGRESSIVE SCAN")
	return result
end

--------------------------------------------------
function GetClosest(EnemiesOnSight)
--------------------------------------------------
	local result = 0
	local nearest_dst = 100
	local owner_dst = 0
	local dst = 0
	for i,v in ipairs(EnemiesOnSight) do
		dst = GetDistance2(MyID, v)
		-- Log(string.format("distance from EnemyID %d is %d", v, dst))
		owner_dst = GetDistance2(OwnerID, v)
		if (dst < nearest_dst and owner_dst < TOO_FAR_TARGET) then
			result = v
			nearest_dst = dst
			-- Log(string.format("he/she is now the closest (%d)", nearest_dst))
		end
	end
	return result
end

--------------------------------------------------
function isCloseToOwner()
--------------------------------------------------
	-- OWNER_CLOSEDISTANCE is no longer used
	return (math.abs(OwnerX - MyX) <= 1) and (math.abs(OwnerY - MyY) <= 1)
end
--------------------------------------------------
function Log(s)
--------------------------------------------------
	local CurrTime = GetTick()
	local dt= CurrTime - LastLogTime
	if LastLogTime == 0 then dt = 0 end
	LastLogTime = CurrTime
	TraceAI("| " .. dt .. "ms: " .. s)
end

--------------------------------------------------
function limMove(ID, x, y) -- Movement protection filter
--------------------------------------------------
	if x == -1 or y == -1 then return; end -- not valid coordinates
	if GetDistance(OwnerX, OwnerY, x, y) < TOO_FAR_TARGET then
		Log(string.format("...moving... (state %d)", MyState))
		stdMove(ID, x, y)
	else
		Log("[ -> IDLE_ST] Destination was too far: back to owner")
		MyState = IDLE_ST
		MyEnemy = 0
		MySkill = 0
		IdleStartTime = GetTick()
		MoveToOwner(MyID)
	end
end

--------------------------------------------------
function AI(myid)
--------------------------------------------------
	MyID = myid
	local msg = GetMsg (myid) -- command
	local rmsg = GetResMsg (myid) -- reserved command

	-----------------------------------------------
	if not Initialized then -- AI init. section
	-----------------------------------------------
		Log("===INIT START===")
		OwnerID = GetV(V_OWNER, MyID)
		HomunType = GetV(V_HOMUNTYPE, MyID)
		
		-- Homunculus S detection
		if (HomunType > 16) then
			HomunS = true
			Log("Homunculus S detected")
		end
		
		-- Vanilmirth ------------------------------
		if(HomunType == VANILMIRTH  or HomunType == VANILMIRTH_H
		or HomunType == VANILMIRTH2 or HomunType == VANILMIRTH_H2
		or (HomunS == true and OldHomunType == VANILMIRTH)) then
			LRASID = AS_VAN_CAPR
		-- Filir -----------------------------------
		elseif (HomunType == FILIR  or HomunType == FILIR_H
		or 	  HomunType == FILIR2 or HomunType == FILIR_H2
		or (HomunS == true and OldHomunType == FILIR)) then
			LRASID = AS_FIL_MOON
		--------------------------------------------
		end
		FriendList_Clear()
		stdMove = Move; Move = limMove -- replace Move with the protected version
		StartupTime = GetTick()
		IdleStartTime = StartupTime
		if FileExists("AI/USER_AI/follow.lck") then
			MyState = FOLLOW_CMD_ST
		end
		ModInit() -- initialize the mod too
		Log("===INIT DONE===")
		Initialized = true
	end
	-----------------------------------------------

	MyX, MyY = GetV(V_POSITION, MyID)
	OwnerX, OwnerY = GetV(V_POSITION, OwnerID)

	if msg[1] == NONE_CMD then
		if rmsg[1] ~= NONE_CMD then
			if List.size(ResCmdList) < 10 then
				List.pushright (ResCmdList,rmsg)
			end
		end
	else
		List.clear (ResCmdList)
		ProcessCommand (msg)
	end

 	if 	 (MyState == IDLE_ST) then
		OnIDLE_ST()
	elseif (MyState == CHASE_ST) then
		OnCHASE_ST()
	elseif (MyState == EVADE_ST) then
		OnEVADE_ST()
	elseif (MyState == ATTACK_ST) then
		OnATTACK_ST()
	elseif (MyState == FOLLOW_ST) then
		OnFOLLOW_ST()
	elseif (MyState == BUGPOSI_ST) then
		OnBUGPOSI_ST()
	-----------------------------------
	elseif (MyState == OUTMOVE_NEWFRIEND_ST) then
		OnOUTMOVE_NEWFRIEND_ST()
	elseif (MyState == OUTMOVE_DELFRIEND_ST) then
		OnOUTMOVE_DELFRIEND_ST()
	-----------------------------------
	elseif (MyState == MOVE_CMD_ST) then
		OnMOVE_CMD_ST()
	elseif (MyState == STOP_CMD_ST) then
		OnSTOP_CMD_ST()
	elseif (MyState == ATTACK_OBJECT_CMD_ST) then
		OnATTACK_OBJECT_CMD_ST ()
	elseif (MyState == ATTACK_AREA_CMD_ST) then
		OnATTACK_AREA_CMD_ST()
	elseif (MyState == PATROL_CMD_ST) then
		OnPATROL_CMD_ST()
	elseif (MyState == HOLD_CMD_ST) then
		OnHOLD_CMD_ST()
	elseif (MyState == SKILL_OBJECT_CMD_ST) then
		OnSKILL_OBJECT_CMD_ST()
	elseif (MyState == SKILL_AREA_CMD_ST) then
		OnSKILL_AREA_CMD_ST()
	elseif (MyState == FOLLOW_CMD_ST) then
		OnFOLLOW_CMD_ST()
	end

end
