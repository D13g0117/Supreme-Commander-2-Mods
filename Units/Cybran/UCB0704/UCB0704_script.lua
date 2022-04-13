-----------------------------------------------------------------------------
--  File     : /units/uef/UCB0704/UCB0704_script.lua
--  Author(s): Mike Robbins
--  Summary  : SC2 Cybran Mass Convertor: UCB0704
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UCB0704 = Class(StructureUnit) {    
	OnMassConvert = function(self, abilityBP, state )  
		if state == 'activate' then		
			self:SendAnimEvent('OnConvert')
			self:PlayUnitSound('OnConvert')
			
			for k, v in EffectTemplates.Units.UEF.Base.UUB0704.ConvertMass01 do
                CreateAttachedEmitter( self, -2, self:GetArmy(), v ):OffsetEmitter( 0, .5, 0 )
            end	
		end
    end,
}
TypeClass = UCB0704