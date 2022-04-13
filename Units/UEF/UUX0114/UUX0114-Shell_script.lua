-----------------------------------------------------------------------------
--  File     :  /units/uef/uux0114/uux0114-shell_script.lua
--  Author(s):  Gordon Duclos
--  Summary  :  SC2 UEF Unit Cannon Shell unit 
--				*temporary hack to allow the shell to animate
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Unit = import('/lua/sim/Unit.lua').Unit

UUX0114Shell = Class(Unit) {

	CreateUnitDestructionDebris = function( self )
		if not self.DestructionPartsCreated then
			self.DestructionPartsCreated = true
			local DestructionParts = self:GetBlueprint().Death.DestructionParts
			
			if DestructionParts then
				local x,y,z = self:GetVelocity()
				local scale = self:GetBlueprint().Display.UniformScale
				for k, v in DestructionParts do
					local proj = self:CreateProjectileAtBone( v.Projectile, v.AttachBone )
					proj:SetMesh( v.Mesh )
					proj:SetScale( scale )
					local offsetBone = v.PivotBone or 'DebrisPivot01'
					local difference = VDiff( proj:GetPosition(), proj:GetPosition(offsetBone) )
					local pos = VAdd( proj:GetPosition(), difference )
					Warp( proj, pos )
					proj:SetVelocity( x + difference[1] * 3, y + difference[2] * 3, z + difference[3] * 3 )
					proj:SetVelocity( Random(8,24) )
					proj:SetBallisticAcceleration( -1 * Random(2,6) )
					self:HideBone( v.AttachBone, true )
				end
			end
		end
	end,

	DeathThread = function( self, overkillRatio, instigator)
		-- Split effects
        for k, v in EffectTemplates.Weapons.UEF_Noah01_ShellSplit01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v )
        end
        
        -- Create destruction debris fragments.
		self:CreateUnitDestructionDebris()
		self:Destroy()
    end,
}
TypeClass = UUX0114Shell