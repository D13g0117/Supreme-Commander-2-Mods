-----------------------------------------------------------------------------
--  File     : /units/scenario/scl2101/scl2101_script.lua
--  Author(s): Chris Daroza, Gordon Duclos
--  Summary  : SC2 Mine Walker: SCL2101
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit

SCL2101 = Class(MobileUnit) {
	OnCreate = function(self)
        MobileUnit.OnCreate(self)
        self:ForkThread(self.WalkAbout)
    end,
    
    WalkAbout = function(self)
        while not self:IsDead() do
            self.WalkAnimation = CreateAnimator(self)
            self.Trash:Add(self.WalkAnimation)
            self.WalkAnimation:PlayAnim('/Units/Scenario/SCL2101/SCL2101_Amine01.sca', false):SetRate(1)
            WaitFor(self.WalkAnimation)
            self.WalkAnimation:SetRate(-1)
            WaitFor(self.WalkAnimation)
            self.WalkAnimation:Destroy()
        end
    end,
}
TypeClass = SCL2101