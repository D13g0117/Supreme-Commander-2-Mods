-----------------------------------------------------------------------------
--  File     :  /units/cybran/ucl0002/ucl0002_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Engineer: UCL0002
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local ConstructionUnit = import('/lua/sim/ConstructionUnit.lua').ConstructionUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCL0002 = Class(ConstructionUnit) {
	DestructionExplosionWaitDelayMin = 0.6,
	DestructionExplosionWaitDelayMax = 0.8,

    Weapons = {
        Laser01 = Class(DefaultProjectileWeapon) {},
    },

	OnCreate = function(self, createArgs)
		ConstructionUnit.OnCreate(self, createArgs)
		self:SetProductionActive(false)
	end,

    OnStopBeingBuilt = function(self,builder,layer)
        ConstructionUnit.OnStopBeingBuilt(self,builder,layer)
        -- If created with F2 on land, then play the transform anim.
        if(self:GetCurrentLayer() == 'Water') then
            self.TerrainLayerTransitionThread = self:ForkThread(self.TransformThread, true)
        end
        self.CustomUnpackSpinners = {
                    -- CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
            Spinner1 = CreateRotator(self, 'UCL0002_LeftShoulder', 'x', 0, 300, 300),
            Spinner2 = CreateRotator(self, 'UCL0002_LeftElbow', '-x', 0, 300, 300),
            Spinner3 = CreateRotator(self, 'UCL0002_T01_Barrel03', 'x', 0, 300, 300),
            Spinner4 = CreateRotator(self, 'UCL0002_RightShoulder', 'x', 0, 300, 300),
            Spinner5 = CreateRotator(self, 'UCL0002_RightElbow', '-x', 0, 300, 300),
            Spinner6 = CreateRotator(self, 'UCL0002_T01_Barrel02', 'x', 0, 300, 300),
        }
    end,
    
    -- By default, just destroy us when we are killed.
    OnKilled = function(self, instigator, type, overkillRatio)
        local layer = self:GetCurrentLayer()
        self:DestroyIdleEffects()
        if(layer == 'Water' or layer == 'Seabed' or layer == 'Sub')then
            self.SinkThread = self:ForkThread(self.SinkingThread)
			self:PlayUnitAmbientSound('Sinking')
        end
        ConstructionUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    SinkingThread = function(self)
        local i = 8 -- initializing the above surface counter
        local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sy * sz
        local army = self:GetArmy()
        
		if self:PrecacheDebris() then
			WaitTicks(1)
		end
		        
		-- Destroy any ambient damage effects on unit
        self:DestroyAllDamageEffects()

		-- Play destruction effects
		local bp = self:GetBlueprint()
		local ExplosionEffect = bp.Death.ExplosionEffect

		if ExplosionEffect then
			local faction = bp.General.FactionName
			local layer = self:GetCurrentLayer()
			local emitters = EffectTemplates.Units[faction][layer].General[ExplosionEffect]
			if emitters then
				CreateBoneEffects( self, -2, self:GetArmy(), emitters )
			end
		end

		if bp.Death.DebrisPieces then
			self:DebrisPieces( self )
		end

		if bp.Death.ExplosionTendrils then
			self:ExplosionTendrils( self )
		end

		if bp.Death.Light then
			local myPos = self:GetPosition()
			myPos[2] = myPos[2] + 7
			CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 10, 4, 0.1, 0.1, 0.5 )
		end

		-- Create destruction debris fragments.
		self:CreateUnitDestructionDebris()

        while i >= 0 do
            if i > 0 then
                local rx, ry, rz = self:GetRandomOffset(1)
                local rs = Random(vol/2, vol*2) / (vol*2)
                CreateAttachedEmitter(self,-1,army,'/effects/emitters/units/general/event/death/destruction_water_sinking_ripples_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)

                local rx, ry, rz = self:GetRandomOffset(1)
                CreateAttachedEmitter(self,self.LeftFrontWakeBone,army, '/effects/emitters/units/general/event/death/destruction_water_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)

                local rx, ry, rz = self:GetRandomOffset(1)
                CreateAttachedEmitter(self,self.RightFrontWakeBone,army, '/effects/emitters/units/general/event/death/destruction_water_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
            end

            local rx, ry, rz = self:GetRandomOffset(1)
            local rs = Random(vol/2, vol*2) / (vol*2)
            CreateAttachedEmitter(self,-1,army,'/effects/emitters/units/general/event/death/destruction_underwater_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)

            i = i - 1
            WaitSeconds(1)
        end
    end,
    
    OnImpact = function(self, with, other)
		if not self:IsDead() then
			return
		end
    
        -- This is a bit of safety to keep us from calling the death thread twice in case we bounce twice quickly
        if not self.DeathBounce then
			self:StopUnitAmbientSound('Sinking')
            self:ForkThread(self.DeathThread, self.OverKillRatio )
            self.DeathBounce = 1
        end
    end,
    
    HandleBuildArm = function(self, enable)
        if enable then
            self.CustomUnpackSpinners.Spinner1:SetGoal(20)
            self.CustomUnpackSpinners.Spinner2:SetGoal(110)
            self.CustomUnpackSpinners.Spinner3:SetGoal(90)
            self.CustomUnpackSpinners.Spinner4:SetGoal(20)
            self.CustomUnpackSpinners.Spinner5:SetGoal(110)
            self.CustomUnpackSpinners.Spinner6:SetGoal(90)
        else
            self.CustomUnpackSpinners.Spinner1:SetGoal(0)
            self.CustomUnpackSpinners.Spinner2:SetGoal(0)
            self.CustomUnpackSpinners.Spinner3:SetGoal(0)
            self.CustomUnpackSpinners.Spinner4:SetGoal(0)
            self.CustomUnpackSpinners.Spinner5:SetGoal(0)
            self.CustomUnpackSpinners.Spinner6:SetGoal(0)
        end
        WaitSeconds(0.5)
    end,

    OnLayerChange = function(self, new, old)
        ConstructionUnit.OnLayerChange(self, new, old)
        if self:GetBlueprint().Display.AnimationWater then
            if self.TerrainLayerTransitionThread then
                self.TerrainLayerTransitionThread:Destroy()
                self.TerrainLayerTransitionThread = nil
            end
            if (new == 'Land') and (old != 'None') and self.MoveAnimDisabled then
                self.TerrainLayerTransitionThread = self:ForkThread(self.TransformThread, false)
                self.MoveAnimDisabled = false
				if (not self.Animator) then
					self.Animator = CreateAnimator(self)
				end

				self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationWalk, true, true)
				self.Animator:SetRate(self:GetBlueprint().Display.AnimationWalkRate or 1)
            elseif (new == 'Water') and not self.MoveAnimDisabled then
                self.TerrainLayerTransitionThread = self:ForkThread(self.TransformThread, true)
                self.MoveAnimDisabled = true
                if (self.Animator) then
                    self.Animator:Destroy()
                    self.Animator = false
                end
            end
        end
    end,

    TransformThread = function(self, water)
        if not self.TransformManipulator then
            self.TransformManipulator = CreateAnimator(self)
            self.Trash:Add( self.TransformManipulator )
        end

        if water then
            self.TransformManipulator:PlayAnim(self:GetBlueprint().Display.AnimationWater)
            self.TransformManipulator:SetRate(1)
            self.TransformManipulator:SetPrecedence(0)
        else
            self.TransformManipulator:SetRate(-1)
            self.TransformManipulator:SetPrecedence(0)
            WaitFor(self.TransformManipulator)
            self.TransformManipulator:Destroy()
            self.TransformManipulator = nil
        end
    end,
}
TypeClass = UCL0002