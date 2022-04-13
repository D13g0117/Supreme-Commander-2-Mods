-----------------------------------------------------------------------------
--  File     : /units/cybran/ucs0103/ucs0103_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Destroyer: UCS0103
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local SeaUnit = import('/lua/sim/SeaUnit.lua').SeaUnit
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCS0103 = Class(SeaUnit) {

    IsWaiting = false,
    ModeWalking = false,

    Weapons = {
        Cannon01 = Class(DefaultProjectileWeapon) {},
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        Torpedo01 = Class(DefaultProjectileWeapon) {
			CreateProjectileForWeapon = function(self, bone)
				local projectile = self:CreateProjectile(bone)
				local damageTable = self:GetDamageTable()
				local bp = self:GetBlueprint()
				local data = {
					Instigator = self.unit,
					Damage = bp.DoTDamage,
					Duration = bp.DoTDuration,
					Frequency = bp.DoTFrequency,
					Type = 'Normal',
					PreDamageEffects = {},
					DuringDamageEffects = {},
					PostDamageEffects = {},
				}
				if projectile and not projectile:BeenDestroyed() then
					projectile:PassData(data)
					projectile:PassDamageData(damageTable)
				end
				return projectile
			end,		
		},
    },

    OnCreate = function(self, createArgs)
        SeaUnit.OnCreate(self, createArgs)

		-- Initialize amphibious walker animset
		local animset = self:GetBlueprint().AnimSet
		if animset then
			self:PushAnimSet(animset, "Base");
		end
		self.HasSeaMoveSpeedBuff = false
		self.HasLandMoveSpeedBuff = false
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        SeaUnit.OnStopBeingBuilt(self,builder,layer)
        -- If created with F2 on land, then play the transform anim.
        if( self:GetCurrentLayer() == 'Land') then
            self:SendAnimEvent( 'OnTransitionToLand' )
            self.AT1 = self:ForkThread(self.TransformThread, true)
			self.ModeWalking = true
        end
    end,
    
    OnAnimStartTrigger = function( self, event )
		if event == 'TransformForLand' then
	        CreateAttachedEmitter(self, -2, self:GetArmy(), '/effects/emitters/ambient/units/tt_water_submerge04_03_emit.bp'):ScaleEmitter(1.4)
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

        if( land ) then
            -- Change movement speed to the multiplier in blueprint
			self.ModeWalking = true	
			WaitSeconds(bp.Physics.LayerTransitionDuration)
			ApplyBuff(self, 'CybranLandMoveSpeedRedux01')
            self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0, 2.0,bp.CollisionOffsetZ or 0, bp.SizeX * 0.75, bp.SizeY * 0.85, bp.SizeZ * 0.5 )
		else
            -- Revert speed to maximum speed
            WaitSeconds(bp.Physics.LayerTransitionDuration)
            RemoveBuff(self, 'CybranLandMoveSpeedRedux01')
            self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0,(bp.CollisionOffsetY + (bp.SizeY * 0.5)) or 0,bp.CollisionOffsetZ or 0, bp.SizeX * 0.5, bp.SizeY * 0.5, bp.SizeZ * 0.5 )
        end
        
        self:ApplyMovementSpeedBuffsForLayer(land)
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
				CreateBoneEffects( self, 'ucs0103_Root', self:GetArmy(), emitters )
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
TypeClass = UCS0103