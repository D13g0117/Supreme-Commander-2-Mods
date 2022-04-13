-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uil0203/uil0203_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate Anti-Missile: UIL0203
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local HoverUnit = import('/lua/sim/HoverUnit.lua').HoverUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local CollisionBeamFile = import('/lua/sim/defaultcollisionbeams.lua')

UIL0203 = Class(HoverUnit) {
    Weapons = {
        AntiMissile01 = Class(DefaultBeamWeapon) {
			BeamType = CollisionBeamFile.ZapperCollisionBeam02,
		},
    },

    ShieldEffects = {
        '/effects/emitters/units/illuminate/general/aeon_shield_generator_mobile_01_emit.bp',
    },

    OnStopBeingBuilt = function(self,builder,layer)
        HoverUnit.OnStopBeingBuilt(self,builder,layer)
		self.ShieldEffectsBag = {}
		
		local sx, sy, sz = self:GetUnitSizes() 
        self.volume = (sx * sz)*1.3
    end,

    OnShieldEnabled = function(self)
        HoverUnit.OnShieldEnabled(self)

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 0, self:GetArmy(), v ) )
        end
    end,

    OnShieldDisabled = function(self)
        HoverUnit.OnShieldDisabled(self)

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,
}
TypeClass = UIL0203