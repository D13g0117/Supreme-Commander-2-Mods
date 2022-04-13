-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uil0101/uil0101_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate Tank: UIL0101
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local HoverUnit = import('/lua/sim/HoverUnit.lua').HoverUnit
local GetRandomFloat = import('/lua/system/utilities.lua').GetRandomFloat
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UIL0101 = Class(HoverUnit) {
    Weapons = {
        TauCannon01 = Class(DefaultProjectileWeapon) {

	        PlayFxMuzzleSequence = function(self, muzzle)
		        DefaultProjectileWeapon.PlayFxMuzzleSequence(self, muzzle)
                local pos = self.unit:GetPosition()
                local TerrainType = GetTerrainType( pos.x,pos.z )
                local effectTable = TerrainType.FXOther[self.unit:GetCurrentLayer()][self.FxMuzzleTerrainTypeName]
                if effectTable != nil then
                    local army = self.unit:GetArmy()
			        for k, v in effectTable do
				        CreateAttachedEmitter(self.unit, muzzle, army, v)
			        end
		        end
            end,
        },
    },
}
TypeClass = UIL0101