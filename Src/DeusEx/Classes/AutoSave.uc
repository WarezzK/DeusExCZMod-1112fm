class Autosave extends Actor
transient;

function PostBeginPlay()
{
	SetTimer(0.01, false);
}

function Timer()
{
	DeusExPlayer(GetPlayerPawn()).SaveGame(-3, "Auto Save"); //Justice: Autosave after loading a new map... this saves lives!
	Destroy();
}

defaultproperties
{
     bHidden=True
}
