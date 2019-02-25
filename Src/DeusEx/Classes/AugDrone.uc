//=============================================================================
// AugDrone.
//=============================================================================
class AugDrone extends Augmentation;

//Justice: Modified to be better at spying

var float mpAugValue;
var float mpEnergyDrain;

var float reconstructTime;
var float lastDroneTime;

var float lastTickTime;

state Active
{
Begin:
	if (Level.TimeSeconds - lastDroneTime < reconstructTime)
	{
		Player.ClientMessage("Reconstruction will be complete in" @ Int(reconstructTime - (Level.TimeSeconds - lastDroneTime)) @ "seconds");
		Deactivate();
	}
	else
	{
		Player.bSpyDroneActive = True;
		Player.spyDroneLevel = CurrentLevel;
		Player.spyDroneLevelValue = LevelValues[CurrentLevel];
	}
}

function Tick(float deltaTime)
{
	if(DeusExGameInfo(Level.Game) != None)
		if(lastTickTime <= DeusExGameInfo(Level.Game).PauseStartTime) //== Pause time offset
			lastDroneTime += (DeusExGameInfo(Level.Game).PauseEndTime - DeusExGameInfo(Level.Game).PauseStartTime);

	Super.Tick(deltaTime);

	lastTickTime = Level.TimeSeconds;
}

function Deactivate()
{
	Super.Deactivate();

	// record the time if we were just active
	if (Player.bSpyDroneActive)
		lastDroneTime = Level.TimeSeconds;

	if(player.activeComputer != None) //Justice: If the drone was accessing a computer, turn it off
		player.activeComputer.termwindow.CloseScreen("EXIT");
		
	Player.bSpyDroneActive = False;
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		LevelValues[3] = mpAugValue;
		EnergyRate = mpEnergyDrain;
	}
}

defaultproperties
{
     mpAugValue=100.000000
     mpEnergyDrain=20.000000
     reconstructTime=30.000000
     lastDroneTime=30.000000
     EnergyRate=100.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconDrone'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconDrone_Small'
     AugmentationName="Spy Drone"
     Description="Advanced nanofactories can assemble a spy drone upon demand which can then be remotely controlled by the agent until released or destroyed, at which a point a new drone will be assembled.|n|nTECH ONE: The drone moves slowly and has a very light EMP attack.|n|nTECH TWO: The drone gains the ability to gather intel from datacubes, gets a slight speed boost, and has a light EMP attack.|n|nTECH THREE: The drone can interact with simple objects such as buttons, gets a moderate speed boost and has a medium EMP attack.|n|nTECH FOUR: The drone can operate computers, gets a large speed boost and has a strong EMP attack."
     MPInfo="Activation creates a remote-controlled spy drone.  Deactivation disables the drone.  Firing while active detonates the drone in a massive EMP explosion.  Energy Drain: Medium"
     LevelValues(0)=10.000000
     LevelValues(1)=20.000000
     LevelValues(2)=35.000000
     LevelValues(3)=50.000000
     LevelValues(4)=65.000000
     MPConflictSlot=7
}
