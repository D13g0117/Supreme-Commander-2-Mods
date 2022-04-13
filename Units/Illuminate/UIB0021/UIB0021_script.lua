-----------------------------------------------------------------------------
--  File     : /units/illuminate/uib0021/uib0021_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Illuminate Build Scaffolding: UIB0021
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ScaffoldUnit = import('/lua/sim/ScaffoldUnit.lua').ScaffoldUnit
local Entity = import('/lua/sim/Entity.lua').Entity

UIB0021 = Class(ScaffoldUnit) {

	BeamAttachBones = { 
		'UIB0021_B01_Antenna01',
		'UIB0021_B02_Antenna01',
		'UIB0021_B03_Antenna01', 
		'UIB0021_B04_Antenna01',		
		'UIB0021_B05_Antenna01', 
		'UIB0021_B06_Antenna01',		
		'UIB0021_B07_Antenna01', 
		'UIB0021_B08_Antenna01',	
	},	

	EffectAttachBones = {	
		'UIB0021_Blade01',
		'UIB0021_Blade02',
		'UIB0021_Blade03',
		'UIB0021_Blade04',
		'UIB0021_Blade05',
		'UIB0021_Blade06',
		'UIB0021_Blade07',
		'UIB0021_Blade08',
	},
	
	OnCreate = function(self)
		ScaffoldUnit.OnCreate(self)
		self.BuildPhase = 1
		self.BuildPhaseEffects = {}
		self.SphereEntity = nil
		self.SphereLight = nil
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

	OnDestroy = function(self)
		ScaffoldUnit.OnDestroy(self)
		if self.SphereLight then
			DestroyLight( self.SphereLight ) 
			self.SphereLight = nil
		end
	end,

	DeployScaffold = function( self, unitBeingBuilt )
		ScaffoldUnit.DeployScaffold( self, unitBeingBuilt )
		self:SetupBuiltUnitInitialState()
		local army = self:GetArmy()
		
		-- Water Effects if being built on water
		if self:GetCurrentLayer() == 'Water' then
			for kEffect, vEffect in EffectTemplates.WaterScaffoldingBuildEffects01 do
				CreateAttachedEmitter( self, -2, army, vEffect ):ScaleEmitter(self.EffectScale)
			end			
		end
	end,

	SetupBuiltUnitInitialState = function(self)
		-- Set unit being built to use it's build textures
		if self.unitBeingBuilt:GetBlueprint().Build.UseBuildMaterial then
			self.unitBeingBuilt:SetTextureSetByName("Build")
		end

		self.unitBeingBuilt:HideMesh()
	end,
	
	CreatePhase1Effects = function(self)
		if self.SphereEntity then
			local army = self:GetArmy()
			for k, v in self.BeamAttachBones do
				table.insert( self.BuildPhaseEffects, AttachBeamEntityToEntity( self, v, self.SphereEntity, -1, army, '/effects/emitters/units/illuminate/uib0021/event/build/illuminate_uib0021_11_build_beam_emit.bp' ):ScaleEmitter(self.EffectScale) )
			end
		end
	end,
	
	BuildPhase01 = function(self)
		--LOG('BuildPhase01')
		local x, y, z = unpack(self:GetPosition())
		local bp = self:GetBlueprint().Display
		local army = self:GetArmy()		
		local pos = VECTOR3( x, y + bp.BuildEffectSphereHeight, z )
		local buildProgress = self.unitBeingBuilt:GetFractionComplete()	
		local sphereSize = bp.BuildEffectSphereScale or 1

		for k, v in EffectTemplates.IlluminateScaffoldingEffects01 do
            CreateAttachedEmitter( self, 'UIB0021_SpinnerCenter', army, v ):ScaleEmitter(self.EffectScale)
        end
        
        for k, v in EffectTemplates.IlluminateScaffoldingEffects02 do
           CreateAttachedEmitter( self, 'UIB0021_buildPoint01', army, v ):ScaleEmitter(self.EffectScale)
           CreateAttachedEmitter( self, 'UIB0021_buildPoint02', army, v ):ScaleEmitter(self.EffectScale)
           CreateAttachedEmitter( self, 'UIB0021_buildPoint03', army, v ):ScaleEmitter(self.EffectScale)
           CreateAttachedEmitter( self, 'UIB0021_buildPoint04', army, v ):ScaleEmitter(self.EffectScale)
        end

		-- Create our sphere entity
		self.SphereEntity = Entity({Owner = self})
		self.Trash:Add(self.SphereEntity)
		Warp( self.SphereEntity, pos )
		self.SphereEntity:SetMesh( '/effects/entities/illuminatebuildsphere01/illuminatebuildsphere01_mesh' )
        self.SphereLight = CreateAttachLight( self, 'UIB0021_SpinnerCenter', sphereSize, 6, 0.1, -1, 0 )

		-- Create beams from pods and make them zap the sphere! Destroyed on the next anim event that
		-- triggers the next build phase.  		
		self:CreatePhase1Effects()

		local scaleMul = bp.BuildSphereScaleMul02
		-- While building during the first 25% of the build phase, scale the sphere up!
		while buildProgress < 0.25 do
			WaitSeconds( 0.1 )
			self.SphereEntity:SetScale( 1 + buildProgress * scaleMul )
			buildProgress = self.unitBeingBuilt:GetFractionComplete()
		end

		-- Shockwave Effect
		for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death01 do
			CreateAttachedEmitter ( self, 'UIB0021_SpinnerCenter', army, v ):ScaleEmitter(self.EffectScale)
		end
		
		self.unitBeingBuilt:ShowMesh()
		DestroyLight(self.SphereLight)
		self.SphereLight = nil
		self.SphereEntity:Destroy()
		self.SphereEntity = nil

		-- Transition to the next build stage
		self:SendAnimEvent( 'SetLooping', 'false' )
		
		self:ClearBuildPhaseEffects()
		self.tt1 = nil
	end,
	
	CreatePhase2Effects = function(self)
		local army = self:GetArmy()
		
		for kEffect, vEffect in EffectTemplates.IlluminateScaffoldingEffects06 do
			for kBone, vBone in self.EffectAttachBones do
				table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, vBone, army, vEffect ):ScaleEmitter(self.EffectScale))
			end
			for k, v in EffectTemplates.IlluminateScaffoldingEffects07 do
				CreateAttachedEmitter( self, 'UIB0021_SpinnerCenter', army, v ):ScaleEmitter(self.EffectScale)
			end
		end
		for k, v in EffectTemplates.IlluminateScaffoldingEffects03 do
			table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, 'UIB0021_SpinnerCenter', army, v ) :ScaleEmitter(self.EffectScale))
		end
	end,

	BuildPhase02 = function(self)
		--LOG('BuildPhase02')
		self:CreatePhase2Effects()

		while self.unitBeingBuilt:GetFractionComplete() < 0.75 do
			WaitSeconds( 0.1 )
		end

		-- Transition to the next build stage
		self:SendAnimEvent( 'SetLooping', 'false' )
		self.tt1 = nil
	end,

	AdvanceToPhase02 = function(self)
		--LOG('AdvanceToPhase02')
		local army = self:GetArmy()	

		self.unitBeingBuilt:ShowMesh()
		self:SendAnimEvent( 'SetLooping', 'false' )

		-- Shockwave Effect
		for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death01 do
			CreateAttachedEmitter ( self, 'UIB0021_SpinnerCenter', army, v ):ScaleEmitter(self.EffectScale)
		end

		for kEffect, vEffect in EffectTemplates.IlluminateScaffoldingEffects06 do
			for kBone, vBone in self.EffectAttachBones do
				table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, vBone, army, vEffect ):ScaleEmitter(self.EffectScale))
			end
			for k, v in EffectTemplates.IlluminateScaffoldingEffects07 do
				CreateAttachedEmitter( self, 'UIB0021_SpinnerCenter', army, v ):ScaleEmitter(self.EffectScale)
			end
		end
		for k, v in EffectTemplates.IlluminateScaffoldingEffects03 do
			table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, 'UIB0021_SpinnerCenter', army, v ) :ScaleEmitter(self.EffectScale))
		end

		WaitSeconds( 0.1 )

		-- Transition to the next build stage
		self:ClearBuildPhaseEffects()
		self:SendAnimEvent( 'SetLooping', 'false' )
		self.tt1 = nil
	end,

	CreatePhase3Effects = function(self)
		local army = self:GetArmy()		
		self.FinalPhase = true

		for k, v in EffectTemplates.IlluminateScaffoldingEffects04 do
			table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, 'UIB0021_SpinnerCenter', army, v ):ScaleEmitter(self.EffectScale) )
		end
		for kEffect, vEffect in EffectTemplates.IlluminateScaffoldingEffects02 do
			for kBone, vBone in self.EffectAttachBones do
				table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, vBone, army, vEffect ):ScaleEmitter(self.EffectScale) )
			end
			for k, v in EffectTemplates.IlluminateScaffoldingEffects08 do
				table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, 'UIB0021_SpinnerCenter', army, v ):ScaleEmitter(self.EffectScale) )
			end
		end
	end,

	BuildPhase03 = function(self)
		--LOG('BuildPhase03')
		self:CreatePhase3Effects()
		
		while self.unitBeingBuilt:GetFractionComplete() < 1.0 do
			WaitSeconds( 0.1 )
		end

		-- Transition to the next build stage
		self:SendAnimEvent( 'SetLooping', 'false' )
		self.tt1 = nil
	end,

	ClearBuildPhaseEffects = function(self)
		-- Destroy all intermediary effects
		for k, v in self.BuildPhaseEffects do
			v:Destroy()
		end
		self.BuildPhaseEffects = {}	
	end,
	
	ClearAllEffects = function(self)
		self:ClearBuildPhaseEffects()
	end,
	
	RestartEffects = function(self)
		if self.BuildPhase == 1 then
			self:CreatePhase1Effects()
		elseif self.BuildPhase == 2 then
			self:CreatePhase2Effects()
		elseif self.BuildPhase == 3 then
			self:CreatePhase3Effects()
		end
	end,

	OnAnimStartTrigger = function( self, event )
		local army = self:GetArmy()	
		
		if event == 'play_build_loop_phase_01' then
			local buildProgress = self.unitBeingBuilt:GetFractionComplete()	
			if buildProgress < 0.5 then
				self.tt1 = self:ForkThread(self.BuildPhase01)
			else
				self.Advancing = true
				self.tt1 = self:ForkThread(self.AdvanceToPhase02)
			end
			self:PlayUnitAmbientSound('BuildPhase01')
		elseif event == 'play_build_transition_01' then
			
			self:StopUnitAmbientSound('BuildPhase01')
			self:PlayUnitAmbientSound('BuildPhase02')

		elseif event == 'play_build_loop_phase_02' then
			if not self.ForceCompleted then
				self.tt1 = self:ForkThread(self.BuildPhase02)
			end
			self.BuildPhase = 2
		elseif event == 'play_build_transition_02' then
			self:ClearBuildPhaseEffects()
			
			self:StopUnitAmbientSound('BuildPhase02')
			self:PlayUnitAmbientSound('BuildPhase03')

		elseif event == 'play_build_loop_phase_03' then
			if not self.ForceCompleted then
				self.tt1 = self:ForkThread(self.BuildPhase03)
			end
			self.BuildPhase = 3
		elseif event == 'play_pack' then
			self:ClearBuildPhaseEffects()

			for k, v in EffectTemplates.IlluminateScaffoldingEffects05 do
				CreateAttachedEmitter( self, 'UIB0021_SpinnerCenter', army, v ):ScaleEmitter(self.EffectScale)
			end
			local x, y, z = unpack(self:GetPosition())
			local pos = VECTOR3( x, y + 10, z )
			CreateLight( pos[1], pos[2], pos[3], 0, -1, 0, 15, 6, 0.1, 2, 2.9 )

			self:StopUnitAmbientSound('BuildPhase03')
			self:PlayUnitSound('Pack')
		end
	end,
	
	OnAnimEndTrigger = function( self, event )
		if event == 'Pack' then
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

		WaitSeconds(1)

		self:SendAnimEvent( 'SetLooping', 'false' )

		WaitSeconds(1)
		self:SendAnimEvent( 'play_pack' )
	end,
}
TypeClass = UIB0021