-----------------------------------------------------------------------------
--  File     : /units/illuminate/uib0702/uib0702_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate Energy Production Facility: UIB0702
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local CollisionBeamFile = import('/lua/sim/defaultcollisionbeams.lua')

UIB0702 = Class(StructureUnit) {

    Weapons = {
        Electroshock = Class(DefaultBeamWeapon) {
			BeamType = CollisionBeamFile.ElectroShockCollisionBeam,
		},
    },
    
    ClawBones = {
	    'claw01', 'claw02', 'claw03', 'claw04', 'claw05', 'claw06', 'claw07', 'claw08'
    },
    
    BigClawBones = {
	    'Petal01', 'Petal02', 'Petal03', 'Petal04'
    },

	OnElectroshock = function( self, abilityBP, state )
		--LOG( 'OnElectroshock, lua script event, state = ', state )
        local bp = self:GetBlueprint()

        if not self.ElectroshockAnimation then
			self.ElectroshockAnimation = CreateAnimator(self)
			self.Trash:Add(self.ElectroshockAnimation)
		end

		if state == 'activate' and not self.ElectroshockOn then
            self.ElectroshockOn = true
			self:SetWeaponEnabledByLabel('Electroshock', true)
            self:SetProductionActive(false)
            self.ElectroshockAnimation:PlayAnim('/units/illuminate/uib0702/uib0702_aopen01.sca')
            
            -- electric effects
            self:ForkThread( self.EffectsThread )
            
		else
            self.ElectroshockOn = false
			self:SetWeaponEnabledByLabel('Electroshock', false)
            self:SetProductionActive(true)
            self.ElectroshockAnimation:PlayAnim('/units/illuminate/uib0702/uib0702_aclose01.sca')
            
            -- clean up effects
            if self.EffectsBag then
			    for k, v in self.EffectsBag do
				    v:Destroy()
			    end
			    self.EffectsBag = {}
		    end
		end
	end,
	
	EffectsThread = function(self)
	    local army = self:GetArmy()

        for kE, vE in EffectTemplates.Units.Illuminate.Base.UIB0702.ShockAmbient04 do
			for kB, vB in self.ClawBones do
				table.insert( self.EffectsBag, CreateAttachedEmitter(self, vB, army, vE ))
			end
		end
		
		for k, v in EffectTemplates.Units.Illuminate.Base.UIB0702.ShockAmbient05 do
			table.insert( self.EffectsBag, CreateAttachedEmitter( self, 'Turret01', army, v ))
		end
		
		for kE, vE in EffectTemplates.Units.Illuminate.Base.UIB0702.ShockAmbient06 do
			for kB, vB in self.BigClawBones do
				table.insert( self.EffectsBag, CreateAttachedEmitter(self, vB, army, vE ))
			end
		end

        WaitSeconds( 3 )
        
        for kE, vE in EffectTemplates.Units.Illuminate.Base.UIB0702.ShockAmbient02 do
			for kB, vB in self.ClawBones do
				table.insert( self.EffectsBag, CreateAttachedEmitter(self, vB, army, vE ))
			end
		end
		
		for kE, vE in EffectTemplates.Units.Illuminate.Base.UIB0702.ShockAmbient03 do
			for kB, vB in self.BigClawBones do
				table.insert( self.EffectsBag, CreateAttachedEmitter(self, vB, army, vE ))
			end
		end
        
        for k, v in EffectTemplates.Units.Illuminate.Base.UIB0702.ShockAmbient01 do
			table.insert( self.EffectsBag, CreateAttachedEmitter( self, 'Turret01', army, v ))
		end
    end,
	
	OnStopBeingBuilt = function(self,builder,layer)
		StructureUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add( CreateRotator(self, 'UIB0702_Circle03_LOD0', 'y', nil, 0, 60, 60) )
        self.Trash:Add( CreateRotator(self, 'UIB0702_Gear01_LOD0', 'z', nil, 0, -20, -20) )
        self.Trash:Add( CreateRotator(self, 'UIB0702_Gear02_LOD0', 'z', nil, 0, 20, 20) )
		self.Trash:Add( CreateRotator(self, 'UIB0702_Gear03_LOD0', 'z', nil, 0, -20, -20) )
        self.Trash:Add( CreateRotator(self, 'UIB0702_Gear04_LOD0', 'z', nil, 0, 20, 20) )
        self.EffectsBag = {}
	end,
}
TypeClass = UIB0702