-----------------------------------------------------------------------------
--  File     :  /units/uef/uua0103/uua0103_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Gunship: UUA0103
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local AirUnit = import('/lua/sim/AirUnit.lua').AirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUA0103 = Class(AirUnit) {
    BeamExhaustCruise = {'/effects/emitters/units/uef/general/gunship_thruster_beam_01_emit.bp'},
    BeamExhaustIdle = {'/effects/emitters/units/uef/general/gunship_thruster_beam_02_emit.bp'},
    
    EngineRotateBones = {'VTOL01', 'VTOL02', 'VTOL03', 'VTOL04',},

    Weapons = {
	    RiotGun01 = Class(DefaultProjectileWeapon) {},
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
TypeClass = UUA0103