Class ChallengeOSP extends Challenge;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	Description = chr(34) $ "For the past seven years I have done nothing but travel around the world getting shot up, locked up, blown up... and all I have to show for it are a couple of empty rolls of duct tape." $ chr(34);
	Description = Description $ "|n|nStart every mission empty-handed, and work your way up from there.|n|nHints:|n-Entering a vehicle usually signifies the end of a mission, so empty your inventory before doing so.";
}

defaultproperties
{
     ChallengeName="On-Site Procurement"
     completed(1)=-1
}
