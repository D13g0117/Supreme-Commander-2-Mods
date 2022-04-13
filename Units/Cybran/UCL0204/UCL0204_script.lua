-----------------------------------------------------------------------------
--  File     :  /units/cybran/ucl0204/ucl0204_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Combo Defense: UCL0204
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local CollisionBeamFile = import('/lua/sim/defaultcollisionbeams.lua')

UCL0204 = Class(MobileUnit) {
	DestructionExplosionWaitDelayMin = 0.7,
	DestructionExplosionWaitDelayMax = 0.7,

    ShieldEffects = {
		'/effects/emitters/units/cybran/ucl0204/shield/ucl0204_s_01_glow_emit.bp',
		'/effects/emitters/units/cybran/ucl0204/shield/ucl0204_s_03_wisps_emit.bp',
		'/effects/emitters/units/cybran/ucl0204/shield/ucl0204_s_02_core_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		MobileUnit.OnCreate(self, createArgs)
		self.ShieldEffectsBag = {}
	end,
	
    Weapons = {
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        AntiAir02 = Class(DefaultProjectileWeapon) {},
		AntiMissile01 = Class(DefaultBeamWeapon) {
			BeamType = CollisionBeamFile.ZapperCollisionBeam02,
		},
    },
    
    OnShieldEnabled = function(self)
        self:PlayUnitSound('ShieldOn')
        MobileUnit.OnShieldEnabled(self)

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, -2, self:GetArmy(), v ))
        end
        
    end,
    
    OnShieldDisabled = function(self)
        self:PlayUnitSound('ShieldOff')
        MobileUnit.OnShieldDisabled(self)
    
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,
}
TypeClass = UCL0204