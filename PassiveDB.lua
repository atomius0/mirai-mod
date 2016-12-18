--------------------------------------------------
-- Mir AI: database for not aggressive and not mobile monsters
--------------------------------------------------
NoAggroMobList = {
------ aggressive but cannot move
1118, --Flora
1368, --Geographer
1277, --Greatest General
1068, --Hydra
1688, --Lady Tanee
1020, --Mandragora
1274, --Megalith
1500, --Parasite
------ not aggressive
1275, --Alice
1737, --Aliza
1271, --Alligator
1094, --Ambernite
1030, --Anacondaq
1095, --Andre
1097, --Ant Egg
1247, --Antonio
1266, --Aster
1107, --Baby Wolw
1494, --Beetle King
1633, --Beholder
1060, --Bigfoot
1084, --Black Mushroom
1079, --Blue Plant
1025, --Boa
1520, --Boiled Rice
1103, --Caramel
1011, --Chonchon
1246, --Christmas Cookie
1269, --Clock
1270, --Clock Tower Manager
1104, --Coco
1009, --Condor
1265, --Cookie
1067, --Cornutus
1073, --Crab
1018, --Creamy
1105, --Deniro
1108, --Deviace
1110, --Dokebi
1721, --Dragon Egg
1113, --Drops
1409, --Dumpling Child
1114, --Dustiness
1396, --Earth Crystal
1116, --Eggyra
1288, --Emperium
1007, --Fabre
1397, --Fire Crystal
1391, --Galapago
1121, --Giearth
1372, --Goat
1280, --Goblin Steamrider
1086, --Golden Thief Bug
1040, --Golem
1369, --Grand Peco
1080, --Green Plant
1632, --Gremlin
1687, --Grove
1413, --Hermit Plant
1127, --Hode
1628, --Holden
1128, --Horn
1004, --Hornet
1400, --Karakasa
1070, --Kukre
1586, --Leaf Cat
1063, --Lunatic
1138, --Magnolia
1242, --Marin
1141, --Marina
1142, --Marine Sphere
1144, --Marse
1145, --Martin
1064, --Megalodon
1613, --Metaling
1058, --Metaller
1516, --Mi Gao
1585, --Mime Monkey
1614, --Mineral
1404, --Miyabi Doll
1055, --Muka
1249, --Myst Case
1019, --Peco Peco
1047, --Peco Peco Egg
1314, --Permeter
1158, --Phen
1049, --Picky
1050, --Picky Shell
1160, --Piere
1616, --Pitman
1161, --Plankton
1402, --Poison Toad
1031, --Poporing
1619, --Porcellio
1002, --Poring
1008, --Pupa
1027, --Raptice
1085, --Red Mushroom
1078, --Red Plant
1052, --Rocker
1012, --Roda Frog
1281, --Sage Worm
1062, --Santa Poring
1166, --Savage
1167, --Savage Babe
1168, --Scorpion King
1043, --Seahorse
1074, --Shellfish
1083, --Shining Plant
1076, --Skeleton
1056, --Smokie
1170, --Sohee
1316, --Solider
1014, --Spore
1322, --Spring Rabbit
1174, --Stainer
1278, --Stalactic Golem
1042, --Steel Chonchon
1175, --Tarou
1034, --Thara Frog
1051, --Thief Bug
1048, --Thief Bug Egg
1017, --Thief Bug Female
1182, --Thief Mushroom
1066, --Vadon
1032, --Verit
1176, --Vitata
1398, --Water Crystal
1022, --Werewolf
1185, --Whisper 
1082, --White Plant
1261, --Wild Rose
1010, --Willow
1395, --Wind Crystal
1013, --Wolf
1024, --Wormtail
1081, --Yellow Plant
1057, --Yoyo
1177, --Zenorc
1514, --Zhu Po Long
1417} --Zipper Bear

NoAggroMob = {}
for i,v in NoAggroMobList do
	NoAggroMob[v] = 1
end