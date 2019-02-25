Class ChallengePacifist extends Challenge;

//Justice: I have to do this here because silly old defaultproperties doesn't let you call functions
simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	//Justice: And I have to do this over multiple statements because silly old Tim Sweeney didn't think we would need to concatenate more than 256 characters at a time
	Description = chr(34) $ "Violence is the mark of the amateur.  Don't kill anyone." $ chr(34);
	Description = Description $ "|n|nUse non-lethal weapons or evade enemies to avoid killing them.|n|nHints:|n-Killing animals or robots will not fail this challenge.";
	Description = Description $ "|n-You are not responsible for preventing the deaths of others, only not causing them yourself.|n-You ARE responsible for the well being of anybody you have rendered unconscious.  Make sure to keep them out of harm's way.";
}

defaultproperties
{
     ChallengeName="Non-Lethal"
}
