-----------------------------------------------------------------------------
--  File     : /units/cybran/ucb0028/ucb0028_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Cybran Build Scaffolding: UCB0028
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ScaffoldUnit = import('/lua/sim/ScaffoldUnit.lua').ScaffoldUnit

UCB0028 = Class(ScaffoldUnit) {

	EffectAttachBones01 = {
		'UCB0028_T01_B01_Muzzle01',
		'UCB0028_T02_B01_Muzzle01',
		'UCB0028_T03_B01_Muzzle01',
		'UCB0028_T04_B01_Muzzle01',
		'UCB0028_T05_B01_Muzzle01',
		'UCB0028_T06_B01_Muzzle01',
	},
	
	EffectAttachBones02 = {
		'UCB0028_buildpoint01',
		'UCB0028_buildpoint02',
		'UCB0028_buildpoint03',
		'UCB0028_buildpoint04',
		'UCB0028_buildpoint05',
		'UCB0028_buildpoint06',
	},

	BotSpawnPoints = {
		'UCB0028_botEmitter01',
		'UCB0028_botEmitter02',
		'UCB0028_botEmitter03',
		'UCB0028_botEmitter04',
		'UCB0028_botEmitter05',
		'UCB0028_botEmitter06',
	},
	
	OnCreate = function(self)
		ScaffoldUnit.OnCreate(self)
		self.BuildPhase = 1
		self.BuildLatticeProjectiles = {}
		self.BuildPhaseEffects = {}
		self.BuildBots = {}
		table.resizeandclear(self.BuildBots, self.BotSpawnPoints)
		
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
		self:SetupBuiltUnitInitialState()
	end,

	SetupBuiltUnitInitialState = function(self)
		-- Set unit being built to use it's build textures
		if self.unitBeingBuilt:GetBlueprint().Build.UseBuildMaterial then
			self.unitBeingBuilt:SetTextureSetByName("Build")
		end

		-- Make the unit invisible for now
		self.unitBeingBuilt:HideMesh()

		-- Offset the unit below ground 
		local ubbBuildBP = self.unitBeingBuilt:GetBlueprint().Build
		local slideY = 0
		local slideZ = 0
        local slideX = 0
		if ubbBuildBP.BuildSliderY then 
			slideY = ubbBuildBP.BuildSliderY 
		end
		
		if ubbBuildBP.BuildSliderZ then
			slideZ = ubbBuildBP.BuildSliderZ
		end
        
		if ubbBuildBP.BuildSliderX then
			slideX = ubbBuildBP.BuildSliderX
		end

		if slideY != 0 and slideZ != 0 then
			WARN( 'UCB0028 Build scaffolding for unit ', self.unitBeingBuilt:GetUnitId(),  ' has build X and Z slide values set, which will have visible artifacts. Fix unit bp definition.' )
		end

		self.BeingBuiltSlider = CreateSlider( self.unitBeingBuilt, ubbBuildBP.BuildSliderBone or 0, slideX, slideY, slideZ, 100, true )
	end,

	CreateAmbientEnergy = function(self)
		local army = self:GetArmy()
		
		-- base ring effect
		for kEffect, vEffect in EffectTemplates.CybranScaffoldingEffects05 do
			table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, -2, army, vEffect ):ScaleEmitter(self.EffectScale) )
		end
		-- base electricity
		for kEffect, vEffect in EffectTemplates.CybranScaffoldingEffects06 do
			for kBone, vBone in self.EffectAttachBones02 do
				table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, vBone, army, vEffect ):ScaleEmitter(self.EffectScale) )
			end
		end
		-- Water Effects if being built on water
		if self:GetCurrentLayer() == 'Water' then
			for kEffect, vEffect in EffectTemplates.WaterScaffoldingBuildEffects01 do
				CreateAttachedEmitter( self, -2, army, vEffect ):ScaleEmitter(self.EffectScale)
			end			
		end
	end,

	BuildPhase01 = function(self)
		--LOG( 'BuildPhase01' )
		local buildProgress = self.unitBeingBuilt:GetFractionComplete()	

		-- Create the build lattice beams and ambient energy effects
		self:CreateLatticeBeams()
		self:CreateAmbientEnergy()
		
		while buildProgress < 0.25 do
			WaitSeconds( 0.1 )
			buildProgress = self.unitBeingBuilt:GetFractionComplete()
		end

		self:SendAnimEvent('play_open_doors')
		self:PlayUnitSound('BuildOpen')
		self.tt1 = nil
	end,

	BuildPhase02 = function(self)
		--LOG( 'BuildPhase02' )
		local buildProgress = self.unitBeingBuilt:GetFractionComplete()	

		self:SpawnBuildBots()
		if not self.Advancing then
			WaitSeconds( 1.0 )
		end

		self:SendAnimEvent('play_close_doors')
		self:PlayUnitSound('BuildClose')

		while buildProgress < 0.5 do
			WaitSeconds( 0.1 )
			buildProgress = self.unitBeingBuilt:GetFractionComplete()
		end

		for kEffect, vEffect in EffectTemplates.CybranScaffoldingEffects08 do
			table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, -2, self:GetArmy(), vEffect ):ScaleEmitter(self.EffectScale))
		end
		
		self:SendAnimEvent('play_build_loop')
		self:PlayUnitAmbientSound('BuildLoop')
		self:StartBuildArmBeams()
		self:BuildPhase03()
	end,

	AdvanceToPhase03 = function(self)
		--LOG( 'AdvanceToPhase03' )
		self:CreateLatticeBeams()
		self:CreateAmbientEnergy()
		self:SendAnimEvent('play_open_doors')
		self:PlayUnitSound('BuildOpen')
		self.tt1 = nil
	end,

	BuildPhase03 = function(self)
		--LOG( 'BuildPhase03' )
		local buildProgress = self.unitBeingBuilt:GetFractionComplete()	
		self.FinalPhase = true

		while buildProgress < 1.0 do
			WaitSeconds( 0.1 )
			buildProgress = self.unitBeingBuilt:GetFractionComplete()
		end

		self:SendAnimEvent( 'SetLooping', 'false' )
		self.tt1 = nil
	end,

	CreateLatticeBeams = function( self, bone )
		local unitPos = self:GetPosition()

		for k, v in self:GetBlueprint().Display.BuildPointBones do
			local BeamEndEntity = self:CreateProjectile('/projectiles/cybran/cbuild01/cbuild01_proj.bp',0,0,0,nil,nil,nil)
			local bonePos = self:GetPosition(v)
			Warp( BeamEndEntity, bonePos )
			local direction = VDiff( bonePos, unitPos )
			direction = VNormal( direction )
			BeamEndEntity:SetVelocity( direction[1], 0, direction[3] )
			BeamEndEntity:SetVelocity( 2 )
			BeamEndEntity:SetInitialVector( direction )

			table.insert( self.BuildLatticeProjectiles, BeamEndEntity )

			BeamEndEntity = self:CreateProjectile('/projectiles/cybran/cbuild01/cbuild01_proj.bp',0,0,0,nil,nil,nil)
			Warp( BeamEndEntity, bonePos )
			BeamEndEntity:SetVelocity( direction[1], 0, direction[3] )
			BeamEndEntity:SetVelocity( 5 )
			BeamEndEntity:SetInitialVector( direction )

			table.insert( self.BuildLatticeProjectiles, BeamEndEntity )
		end
	end,

	CleanupLatticeBeams = function(self)
		for k, v in self.BuildLatticeProjectiles do
			v:Destroy()
		end
		self.BuildLatticeProjectiles = {}
	end,

	SpawnBuildBots = function( self )
		local army = self:GetArmy()
		local numBots = table.getn(self.BotSpawnPoints)
		
		for i = 1, numBots do
			local x, y, z = unpack(self:GetPosition(self.BotSpawnPoints[i]))
			local qx, qy, qz, qw = unpack(self:GetOrientation())
			local droneUnit = CreateUnit( 'uca0021', army, x, y + 1, z, qx, qy, qz, qw, 'Air' )
			self.BuildBots[i] = droneUnit 
		end

		for kEffect, vEffect in EffectTemplates.CybranScaffoldingEffects01 do
			for kBone, vBone in self.BotSpawnPoints do
				CreateAttachedEmitter( self, vBone, self:GetArmy(), vEffect ):ScaleEmitter(self.EffectScale)
			end
		end
		
		IssueGuard( self.BuildBots, self.unitBeingBuilt )
	end,
	
	DestroyBuildBots = function( self )
		local numBots = table.getn(self.BuildBots)
		for i = 1, numBots do
			local bot = self.BuildBots[i]
			if bot and not bot:IsDead() then
				bot:Destroy()
			end
			self.BuildBots[i] = nil			
		end
		
		self.BuildBots = {}
	end,

	SliderThread = function( self, depth )
		local BuildBp = self.unitBeingBuilt:GetBlueprint().Build
		local buildProgress = self.unitBeingBuilt:GetFractionComplete()	
		self.unitBeingBuilt:ShowMesh()
		self.BeingBuiltSlider:SetSpeed( 0.5 )

		for kEffect, vEffect in EffectTemplates.CybranScaffoldingEffects04 do
			table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, -2, self:GetArmy(), vEffect ):ScaleEmitter(self.EffectScale) )
		end
		
		local depth = 0
		if BuildBp.BuildSliderY then
			depth = BuildBp.BuildSliderY
			while buildProgress < 0.75 do
				WaitSeconds( 0.1 )
				buildProgress = self.unitBeingBuilt:GetFractionComplete()
				self.BeingBuiltSlider:SetGoal( 0, depth + ((buildProgress - 0.25) * -depth * 2), 0 ) 
			end
		elseif BuildBp.BuildSliderZ then
			depth = BuildBp.BuildSliderZ
			while buildProgress < 0.75 do
				WaitSeconds( 0.1 )
				buildProgress = self.unitBeingBuilt:GetFractionComplete()
				self.BeingBuiltSlider:SetGoal( 0, 0, depth + ((buildProgress - 0.25) * -depth * 2) ) 
			end
		elseif BuildBp.BuildSliderX then
			depth = BuildBp.BuildSliderX
			while buildProgress < 0.75 do
				WaitSeconds( 0.1 )
				buildProgress = self.unitBeingBuilt:GetFractionComplete()
				self.BeingBuiltSlider:SetGoal( depth + ((buildProgress - 0.25) * -depth * 2), 0, 0 ) 
			end
		end

		self.BeingBuiltSlider:Destroy()
	end,

	StartBuildArmBeams = function(self)
		self:ForkThread( CreateCybranBuildBeams, self.unitBeingBuilt, {'UCB0028_T01_B01_Muzzle01',}, self.BuildEffectsBag )
		self:ForkThread( CreateCybranBuildBeams, self.unitBeingBuilt, {'UCB0028_T02_B01_Muzzle01',}, self.BuildEffectsBag )
		self:ForkThread( CreateCybranBuildBeams, self.unitBeingBuilt, {'UCB0028_T03_B01_Muzzle01',}, self.BuildEffectsBag )
		self:ForkThread( CreateCybranBuildBeams, self.unitBeingBuilt, {'UCB0028_T04_B01_Muzzle01',}, self.BuildEffectsBag )
		self:ForkThread( CreateCybranBuildBeams, self.unitBeingBuilt, {'UCB0028_T05_B01_Muzzle01',}, self.BuildEffectsBag )
		self:ForkThread( CreateCybranBuildBeams, self.unitBeingBuilt, {'UCB0028_T06_B01_Muzzle01',}, self.BuildEffectsBag )
	
		for kEffect, vEffect in EffectTemplates.CybranScaffoldingEffects02 do
			for kBone, vBone in self.EffectAttachBones01 do
				table.insert( self.BuildPhaseEffects, CreateAttachedEmitter( self, vBone, self:GetArmy(), vEffect ):ScaleEmitter(self.EffectScale) )
			end	
		end
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
		self.BuildEffectsBag:Destroy()
		if self.BuildPhase == 2 then
			self:DestroyBuildBots()
		end
	end,
	
	RestartEffects = function(self)
		if self.BuildPhase == 1 then
			self:CreateAmbientEnergy()
		elseif self.BuildPhase == 2 then
			-- Just in case they are still around
			self:DestroyBuildBots()
			self:CreateAmbientEnergy()
			self:StartBuildArmBeams()
			self:SpawnBuildBots()
		end
	end,

	OnAnimStartTrigger = function( self, event )
		if event == 'play_pack' then
			for kEffect, vEffect in EffectTemplates.CybranScaffoldingEffects07 do
				CreateAttachedEmitter( self, -2, self:GetArmy(), vEffect ):ScaleEmitter(self.EffectScale)
			end
			local x, y, z = unpack(self:GetPosition())
			local pos = VECTOR3( x, y + 10, z )
			CreateLight( pos[1], pos[2], pos[3], 0, 0, 0, 15, 2, 0.1, 1, 2 )
			
			self:StopUnitAmbientSound('BuildLoop')
			self:PlayUnitSound('Pack')

			self:CleanupLatticeBeams()
			self.BuildEffectsBag:Destroy()
		end
	end,

	OnAnimEndTrigger = function( self, event )
		--LOG( 'OnAnimEndTrigger', event )
		if event == 'play_deploy' then
			-- A structure can be rebuilt on top of other wreckage. If it is, the structure
			-- starts off at 50% of its build progress, so we need to advance the build 
			-- scaffolding to the 50% mark.
			local buildProgress = self.unitBeingBuilt:GetFractionComplete()	
			if buildProgress < 0.5 then
				self.tt1 = self:ForkThread(self.BuildPhase01)
			else
				self.Advancing = true
				self.tt1 = self:ForkThread(self.AdvanceToPhase03)
			end
		elseif event == 'play_open' then
			if self.BuildPhase < 2 then
				self.BuildPhase = 2
				self.tt1 = self:ForkThread(self.BuildPhase02)
				self.tt2 = self:ForkThread(self.SliderThread)
			end
		elseif event == 'play_pack' then
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

		WaitSeconds(1)
		self:SendAnimEvent( 'play_pack' )
	end,

	OnDestroy = function(self)
		self:CleanupLatticeBeams()
		self:DestroyBuildBots()
		ScaffoldUnit.OnDestroy(self)
	end,
}
TypeClass = UCB0028