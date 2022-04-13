-----------------------------------------------------------------------------
--  File     : /units/uef/uub0704/uub0704_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Mass Convertor: UUB0704
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UUB0704 = Class(StructureUnit) {    
    OnStopBeingBuilt = function(self, createArgs)
		StructureUnit.OnStopBeingBuilt(self, createArgs)
		
		self.Spinners = {
			Spinner01 = CreateRotator(self, 'Rotator01', 'y', nil, 0, 60, 360):SetTargetSpeed(8),
			Spinner02 = CreateRotator(self, 'Fan01', 'y', nil, 0, 60, 360):SetTargetSpeed(-80),
		}
		self.Trash:Add(self.Spinner)
		
		-- Initialize animset
		self.animset = self:GetBlueprint().AnimSet or nil
		if self.animset then
			self:PushAnimSet(self.animset, "Base");
		end		
	end,
	
	OnMassConvert = function(self, abilityBP, state )  
		if state == 'activate' then		
			self:SendAnimEvent('OnConvert')
			self:PlayUnitSound('OnConvert')
			
			for k, v in EffectTemplates.Units.UEF.Base.UUB0704.ConvertMass01 do
                CreateAttachedEmitter( self, 'Rotator01', self:GetArmy(), v ) 
            end		
		end
    end,
}
TypeClass = UUB0704