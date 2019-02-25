//=============================================================================
// AugAqualung.
//=============================================================================
class AugAqualung extends Augmentation;

var float mult, pct;

var float mpAugValue;
var float mpEnergyDrain;

state Active
{
	function Tick(float deltaTime)
	{ //Justice: The player now gains energy instead of losing it
		if(player.IsInState('PlayerSwimming') && player.energy < 25 * currentLevel)
			EnergyRate = -25 * currentLevel;
		else
			EnergyRate = 0;
	}
	
Begin:
	mult = Player.SkillSystem.GetSkillLevelValue(class'SkillSwimming');
	pct = Player.swimTimer / Player.swimDuration;
	Player.UnderWaterTime = LevelValues[CurrentLevel];
	Player.swimDuration = Player.UnderWaterTime * mult;
	Player.swimTimer = Player.swimDuration * pct;

	if (( Level.NetMode != NM_Standalone ) && Player.IsA('Human') )
	{
		mult = Player.SkillSystem.GetSkillLevelValue(class'SkillSwimming');
		Player.WaterSpeed = Human(Player).Default.mpWaterSpeed * 2.0 * mult;
	}
}

function Deactivate()
{
	Super.Deactivate();
	
	mult = Player.SkillSystem.GetSkillLevelValue(class'SkillSwimming');
	pct = Player.swimTimer / Player.swimDuration;
	Player.UnderWaterTime = Player.Default.UnderWaterTime;
	Player.swimDuration = Player.UnderWaterTime * mult;
	Player.swimTimer = Player.swimDuration * pct;

	if (( Level.NetMode != NM_Standalone ) && Player.IsA('Human') )
	{
		mult = Player.SkillSystem.GetSkillLevelValue(class'SkillSwimming');
		Player.WaterSpeed = Human(Player).Default.mpWaterSpeed * mult;
	}
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
     mpAugValue=240.000000
     mpEnergyDrain=10.000000
     EnergyRate=0.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconAquaLung'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconAquaLung_Small'
     AugmentationName="Aqualung"
     Description="Soda lime exostructures imbedded in the alveoli of the lungs convert CO2 to O2, extending the time an agent can remain underwater, recovering some energy in the process.|n|nTECH ONE: Lung capacity is extended slightly.|n|nTECH TWO: Lung capacity is extended moderately and a small amount of energy is recovered.|n|nTECH THREE: Lung capacity is extended significantly and a moderate amount of energy is recovered.|n|nTECH FOUR: An agent can stay underwater indefinitely and recover a significant amount of energy."
     MPInfo="When active, you can stay underwater 12 times as long and swim twice as fast.  Energy Drain: Low"
     LevelValues(0)=30.000000
     LevelValues(1)=60.000000
     LevelValues(2)=120.000000
     LevelValues(3)=240.000000
     LevelValues(4)=360.000000
     AugmentationLocation=LOC_Torso
     AugType=passive
     MPConflictSlot=9
}
