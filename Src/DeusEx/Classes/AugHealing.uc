//=============================================================================
// AugHealing.
//=============================================================================
class AugHealing extends Augmentation;

//Justice: Modified to work like modern shooters (Automatic)

var float mpAugValue;
var float mpEnergyDrain;

var int haloTimer;

state Active
{
	function Timer()
	{
		if (Player.Health < 100 && Player.Energy > 0 && !Player.IsInState('Dying'))
		{
			if(haloTimer <= 0)
			{
				EnergyRate = 300.0;
				//Player.HealPlayer(Int(LevelValues[CurrentLevel]), False);
				Switch(CurrentLevel)
				{
					case 0:
						Player.HealPlayer(5, False);
						break;
					case 1:
						Player.HealPlayer(10, False);
						break;
					case 2:
						Player.HealPlayer(15, False);
						break;
					case 3:
						Player.HealPlayer(20, False);
						break;
					case 4:
						Player.HealPlayer(25, False);
						break;
				}
				
				if (!Player.NanoMod.disableClientFlash)
				Player.ClientFlash(0.5, vect(0, 0, 500));
			}
			else if(haloTimer > 0)
			{
				haloTimer--;
				EnergyRate = 0.0;
			}
		}
		else
		{
			haloTimer = levelValues[currentLevel];
			EnergyRate = 0.0;
		}
	}
	
Begin:

haloTimer = levelValues[currentLevel];
setTimer(1.0, True);

}

function Deactivate()
{
	Super.Deactivate();
	
	setTimer(1.0, False);
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
     mpAugValue=10.000000
     mpEnergyDrain=100.000000
     EnergyRate=0.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconHealing'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconHealing_Small'
     EnergyRateLabel="Energy Rate: 300 Units/Minute while healing"
     AugmentationName="Regeneration"
     Description="Programmable polymerase automatically directs construction of proteins in injured cells, restoring an agent to full health over time.  There is a delay while the polymerase reconfigures itself to address the injured cells.  Further damage will disrupt the process, causing it to start over.|n|nTECH ONE: Healing occurs after a long delay.|n|nTECH TWO: Healing occurs after a moderate delay.|n|nTECH THREE: Healing occurs after a short delay.|n|nTECH FOUR: Healing occurs almost immediately."
     MPInfo="When active, you heal, but at a rate insufficient for healing in combat.  Energy Drain: High"
     LevelValues(0)=10.000000
     LevelValues(1)=7.500000
     LevelValues(2)=5.000000
     LevelValues(3)=2.500000
     LevelValues(4)=1.000000
     AugmentationLocation=LOC_Torso
     AugType=automatic
     MPConflictSlot=2
}
