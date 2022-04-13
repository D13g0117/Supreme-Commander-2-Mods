-----------------------------------------------------------------------------
--  File     : /units/cybran/ucb0702/ucb0702_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Energy Production Facility: UCB0702
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UCB0702 = Class(StructureUnit) {

	OnMassConvert = function(self, abilityBP, state )  
		if state == 'activate' then		
			self:PlayUnitSound('OnConvert')
			
			for k, v in EffectTemplates.Units.UEF.Base.UUB0704.ConvertMass01 do
                CreateAttachedEmitter( self, -2, self:GetArmy(), v ):OffsetEmitter( 0, .5, 0 )
            end		
		end
    end,
    
}
TypeClass = UCB0702