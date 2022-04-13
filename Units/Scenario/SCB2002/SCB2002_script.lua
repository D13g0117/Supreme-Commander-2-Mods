-----------------------------------------------------------------------------
--  File     :  /units/dev/scb2002/scb2002_script.lua
--  Author(s):
--  Summary  :  SC2 Flag: SCB2002
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

SCB2002 = Class(StructureUnit) {
    OnCreate = function(self, createArgs)
        StructureUnit.OnCreate(self, createArgs)
		self:SetUnSelectable(true)
		self:SetDoNotTarget(true)
		self.IgnoreDamage = true
	end,

	PlayActivateAnimation = function(self)
		self:ForkThread(function()
			WaitSeconds(Random(1,15) * 0.1)
			local DisplayBp = self:GetBlueprint().Display

			if not self.AnimationManipulator then
				self.AnimationManipulator = CreateAnimator(self)
				self.Trash:Add(self.AnimationManipulator)
			end
			self.AnimationManipulator:PlayAnim(DisplayBp.AnimationActivate, DisplayBp.AnimationActivateLoop or false )
		end)
    end,
}
TypeClass = SCB2002