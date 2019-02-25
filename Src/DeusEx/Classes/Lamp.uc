//=============================================================================
// Lamp.
//=============================================================================
class Lamp extends Furniture
	abstract;

var() bool bOn;

function bool Facelift(bool bOn2)
{
	if(!Super.Facelift(bOn2))
		return false;
	
	ResetScaleGlow();

	return true;
}

function Frob(Actor Frobber, Inventory frobWith)
{
	Super.Frob(Frobber, frobWith);

	if (!bOn)
	{
		bOn = True;
		
		PlaySound(sound'Switch4ClickOn');
	}
	else
	{
		bOn = False;
		
		PlaySound(sound'Switch4ClickOff');
	}
	
	ResetScaleGlow();
}

function ResetScaleGlow()
{
	Super.ResetScaleGlow();

	if (bOn)
	{
		LightType = LT_Steady;
		
		if (bInvincible)
		ScaleGlow = 2.0;
		
		else
		ScaleGlow *= 2.0;
	}
	
	else
	{
		LightType = LT_None;
		
		if (bInvincible)
		ScaleGlow = 1.0;
	}
	
	bUnlit = bOn;
}

defaultproperties
{
     FragType=Class'DeusEx.GlassFragment'
     bPushable=False
     LightBrightness=255
     LightSaturation=255
     LightRadius=10
}
