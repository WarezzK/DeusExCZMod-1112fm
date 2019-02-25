Class ChallengeNoGuns extends Challenge;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	Description = chr(34) $ "This loud, clumsy, stupid thing -- this is the weapon of the enemy. We do not need it. We will not use it." $ chr(34);
	Description = Description $ "|n|nDon't fire anything that could be considered a gun.|n|nHints:|n-The mini-crossbow is safe to use but the pepper gun is NOT.|n";
	Description = Description $ "-Gun (noun): a weapon consisting of a metal tube, with mechanical attachments, from which projectiles are shot by the force of an explosive; a piece of ordnance.";
}

defaultproperties
{
     ChallengeName="No Guns"
}
