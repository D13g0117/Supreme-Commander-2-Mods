-----------------------------------------------------------------------------
--  File     :  /units/cybran/ucb0105/ucb0105_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Long Range Artillery: UCB0105
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCB0105 = Class(StructureUnit) {
    Weapons = {
        Artillery01 = Class(DefaultProjectileWeapon) {
            FxGroundEffect = EffectTemplates.Weapons.Cybran_Artillery02_Launch02,
	        FxVentEffect = EffectTemplates.Weapons.Cybran_Artillery02_Launch03,
	        FxMuzzleEffect = EffectTemplates.Weapons.Cybran_Artillery02_Launch04,
	        FxCoolDownEffect = EffectTemplates.Weapons.Cybran_Artillery02_Launch05,

	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()
		        DefaultProjectileWeapon.PlayFxMuzzleSequence(self, muzzle)
	            for k, v in self.FxGroundEffect do
                    CreateAttachedEmitter(self.unit, 'UCB0105', army, v)
                end
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'T01_Arm01', army, v)
                end
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'T01_Barrel01', army, v)
                end
  	            for k, v in self.FxCoolDownEffect do
                    CreateAttachedEmitter(self.unit, 'Turret01', army, v)
                end
                -- Light on Muzzle
				local myPos = self.unit:GetPosition(muzzle)
				local lightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, 0, 0, 15, 2, 0.0, 0.2, 0.255 )
            end,

        }
    },
}

TypeClass = UCB0105