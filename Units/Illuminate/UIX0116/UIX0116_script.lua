-----------------------------------------------------------------------------
--  File     : /units/illuminate/uix0116/uix0116_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate Sea Hunter Pod: UIX0116
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalAirUnit = import('/lua/sim/ExperimentalAirUnit.lua').ExperimentalAirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UIX0116 = Class(ExperimentalAirUnit) {

    Weapons = {
        MainGun = Class(DefaultProjectileWeapon){},
    },

	OnCreate = function(self)
		ExperimentalAirUnit.OnCreate(self)
		self:SetDoNotTarget(true)
		self:SetCanTakeDamage(false)
		self:SetUnSelectable(true)
		self.IgnoreDamage = true
	end,
	
	OnKilled = function(self, instigator, type, overkillRatio)
		if self.parent and not self.parent:IsDead() then
			self.parent:RemovePod(self)
			self.parent = nil
		end
	end,
	
	OnDestroyed = function(self, instigator, type, overkillRatio)
		if self.parent and not self.parent:IsDead() then
			self.parent:RemovePod(self)
			self.parent = nil
		end
	end,

	SetParent = function( self, parent )
		self.parent = parent
	end,
	
	OnAwardExperience = function( self, new, total )
		if self.parent and not self.parent:IsDead() then
			self.parent:AwardExperience(new)
		end
	end,
}
TypeClass = UIX0116