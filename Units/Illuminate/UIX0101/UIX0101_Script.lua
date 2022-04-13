-----------------------------------------------------------------------------
--  File     : /units/illuminate/uix0101/uix0101_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate Experimental Assault Block: UIX0101
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local utilities = import('/lua/system/utilities.lua')
local GetRandomFloat = utilities.GetRandomFloat

UIX0101 = Class(ExperimentalMobileUnit)
{
    Weapons = {
        Laser01 = Class(DefaultProjectileWeapon) {},
        Laser02 = Class(DefaultProjectileWeapon) {},
        Laser03 = Class(DefaultProjectileWeapon) {},
        Artillery01 = Class(DefaultProjectileWeapon) {},
        Artillery02 = Class(DefaultProjectileWeapon) {
        	IdleState = State {
				OnGotTarget = function(self)
					self.unit.SpinnerTarget = true
					DefaultProjectileWeapon.IdleState.OnGotTarget(self)
				end,
			},
		},
    },
    
    EngineRotateBones = {'FootLF', 'FootLR', 'FootRF', 'FootRR'},

	OnStopBeingBuilt = function(self,builder,layer)
		ExperimentalMobileUnit.OnStopBeingBuilt(self,builder,layer)
        self.Spinners = {
            Spinner01 = CreateRotator(self, 'PowerRing01', 'x', nil, 0, 60, 360):SetTargetSpeed(-10),
            Spinner02 = CreateRotator(self, 'PowerRing02', 'x', nil, 0, 30, 360):SetTargetSpeed(-10),
        }
		self.Trash:Add(self.Spinner)
		self.SpinnerTarget = false
		self:ForkThread( self.SpinnerThread )
        
        self.EngineManipulators = {}

        -- create the engine thrust manipulators
        for key, value in self.EngineRotateBones do
            table.insert(self.EngineManipulators, CreateThrustController(self, 'Thruster', value))
        end

        -- set up the thursting arcs for the engines
        for key,value in self.EngineManipulators do
            --                          XMAX, XMIN, YMAX,YMIN, ZMAX,ZMIN, TURNMULT, TURNSPEED
            value:SetThrustingParam( -0.05, 0.05, -0.25, 0.25, 0, 0, 150, 0.01 )
        end

        for k, v in self.EngineManipulators do
            self.Trash:Add(v)
        end
        
        local sx, sy, sz = self:GetUnitSizes() 
        self.volume = (sx * sz) / 4
	end,

	SpinnerThread = function(self)
		while not self:IsDead() do
			if self.SpinnerTarget then
				self.Spinners.Spinner01:SetTargetSpeed(-150)
				self.Spinners.Spinner02:SetTargetSpeed(-150)
				self.SpinnerTarget = false
				WaitSeconds(5)
				self.Spinners.Spinner01:SetTargetSpeed(-10)
				self.Spinners.Spinner02:SetTargetSpeed(-10)
			else
				WaitSeconds(1)
			end
		end
	end,
    
    -- By default, just destroy us when we are killed.
    OnKilled = function(self, instigator, type, overkillRatio)
        self:DestroyIdleEffects()
        
        self:OnKilledVO()
        self.Callbacks.OnKilled:Call( self, instigator, type )        
        
        if instigator and IsUnit(instigator) then
            instigator:OnKilledUnit(self)
        end

		local bp = self:GetBlueprint().Death.ExplosionEffect
	    local ExplosionEffect = bp.Death.ExplosionEffect
	    
	    if ExplosionEffect then
			local layer = self:GetCurrentLayer()
			local emitters = EffectTemplates.Explosions[layer][ExplosionEffect]
			
			if emitters then
				CreateBoneEffects( self, -2, self:GetArmy(), emitters )
			end
		end
    end,

    OnImpact = function(self, with, other)  
		if not self:IsDead() then
			return
		end
		
        if with == 'Water' then
            self:PlayUnitSound('AirUnitWaterImpact')
            
            -- Play water impact effects
            for k, v in EffectTemplates.WaterSplash01 do
                CreateEmitterAtBone( self, -2, self:GetArmy(), v ):ScaleEmitter( self.volume/5 )
            end
            
            self:DestroyAllDamageEffects()
			self:PlayUnitAmbientSound('Sinking')
            self:ForkThread(self.SinkingEffects)
            
        elseif with == 'Seabed' then
			self:StopUnitAmbientSound('Sinking')
            self:ForkThread(self.DeathThread)
		elseif with == 'Terrain' then
			self:ForkThread(self.DeathThread)
		end
    end,
    
    DeathThread = function(self, overkillRatio, instigator)   
		if self:PrecacheDebris() then
			WaitTicks(1)
		end
        -- Play destruction effects
		local bp = self:GetBlueprint()
		local deathBp = bp.Death

		if deathBp.ExplosionEffect then
			local layer = self:GetCurrentLayer()
			local emitters = EffectTemplates.Explosions[layer][deathBp.ExplosionEffect]
			if emitters then
				CreateBoneEffects( self, -2, self:GetArmy(), emitters )
			end
		end

        local layer = self:GetCurrentLayer()
        if layer == 'Seabed' then
            self:ForkThread(self.SeaFloorImpactEffects)
        else
			if deathBp.DebrisPieces then
				self:DebrisPieces( self )
			end

			if deathBp.ExplosionTendrils then
				self:ExplosionTendrils( self )
			end

			if deathBp.Light then
				local myPos = self:GetPosition()
				myPos[2] = myPos[2] + 7
				CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 10, 4, 0.1, 0.1, 0.5 )
			end

			self:CreateUnitDestructionDebris()

            local scale = (bp.SizeX + bp.SizeZ) * 1.5
		    if deathBp.ScorchDecal then
			    CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi), deathBp.ScorchDecal, '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), scale * 0.75 )
		    else
			    CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), scale * 0.75 )
		    end        
        end
        
        --LOG('*DEBUG: OVERKILL RATIO = ', repr(overkillRatio))

		-- Create unit wreckage
        self:CreateWreckage( overkillRatio )

        self:PlayUnitSound('Destroyed')
        self:Destroy()
    end,

    SeaFloorImpactEffects = function(self)
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(self.volume/4)
    end,
    
    SinkingEffects = function(self)
        local i = 8 -- initializing the above surface counter     
        local army = self:GetArmy()
        
        while i >= 0 do
            if i > 0 then
                local rx, ry, rz = self:GetRandomOffset(1)
                local rs = Random(self.volume/2, self.volume*2) / (self.volume*2)
                CreateAttachedEmitter(self,-1,army,'/effects/emitters/units/general/event/death/destruction_water_sinking_ripples_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
            end

            local rx, ry, rz = self:GetRandomOffset(1)
            local rs = Random(self.volume/2.5, self.volume*2.5) / (self.volume*2.5)
            CreateAttachedEmitter(self,-2,army,'/effects/emitters/units/general/event/death/destruction_underwater_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
            CreateAttachedEmitter(self,-2,army,'/effects/emitters/units/general/event/death/destruction_water_sinking_bubbles_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(self.volume/4)
            
            i = i - 1
            WaitSeconds(1)
        end
    end,
}
TypeClass = UIX0101