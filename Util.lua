--------------------------------------------------
-- Util.lua for Mir AI
--------------------------------------------------
require "./AI/USER_AI/Const.lua"

--------------------------------------------------
function IsMonster2(ID)
--------------------------------------------------
	local mob_type = GetV(V_HOMUNTYPE, ID)
	--Log(string.format("mob target: type = %d", mob_type))
	if (mob_type >=0) and ((mob_type < 1000) or (mob_type > 4000)) then
		return false
	end
	return true
end

--------------------------------------------------
-- ### Tact ######################################
--------------------------------------------------

--------------------------------------------------
function GetFullTact(ID)
-- get all tact. data for this monster
--------------------------------------------------
	T = {}
	if Tact[ID] == nil then -- Return default Tactic for unlisted monsters
		Log(string.format("No tact data for monster type-ID %d", ID))
		T.Behav = DEFAULT_BEHA
		T.Skill = DEFAULT_WITH
		T.Level = -1
		T.Alche = 0
	else
		Log(string.format("Tact data found for %s: behaviour %d, skill mode %d", Tact[ID][1], Tact[ID][V_TACTBEHAV], Tact[ID][V_TACTSKILL]))
		T.Behav = Tact[ID][V_TACTBEHAV]
		T.Skill = Tact[ID][V_TACTSKILL]
		T.Level = Tact[ID][V_TACTLEVEL]
		T.Alche = Tact[ID][V_TACTALCHE]
	end
	return T
end

--------------------------------------------------
function GetTact(tv, ID)
-- get specified tact. data for this monster
--------------------------------------------------
	if Tact[ID] == nil then -- Return default Tactic for unlisted monsters
		TraceAI(string.format("No tact data for monster type-ID %d", ID))
		if     tv == V_TACTBEHAV then
			return DEFAULT_BEHA
		elseif tv == V_TACTSKILL then
			return DEFAULT_WITH
		elseif tv == V_TACTLEVEL then
			return -1
		elseif tv == V_TACTALCHE then
			return 0
		end
	else
		TraceAI(string.format("Tact data found for %s: behaviour %d, skill mode %d", Tact[ID][1], Tact[ID][V_TACTBEHAV], Tact[ID][V_TACTSKILL]))
		return Tact[ID][tv]
	end
end

--------------------------------------------------
-- ### Friends ###################################
--------------------------------------------------
Friends = {}
FRIENDLIST_FILE = "AI/USER_AI/Friends.txt"

--------------------------------------------------
function FriendList_Clear()
--------------------------------------------------
	for i,v in Friends do
		Friends[i] = nil
	end
end

--------------------------------------------------
function FriendList_Load()
--------------------------------------------------
	local f_in = io.open(FRIENDLIST_FILE, "r")
	if f_in ~= nil then
		FriendList_Clear()
		local ln = f_in:read()
		while ln ~= nil do
			Friends[ln] = tonumber(ln)
			ln = f_in:read()
		end
		f_in:close()
		TraceAI("Friend list loaded")
	else
		TraceAI("Cannot load friend list")
	end
end

--------------------------------------------------
function FriendList_Save()
--------------------------------------------------
	local f_out = io.open(FRIENDLIST_FILE, "w")
	if f_out ~= nil then
		for i,v in Friends do
			f_out:write(v .. "\n")
			-- TraceAI(string.format("Friend %d saved", v))
		end
		f_out:close()
		TraceAI("Friend list has been saved")
	else
		TraceAI("Cannot save friend list")
	end
end

--------------------------------------------------
function isNotFriend(ID)
-- if he/she (ID) is not in the list
--------------------------------------------------
	return (Friends[ID] == nil)
end

--------------------------------------------------
function FriendList_Switch(ID)
-- add or remove someone (ID) from the list
--------------------------------------------------
	if isNotFriend(ID) then
		Friends[ID] = ID
		TraceAI(string.format("Friend ID %d not found: added", ID))
	else
		Friends[ID] = nil
		TraceAI(string.format("Friend ID %d found: removed", ID))
	end
	FriendList_Save()
end

--------------------------------------------------
function FileExists(path)
--------------------------------------------------
	local file = io.open(path, "rb")
	if file then file:close() end
	return file ~= nil
end

--------------------------------------------------
-- ### Misc (from default AI) ####################
--------------------------------------------------

function GetDistance(x1, y1, x2, y2)
	return math.floor(math.sqrt((x1-x2)^2+(y1-y2)^2))
end

function GetDistance2(id1, id2)
	local x1, y1 = GetV(V_POSITION, id1)
	local x2, y2 = GetV(V_POSITION, id2)
	if (x1 == -1 or x2 == -1) then
		return -1
	end
	return GetDistance(x1, y1, x2, y2)
end

function GetOwnerPosition(id)
	return GetV(V_POSITION, GetV(V_OWNER,id))
end

function GetDistanceFromOwner(id)
	local x1, y1 = GetOwnerPosition (id)
	local x2, y2 = GetV (V_POSITION,id)
	if (x1 == -1 or x2 == -1) then
		return -1
	end
	return GetDistance(x1, y1, x2, y2)
end

function IsOutOfSight(id1, id2)
	local x1,y1 = GetV(V_POSITION, id1)
	local x2,y2 = GetV(V_POSITION, id2)
	if (x1 == -1 or x2 == -1) then
		return true
	end
	local d = GetDistance(x1, y1, x2, y2)
	if d > 20 then
		return true
	else
		return false
	end
end

function IsInAttackSight(id1, id2)
	local x1,y1 = GetV(V_POSITION, id1)
	local x2,y2 = GetV(V_POSITION, id2)
	if (x1 == -1 or x2 == -1) then
		return false
	end
	local d = GetDistance(x1, y1, x2, y2)
	local a = 0
	if (MySkill == 0) then
		a = GetV(V_ATTACKRANGE, id1)
	else
		a = GetV(V_SKILLATTACKRANGE, id1, MySkill)
	end

	if a >= d then
		return true;
	else
		return false;
	end
end

--------------------------------------------------
-- ### List (from default AI) ####################
--------------------------------------------------
List = {}

function List.new ()
	return { first = 0, last = -1}
end

function List.pushleft (list, value)
	local first = list.first-1
	list.first  = first
	list[first] = value;
end

function List.pushright (list, value)
	local last = list.last + 1
	list.last = last
	list[last] = value
end

function List.popleft (list)
	local first = list.first
	if first > list.last then
		return nil
	end
	local value = list[first]
	list[first] = nil         -- to allow garbage collection
	list.first = first+1
	return value
end

function List.popright (list)
	local last = list.last
	if list.first > last then
		return nil
	end
	local value = list[last]
	list[last] = nil
	list.last = last-1
	return value
end

function List.clear (list)
	for i,v in ipairs(list) do
		list[i] = nil
	end
--[[
	if List.size(list) == 0 then
		return
	end
	local first = list.first
	local last  = list.last
	for i=first, last do
		list[i] = nil
	end
--]]
	list.first = 0
	list.last = -1
end

function List.size (list)
	local size = list.last - list.first + 1
	return size
end