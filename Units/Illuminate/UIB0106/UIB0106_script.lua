-----------------------------------------------------------------------------
--  File     : /units/illuminate/uib0106/uib0106_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate Tactical Missile Launcher: UIB0106
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UIB0106 = Class(StructureUnit) {

    EffectAttachBones = {	
		'Effect01',
		'Effect02',
		'Effect03',
		'Effect04',
	},
	
	EffectAttachBones02 = {	
		'Bracket01',
		'Bracket02',
		'Bracket03',
		'Bracket04',
	},
	
	OnStopBeingBuilt = function(self,builder,layer)
		StructureUnit.OnStopBeingBuilt(self, builder, layer)
		local army = self:GetArmy()	
			
		-- plasma on claws
		for kBone, vBone in self.EffectAttachBones do
			CreateAttachedEmitter( self, vBone, army, '/effects/emitters/units/illuminate/uib0106/ambient/uib0106_a_01_plasma_emit.bp' )
			CreateAttachedEmitter( self, vBone, army, '/effects/emitters/units/illuminate/uib0106/ambient/uib0106_a_02_wisps_emit.bp' )
		end
		
		for kBone, vBone in self.EffectAttachBones02 do
			CreateAttachedEmitter( self, vBone, army, '/effects/emitters/units/illuminate/uib0106/ambient/uib0106_a_03_plasma_emit.bp' )
			CreateAttachedEmitter( self, vBone, army, '/effects/emitters/units/illuminate/uib0106/ambient/uib0106_a_04_wisps_emit.bp' )
		end

	end,
			
    Weapons = {
        TacticalMissile01 = Class(DefaultProjectileWeapon) {

			ArmBoneSet01 = {
				'Bracket01',
				'Bracket02',
				'Bracket03',
				'Bracket04',
			},

			ArmBoneSet02 = {
				'Finger01',
				'Finger02',
				'Finger03',
				'Finger04',
			},

			HatchBoneSet01 = {
				'Door1',
				'Door2',
				'Door3',
				'Door4',
			},

			OnCreate = function(self)
				DefaultProjectileWeapon.OnCreate(self)

				self.HatchRotators01 = {}
				self.HatchRotators02 = {}
				self.HatchRotators03 = {}

				for k, v in self.ArmBoneSet01 do
					local rotator = CreateRotator(self.unit, v, 'x', 0, 40, 20 )
					table.insert( self.HatchRotators01, rotator )
					self.unit.Trash:Add( rotator )
				end

				for k, v in self.ArmBoneSet02 do
					local rotator = CreateRotator(self.unit, v, 'x', 0, 50, 20 )
					table.insert( self.HatchRotators02, rotator )
					self.unit.Trash:Add( rotator )
				end

				for k, v in self.HatchBoneSet01 do
					local rotator = CreateRotator(self.unit, v, 'x', 0, 40, 20 )
					table.insert( self.HatchRotators03, rotator )
					self.unit.Trash:Add( rotator )
				end
			end,
			
			PlayFxWeaponUnpackSequence = function(self)
                local bp = self:GetBlueprint()
                local unitBP = self.unit:GetBlueprint()
                if unitBP.Audio.Activate then
                    self:PlaySound(unitBP.Audio.Activate)
                end
                if unitBP.Audio.Open then
                    self:PlaySound(unitBP.Audio.Open)
                end
                if bp.Audio.Unpack then
                    self:PlaySound(bp.Audio.Unpack)
                end
                for k, v in self.HatchRotators01 do
					v:SetGoal(-140)
				end
                for k, v in self.HatchRotators03 do
					v:SetGoal(70)
				end
                for k, v in self.HatchRotators02 do
					v:SetGoal(120)
				end
                WaitSeconds(2)
            end,

            PlayFxWeaponPackSequence = function(self)
                local bp = self:GetBlueprint()
                local unitBP = self.unit:GetBlueprint()
                if unitBP.Audio.Close then
                    self:PlaySound(unitBP.Audio.Close)
                end
                for k, v in self.HatchRotators01 do
					v:SetGoal(0)
				end
                for k, v in self.HatchRotators02 do
					v:SetGoal(0)
				end
                for k, v in self.HatchRotators03 do
					v:SetGoal(0)
				end
                WaitSeconds(2)
            end,	

		},
    },
}
TypeClass = UIB0106