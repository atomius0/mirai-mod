--------------------------------------------------
- Mir AI (v1.2) by Miranda Blade
--------------------------------------------------
http://www.mirandablade.altervista.org/index.php?pg=mirai

Summary:
1. Features
2. Installation
3. Configuration
4. Editing

-- 1. Features --------------------------------------

- Configurable "Tact List": 
for each monster you can choose a different behaviours and how your homunculus will use his/her aggressive skills (no skill for some monsters, only one shot for others, and so on... and skill levels), so that your homunculus can attack some monster (with different priorities) or he/she can react only to an aggression. The AI can also avoid to engage in combat with some monsters (avoid mode) or (in coward mode) can attack some monsters only when they are "tanked" by the owner. 
Please visit roempire database for new IDs or click on the ID link in the Control Panel.

- Friend List: 
Anti-KS is disabled  for player in the friend list, so the homunculus can cooperate with party members or he/she can be tanked by a friend. To add or to remove someone from the friend list, move the homunculus (alt+right click) to a cell north or south from that player. The omunculus does a cute movement when you add a friend to the list, and another movement when you remove him/her. The friend list is saved in Friends.txt (in the USER_AI folder).

- Auto Aid Potion: 
you can choose when to throw potions to your homunculus (when attacking, when escaping or both, and the minimum HP percentage). The AI has a smart out of potion detection (you can disable this feature).

- Alchemist auto-attacks: 
Cart Revolution for multiple targets and weapon-based single-target skills when there is only one enemy (eg. Bash with a Cultus)

- Anti KS:
the AI checks for both monster and other player targets

- Fast follow: 
many optimizations have been done, and now your homunculus walks very fast when he/she follows you; moreover he is smart enough to disengage his/her target and follow you when you flee away from too many monsters.

- Recharge and patrol: 
the AI waits until HPs are fully recharged, then it starts to patrol around the owner

- Obstacle detection: 
archers and bathory webs don't stop the AI, and the AI can detect obstacles on her path. 

- Escaping mode: 
if the humunculus is under attack and his/her HP are less than the secure level, then the AI starts evasive maneuvers (the AI then hopes that you help your homunculus in danger with (auto) aid potion or (auto) attacks)

- Defensive mode:
The AI goes in defensive mode when HPs are low (the homunculus will only react to attacks in order to defend himself or you, until the HPs are good enough to start an aggressive attack). If you choose "Cautious" option, the AI will ever stay in defensive mode.

Other features:
- The AI can remember the passive mode (alt+t) even when you teleport, change map, relog, and so on.
- There is an option that limits the interception range of your homunculus so he/she doesn't go too far
- If the owner or a friend is under attack, the homunculus comes to help
- If the owner or a friend attacks a monster, the homunculus comes to cooperate

- Plugins and Mods support: 
other script writers can add new functions or changes. Please note that the file name of a mod must end with "_Mod.lua" (e.g.: PvP_Mod.lua).

=== Homunculus Autoskills ===
Please note:
- Amistr's Castling is not implemented, because it doesn't work on RO.
- Vanilmirth's Chaotic Blessings seems disabled for custom AIs (it works manually only)

Amistr:
- Bulwark (when he attacks and skill duration has been expired)
Filir:
- Moonlight (every time he attacks)
- Flitting (when he attacks)
- Accelerated Flight (when he attacks) [they say AF don't actually works on RO]
Lif: 
- Healing touch (when the owner is in a bad shape)
- Urgent escape (when she is evading)
Vanilmirth: 
- Caprice (every time he attacks)

-- 2. Installation ----------------------------------
1. WARNING: backup your Config.lua before to install this version over an older version of this AI!
2. extract the files in your Ragnarok folder\AI\USER_AI
3. don't forget to type /hoai in your client: this command tells the client to load the user's AI instead of the default AI.

-- 3. Configuration ---------------------------------
Just open Config.lua and edit it. 

I tryed to make that file well commented, so you should easily understand what any option does ^^ Anyway, the MirAI Control Panel (an external utility that you can download from the Mir AI web page) helps you to configure Mir AI in an easier way. Please note that the generated configuration file has less comments.

-- 4. Editing ---------------------------------------
Notepad.exe is sufficient to edit .lua files, but you could try ConTEXT, a good
editor with syntax highlighting (so the code displayed is easier to read):
http://www.context.cx/
and its .lua highlighter:
http://context.cx/component/option,com_docman/task,doc_details/gid,100/Itemid,48/