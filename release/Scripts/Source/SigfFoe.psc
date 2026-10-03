Scriptname SigfFoe extends Actor
{Storm soldiers: they pull out their SCAR when they load, a kill-feed line when they fall, and loot for the winner.}

string Property Label = "Storm Soldier" Auto
MiscObject Property SigfWoodBundle Auto
Potion Property SigfShieldPotion Auto
Weapon Property SigfScarRare Auto
Ammo Property SigfScarRound Auto
EffectShader Property EnchPurpleFXShader Auto
EffectShader Property GhostFXShaderNew Auto
Explosion Property SigfChestPop Auto
bool armed = false

Event OnLoad()
	if armed
		return
	endif
	armed = true
	AddItem(SigfScarRare, 1, true)
	AddItem(SigfScarRound, 80, true)
	EquipItem(SigfScarRare, false, true)
	EquipItem(SigfScarRound, false, true)
	EnchPurpleFXShader.Play(self, -1.0)
	SetScale(1.25)
EndEvent

Event OnDeath(Actor akKiller)
	Debug.Notification("Eliminated " + Label + "!")
	GhostFXShaderNew.Play(self, 3.0)
	int r = Utility.RandomInt(1, 100)
	if r <= 55
		PlaceAtMe(SigfWoodBundle)
	elseif r <= 80
		PlaceAtMe(SigfShieldPotion)
	endif
EndEvent
