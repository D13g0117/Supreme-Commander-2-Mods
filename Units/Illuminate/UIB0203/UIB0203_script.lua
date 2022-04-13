-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uib0203/uib0203_script.lua
--  Author(s):  Gordon Duclos
--  Summary  :  SC2 UIB0203: Illuminate Tactical/ ICBM Combo Defense
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local CollisionBeamFile = import('/lua/sim/defaultcollisionbeams.lua')

UIB0203 = Class(StructureUnit) {

    Weapons = {
    
        AntiTacticalMissile01 = Class(DefaultBeamWeapon) {
			BeamType = CollisionBeamFile.ZapperCollisionBeam,
		},
		
        AntiStrategicMissile01 = Class(DefaultProjectileWeapon) {
			CreateProjectileForWeapon = function(self, bone)
				DefaultProjectileWeapon.CreateProjectileForWeapon(self, bone)
				self:ResetTarget()
			end,        
        },
    },
}
TypeClass = UIB0203