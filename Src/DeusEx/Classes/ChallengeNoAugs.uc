class ChallengeNoAugs extends Challenge;

var string quote;

simulated function PreBeginPlay()
{
	local int i;
	
	Super.PreBeginPlay();
	
	Description = chr(34) $ quote $ chr(34);
	Description = Description $ "|n|nDon't install any augmentations other than the ones you start with.|n|nHints:|n-Look for alternative ways to replicate augmentations.  There are 'mundane' equivalents to most of them.";
}

defaultproperties
{
     quote="The individual worker -- careerist, let's say -- seldom understands how his small labor contributes to human history. Seemingly innocuous innovations in cell biology, nanotechnology, and computer science add up to a teeming substrate of new life. But it isn't life. It's death. It seeks to devour its clumsy, organic creators."
     ChallengeName="No Augmentations"
}
