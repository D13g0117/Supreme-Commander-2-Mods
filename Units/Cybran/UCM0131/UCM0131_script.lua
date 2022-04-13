-----------------------------------------------------------------------------
--  File     : /units/cybran/ucm0131/ucm0131_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Torpedo Addon: UCM0131
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UCM0131 = Class(StructureUnit) {
    Weapons = {
        Torpedo01 = Class(import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon) {},
    },
	
	OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self:SetCapturable(false)
	end,
	
	--[[OnStopBeingBuilt = function(self,builder,layer)
		StructureUnit.OnStopBeingBuilt(self,builder,layer)
		local offset = VDiff(builder:GetPosition(), self:GetPosition())
		for i = 1, self:GetWeaponCount() do
			self:GetWeapon(i):SetCenterOffset(offset)
		end
	end]]--
}
TypeClass = UCM0131