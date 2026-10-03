Scriptname SigfFx Hidden
{Gun effects: a burst of SCAR rounds, each with a muzzle flash, a shot sound, a glowing tracer streak, a hit flash on the target and real damage.}

Function Burst(Actor shooter, Actor target, Weapon w, Ammo a, Sound snd, int n, float gap, Light flash, Explosion hit, float dmg, Spell tracer = None, Light spark = None, Static trail = None, EffectShader hitFx = None) global
	int i = 0
	while i < n
		if !tracer
			w.Fire(shooter, a)
		endif
		if tracer && target
			tracer.Cast(shooter, target)
		endif
		snd.Play(shooter)
		float yaw = shooter.GetAngleZ()
		float sx = shooter.GetPositionX() + Math.Sin(yaw) * 70.0
		float sy = shooter.GetPositionY() + Math.Cos(yaw) * 70.0
		float sz = shooter.GetPositionZ() + 105.0
		ObjectReference f = shooter.PlaceAtMe(flash)
		f.MoveTo(shooter, 0.0, 0.0, 110.0, false)
		; a glowing tracer streak flies from the muzzle to the target
		ObjectReference tr = None
		if trail
			float tx = sx + Math.Sin(yaw) * 1400.0
			float ty = sy + Math.Cos(yaw) * 1400.0
			float tz = sz
			if target
				tx = target.GetPositionX()
				ty = target.GetPositionY()
				tz = target.GetPositionZ() + 95.0
				yaw = shooter.GetAngleZ() + shooter.GetHeadingAngle(target)
			endif
			tr = shooter.PlaceAtMe(trail)
			tr.SetScale(0.07)
			tr.SetPosition(sx, sy, sz)
			tr.SetAngle(90.0, 0.0, yaw)
			int t3 = 0
			while !tr.Is3DLoaded() && t3 < 6
				Utility.Wait(0.02)
				t3 += 1
			endwhile
			tr.TranslateTo(tx, ty, tz, 90.0, 0.0, yaw, 7000.0)
		endif
		ObjectReference sp = None
		if target && !target.IsDead()
			if hit
				target.PlaceAtMe(hit)
			endif
			if spark
				sp = target.PlaceAtMe(spark)
				sp.MoveTo(target, 0.0, 0.0, 90.0, false)
			endif
			if hitFx
				hitFx.Play(target, 0.3)
			endif
			target.StartCombat(shooter)
			target.DamageActorValue("Health", dmg)
		endif
		Utility.Wait(gap)
		f.Delete()
		if sp
			sp.Delete()
		endif
		if tr
			tr.Disable()
			tr.Delete()
		endif
		i += 1
	endwhile
EndFunction
