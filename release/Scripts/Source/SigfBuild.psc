Scriptname SigfBuild Hidden
{Fortnite-style building: wood walls, floors and ramps, each costing one Wood Bundle.
A blue hologram of the piece shows first, then the solid piece pops up out of the ground.
Ramps are pre-sloped meshes (low edge at the origin, rising toward +Y), so they are placed with a yaw only.}

; kind = "wall", "floor" or "ramp". Placed in front of the player, snapped to the way the player faces.
; A ramp starts at the player's feet and rises away from the player; a wall stands across the way, a floor lies under.
Function Piece(string kind, Form wall, Form floor, Form ramp, MiscObject wood, Sound snd, EffectShader holo, float dist = 280.0, float side = 0.0) global
	Actor p = Game.GetPlayer()
	float a = p.GetAngleZ()
	float d = dist
	float s = side
	Form f = floor
	float yaw = a
	float lift = 3.0
	if kind == "wall"
		f = wall
		lift = 91.0
		yaw = a + 90.0
	elseif kind == "ramp"
		f = ramp
		lift = 8.0
		d = 30.0
		s = 0.0
	endif
	float x = p.GetPositionX() + d * Math.Sin(a) + s * Math.Cos(a)
	float y = p.GetPositionY() + d * Math.Cos(a) - s * Math.Sin(a)
	if Put(f, x, y, p.GetPositionZ() + lift, yaw, wood, snd, holo)
		SigfLib.Say("Built a wood " + kind + "  (" + p.GetItemCount(wood) + " wood left)")
	else
		SigfLib.Say("Out of wood! Open Loot Chests for Wood Bundles.")
	endif
EndFunction

; One piece at an exact place: hologram first, then the solid piece. Returns the piece (None without wood).
ObjectReference Function Put(Form f, float x, float y, float z, float yaw, MiscObject wood, Sound snd, EffectShader holo, float holoSecs = 0.2, float rise = 140.0) global
	Actor p = Game.GetPlayer()
	if p.GetItemCount(wood) < 1
		return None
	endif
	p.RemoveItem(wood, 1, true)
	ObjectReference g = p.PlaceAtMe(f, 1, false, true)
	g.SetScale(1.4)
	g.SetPosition(x, y, z)
	g.SetAngle(0.0, 0.0, yaw)
	g.EnableNoWait(false)
	int t = 0
	while !g.Is3DLoaded() && t < 40
		Utility.Wait(0.05)
		t += 1
	endwhile
	holo.Play(g, holoSecs)
	Utility.Wait(holoSecs)
	g.Disable()
	g.Delete()
	ObjectReference w = p.PlaceAtMe(f, 1, false, true)
	w.SetScale(1.4)
	w.SetPosition(x, y, z - rise)
	w.SetAngle(0.0, 0.0, yaw)
	w.EnableNoWait(true)
	t = 0
	while !w.Is3DLoaded() && t < 40
		Utility.Wait(0.05)
		t += 1
	endwhile
	w.TranslateTo(x, y, z, 0.0, 0.0, yaw, 900.0)
	Utility.Wait(rise / 900.0 + 0.1)
	; the collision stays where the piece started: set the final place again so Havok follows
	w.StopTranslation()
	w.SetPosition(x, y, z)
	w.SetAngle(0.0, 0.0, yaw)
	snd.Play(p)
	SigfLib.Shake(0.08, 0.2)
	Debug.Trace("SIGF_SPAWN build")
	return w
EndFunction

; Walks the player up a ramp for real: the pilot holds the forward key (it reads the SIGF_KEY lines of the log).
; Without a pilot the player would stand still, so after a short wait the climb is helped along by a slide.
; Returns once the player has gained `rise` units (or `maxSecs` passed).
Function Climb(float rise, float yaw, float z0, float x0, float y0, float maxSecs = 5.0) global
	Actor p = Game.GetPlayer()
	float t = 0.0
	bool helped = false
	while t < maxSecs && (p.GetPositionZ() - z0) < rise - 12.0
		Utility.Wait(0.1)
		t += 0.1
		if t > 1.4 && !helped && (p.GetPositionZ() - z0) < 6.0
			helped = true
			Debug.Trace("SIGF_NOPILOT climb helped")
			p.TranslateTo(x0 + 500.0 * Math.Sin(yaw), y0 + 500.0 * Math.Cos(yaw), z0 + 199.0, 0.0, 0.0, yaw, 300.0)
		endif
	endwhile
	Debug.Trace("SIGF_CLIMB dz " + (p.GetPositionZ() - z0) + " t " + t)
EndFunction

Function KeyUp() global
	Debug.Trace("SIGF_KEY up w")
EndFunction

Function Jump() global
	Debug.Trace("SIGF_KEY tap space")
EndFunction

Function KeyDown() global
	Debug.Trace("SIGF_KEY down w")
EndFunction

; zoom the third-person camera (positive = closer, negative = farther), done by the pilot through the mouse wheel
Function Wheel(int notches) global
	Debug.Trace("SIGF_KEY wheel " + notches)
EndFunction
