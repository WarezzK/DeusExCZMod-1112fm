class ChallengeNoSkills extends Challenge;

var string quote;

simulated function PreBeginPlay()
{
	local int i;
	
	Super.PreBeginPlay();
	
	Description = chr(34) $ quote $ chr(34);
	Description = Description $ "|n|nDon't upgrade any skills.|n|nHints:|n-Your initial training in pistols counts, so be sure to downgrade it before starting a new game.";
	Description = Description $ "|n-Some weapons don't require a high skill level to be effective.|n-Look for usernames and passwords hidden in datacubes.";
}

defaultproperties
{
     quote="The man you have consistently failed to slow, let alone capture, is by all standards simply that - an ordinary man. How can you have failed to apprehend him?"
     ChallengeName="No Skills"
}
