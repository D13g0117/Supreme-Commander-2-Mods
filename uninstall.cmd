@echo off
if not exist "C:\Program Files (x86)\Steam\steamapps\common\Supreme Commander 2\gamedata" (
    FOR /F "tokens=* USEBACKQ" %%F IN (`dir .\Mods\ /b`) DO (
    del "D:\PROGRAMAS\Steam\steamapps\common\Supreme Commander 2\gamedata\%%F"
    echo "Uninstalled mod %%F"
    )
    timeout 5
) else (
    FOR /F "tokens=* USEBACKQ" %%F IN (`dir .\Mods\ /b`) DO (
    del "C:\Program Files (x86)\Steam\steamapps\common\Supreme Commander 2\gamedata\%%F"
    echo "Uninstalled mod %%F"
    )
    timeout 5
)