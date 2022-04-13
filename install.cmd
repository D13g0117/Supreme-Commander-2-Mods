@echo off
if not exist "C:\Program Files (x86)\Steam\steamapps\common\Supreme Commander 2\gamedata" (
    copy .\Mods\* "D:\PROGRAMAS\Steam\steamapps\common\Supreme Commander 2\gamedata" /Y
    echo "Mods installed succesfully"
    timeout 5
) else (
    copy .\Mods\* "C:\Program Files (x86)\Steam\steamapps\common\Supreme Commander 2\gamedata" /Y
    echo "Mods installed succesfully"
    timeout 5
)
