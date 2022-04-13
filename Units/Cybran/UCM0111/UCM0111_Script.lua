-----------------------------------------------------------------------------
--  File     :  /units/cybran/ucm0111/ucm0111_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Point Defense Upgrade: UCM0111
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCM0111 = Class(StructureUnit) {
    Weapons = {
        TacticalMissile01 = Class(DefaultProjectileWeapon) {}
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
TypeClass = UCM0111