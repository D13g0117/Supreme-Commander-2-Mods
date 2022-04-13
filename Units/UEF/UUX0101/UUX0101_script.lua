-----------------------------------------------------------------------------
--  File     : /units/uef/uux0101/uux0101_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist, Drew Staltman
--  Summary  : SC2 UEF Experimental Mobile Factory: UUX0101
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUX0101 = Class(ExperimentalMobileUnit) {

    ExhaustEffects = {
		'/effects/emitters/units/uef/uux0101/ambient/uux0101_01_smoke_emit.bp',
    },
    
    Weapons = {
        MainTurret01 = Class(DefaultProjectileWeapon) {
             CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Light on Muzzle
		        local myPos = self.unit:GetPosition(muzzle)
		        local lightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 10, 4, 0.0, 0.0, 0.255 )
            end,
        },
        RightTurret01 = Class(DefaultProjectileWeapon) {},
        RightTurret02 = Class(DefaultProjectileWeapon) {},
        LeftTurret01 = Class(DefaultProjectileWeapon) {},
        LeftTurret02 = Class(DefaultProjectileWeapon) {},
    },

    TreadRotateBones = {
        'Tread01',
        'Tread02',
    },

    TreadRotateInvertBones = {
        'Tread03',
        'Tread04',
    },

    OnStopBeingBuilt = function(self,builder,layer)
        ExperimentalMobileUnit.OnStopBeingBuilt(self,builder,layer)
        self.TreadManipulators = {}
        self.AmbientEffectsBag = {}

        -- Create the tread turn controllers
        for k, v in self.TreadRotateBones do
            table.insert(self.TreadManipulators, CreateTurnController(self, v, false))
        end

        for k, v in self.TreadRotateInvertBones do
            table.insert(self.TreadManipulators, CreateTurnController(self, v, true))
        end

        -- Set up the turning treads
        for k,v in self.TreadManipulators do
            v:SetTurningSpeed( 0.25 )
            v:SetTurningParams( -0.25, 0.25, -0.25, 0.25, -0.25, 0.25 )
            self.Trash:Add(v)
        end
        
        -- Exhaust smoke effects
        for k, v in self.ExhaustEffects do
            table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'UUX0101', self:GetArmy(), v ) )
        end
    end,
}
TypeClass = UUX0101