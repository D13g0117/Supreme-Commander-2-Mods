-----------------------------------------------------------------------------
--  File     : /units/illuminate/uix0103/uix0103_script.lua
--  Author(s): Aaron Lundquist, Gordon Duclos
--  Summary  : SC2 Illuminate Experimental Air Defense: UIX0103
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalAirUnit = import('/lua/sim/ExperimentalAirUnit.lua').ExperimentalAirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UIX0103 = Class(ExperimentalAirUnit) {
    Weapons = {
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        AntiAir02 = Class(DefaultProjectileWeapon) {},
        AntiAir03 = Class(DefaultProjectileWeapon) {},
        AntiAir04 = Class(DefaultProjectileWeapon) {},
        AntiAir05 = Class(DefaultProjectileWeapon) {},
        AntiAir06 = Class(DefaultProjectileWeapon) {},

        FrontRight = Class(DefaultProjectileWeapon) {},
        FrontLeft = Class(DefaultProjectileWeapon) {},
        BackRight = Class(DefaultProjectileWeapon) {},
        BackLeft = Class(DefaultProjectileWeapon) {},
    },
    
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
        for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death01 do
			CreateAttachedEmitter ( self, 'UIX0103_Chest', self:GetArmy(), v ):ScaleEmitter(0.5)
		end
        WaitSeconds(1.0)
        self:CreateExplosionDebris( army, 'UIX0103_Head' )     
        WaitSeconds(0.3)
        self:CreateExplosionDebris( army, 'UIX0103_RightShoulder' )      
        WaitSeconds(0.4)   
        self:CreateUnitDestructionDebris()   
        self:CreateExplosionDebris( army, 'UIX0103_Turret02' )
		WaitSeconds(0.2)
		self:CreateExplosionDebris( army, 'UIX0103_Turret07' )
		
		self:ShakeCamera(16, 3, 1, 2.0)
							 				
		WaitSeconds(1.0)
		for k, v in EffectTemplates.Explosions.Land.IlluminateStructureDestroyEffectsExtraLarge01 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(0.8)
		end
		 
		if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end
        self:CreateWreckage(0.1)
                
        self:Destroy()
    end,
}
TypeClass = UIX0103