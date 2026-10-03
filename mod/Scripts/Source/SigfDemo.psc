Scriptname SigfDemo extends Quest
{The demo (pilot.ps1 starts it with "startquest SigfDemo" when the recording begins): the bot drops onto a wooden build island, opens a
gold Loot Chest that bursts into rarity beams and SCARs, takes the Gold SCAR and shoots the first Storm wave, builds a 3-level wood
tower under fire (filmed from a film-crew camera actor), then wins from the high ground and dances.}

Activator Property SigfLootChest Auto
Weapon Property SigfGoldScar Auto
Ammo Property SigfScarRound Auto
Sound Property WPNBowFire Auto
MiscObject Property SigfWoodBundle Auto
Sound Property NPCHumanWoodPlace Auto
EffectShader Property GhostFXShaderNew Auto
ActorBase Property SigfStormGrunt Auto
ActorBase Property SigfStormArcher Auto
ActorBase Property SigfCameraman Auto
Static Property SigfWoodWall Auto
Static Property SigfWoodFloor Auto
Static Property SigfWoodRamp Auto
Static Property SigfBeamGold Auto
EffectShader Property EnchArmorFireFXS Auto
Light Property SigfMuzzleFlash Auto
Light Property SigfBulletGlow Auto
Actor cam

Event OnInit()
	; OnInit also runs once at game start for quests that are not running: act only when started.
	if IsRunning()
		RegisterForSingleUpdate(0.5)
	endif
EndEvent

Event OnUpdate()
	RunDemo()
EndEvent

; The film-crew camera: an invisible, frozen actor the game camera follows (the camera sits behind it, looking where it faces).
Function CamAt(float x, float y, float z, float yaw)
	Actor p = Game.GetPlayer()
	if !cam
		cam = p.PlaceAtMe(SigfCameraman, 1, false, false) as Actor
		int t = 0
		while !cam.Is3DLoaded() && t < 40
			Utility.Wait(0.05)
			t += 1
		endwhile
		cam.SetAlpha(0.0, false)
		cam.SetGhost(true)
		cam.SetRestrained(true)
		cam.StopCombat()
	endif
	cam.SetPosition(x, y, z)
	cam.SetAngle(0.0, 0.0, yaw)
	Game.SetCameraTarget(cam)
EndFunction

Function CamOff()
	Game.SetCameraTarget(Game.GetPlayer())
EndFunction

; The arena: a big flat wooden deck floating above the hills, so the build, the chest and the fight are all in open view.
Function Arena(float x, float y, float z)
	Actor p = Game.GetPlayer()
	int i = 0
	while i < 3
		int j = 0
		while j < 3
			ObjectReference t = p.PlaceAtMe(SigfWoodFloor, 1, false, false)
			t.SetScale(2.8)
			t.SetPosition(x + (i - 1) * 790.0, y + (j - 1) * 790.0, z + ((i + j) % 2) * 1.5)
			t.SetAngle(0.0, 0.0, 0.0)
			j += 1
		endwhile
		i += 1
	endwhile
	p.SetPosition(x, y, z + 80.0)
	Utility.Wait(0.4)
EndFunction

; one burst of the gold SCAR at a target: muzzle flash, tracers, hit flashes, damage
Function Shoot(Actor p, Actor t, int n, float dmg)
	SigfLib.FaceTo(p, t)
	SigfFx.Burst(p, t, SigfGoldScar, SigfScarRound, WPNBowFire, n, 0.07, SigfMuzzleFlash, None, dmg, None, SigfBulletGlow, SigfBeamGold, EnchArmorFireFXS)
EndFunction

; callable from the console while developing: cqf SigfDemo RunDemo
Function RunDemo()
	Debug.Trace("SIGF_DEMO start")
	Actor p = Game.GetPlayer()
	p.AddItem(SigfWoodBundle, 30, true)
	p.AddItem(SigfScarRound, 120, true)
	float h = p.GetAngleZ()
	SigfLib.Say("Dropping onto the build island...")
	Arena(p.GetPositionX(), p.GetPositionY(), p.GetPositionZ() + 1100.0)
	p.SetAngle(0.0, 0.0, h)
	float px = p.GetPositionX()
	float py = p.GetPositionY()
	float pz = p.GetPositionZ()
	float fx = Math.Sin(h)
	float fy = Math.Cos(h)
	float rx = Math.Cos(h)
	float ry = -Math.Sin(h)
	Debug.Trace("SIGF_ARENA z " + pz)

	; 1. the chest: a gold Loot Chest ahead; the bot runs up and cracks it open: five rarity beams shoot up, every SCAR flies out
	SigfLib.Say("A Loot Chest! Crack it open...")
	ObjectReference chest = SigfLib.Place(SigfLootChest, "chest", 520.0, 0.0)
	SigfBuild.Wheel(-4)
	chest.SetScale(1.6)
	chest.SetAngle(0.0, 0.0, h + 180.0)
	SigfChest c = chest as SigfChest
	c.Tier = 6
	SigfBuild.KeyDown()
	float tr = 0.0
	while tr < 3.5 && p.GetDistance(chest) > 380.0
		Utility.Wait(0.1)
		tr += 0.1
	endwhile
	SigfBuild.KeyUp()
	chest.Activate(p)
	Utility.Wait(6.0)

	; 2. the bot takes everything and holds the Legendary Gold SCAR
	c.Collect(p, 0.08)
	SigfLib.Say("Legendary Gold SCAR acquired!")
	p.EquipItem(SigfGoldScar, false, true)
	p.EquipItem(SigfScarRound, false, true)
	p.DrawWeapon()
	Utility.Wait(0.5)

	; 3. wave one drops in close; the camera moves to the bot's front-right so the gold SCAR is in view
	SigfLib.Say("The Storm is closing in!")
	Actor[] w1 = new Actor[3]
	w1[0] = Spawn(SigfStormGrunt, "grunt", px + fx * 560.0 - rx * 230.0, py + fy * 560.0 - ry * 230.0)
	w1[1] = Spawn(SigfStormGrunt, "grunt", px + fx * 600.0 + rx * 250.0, py + fy * 600.0 + ry * 250.0)
	w1[2] = Spawn(SigfStormArcher, "archer", px + fx * 700.0, py + fy * 700.0)
	int i = 0
	while i < 3
		w1[i].StartCombat(p)
		i += 1
	endwhile
	SigfBuild.Wheel(6)
	Utility.Wait(0.6)
	int guard = 0
	while guard < 10 && !AllDead(w1)
		Actor t = Nearest(w1)
		if t
			Shoot(p, t, 4, 42.0)
		endif
		Utility.Wait(0.2)
		guard += 1
	endwhile
	SigfLib.Say("3 eliminated! Build up!")

	; 4. wave two arrives while the bot builds walls and a 3-level tower; the camera stands off to the side so the whole tower is in frame
	Actor[] foes = new Actor[3]
	foes[0] = Spawn(SigfStormGrunt, "grunt", px + fx * 800.0 + rx * 300.0, py + fy * 800.0 + ry * 300.0)
	foes[1] = Spawn(SigfStormGrunt, "grunt", px + fx * 850.0 - rx * 350.0, py + fy * 850.0 - ry * 350.0)
	foes[2] = Spawn(SigfStormArcher, "archer", px + rx * 750.0 - fx * 350.0, py + ry * 750.0 - fy * 350.0)
	i = 0
	while i < 3
		foes[i].StartCombat(p)
		i += 1
	endwhile
	SigfBuild.Wheel(-8)
	p.SetAngle(0.0, 0.0, h)
	float cx = px + fx * 220.0 - rx * 220.0
	float cy = py + fy * 220.0 - ry * 220.0
	float vy = h - 45.0
	SigfBuild.Piece("wall", SigfWoodWall, SigfWoodFloor, SigfWoodRamp, SigfWoodBundle, NPCHumanWoodPlace, GhostFXShaderNew, 150.0, 330.0)
	SigfBuild.Piece("wall", SigfWoodWall, SigfWoodFloor, SigfWoodRamp, SigfWoodBundle, NPCHumanWoodPlace, GhostFXShaderNew, 150.0, -330.0)
	SigfLib.Say("Build! A wood tower, three levels high...")
	float yaw = h
	float fz = pz
	int lv = 0
	while lv < 3
		float qx = p.GetPositionX()
		float qy = p.GetPositionY()
		float sy = Math.Sin(yaw)
		float cyaw = Math.Cos(yaw)
		Debug.Trace("SIGF_LV " + lv + " start " + qx + " " + qy + " fz " + fz + " playerz " + p.GetPositionZ() + " yaw " + yaw)
		SigfBuild.Put(SigfWoodRamp, qx, qy, fz - 12.0, yaw, SigfWoodBundle, NPCHumanWoodPlace, GhostFXShaderNew, 0.12, 60.0)
		SigfBuild.KeyDown()
		SigfBuild.Put(SigfWoodFloor, qx + 472.0 * sy, qy + 472.0 * cyaw, fz + 195.0, yaw, SigfWoodBundle, NPCHumanWoodPlace, GhostFXShaderNew, 0.04)
		SigfBuild.Climb(185.0, yaw, fz, qx, qy)
		float stopAt = 440.0
		if lv == 2
			stopAt = 545.0
		endif
		float tw = 0.0
		while tw < 2.0 && Math.Sqrt((p.GetPositionX() - qx) * (p.GetPositionX() - qx) + (p.GetPositionY() - qy) * (p.GetPositionY() - qy)) < stopAt
			Utility.Wait(0.1)
			tw += 0.1
		endwhile
		SigfBuild.KeyUp()
		fz += 195.0
		lv += 1
		SigfLib.Say("Level " + lv + "!")
		if lv < 3
			yaw -= 90.0
			p.SetAngle(0.0, 0.0, yaw)
			SigfBuild.Jump()
			Utility.Wait(0.3)
		endif
	endwhile
	SigfLib.Say("High ground!")
	Utility.Wait(1.5)

	; 5. from the top deck the gold SCAR rains down on wave two (camera back on the bot, over the shoulder)
	SigfBuild.Wheel(7)
	guard = 0
	while guard < 16 && !AllDead(foes)
		Actor t2 = Nearest(foes)
		if t2
			Shoot(p, t2, 4, 46.0)
		endif
		Utility.Wait(0.2)
		guard += 1
	endwhile

	; 6. victory: the camera goes back to the side so the whole tower is in frame while the bot dances on top
	Debug.Trace("SIGF_END playerz " + p.GetPositionZ())
	SigfLib.Say("VICTORY ROYALE!")
	SigfBuild.Wheel(-8)
	SigfLib.Shake(0.3, 1.0)
	int dance = 0
	while dance < 8
		SigfBuild.Jump()
		p.SetAngle(0.0, 0.0, p.GetAngleZ() + 60.0)
		SigfFx.Burst(p, None, SigfGoldScar, SigfScarRound, WPNBowFire, 3, 0.07, SigfMuzzleFlash, None, 0.0, None, None, SigfBeamGold, None)
		Utility.Wait(0.4)
		dance += 1
	endwhile
	Utility.Wait(1.0)
	Debug.Trace("SIGF_DEMO end")
EndFunction

Actor Function Spawn(ActorBase b, string tag, float x, float y)
	Actor a = SigfLib.Spawn(b, tag, 400.0, 0.0)
	a.MoveTo(Game.GetPlayer(), 0.0, 0.0, 0.0, false)
	a.SetPosition(x, y, Game.GetPlayer().GetPositionZ() + 60.0)
	SigfLib.FaceTo(a, Game.GetPlayer())
	return a
EndFunction

bool Function AllDead(Actor[] a)
	int i = 0
	while i < a.Length
		if a[i] && !a[i].IsDead()
			return false
		endif
		i += 1
	endwhile
	return true
EndFunction

Actor Function Nearest(Actor[] a)
	Actor best = None
	float bd = 100000.0
	int i = 0
	while i < a.Length
		if a[i] && !a[i].IsDead()
			float d = a[i].GetDistance(Game.GetPlayer())
			if d < bd
				bd = d
				best = a[i]
			endif
		endif
		i += 1
	endwhile
	return best
EndFunction
