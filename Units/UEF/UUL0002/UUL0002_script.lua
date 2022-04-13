-----------------------------------------------------------------------------
--  File     : /units/uef/uul0002/uul0002_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Engineer: UUL0002
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ConstructionUnit = import('/lua/sim/ConstructionUnit.lua').ConstructionUnit

UUL0002 = Class(ConstructionUnit) {
	OnCreate = function(self, createArgs)
		ConstructionUnit.OnCreate(self, createArgs)
		self:SetProductionActive(false)
	end,
    
    OnStopBeingBuilt = function(self,builder,layer)
        ConstructionUnit.OnStopBeingBuilt(self,builder,layer)
        self.CustomUnpackSpinners = {
            -- CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
            Spinner1 = CreateRotator(self, 'UUL0002_MidLever', 'x', 0, 300, 300),
            Spinner2 = CreateRotator(self, 'UUL0002_Lever01', '-x', 0, 300, 300),
            Spinner3 = CreateRotator(self, 'T01_Barrel01', 'x', 0, 300, 300),
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
            self.CustomUnpackSpinners.Spinner1:SetGoal(30)
            self.CustomUnpackSpinners.Spinner2:SetGoal(120)
            self.CustomUnpackSpinners.Spinner3:SetGoal(90)
        else
            self.CustomUnpackSpinners.Spinner1:SetGoal(0)
            self.CustomUnpackSpinners.Spinner2:SetGoal(0)
            self.CustomUnpackSpinners.Spinner3:SetGoal(0)
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
            if (new == 'Land') and (old != 'None') then
                self.TerrainLayerTransitionThread = self:ForkThread(self.TransformThread, false)
            elseif (new == 'Water') then
                self.TerrainLayerTransitionThread = self:ForkThread(self.TransformThread, true)
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
            self:RemoveUVRScroller(1)
            self:RemoveUVRScroller(2)
        else
            self.TransformManipulator:SetRate(-1)
            self.TransformManipulator:SetPrecedence(0)
            WaitFor(self.TransformManipulator)
            self.TransformManipulator:Destroy()
            self.TransformManipulator = nil
			self:AddThreadUVRScroller(1, 1, 1.0, -0.6 )
			self:AddThreadUVRScroller(2, 1, -1.0, -0.6 )
        end
    end,

    CreateMovementEffects = function( self, EffectsBag, TypeSuffix, TerrainType )
        local layer = self:GetCurrentLayer()
        local bpTable = self:GetBlueprint().Display.MovementEffects

        if bpTable[layer] then
            bpTable = bpTable[layer]
            local effectTypeGroups = bpTable.Effects

			if layer != 'Water' then
				if bpTable.Treads.ScrollTreads then
					self:AddThreadUVRScroller(1, 1, 1.0, bpTable.Treads.ScrollMultiplier or 0.2)
					self:AddThreadUVRScroller(2, 1, -1.0, bpTable.Treads.ScrollMultiplier or 0.2)
				end
			end

            if (not effectTypeGroups or (effectTypeGroups and (table.getn(effectTypeGroups) == 0))) then
                if not self.Footfalls and bpTable.Footfall then
                    LOG('*WARNING: No movement effect groups defined for unit ',repr(self:GetUnitId()),', Effect groups with bone lists must be defined to play movement effects. Add these to the Display.MovementEffects', layer, '.Effects table in unit blueprint. ' )
                end
                return false
            end

            if bpTable.CameraShake then
                self.CamShakeT1 = self:ForkThread(self.MovementCameraShakeThread, bpTable.CameraShake )
            end

            self:CreateTerrainTypeEffects( effectTypeGroups, 'FXMovement', layer, TypeSuffix, EffectsBag, TerrainType )
        end
    end,
}
TypeClass = UUL0002