-----------------------------------------------------------------------------
--  File     : /units/cybran/uca0021/uca0021_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Build Drone: UCA0021
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local AirUnit = import('/lua/sim/AirUnit.lua').AirUnit

UCA0103 = Class(AirUnit) {

    OnCreate = function(self)
        AirUnit.OnCreate(self) 

		-- Make build bots unkillable
		self:SetCanTakeDamage(false)
		self:SetCanBeKilled(false)

        --CreateBuilderArmController(unit,turretBone, [barrelBone], [aimBone])
        self.BuildArmManipulator = CreateBuilderArmController(self, 'T01_B01_Muzzle01' , 'T01_B01_Muzzle01', 0)
        self.BuildArmManipulator:SetAimingArc(-180, 180, 360, -90, 90, 360)
        self.BuildArmManipulator:SetPrecedence(5)
        self.Trash:Add(self.BuildArmManipulator)

        self.AnimationManipulator = CreateAnimator(self)
		self.AnimationManipulator:PlayAnim( self:GetBlueprint().Display.AnimationOpen )
        self.Trash:Add( self.AnimationManipulator )
    end,

    OnStartBuild = function(self, unitBeingBuilt, order )
        AirUnit.OnStartBuild(self,unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.StartBuildingEffects(self, unitBeingBuilt, order)
	self.Trash:Add(CreateRotator(self, 'frontring', 'y', nil, 0, 10, -600))
	self.Trash:Add(CreateRotator(self, 'innerring', 'y', nil, 0, 10, 600))
	self.Trash:Add(CreateRotator(self, 'backring', 'y', nil, 0, 10, 600))
	self.Trash:Add(CreateRotator(self, 'backring2', 'y', nil, 0, 10, -600))
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        CreateCybranBuildBeams( self, unitBeingBuilt, {'T01_B01_Muzzle01',}, self.BuildEffectsBag )
    end,
}
TypeClass = UCA0103