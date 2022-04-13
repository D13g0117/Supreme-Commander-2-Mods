-----------------------------------------------------------------------------
--  File     : /units/illuminate/uix0114/uix0114_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Illuminate Experimental Conversion Ray: UIX0114
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local captureCategory = (categories.MOBILE + categories.STRUCTURE) - categories.COMMAND - (categories.AIR * categories.MOBILE)

UIX0114 = Class(StructureUnit) {

	BeamAttachBones = {
		'Addon02',
		'Addon03',
		'Addon04',
	},

    AmbientEffectBones01 = {
        'Rotor01',
        'Rotor02',
        'Rotor03',
        'Rotor04',
    },
      
    AmbientEffectBones02 = {
        'Addon06',
        'Addon07',
        'Addon08',
    },
    
  	AmbientEffects01 = { 
		'/effects/emitters/units/illuminate/uix0114/ambient/uix0114_ambient_02_plasmaflat_emit.bp',
		'/effects/emitters/units/illuminate/uix0114/ambient/uix0114_ambient_03_lines_emit.bp',
		'/effects/emitters/units/illuminate/uix0114/ambient/uix0114_ambient_04_ring_emit.bp',
		'/effects/emitters/units/illuminate/uix0114/ambient/uix0114_ambient_05_plasmacore_emit.bp',
	},        
	          
    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateRotator(self, 'Rotor01', 'z', nil, 0, 60, 360):SetTargetSpeed(-105))
		self.Trash:Add(CreateRotator(self, 'Rotor02', 'z', nil, 0, 60, 360):SetTargetSpeed(-105))
		self.Trash:Add(CreateRotator(self, 'Rotor03', 'z', nil, 0, 60, 360):SetTargetSpeed(-105))
		self.Trash:Add(CreateRotator(self, 'Rotor04', 'z', nil, 0, 60, 360):SetTargetSpeed(-105))

        self:ForkThread( self.AutoCapture )
		self.AmbientEffectsBag = {}
    	self.UnitCaptureEffects = {}
    	
		-- Ambient effects
        for k, v in self.AmbientEffects01 do
			table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'UIX0114', self:GetArmy(), v ) )
		end
        
		for kEffect, vEffect in self.AmbientEffectBones01 do
            table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, vEffect, self:GetArmy(), '/effects/emitters/units/illuminate/uix0114/ambient/uix0114_ambient_01_plasma_emit.bp' ) )
        end
        
        for kBone, vBone in self.AmbientEffectBones02 do
            table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, vBone, self:GetArmy(), '/effects/emitters/units/illuminate/uix0114/ambient/uix0114_ambient_07_plasmalines_emit.bp' ) )
        end
        
        table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'T01_Barrel01', self:GetArmy(), '/effects/emitters/units/illuminate/uix0114/ambient/uix0114_ambient_06_plasmaeye_emit.bp' ) )
        
    end,

    CreateCaptureEffects = function( self, target )
        local emitters = EffectTemplates.LoyaltyBeamMuzzle01
        local emitters02 = EffectTemplates.LoyaltyBeamImpact01
        local army = self:GetArmy()

		-- Create emitters at beam start point
        for h, v in emitters do
			self.CaptureEffectsBag:Add(CreateAttachedEmitter(self, 'Addon01', army, v))
		end
        for kBone, vBone in self.AmbientEffectBones02 do
            self.CaptureEffectsBag:Add(CreateAttachedEmitter( self, vBone, army, '/effects/emitters/units/illuminate/uix0114/event/capture/illuminate_uix0114_01_glow_emit.bp' ):ScaleEmitter(0.4):OffsetEmitter( 0, 0, -0.9 ))
        end

		self.CaptureEffectsBag:Add(CreateAttachedEmitter( self, 'T01_B01_Muzzle01', army, '/effects/emitters/units/illuminate/uix0114/event/capture/illuminate_uix0114_04_smallglow_emit.bp' ))

		-- Create our beam between this unit and our beam end point entity
		for k, v in self.BeamAttachBones do
			self.CaptureEffectsBag:Add(AttachBeamEntityToEntity(self, v, self, 'T01_B01_Muzzle01', army, '/effects/emitters/units/illuminate/uix0114/event/capture/illuminate_loyalty_beam_02_emit.bp' ))
		end

		WaitSeconds( 0.7 )
		
		if self and not self:IsDead() and target and not target:IsDead() then
			-- Create our beam between this unit and our beam end point entity
			local beam = AttachBeamEntityToEntity(self, 'T01_B01_Muzzle01', target, -1, army, '/effects/emitters/units/illuminate/uix0114/event/capture/illuminate_loyalty_beam_01_emit.bp' )
			self.CaptureEffectsBag:Add(beam)

			-- Create emitters on beam end entity
			for h, v in emitters02 do
				self.CaptureEffectsBag:Add(CreateAttachedEmitter(target, -1, army, v))
			end
		end
    end,

    AutoCapture = function(self)
        local unitBp = self:GetBlueprint()
        local aiBrain = self:GetAIBrain()

        while not self:IsDead() do
            if not self:IsUnitState('Capturing') and not self:IsStunned() then

                -- look for capturables in area
                local targets = aiBrain:GetUnitsAroundPoint( captureCategory, self:GetPosition(), unitBp.Economy.MaxCaptureDistance, 'Enemy' )

                if not table.empty(targets) then
                    local sorted = SortEntitiesByDistanceXZ( self:GetPosition(), targets )

                    -- order capture
                    for k,v in sorted do
                        if not v:IsCapturable() or v:IsUnitState('BeingCaptured') then
                            continue
                        end

                        IssueCapture( {self}, v )
                        break
                    end
                end
            end
            WaitSeconds(1)
        end
    end,
    
    OnStunned = function(self,stunned)
		if stunned then
			IssueClearCommands({self})
		end
    end,
}
TypeClass = UIX0114