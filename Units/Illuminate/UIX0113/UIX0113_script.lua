-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uix0113/uix0113_script.lua
--  Author(s):	Gordon Duclos
--  Summary  :  SC2 Illuminate Experimental Teleporter: UIX0113
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UIX0113 = Class(StructureUnit) {
    
    EffectAttachBones = {	
		'Spinner01',
		'Spinner02',
		'Spinner03',
		'Spinner04',
		'Spinner05',
		'Spinner06',
	},
	
	EffectAttachBones02 = {	
		'Effect09',
		'Effect10',
		'Effect11',
		'Effect12',
		'Effect13',
		'Effect14',
	},
	
    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self, builder, layer)
		local army = self:GetArmy()	
		
        self.Spinners = {
			-- lower rings
            Spinner1 = CreateRotator(self, 'Spinner01', 'x', nil, 0, 60, 14 ),
            Spinner2 = CreateRotator(self, 'Spinner02', 'x', nil, 0, 60, 14 ),
            Spinner3 = CreateRotator(self, 'Spinner03', 'x', nil, 0, 60, 14 ),
            Spinner4 = CreateRotator(self, 'Spinner04', 'x', nil, 0, 60, 14 ),
            Spinner5 = CreateRotator(self, 'Spinner05', 'x', nil, 0, 60, 14 ),
            Spinner6 = CreateRotator(self, 'Spinner06', 'x', nil, 0, 60, 14 ),
            
            -- center rings
            Spinner7 = CreateRotator(self, 'Ring01', 'z', nil, 0, -50),
            Spinner8 = CreateRotator(self, 'Ring02', 'z', nil, 0, 50),
        }
		self.Trash:Add(self.Spinner)
		self.SpinnerTarget = false
		self:ForkThread( self.SpinnerThread )
		
        -- bottom light ray effects
	    CreateAttachedEmitter ( self, 'Effect01', army, '/effects/emitters/units/illuminate/uix0113/ambient/uix0113_amb_04_light_emit.bp' )
	    CreateAttachedEmitter ( self, 'Effect02', army, '/effects/emitters/units/illuminate/uix0113/ambient/uix0113_amb_04_light_emit.bp' )
		
		-- mid level light ray effects
		CreateAttachedEmitter ( self, 'Effect05', army, '/effects/emitters/units/illuminate/uix0113/ambient/uix0113_amb_05_light_emit.bp' )
		CreateAttachedEmitter ( self, 'Effect06', army, '/effects/emitters/units/illuminate/uix0113/ambient/uix0113_amb_05_light_emit.bp' )
				
		-- plasma on spinners
		for kBone, vBone in self.EffectAttachBones do
			CreateAttachedEmitter( self, vBone, army, '/effects/emitters/units/illuminate/uix0113/ambient/uix0113_amb_06_plasma_emit.bp' )
		end
			
		-- bottom ring
		CreateAttachedEmitter ( self, 'Effect03', army, '/effects/emitters/units/illuminate/uix0113/ambient/uix0113_amb_01_ring_emit.bp' )
		-- middle ring
		CreateAttachedEmitter ( self, 'Effect04', army, '/effects/emitters/units/illuminate/uix0113/ambient/uix0113_amb_02_ring_emit.bp' )
		-- top ring
		CreateAttachedEmitter ( self, 'Effect07', army, '/effects/emitters/units/illuminate/uix0113/ambient/uix0113_amb_03_ring_emit.bp' )

		self.TeleportLoadingEffects = {}
		self.TeleportUnitSpotEffects = {}
    end,

    OnStartTransportLoading = function(self)
		local effectbps01 = {
			'/effects/emitters/units/illuminate/uix0113/event/activate/uix0113_e_a_02_midplasma_emit.bp',
			'/effects/emitters/units/illuminate/uix0113/event/activate/uix0113_e_a_04_toplines_emit.bp',
			'/effects/emitters/units/illuminate/uix0113/event/activate/uix0113_e_a_09_topring_emit.bp',
		}
		local effectbps02 = {
			'/effects/emitters/units/illuminate/uix0113/event/activate/uix0113_e_a_01_bottomring_emit.bp',
			'/effects/emitters/units/illuminate/uix0113/event/activate/uix0113_e_a_05_bottomlines_emit.bp',
		}
		
		-- top light effects
		table.insert( self.TeleportLoadingEffects, CreateAttachedEmitter ( self, 'Effect08', self:GetArmy(), '/effects/emitters/units/illuminate/uix0113/event/activate/uix0113_e_a_03_upwardlight_emit.bp' ))
		table.insert( self.TeleportLoadingEffects, CreateAttachedEmitter ( self, 'Effect08', self:GetArmy(), '/effects/emitters/units/illuminate/uix0113/event/activate/uix0113_e_a_07_topplasma_emit.bp' ))
		
		-- plasma on spinners
		for kBone, vBone in self.EffectAttachBones do
			table.insert( self.TeleportLoadingEffects, CreateAttachedEmitter( self, vBone, self:GetArmy(), '/effects/emitters/units/illuminate/uix0113/event/activate/uix0113_e_a_06_plasma_emit.bp' ))
		end
		
		-- middle section effects
		for k, v in effectbps01 do
			table.insert( self.TeleportLoadingEffects, CreateAttachedEmitter( self, 'Effect04', self:GetArmy(), v ) )
		end

		-- lower section upward lines
		for k, v in effectbps02 do
			table.insert( self.TeleportLoadingEffects, CreateAttachedEmitter( self, 'Effect03', self:GetArmy(), v ) )
		end
		
		-- lower section upward plasma
		for kBone, vBone in self.EffectAttachBones02 do
			table.insert( self.TeleportLoadingEffects, CreateAttachedEmitter( self, vBone, self:GetArmy(), '/effects/emitters/units/illuminate/uix0113/event/activate/uix0113_e_a_08_bottomplasma_emit.bp' ))
		end
		
		self.Spinners.Spinner1:SetTargetSpeed(-200)
		self.Spinners.Spinner2:SetTargetSpeed(-200)
		self.Spinners.Spinner3:SetTargetSpeed(-200)
		self.Spinners.Spinner4:SetTargetSpeed(-200)
		self.Spinners.Spinner5:SetTargetSpeed(-200)
		self.Spinners.Spinner6:SetTargetSpeed(-200)
    end,

    OnStopTransportLoading = function(self)
		for k, v in self.TeleportLoadingEffects do
			v:Destroy()
		end

		self.Spinners.Spinner1:SetTargetSpeed(14)
		self.Spinners.Spinner2:SetTargetSpeed(14)
		self.Spinners.Spinner3:SetTargetSpeed(14)
		self.Spinners.Spinner4:SetTargetSpeed(14)
		self.Spinners.Spinner5:SetTargetSpeed(14)
		self.Spinners.Spinner6:SetTargetSpeed(14)

		-- Clear any teleport spot effects
		for kData, vData in self.TeleportUnitSpotEffects do
			for kEffect, vEffect in vData.Effects do
				vEffect:Destroy()
			end
		end

		self.TeleportUnitSpotEffects = {}
    end,

	OnAssignTeleportSpot = function(self,unitBeingTeleported,loadPosition)
		loadPosition[2] = loadPosition[2] + 0.2

		local teleportUnitEffect = {
			Unit = unitBeingTeleported,
			Effects = {}
		}

		local effectbps = {
			'/effects/emitters/units/illuminate/uix0113/event/select/uix0113_e_s_01_glow_emit.bp',
			'/effects/emitters/units/illuminate/uix0113/event/select/uix0113_e_s_02_groundring_emit.bp',
			'/effects/emitters/units/illuminate/uix0113/event/select/uix0113_e_s_03_symbol_emit.bp',
		}

		local army = self:GetArmy()
		for k, v in effectbps do
			table.insert( teleportUnitEffect.Effects, CreateEmitterPositionVector(loadPosition,Vector(0,0,0),army, v ))
		end

		table.insert( self.TeleportUnitSpotEffects, teleportUnitEffect )
	end,

	OnTeleporterReleaseUnit = function(self,unitBeingTeleported)
		for kData, vData in self.TeleportUnitSpotEffects do
			if vData.Unit == unitBeingTeleported then
				for kEffect, vEffect in vData.Effects do
					vEffect:Destroy()
				end
				self.TeleportUnitSpotEffects[kData] = nil
				return
			end
		end
	end,

	DeathThread = function(self)
        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()

        -- Create explosion effects
        for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death01 do
			CreateAttachedEmitter ( self, 'Effect07', self:GetArmy(), v ):ScaleEmitter(0.6)
		end
		
		for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0113.Deatht01 do
			CreateAttachedEmitter ( self, 'Effect08', self:GetArmy(), v )
		end
		
        WaitSeconds(0.75)
  
		for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death01 do
			CreateAttachedEmitter ( self, 'Effect04', self:GetArmy(), v ):ScaleEmitter(0.8)
		end
		
		WaitSeconds(0.2)
		self:CreateUnitDestructionDebris()
			        				
		WaitSeconds(0.4)
		for k, v in EffectTemplates.Explosions.Air.IlluminateDefaultDestroyEffectsAir02 do
			CreateAttachedEmitter ( self, 'Effect11', self:GetArmy(), v )
		end
		WaitSeconds(0.1)
		for k, v in EffectTemplates.Explosions.Air.IlluminateDefaultDestroyEffectsAir02 do
			CreateAttachedEmitter ( self, 'Effect13', self:GetArmy(), v )
		end

        WaitSeconds(0.8)
        
        -- Effects: large dust around unit
        -- Other: Damage force ring to force trees over and camera shake
        
		for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death01 do
			CreateAttachedEmitter ( self, 'Effect03', self:GetArmy(), v ):ScaleEmitter(1.3):OffsetEmitter( 0, 7, 0 )
		end
		
		for k, v in EffectTemplates.Explosions.Land.IlluminateStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(1.3)
		end
		
        self:ShakeCamera(20, 4, 1, 2.0)
        
		if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end
        
        self:CreateWreckage(0.1)
        
        local x, y, z = unpack(self:GetPosition())
        z = z + 3
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)
        WaitSeconds(0.2)
		
        -- Finish up force ring to push trees
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)
		
		WaitSeconds(0.9)
        self:ShakeCamera(2, 1, 0, 0.05)
        
        self:Destroy()
    end,

}
TypeClass = UIX0113