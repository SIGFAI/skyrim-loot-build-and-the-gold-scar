Scriptname SigfChest extends ObjectReference
{A glowing Loot Chest: activate it and it bursts open, throwing out a pile of loot with rarity glows.}

Weapon Property SigfScarCommon Auto
Weapon Property SigfScarUncommon Auto
Weapon Property SigfScarRare Auto
Weapon Property SigfScarEpic Auto
Weapon Property SigfGoldScar Auto
Potion Property SigfShieldPotion Auto
MiscObject Property SigfWoodBundle Auto
Ammo Property SigfScarRound Auto
Explosion Property SigfChestPop Auto
Explosion Property SigfScarImpact Auto
Explosion Property FXdustDropMedExplosion Auto
Activator Property DLC1DawnguardLightBeam01 Auto
Static Property SigfBeamCommon Auto
Static Property SigfBeamUncommon Auto
Static Property SigfBeamRare Auto
Static Property SigfBeamEpic Auto
Static Property SigfBeamGold Auto
Sound Property DRScCrateOpen Auto
Sound Property UILevelUp Auto
Light Property SigfGlowCommon Auto
Light Property SigfGlowUncommon Auto
Light Property SigfGlowRare Auto
Light Property SigfGlowEpic Auto
Light Property SigfGlowGold Auto
Light Property SigfChestGlow Auto
Light Property SigfBurstFlash Auto
EffectShader Property EnchGreenFXShader Auto
EffectShader Property EnchArmorStaminaFXS Auto
EffectShader Property GhostFXShaderNew Auto
EffectShader Property EnchPurpleFXShader Auto
EffectShader Property EnchArmorFireFXS Auto

; 0 = random rarity, 1..5 = forced (5 = legendary Gold SCAR)
int Property Tier = 0 Auto
bool opened = false
ObjectReference myLight
ObjectReference myBeam
ObjectReference[] drops
ObjectReference[] beams
int nBeams = 0
int nDrops = 0

Event OnLoad()
	; the closed chest glows gold so it is easy to spot: shader, a gold light and a light beam over it
	if opened || myLight
		return
	endif
	myLight = PlaceAtMe(SigfChestGlow)
	myLight.MoveTo(self, 0.0, 0.0, 90.0, false)
	myBeam = PlaceAtMe(SigfBeamGold)
	myBeam.SetScale(0.5)
EndEvent

Event OnActivate(ObjectReference akActionRef)
	if !opened && akActionRef == Game.GetPlayer()
		Burst()
	endif
EndEvent

Function Burst()
	if opened
		return
	endif
	opened = true
	if myLight
		myLight.Delete()
	endif
	if myBeam
		myBeam.Delete()
	endif
	drops = new ObjectReference[16]
	beams = new ObjectReference[16]
	nBeams = 0
	nDrops = 0
	DRScCrateOpen.Play(self)
	ObjectReference flash = PlaceAtMe(SigfBurstFlash)
	flash.MoveTo(self, 0.0, 0.0, 120.0, false)
	PlayAnimation("Open")
	SigfLib.Shake(0.35, 0.6)
	; the weapon: rarity by roll, or forced
	int t = Tier
	if t == 0
		int roll = Utility.RandomInt(1, 100)
		if roll <= 30
			t = 1
		elseif roll <= 58
			t = 2
		elseif roll <= 80
			t = 3
		elseif roll <= 94
			t = 4
		else
			t = 5
		endif
	endif
	Weapon w = SigfScarCommon
	Static bm = SigfBeamCommon
	Light glow = SigfGlowCommon
	EffectShader fx = None
	if t == 2
		w = SigfScarUncommon
		bm = SigfBeamUncommon
		glow = SigfGlowUncommon
		fx = EnchGreenFXShader
	elseif t == 3
		w = SigfScarRare
		bm = SigfBeamRare
		glow = SigfGlowRare
		fx = GhostFXShaderNew
	elseif t == 4
		w = SigfScarEpic
		bm = SigfBeamEpic
		glow = SigfGlowEpic
		fx = EnchPurpleFXShader
	elseif t == 5
		w = SigfGoldScar
		bm = SigfBeamGold
		glow = SigfGlowGold
		fx = EnchArmorFireFXS
		UILevelUp.Play(self)
	endif
	if Tier == 6
		Drop(SigfScarCommon, 1, -400.0, 60.0, EnchArmorStaminaFXS, SigfGlowCommon, false, 4.0, 150.0, SigfBeamCommon)
		Drop(SigfScarUncommon, 1, -200.0, 110.0, EnchGreenFXShader, SigfGlowUncommon, false, 4.0, 180.0, SigfBeamUncommon)
		Drop(SigfScarRare, 1, 0.0, 150.0, GhostFXShaderNew, SigfGlowRare, false, 4.0, 210.0, SigfBeamRare)
		Drop(SigfScarEpic, 1, 200.0, 110.0, EnchPurpleFXShader, SigfGlowEpic, false, 4.0, 180.0, SigfBeamEpic)
		Drop(SigfGoldScar, 1, 400.0, 60.0, EnchArmorFireFXS, SigfGlowGold, false, 5.5, 160.0, SigfBeamGold)
		Utility.Wait(0.5)
		Drop(SigfShieldPotion, 1, -60.0, 200.0, GhostFXShaderNew, SigfGlowRare)
		Drop(SigfWoodBundle, 2, 60.0, 200.0, None, None)
		Drop(SigfScarRound, 20, 0.0, 240.0, EnchGreenFXShader, None)
		flash.Delete()
		return
	endif
	; loot fans out beyond the chest (offsets are right/forward of the way the player faces)
	Drop(w, 1, 0.0, 60.0, fx, glow, false, 3.0, 0.0, bm)
	Drop(SigfShieldPotion, 1, 200.0, 70.0, GhostFXShaderNew, SigfGlowRare)
	Drop(SigfShieldPotion, 1, -40.0, 230.0, GhostFXShaderNew, SigfGlowRare)
	Drop(SigfWoodBundle, 2, 190.0, 200.0, None, None)
	Drop(SigfScarRound, 20, 20.0, 110.0, EnchGreenFXShader, None)
	Utility.Wait(1.2)
	flash.Delete()
EndFunction

Function Drop(Form f, int count, float dx, float dy, EffectShader fx, Light glow, bool hero = false, float big = 1.0, float hover = 0.0, Static beam = None)
	; dx = to the player's right, dy = toward the player (the chest faces the player), world positions computed here
	ObjectReference item = PlaceAtMe(f, count)
	drops[nDrops] = item
	nDrops += 1
	float a = Game.GetPlayer().GetAngleZ()
	float wx = GetPositionX() + dx * Math.Cos(a) - dy * Math.Sin(a)
	float wy = GetPositionY() - dx * Math.Sin(a) - dy * Math.Cos(a)
	float wz = GetPositionZ()
	item.SetPosition(GetPositionX(), GetPositionY(), wz + 100.0)
	int waited = 0
	while !item.Is3DLoaded() && waited < 30
		Utility.Wait(0.1)
		waited += 1
	endwhile
	if big > 1.0
		item.SetScale(big)
	endif
	if beam
		ObjectReference b = PlaceAtMe(beam)
		b.SetPosition(wx, wy, wz - 1700.0)
		int bw = 0
		while !b.Is3DLoaded() && bw < 20
			Utility.Wait(0.05)
			bw += 1
		endwhile
		b.TranslateTo(wx, wy, wz, 0.0, 0.0, 0.0, 2600.0)
		beams[nBeams] = b
		nBeams += 1
		Utility.Wait(0.3)
		Debug.Trace("SIGF_DROPDBG beam3d " + b.Is3DLoaded() + " z " + b.GetPositionZ())
	endif
	if hover > 0.0
		; a tall rarity beam shoots up where the loot will hang, then the loot flies out of the chest to it, spinning
		item.SetMotionType(4, false)
		item.TranslateTo(wx, wy, wz + hover, 0.0, 0.0, 720.0, 520.0, 360.0)
	else
		item.SetPosition(wx, wy, wz + 110.0)
	endif
	Debug.Trace("SIGF_DROPDBG item3d " + item.Is3DLoaded() + " z " + item.GetPositionZ() + " scale " + item.GetScale())
	Debug.Trace("SIGF_SPAWN drop " + wx + " " + wy + " " + (wz + hover) + " chest " + GetPositionX() + " " + GetPositionY() + " " + wz)
	if fx && item.Is3DLoaded()
		fx.Play(item, -1.0)
	endif
	if glow
		ObjectReference l = PlaceAtMe(glow)
		l.SetPosition(wx, wy, wz + hover + 40.0)
	endif
EndFunction

; Picks every dropped item up for the given actor, one by one (the demo bot uses this; players just walk up and take things).
Function Collect(Actor who, float gap)
	int i = 0
	while i < nDrops
		if drops[i]
			EnchArmorStaminaFXS.Stop(drops[i])
			EnchGreenFXShader.Stop(drops[i])
			GhostFXShaderNew.Stop(drops[i])
			EnchPurpleFXShader.Stop(drops[i])
			EnchArmorFireFXS.Stop(drops[i])
			drops[i].Activate(who)
			Utility.Wait(gap)
		endif
		i += 1
	endwhile
	i = 0
	while i < nBeams
		if beams[i]
			beams[i].Disable()
			beams[i].Delete()
		endif
		i += 1
	endwhile
EndFunction
