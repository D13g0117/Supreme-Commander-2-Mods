-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uia0103/uia0103_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate Gunship: UIA0103
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local AirUnit = import('/lua/sim/AirUnit.lua').AirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UIA0103 = Class(AirUnit) {

	BeamExhaustCruise = {
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_05_emit.bp',
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_06_emit.bp',
	},
	BeamExhaustIdle = {
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_07_emit.bp',
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_08_emit.bp',
	},
	ContrailEffects = {
	},

    Weapons = {
        MainGun = Class(DefaultProjectileWeapon) {},
        AntiMissile = Class(DefaultProjectileWeapon) {
			CreateProjectileAtMuzzle = function(self, muzzle)
				local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)
				if proj then
					local bp = self:GetBlueprint()
					if bp.Flare then
						proj:AddFlare(bp.Flare)
					end
				end
			end,             
        },
    },

    EngineRotateBones = {
        'VTOL01',
        'VTOL02',
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        AirUnit.OnStopBeingBuilt(self,builder,layer)
        self.EngineManipulators = {}

        -- create the engine thrust manipulators
        for key, value in self.EngineRotateBones do
            table.insert(self.EngineManipulators, CreateThrustController(self, 'Thruster', value))
        end

        -- set up the thursting arcs for the engines
        for key,value in self.EngineManipulators do
            --                          XMAX, XMIN, YMAX,YMIN, ZMAX,ZMIN, TURNMULT, TURNSPEED
            value:SetThrustingParam( 0, 0, -0.75, 0.75, 0, 0, 35, 0.2 )
        end

        for k, v in self.EngineManipulators do
            self.Trash:Add(v)
        end
    end,

}
TypeClass = UIA0103