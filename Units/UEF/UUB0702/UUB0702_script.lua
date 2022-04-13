-----------------------------------------------------------------------------
--  File     : /units/uef/uub0702/uub0702_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Energy Production Facility: UUB0702
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UUB0702 = Class(StructureUnit) {

    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self:SetBuilderAutoRepair(false)
	end,

    OnStartBuild = function(self, unitBeingBuilt, order )
        StructureUnit.OnStartBuild(self,unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true
        local bp = self:GetBlueprint()

		if self.UnitBeingBuilt and not self.UnitBeingBuilt:IsDead() and
			self.UnitBeingBuilt.BuildScaffoldUnit and not self.UnitBeingBuilt.BuildScaffoldUnit:IsDead() then
			self.UnitBeingBuilt.BuildScaffoldUnit:OnUnpaused()
		end
      
		self:StartBuildingEffects( unitBeingBuilt, order )
    end,
    

    OnStopBuild = function(self, unitBeingBuilt)
        StructureUnit.OnStopBuild(self,unitBeingBuilt)

		if self.UnitBeingBuilt and not self.UnitBeingBuilt:IsDead() and
			self.UnitBeingBuilt.BuildScaffoldUnit and not self.UnitBeingBuilt.BuildScaffoldUnit:IsDead() then
			self.UnitBeingBuilt.BuildScaffoldUnit:OnPaused()
		end
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false
    end,    
    
    OnPaused = function(self)
        --When construction is paused take some action
        self:StopUnitAmbientSound( 'ConstructLoop' )
        StructureUnit.OnPaused(self)
        if self.BuildingUnit then
            StructureUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end
    end,

    OnUnpaused = function(self)
        if self.BuildingUnit then
            self:PlayUnitAmbientSound( 'ConstructLoop' )
            StructureUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        StructureUnit.OnUnpaused(self)
    end,    

	CreateBuildEffects = function( self, unitBeingBuilt, order )
		CreateRepairBeams( self, unitBeingBuilt, self:GetBlueprint().Build.EffectBones, self.BuildEffectsBag )
    end,

	OnResearchedTechnologyAdded = function( self, upgradeName, level, modifierGroup )
		StructureUnit.OnResearchedTechnologyAdded( self, upgradeName, level, modifierGroup )
		if upgradeName == 'UBP_ENGINEERINGTOWER' then
			self:SetBuilderAutoRepair(true)
		end
	end,


	
}
TypeClass = UUB0702