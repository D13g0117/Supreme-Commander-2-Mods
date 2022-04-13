-----------------------------------------------------------------------------
--  File     : /units/uef/uub0021/uub0021_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 UEF Build Scaffolding: UUB0021
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ScaffoldUnit = import('/lua/sim/ScaffoldUnit.lua').ScaffoldUnit
local Entity = import('/lua/sim/Entity.lua').Entity

UUB0021 = Class(ScaffoldUnit) {
	
	EffectAttachBones01 = {	
		'UUB0021_T01_Tower01',
		'UUB0021_T02_Tower01',
		'UUB0021_T03_Tower01',
		'UUB0021_T04_Tower01',
	},
	
	EffectAttachBones02 = {	
		'UUB0021_T01_Muzzle01',
		'UUB0021_T02_Muzzle01',
		'UUB0021_T03_Muzzle01',
		'UUB0021_T04_Muzzle01',
	},

	SliderBones = {
        'UUB0021_T01_Base01',
        'UUB0021_T01_Base02',
        'UUB0021_T02_Base01',
        'UUB0021_T02_Base02',
        'UUB0021_T03_Base01',
        'UUB0021_T03_Base02',
        'UUB0021_T04_Base01',
        'UUB0021_T04_Base02',
	},

	PodPairBones = {
		{	
			'UUB0021_T01_Pod01',
			'UUB0021_T03_Pod01',
		},
		{	
			'UUB0021_T04_Pod02',
			'UUB0021_T02_Pod02',
		},
		{	
			'UUB0021_T04_Pod01',
			'UUB0021_T02_Pod01',
		},
		{	
			'UUB0021_T01_Pod02',
			'UUB0021_T03_Pod02',
		},
		{	
			'UUB0021_T01_Base01',
			'UUB0021_T01_Pod01',
		},
		{	
			'UUB0021_T01_Base02',
			'UUB0021_T01_Pod02',
		},
		{	
			'UUB0021_T02_Base01',
			'UUB0021_T02_Pod01',
		},
		{	
			'UUB0021_T02_Base02',
			'UUB0021_T02_Pod02',
		},
		{	
			'UUB0021_T03_Base01',
			'UUB0021_T03_Pod01',
		},
		{	
			'UUB0021_T03_Base02',
			'UUB0021_T03_Pod02',
		},
		{	
			'UUB0021_T04_Base01',
			'UUB0021_T04_Pod01',
		},
		{	
			'UUB0021_T04_Base02',
			'UUB0021_T04_Pod02',
		},
	},

	TowerPairBones = {
		{	
			'UUB0021_T01_Tower01',
			'UUB0021_T01_Tower02',
		},
		{	
			'UUB0021_T02_Tower01',
			'UUB0021_T02_Tower02',
		},
		{	
			'UUB0021_T03_Tower01',
			'UUB0021_T03_Tower02',
		},
		{	
			'UUB0021_T04_Tower01',
			'UUB0021_T04_Tower02',
		},
	},
	
	OnCreate = function(self)
		ScaffoldUnit.OnCreate(self)
		self.BuildPhase = 1
		self.BuildPhaseEffects = {}
		self.BuildBeamsEffects = {}		
		self.BeamEndEntitiesTrash = TrashBag()
		self.Sliders = {}
		self.Emitters = {}
		self:SetCapturable(false)
	end,
	
	OnPaused = function(self)
		ScaffoldUnit.OnPaused(self)
		self:ClearAllEffects()
	end,
	
	OnUnpaused = function(self)
		ScaffoldUnit.OnUnpaused(self)
		self:RestartEffects()
	end,

	DeployScaffold = function( self, unitBeingBuilt )
		ScaffoldUnit.DeployScaffold( self, unitBeingBuilt )

		-- Set unit being built to use it's build textures
		if self.unitBeingBuilt:GetBlueprint().Build.UseBuildMaterial then
			self.unitBeingBuilt:SetTextureSetByName("Build")
		end
		
		-- Water Effects if being built on water
		if self:GetCurrentLayer() == 'Water' then
			local army = self:GetArmy()		
			for kEffect, vEffect in EffectTemplates.WaterScaffoldingBuildEffects01 do
				CreateAttachedEmitter( self, -2, army, vEffect ):ScaleEmitter(self.EffectScale)
			end			
		end
	end,

	CreateRailBeamEffects = function(self)
		local army = self:GetArmy()

		for k, v in self.PodPairBones do
			table.insert( self.Emitters, CreateAttachedEmitter( self, v[1], army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_04_glow_emit.bp' ):ScaleEmitter(self.EffectScale) )
			table.insert( self.Emitters, CreateAttachedEmitter( self, v[2], army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_04_glow_emit.bp' ):ScaleEmitter(self.EffectScale) )
			table.insert( self.Emitters, AttachBeamEntityToEntity( self, v[1], self, v[2], army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_05_beam_emit.bp' ) )
		end
		
		for k, v in self.TowerPairBones do
			table.insert( self.Emitters, AttachBeamEntityToEntity( self, v[1], self, v[2], army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_12_beamtower_emit.bp' ) )
			table.insert( self.Emitters, AttachBeamEntityToEntity( self, v[1], self, v[2], army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_05_beam_emit.bp' ) )
		end

		for kEffect, vEffect in EffectTemplates.UEFScaffoldingEffects01 do
			for kBone, vBone in self.EffectAttachBones01 do
				CreateAttachedEmitter( self, vBone, self:GetArmy(), vEffect ):ScaleEmitter(self.EffectScale)
			end
		end
	end,

	BuildPhase01 = function(self)
		--LOG( 'BuildPhase01' )
		local buildProgress = self.unitBeingBuilt:GetFractionComplete()	
		local distance = 50	

		self:CreateRailBeamEffects()
				
		for k, v in self.SliderBones do
			local slider = CreateSlider( self, v )
			slider:SetSpeed(5)
			table.insert( self.Sliders, slider )
			self.Trash:Add(slider)
		end

		-- While building slide the brackets up to the top of the scaffold.
		while buildProgress < 0.25 do
			WaitSeconds( 0.1 )
			buildProgress = self.unitBeingBuilt:GetFractionComplete()

			for k, v in self.Sliders do
				 v:SetGoal(0, distance * buildProgress * 2, 0  )
			end
		end
			
		self:SendAnimEvent( 'SetLooping', 'false' )
		self:ClearBuildPhaseEffects()
		self.tt1 = nil
	end,

	BuildPhase02 = function(self)
		--LOG( 'BuildPhase02' )
		local buildProgress = self.unitBeingBuilt:GetFractionComplete()	
		local army = self:GetArmy()	
		local distance = 50	

		-- Create phase 2 effects, welding and sparks		
		for kEffect, vEffect in EffectTemplates.UEFScaffoldingEffects02 do
			for kBone, vBone in self.EffectAttachBones01 do
				CreateAttachedEmitter( self, vBone, army, vEffect ):ScaleEmitter(self.EffectScale)
			end	
		end

		for k, v in self.Sliders do
			 v:SetSpeed(2)
		end

		while buildProgress < 0.5 do
			WaitSeconds( 0.1 )
			buildProgress = self.unitBeingBuilt:GetFractionComplete()

			for k, v in self.Sliders do
				 v:SetGoal(0, distance * buildProgress * 2, 0  )
			end
		end

		self:BuildPhase03()
	end,

	AdvanceToPhase03 = function(self)
		--LOG( 'AdvanceToPhase03' )
		self:SendAnimEvent('play_build_transition_01')
		self:CreateRailBeamEffects()
		local distance = 50	
		for k, v in self.SliderBones do
			local slider = CreateSlider( self, v )
			slider:SetSpeed(30):SetGoal(0, 50, 0  )
			table.insert( self.Sliders, slider )
			self.Trash:Add(slider)
		end	

		self:BuildPhase03()
	end,

	BuildPhase03 = function(self)
		--LOG( 'BuildPhase03' )
		while self.unitBeingBuilt:GetFractionComplete() < 0.75 do
			WaitSeconds( 0.1 )
		end

		for k, v in self.Emitters do
			v:Destroy()
		end
		self.Emitters = {}
		
		self:SendAnimEvent( 'SetLooping', 'false' )
		self:ClearBuildPhaseEffects()
		self.tt1 = nil
	end,
	
	CreateSteamEffects = function(self)
		local army = self:GetArmy()	
		for kEffect, vEffect in EffectTemplates.UEFScaffoldingEffects06 do
			for kBone, vBone in self.EffectAttachBones02 do
				table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, vBone, army, vEffect ):ScaleEmitter(self.EffectScale) )
			end	
		end
		for k, v in EffectTemplates.UEFScaffoldingEffects03 do
			for kBone, vBone in self.EffectAttachBones01 do
				table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, vBone, army, v ):ScaleEmitter(self.EffectScale) )
			end	
		end
		for k, v in EffectTemplates.UEFScaffoldingEffects07 do
			CreateAttachedEmitter( self, -2, army, v ):ScaleEmitter(self.EffectScale)
		end
	end,

	BuildPhase04 = function(self)
		--LOG( 'BuildPhase04' )

		self.FinalPhase = true

		-- Create phase 4 effects, water and steam
		self:CreateSteamEffects()
		
		self:RetractSliders()

		while not self:BeenDestroyed() and not self.unitBeingBuilt:BeenDestroyed() and self.unitBeingBuilt:GetFractionComplete() < 1.0 do
			WaitSeconds(1)
		end

		self:ClearBuildPhaseEffects()
		self:SendAnimEvent( 'SetLooping', 'false' )
		self.tt1 = nil
	end,

	BuildBeamsThread = function( self )
		local army = self:GetArmy()
		local ox, oy, oz = unpack(self.unitBeingBuilt:GetPosition())
		local BeamEndEntities = {}

		if self.EffectAttachBones02 then
			for i, BuildBone in self.EffectAttachBones02 do
				local beamEnd = Entity()
				self.Trash:Add(beamEnd)
				self.BeamEndEntitiesTrash:Add(beamEnd)
				table.insert( BeamEndEntities, beamEnd )
				table.insert( self.BuildBeamsEffects, beamEnd )
				Warp( beamEnd, Vector(ox, oy, oz))
	            
				CreateEmitterOnEntity( beamEnd, army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_15_weldglow_emit.bp' ):ScaleEmitter(self.EffectScale)
				CreateEmitterOnEntity( beamEnd, army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_06_fire_emit.bp' ):ScaleEmitter(self.EffectScale)
				CreateEmitterOnEntity( beamEnd, army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_03_sparks_emit.bp' ):ScaleEmitter(self.EffectScale)
				CreateEmitterOnEntity( beamEnd, army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_18_bluesparks_emit.bp' ):ScaleEmitter(self.EffectScale)

				local emit = AttachBeamEntityToEntity(self, BuildBone, beamEnd, -1, army, '/effects/emitters/units/uef/uub0021/event/build/uub0021_e_b_14_weldbeam_emit.bp'):ScaleEmitter(self.EffectScale)	            
	            
	            for kEffect, vEffect in EffectTemplates.UEFScaffoldingEffects04 do
					for kBone, vBone in self.EffectAttachBones02 do
						table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, vBone, army, vEffect ):ScaleEmitter(self.EffectScale) )
					end	
				end

				for k, v in EffectTemplates.UEFScaffoldingEffects05 do
					table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, -2, army, v ):ScaleEmitter(self.EffectScale) )
				end
			
	            table.insert( self.BuildBeamsEffects, emit )
			end
		end

		while not self:BeenDestroyed() and not self.unitBeingBuilt:BeenDestroyed() and self.unitBeingBuilt:GetFractionComplete() < 0.75 do
			for k, v in BeamEndEntities do
				local x, y, z = self.GetRandomOffset(self.unitBeingBuilt, 1 )
				if v and not v:BeenDestroyed() and not self.IsPaused then
					Warp( v, Vector(ox + x, oy + y, oz + z))
				end
			end
			WaitSeconds(1)
		end	
		
		self:ClearBuildBeams()
		self.tt2 = nil
	end,

	RetractSliders = function(self)
		for k, v in self.Sliders do
			v:SetGoal(0, 0, 0)
			v:SetSpeed(8)
		end
	end,

	ClearBuildBeams = function(self)
		for k, v in self.BuildBeamsEffects do
			v:Destroy()
		end
		if self.BeamEndEntitiesTrash then
			self.BeamEndEntitiesTrash:Destroy()
		end	
		self.BuildBeamsEffects = {}		
	end,

	ClearBuildPhaseEffects = function(self)
		-- Destroy all intermediary effects
		for k, v in self.BuildPhaseEffects do
			v:Destroy()
		end
		self.BuildPhaseEffects = {}	
	end,
	
	ClearAllEffects = function(self)
		self:ClearBuildBeams()
		self:ClearBuildPhaseEffects()
		if self.tt2 then
			KillThread( self.tt2 )
		end
		for k, v in self.Emitters do
			v:Destroy()
		end
		self.Emitters = {}
	end,
	
	RestartEffects = function(self)
		if self.BuildPhase == 1 then
			self:CreateRailBeamEffects()
		elseif self.BuildPhase == 2 then
			self:CreateRailBeamEffects()
			self.tt2 = self:ForkThread( self.BuildBeamsThread )
		elseif self.BuildPhase == 3 then
			self:CreateSteamEffects()
		end
	end,
	
	OnAnimStartTrigger = function( self, event )

		if not self.ForceCompleted then
			if event == 'play_build_loop_phase_01' then
				-- A structure can be rebuilt on top of other wreckage. If it is, the structure
				-- starts off at 50% of its build progress, so we need to advance the build 
				-- scaffolding to the 50% mark.
				local buildProgress = self.unitBeingBuilt:GetFractionComplete()	
				if buildProgress < 0.5 then
					self:PlayUnitAmbientSound('BuildPhase01')
					self.tt1 = self:ForkThread(self.BuildPhase01)
				else
					self.Advancing = true
					self.tt1 = self:ForkThread(self.AdvanceToPhase03)
				end

			elseif event == 'play_build_loop_phase_02' then
				self.BuildPhase = 2
				if not self.Advancing then
					self.tt1 = self:ForkThread(self.BuildPhase02)
				end
				self.tt2 = self:ForkThread( self.BuildBeamsThread )

			elseif event == 'play_build_loop_phase_03' then
				self.BuildPhase = 3
				self.tt1 = self:ForkThread(self.BuildPhase04)

			elseif event == 'play_build_transition_01' then
				-- Stop phase 1 looping sound and start phase 2 looping sound
				self:StopUnitAmbientSound('BuildPhase01')
				self:PlayUnitAmbientSound('BuildPhase02')
			
			elseif event == 'play_build_transition_02' then
				-- Stop phase 2 looping sound and start phase 3 looping sound
				self:StopUnitAmbientSound('BuildPhase02')
				self:PlayUnitAmbientSound('BuildPhase03')
			end
		end

		if event == 'play_pack' then
			-- Create ending effects, smoke, stop ambient sounds and play pack up sound.
			local army = self:GetArmy()
			for k, v in EffectTemplates.UEFScaffoldingEffects08 do
				CreateAttachedEmitter( self, -2, army, v ):ScaleEmitter(self.EffectScale)
			end
			self:StopUnitAmbientSound('BuildPhase03')
			self:PlayUnitSound('Pack')
		end
	end,

	OnAnimEndTrigger = function( self, event )
		if event == 'pack' then
			self:Destroy()
		end
	end,

	BuildUnitComplete = function(self)
		if not self.FinalPhase then
			self:ForkThread( self.ForceComplete )
		end
	end,

	ForceComplete = function( self )
		--LOG('ForceComplete')
		self.ForceCompleted = true

		if self.tt1 then
			KillThread( self.tt1 )
		end
		if self.tt2 then
			KillThread( self.tt2 )
		end

		WaitSeconds(1)

		self:SendAnimEvent( 'SetLooping', 'false' )
		self:ClearBuildBeams()
		self:ClearBuildPhaseEffects()
		self:RetractSliders()

		WaitSeconds(1)
		self:SendAnimEvent( 'play_pack' )
	end,
}
TypeClass = UUB0021