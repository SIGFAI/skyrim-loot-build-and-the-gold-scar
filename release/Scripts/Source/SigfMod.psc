Scriptname SigfMod extends Quest
{Loot, Build and the Gold Scar: main script. Gives the player the Build powers and wood, listens for SCAR shots and
turns each pull of the trigger into a burst, and scatters Loot Chests around the player.}

Weapon Property SigfScarCommon Auto
Weapon Property SigfScarUncommon Auto
Weapon Property SigfScarRare Auto
Weapon Property SigfScarEpic Auto
Weapon Property SigfGoldScar Auto
Ammo Property SigfScarRound Auto
MiscObject Property SigfWoodBundle Auto
Spell Property SigfBuildWall Auto
Spell Property SigfBuildRamp Auto
Spell Property SigfBuildFloor Auto
Spell Property FireboltStormNoDamage Auto
Sound Property WPNBowFire Auto
Light Property SigfMuzzleFlash Auto
Light Property SigfBulletGlow Auto
Explosion Property SigfScarImpact Auto
Activator Property SigfLootChest Auto

Event OnInit()
	if IsRunning()
		RegisterForSingleUpdate(6.0)
	endif
EndEvent

Event OnUpdate()
	Actor p = Game.GetPlayer()
	p.AddItem(SigfWoodBundle, 12, true)
	p.AddItem(SigfScarRound, 60, true)
	p.AddSpell(SigfBuildWall, false)
	p.AddSpell(SigfBuildRamp, false)
	p.AddSpell(SigfBuildFloor, false)
	RegisterForAnimationEvent(p, "bowRelease")
	SigfLib.Log("mod ready")
EndEvent

bool Function IsScar(Weapon w)
	return w == SigfScarCommon || w == SigfScarUncommon || w == SigfScarRare || w == SigfScarEpic || w == SigfGoldScar
EndFunction

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	Actor p = Game.GetPlayer()
	Weapon w = p.GetEquippedWeapon(false)
	if IsScar(w)
		SigfFx.Burst(p, Game.FindClosestActor(p.GetPositionX(), p.GetPositionY(), p.GetPositionZ(), 1500.0), w, SigfScarRound, WPNBowFire, 4, 0.07, SigfMuzzleFlash, None, 14.0, None, SigfBulletGlow)
	endif
EndEvent
