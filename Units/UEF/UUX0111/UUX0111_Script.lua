-----------------------------------------------------------------------------
--  File     : /units/uef/uux0111/uux0111_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Experimental Assault Bot: UUX0111
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local TurretWeapon = import('/lua/sim/weapon.lua').TurretWeapon

local function PassData(self, proj)
    local data = {
        Radius = self:GetBlueprint().CameraVisionRadius or 5,
        Lifetime = self:GetBlueprint().CameraLifetime or 5,
        Army = self.unit:GetArmy(),
    }
    if proj and not proj:BeenDestroyed() then
        proj:PassData(data)
    end
end

local MainGun = Class(DefaultProjectileWeapon) {
    CreateProjectileAtMuzzle = function(self, muzzle)
		PassData( self, DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle) )
    end,
}

UUX0111 = Class(ExperimentalMobileUnit) {
    
    Weapons = {
        BodyYaw = Class(TurretWeapon) {},
        RightMainWeapon = Class(DefaultProjectileWeapon) {       
            OnCreate = function(self)            
                self.RightSpinner = CreateRotator(self.unit, 'UUX0111_T01_B01_Recoil01', 'z')
                self.RightSpinnerGoal = 180
                self.unit.Trash:Add(self.RightSpinner)        
                DefaultProjectileWeapon.OnCreate(self)
            end,
              
            PlayFxRackReloadSequence = function(self)
                self.RightSpinner:SetCurrentAngle(0)
                self.RightSpinner:SetGoal(self.RightSpinnerGoal)
                self.RightSpinner:SetSpeed(100)
                self.RightSpinner:SetAccel(10)
		        DefaultProjectileWeapon.PlayFxRackReloadSequence(self)
	        end,
	        
	        CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Light on Muzzle
		        local myPos = self.unit:GetPosition(muzzle)
		        local lightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 50, 6, 0.0, 0.0, 0.255 )
            end,
        },
        LeftMainWeapon = Class(DefaultProjectileWeapon) {
            OnCreate = function(self)            
                self.LeftSpinner = CreateRotator(self.unit, 'UUX0111_T01_B02_Recoil01', '-z')
                self.LeftSpinnerGoal = 180
                self.unit.Trash:Add(self.LeftSpinner)        
                DefaultProjectileWeapon.OnCreate(self)
            end,
              
            PlayFxRackReloadSequence = function(self)
                self.LeftSpinner:SetCurrentAngle(0)
                self.LeftSpinner:SetGoal(self.LeftSpinnerGoal)
                self.LeftSpinner:SetSpeed(100)
                self.LeftSpinner:SetAccel(10)
		        DefaultProjectileWeapon.PlayFxRackReloadSequence(self)
	        end,
	        
	        CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Light on Muzzle
		        local myPos = self.unit:GetPosition(muzzle)
		        local lightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 50, 6, 0.0, 0.0, 0.255 )
            end,
        },
        Turret02 = Class(DefaultProjectileWeapon) {},
		Turret03 = Class(DefaultProjectileWeapon) {},
		Turret04 = Class(DefaultProjectileWeapon) {},
		TacticalMissile01 = Class(DefaultProjectileWeapon) {
            OnLostTarget = function(self)
				self.unit.TopLeftDoor:SetGoal(0)
				self.unit.TopRightDoor:SetGoal(0)
				self.unit.BottomLeftDoor:SetGoal(0)
				self.unit.BottomRightDoor:SetGoal(0)
                DefaultProjectileWeapon.OnLostTarget(self)
            end,

        	IdleState = State {
				OnGotTarget = function(self)
					self.unit.TopLeftDoor:SetGoal(-90)
					self.unit.TopRightDoor:SetGoal(-90)
					self.unit.BottomLeftDoor:SetGoal(90)
					self.unit.BottomRightDoor:SetGoal(90)
					DefaultProjectileWeapon.IdleState.OnGotTarget(self)
				end,
			},
        },
		TacticalMissile02 = Class(DefaultProjectileWeapon) {},
        CrownArtillery01 = Class(MainGun) {},
        CrownArtillery02 = Class(MainGun) {},
        CrownArtillery03 = Class(MainGun) {},
        CrownArtillery04 = Class(MainGun) {},
    },

    OnCreate = function(self, createArgs)
		ExperimentalMobileUnit.OnCreate(self, createArgs)
		self.Spinner = CreateRotator(self, 'UUX0111_Crown', 'y', nil, 0, 60, 360):SetTargetSpeed(-30)
		self.Trash:Add(self.Spinner)

        -- Create missile doors
        self.TopLeftDoor = CreateRotator(self, 'UUX0111_LeftMissileTop', 'x', 0, 90, 360)
        self.TopRightDoor = CreateRotator(self, 'UUX0111_RightMissileTop', 'x', 0, 90, 360)
        self.BottomLeftDoor = CreateRotator(self, 'UUX0111_LeftMissileBottom', 'x', 0, 90, 360)
        self.BottomRightDoor = CreateRotator(self, 'UUX0111_RightMissileBottom', 'x', 0, 90, 360)
	end,
	
	CreateExplosionDebris = function( self, army, bone )
        for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death02 do
            CreateAttachedEmitter( self, bone, army, v )
        end
    end,
    
	DeathThread = function(self)

		-- Destroy idle animation
		if(self.Animator) then
			self.Animator:Destroy()
			self.Animator = false
		end

        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()

        -- Create explosion effects
        for k, v in EffectTemplates.Units.UEF.Experimental.UUX0111.Death01 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(1.3):OffsetEmitter( 0, 7, 0 )
		end
        WaitSeconds(1.5)
        self:CreateExplosionDebris( army, 'UUX0111_LeftShoulder' )
        WaitSeconds(0.2)      
        self:CreateExplosionDebris( army, 'UUX0111_Crown' )
		WaitSeconds(0.3)
		self:CreateExplosionDebris( army, 'UUX0111_T01_Barrel01' )

		self:CreateUnitDestructionDebris()
			
        -- When the unit impacts with the ground
        -- Effects: large dust around unit
        -- Other: Damage force ring to force trees over and camera shake
        
        WaitSeconds(0.5)
        
        self:CreateExplosionDebris( army, 'UUX0111_RightKnee' )

		WaitSeconds(1.7)

		for k, v in EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsExtraLarge02 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):OffsetEmitter( 0, 0, 7 )
		end
		
        self:ShakeCamera(20, 4, 1, 2.0)
        				
		WaitSeconds(0.1)

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
		
        self:ShakeCamera(2, 1, 0, 0.05)
        
        self:Destroy()
    end,
}
TypeClass = UUX0111
