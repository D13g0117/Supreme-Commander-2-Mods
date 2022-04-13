-----------------------------------------------------------------------------
--  File     : /units/illuminate/uib0704/uib0704_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate Mass Converter: UIB0704
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UIB0704 = Class(StructureUnit) {

    OnStopBeingBuilt = function(self, createArgs)
		StructureUnit.OnStopBeingBuilt(self, createArgs)

		self.Spinners = {
			Spinner01 = CreateRotator(self, 'UIB0704_Ball01', 'y', nil, 0, 50, 360):SetTargetSpeed(90),
			Spinner02 = CreateRotator(self, 'UIB0704_Ball02', 'y', nil, 0, 40, 360):SetTargetSpeed(-20),
			Spinner03 = CreateRotator(self, 'UIB0704_Ball03', 'y', nil, 0, 150, 360):SetTargetSpeed(-160),
		}
		self.Trash:Add(self.Spinner)
	end,
	
	OnMassConvert = function(self, abilityBP, state )  
		if state == 'activate' then		
			self:SendAnimEvent( 'OnConvert' )
			self:PlayUnitSound('OnConvert')
			
			for k, v in EffectTemplates.Units.UEF.Base.UUB0704.ConvertMass01 do
                CreateAttachedEmitter( self, 'Attachpoint01', self:GetArmy(), v ) 
            end		
		end
    end,
	
}
TypeClass = UIB0704