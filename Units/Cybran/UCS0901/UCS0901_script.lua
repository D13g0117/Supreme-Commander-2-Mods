-----------------------------------------------------------------------------
--  File     : /units/cybran/ucs0901/ucs0901_script.lua
--  Author(s): Gordon DUclos
--  Summary  : SC2 Cybran Aircraft Carrier: UCS0901
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local SeaUnit = import('/lua/sim/SeaUnit.lua').SeaUnit
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCS0901 = Class(SeaUnit) {

    BuildAttachBone = 'ucs0901_Dock01',
    IsWaiting = false,
    ModeWalking = false,

    Weapons = {
        Laser01 = Class(DefaultProjectileWeapon) {},
        Laser02 = Class(DefaultProjectileWeapon) {},
        Laser03 = Class(DefaultProjectileWeapon) {},
    },

    OnCreate = function(self, createArgs)
        SeaUnit.OnCreate(self, createArgs)

		-- Initialize amphibious walker animset
		local animset = self:GetBlueprint().AnimSet
		if animset then
			self:PushAnimSet(animset, "Base");
		end
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        SeaUnit.OnStopBeingBuilt(self,builder,layer)
        self.UnitBeingBuilt = nil
        self:DetachAll(self.BuildAttachBone)

        -- If created with F2 on land, then play the transform anim.
        if( self:GetCurrentLayer() == 'Land') then
            self:SendAnimEvent( 'OnTransitionToLand' )
            self.AT1 = self:ForkThread(self.TransformThread, true)
			self.ModeWalking = true
        end
    end,
    
    OnAnimStartTrigger = function( self, event )
		if event == 'TransformForLand' then
	        CreateAttachedEmitter(self, -2, self:GetArmy(), '/effects/emitters/ambient/units/tt_water_submerge04_03_emit.bp'):ScaleEmitter(2)
		end
	end,

    OnStartBuild = function(self, unitBuilding, order)
        SeaUnit.OnStartBuild(self, unitBuilding, order)
        self.UnitBeingBuilt = unitBuilding
        unitBuilding:SetDoNotTarget(true)
        unitBuilding:SetCanTakeDamage(false)
        unitBuilding:SetUnSelectable(true)
        unitBuilding:HideMesh()
        local bone = self.BuildAttachBone
        self:DetachAll(bone)
        unitBuilding:AttachBoneTo(-2, self, bone)
        self.UnitDoneBeingBuilt = false
    end,

    OnFailedToBuild = function(self)
        SeaUnit.OnFailedToBuild(self)
        self:DetachAll(self.BuildAttachBone)
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        SeaUnit.OnStopBuild(self, unitBeingBuilt)
        if not unitBeingBuilt or unitBeingBuilt:IsDead() then
            return
        end

        unitBeingBuilt:DetachFrom(true)
        unitBeingBuilt:SetDoNotTarget(false)
        unitBeingBuilt:SetCanTakeDamage(true)
        unitBeingBuilt:SetUnSelectable(false)
        self:DetachAll(self.BuildAttachBone)
        if self:TransportHasAvailableStorage(unitBeingBuilt) then
            self:TransportAddUnitToStorage(unitBeingBuilt)
        else
            local worldPos = self:CalculateWorldPositionFromRelative({0, 0, -20})
            IssueMoveOffFactory({unitBeingBuilt}, worldPos)
            unitBeingBuilt:ShowMesh()
        end
        
        -- If there are no available storage slots, pause the builder!
        if self:GetNumberOfAvailableStorageSlots() == 0 then
            self:SetBuildDisabled(true)
            self:SetPaused(true)
        end        
                
		self.UnitBeingBuilt = nil
        self:RequestRefreshUI()
    end,
    
    OnTransportUnloadUnit = function(self,unit)
        if self:IsBuildDisabled() and self:GetNumberOfAvailableStorageSlots() > 0 then
            self:SetBuildDisabled(false)
            self:RequestRefreshUI()
        end   
    end,    

    OnMotionHorzEventChange = function(self, new, old)
        SeaUnit.OnMotionHorzEventChange(self, new, old)
        if self:IsDead() then
			return 
		end
        if( not self.IsWaiting ) then
            if( self.ModeWalking ) then
                if( old == 'Stopped' ) then
                    self:SendAnimEvent( 'OnMove' )
                elseif( new == 'Stopped' ) then
                    self:SendAnimEvent( 'OnIdle' )
                end
            end
        end
    end,

    OnLayerChange = function(self, new, old)
        SeaUnit.OnLayerChange(self, new, old)
        if( old != 'None' ) then
            if( self.AT1 ) then
                self.AT1:Destroy()
                self.AT1 = nil
            end
            local myBlueprint = self:GetBlueprint()
            if( new == 'Land' ) then
				self:SendAnimEvent( 'OnTransitionToLand' )
                self.AT1 = self:ForkThread(self.TransformThread, true)
            elseif( new == 'Water' ) then
				self.ModeWalking = false
				self:SendAnimEvent( 'OnTransitionToSea' )
                self.AT1 = self:ForkThread(self.TransformThread, false)
            end
        end
    end,

    TransformThread = function(self, land)
        local bp = self:GetBlueprint()
        local scale = bp.Display.UniformScale or 1

        if( land ) then
            -- Change movement speed to the multiplier in blueprint
            self.ModeWalking = true
			WaitSeconds(bp.Physics.LayerTransitionDuration)
			ApplyBuff(self, 'CybranLandMoveSpeedRedux01')
            self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0, 3.0,bp.CollisionOffsetZ or 0, bp.SizeX * 0.5, bp.SizeY * 0.85, bp.SizeZ * 0.5 )
        else
            -- Revert speed to maximum speed
            WaitSeconds(bp.Physics.LayerTransitionDuration)
            RemoveBuff(self, 'CybranLandMoveSpeedRedux01')
            self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0,(bp.CollisionOffsetY + (bp.SizeY * 0.5)) or 0,bp.CollisionOffsetZ or 0, bp.SizeX * 0.5, bp.SizeY * 0.5, bp.SizeZ * 0.5 )
        end
        
        self:ApplyMovementSpeedBuffsForLayer(land)
    end,
    
    SeaFloorImpactEffects = function(self)
        local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz  
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(vol/18)
    end,

    SinkingEffects = function(self)
        local i = 8 -- initializing the above surface counter
        local sx, sy, sz = self:GetUnitSizes()
        local vol = (sx * sz)/2   
        local army = self:GetArmy()
        
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
            local rs = Random(vol/2.5, vol*2.5) / (vol*2.5)
            CreateAttachedEmitter(self,-2,army,'/effects/emitters/units/general/event/death/destruction_underwater_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
            CreateAttachedEmitter(self,-2,army,'/effects/emitters/units/general/event/death/destruction_water_sinking_bubbles_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(vol/12)
            
            i = i - 1
            WaitSeconds(1)
        end
    end,

    DeathThread = function(self, overkillRatio)
        if self:GetCurrentLayer() == 'Water' then
			SeaUnit.DeathThread(self, overkillRatio)
        else
            MobileUnit.DeathThread(self, overkillRatio)
        end
        
        -- Play destruction effects
		local bp = self:GetBlueprint()
		local ExplosionEffect = bp.Death.ExplosionEffect

		if ExplosionEffect then
			local layer = self:GetCurrentLayer()
			local emitters = EffectTemplates.Explosions[layer][ExplosionEffect]
			
			if emitters then
				CreateBoneEffects( self, 'ucs0901_Root', self:GetArmy(), emitters )
			end
		end
    end,
    
    ApplyMovementSpeedBuffsForLayer = function( self, isLand )
		if isLand then
			if self.HasSeaMoveSpeedBuff and HasBuff(self, 'RB_CSB_SEAMOVESPEED' ) then
				RemoveBuff(self, 'RB_CSB_SEAMOVESPEED')
			end
			if self.HasLandMoveSpeedBuff then
				ApplyBuff( self, 'RB_CSB_LANDMOVESPEED' )
			end
		else
			if self.HasSeaMoveSpeedBuff then
				ApplyBuff(self, 'RB_CSB_SEAMOVESPEED')
			end
			if self.HasLandMoveSpeedBuff and HasBuff( self, 'RB_CSB_LANDMOVESPEED' ) then
				RemoveBuff( self, 'RB_CSB_LANDMOVESPEED' )
			end
		end
    end,
    
    OnResearchedTechnologyAdded = function( self, upgradeName, level, modifierGroup )
		SeaUnit.OnResearchedTechnologyAdded( self, upgradeName, level, modifierGroup )
		if upgradeName == 'CSB_LANDMOVESPEED' then
			self.HasLandMoveSpeedBuff = true
			if self:GetCurrentLayer() == 'Land' then
				ApplyBuff( self, 'RB_CSB_LANDMOVESPEED' )
			end			
		elseif upgradeName == 'CSB_SEAMOVESPEED' then
			self.HasSeaMoveSpeedBuff = true
			if self:GetCurrentLayer() == 'Water' then
				ApplyBuff( self, 'RB_CSB_SEAMOVESPEED' )
			end
		end
    end,    
}
TypeClass = UCS0901