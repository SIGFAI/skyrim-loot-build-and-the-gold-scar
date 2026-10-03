Scriptname SigfBuildFx extends ActiveMagicEffect
{The three Build powers: casting one places a wood piece in front of the player.}

string Property Kind Auto
Static Property SigfWoodWall Auto
Static Property SigfWoodFloor Auto
Static Property SigfWoodRamp Auto
MiscObject Property SigfWoodBundle Auto
Sound Property NPCHumanWoodPlace Auto
EffectShader Property GhostFXShaderNew Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	SigfBuild.Piece(Kind, SigfWoodWall, SigfWoodFloor, SigfWoodRamp, SigfWoodBundle, NPCHumanWoodPlace, GhostFXShaderNew)
EndEvent
