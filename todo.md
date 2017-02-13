
## Todo

- [ ] update version number
- [ ] remove unsupported features: AAA, ACR, AST, AAP (also remove AAA parameter in tact list writer and all other unsupported features in mirai-mod-config's save functions)
- [x] include mirai-mod-config in release archives (update makefile)
- [x] move the global variable "OldHomunType" out of Standard_Mod.lua and into Config.lua (after writing the new config GUI, to keep compatibility with the old Config.exe for now)
- [ ] add proper support for Homunculus S skills (need more information)

- [x] change SelectedMod.lua to use 'require' instead of 'dofile'
- [x] update [changelog.txt](changelog.txt)
- [x] write a new Config GUI (probably in wxLua)

## Notes

- full homunculus S and mercenary skill list: https://github.com/15peaces/15-3athena/blob/master/db/skill_db.txt#L1369
