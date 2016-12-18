--------------------------------------------------
-- Mir AI Mod
--------------------------------------------------
-- Here you can add new stuff or changes to Mir AI
-- without the need to modify AI.lua at every release

--------------------------------------------------
-- Libraries
--------------------------------------------------
-- require "./AI/USER_AI/extra.lua" -- example

--------------------------------------------------
-- Extra Globals
--------------------------------------------------
-- MyExtraGlobal1 = 0 -- example
-- MyExtraGlobal2 = 0 -- example

-- Homu S global, TODO: move to Config.lua later.
OldHomunType = VANILMIRTH	-- LIF || FILIR || AMISTR || VANILMIRTH

--------------------------------------------------
function ModInit()
-- plugin initialization
--------------------------------------------------
--[[
   This function is called in the Mir AI initialization procedure.
   Here you can even replace functions with your own functions;
   example of function replacement:

   DoSkill_AAP = DoSkill_MyAAP -- replaces Auto Aid Potion function
--]]
end

--[[
### Example ###
This is as example of custom Auto Aid Potion function,
that does first aid instead of aid potion (lol)
--------------------------------------------------
function	DoSkill_MyAAP(CurrHPVar)
--------------------------------------------------
   SkillObject(MyID, 1, 142, MyID)
end
--]]