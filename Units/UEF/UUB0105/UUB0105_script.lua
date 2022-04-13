-----------------------------------------------------------------------------
--  File     :  /units/uef/uub0105/uub0105_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Long Range Artillery: UUB0105
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUB0105 = Class(StructureUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self,builder,layer)
		self.Trash:Add( CreateRotator(self, 'dish', 'y', nil, 0, 50, 20) )
    end,

    Weapons = {
        MainGun = Class(DefaultProjectileWeapon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Light on Muzzle
		        local myPos = self.unit:GetPosition(muzzle)
		        local lightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 12, 4, 0.0, 0.0, 0.255 )
		        
				-- Base dust effects when unit fires
		        CreateBoneEffects( self.unit, -2, self.unit:GetArmy(), EffectTemplates.Units.UEF.Base.UUB0105.BaseLaunch01 )
            end,
        },
    },
}
TypeClass = UUB0105