-----------------------------------------------------------------------------
--  File     :  /units/uef/uul0201/uul0201_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Mobile Shield Generator: UUL0201
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit

UUL0201 = Class(MobileUnit) {

    ShieldEffects = {
		'/effects/emitters/units/uef/uul0201/shield/uul0201_s_01_glow_emit.bp',
		'/effects/emitters/units/uef/uul0201/shield/uul0201_s_02_core_emit.bp',
		'/effects/emitters/units/uef/uul0201/shield/uul0201_s_03_wisps_emit.bp',
    },
    
    OnCreate = function(self, createArgs)
		MobileUnit.OnCreate(self, createArgs)
		self.ShieldEffectsBag = {}
	end,
	
    OnShieldEnabled = function(self)
        MobileUnit.OnShieldEnabled(self)
        KillThread( self.DestroyManipulatorsThread )
        if not self.RotatorManipulator then
            self.RotatorManipulator = CreateRotator( self, 'Turret01', 'z' )
            self.Trash:Add( self.RotatorManipulator )
        end
        self.RotatorManipulator:SetAccel( 5 )
        self.RotatorManipulator:SetTargetSpeed( 30 )
        if not self.AnimationManipulator then
            local myBlueprint = self:GetBlueprint()
            --LOG( 'it is ', repr(myBlueprint.Display.AnimationOpen) )
            self.AnimationManipulator = CreateAnimator(self)
            self.AnimationManipulator:PlayAnim( myBlueprint.Display.AnimationOpen )
            self.Trash:Add( self.AnimationManipulator )
        end
        self.AnimationManipulator:SetRate(1)

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
		
		for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, -2, self:GetArmy(), v ) )
        end
    end,

    OnShieldDisabled = function(self)
        MobileUnit.OnShieldDisabled(self)
        KillThread( self.DestroyManipulatorsThread )
        self.DestroyManipulatorsThread = self:ForkThread( self.DestroyManipulators )

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,

    DestroyManipulators = function(self)
        if self.RotatorManipulator then
            self.RotatorManipulator:SetAccel( 10 )
            self.RotatorManipulator:SetTargetSpeed( 0 )
            -- Unless it goes smoothly back to its original position,
            -- it will snap there when the manipulator is destroyed.
            -- So for now, we'll just keep it on.
            --WaitFor( self.RotatorManipulator )
            --self.RotatorManipulator:Destroy()
            --self.RotatorManipulator = nil
        end
        if self.AnimationManipulator then
            self.AnimationManipulator:SetRate(-1)
            WaitFor( self.AnimationManipulator )
            self.AnimationManipulator:Destroy()
            self.AnimationManipulator = nil
        end
    end,
}
TypeClass = UUL0201