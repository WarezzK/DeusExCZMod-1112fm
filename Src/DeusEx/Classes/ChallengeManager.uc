class ChallengeManager extends Actor
	config(User);

var Class<challenge> challengeClasses[15];
var travel challenge Firstchallenge;		// Pointer to first challenge

var travel int mission; //Justice: Mission number; 0 is for the overall game
var config string missionNames[30];
var config bool notifyChallenges;

function CreateChallenges()
{
	local int challengeIndex;
	local challenge achallenge;
	local challenge lastchallenge;

	Firstchallenge = None;
	Lastchallenge  = None;

	for(challengeIndex=0; challengeIndex<arrayCount(challengeClasses); challengeIndex++)
	{
		if (challengeClasses[challengeIndex] != None)
		{
			achallenge = Spawn(challengeClasses[challengeIndex], Self);

			// Manage our linked list
			if (achallenge != None)
			{
				if (Firstchallenge == None)
				{
					Firstchallenge = achallenge;
				}
				else
				{
					Lastchallenge.next = achallenge;
				}

				Lastchallenge  = achallenge;
			}
		}
	}
}

function addMission(String mName)
{
	local int mNum;

	mNum = DeusExPlayer(Owner).GetLevelInfo().missionNumber;
		
	if(mName == "NOCHALLENGES" || mNum < 1 || mNum == 98)
		return;

	if(mNum > 1)
		completeChallenges(False);
	
	if(mName == "DEFAULT")
		mName = "Mission " $ string(mNum);
	
	mission = mNum;
	missionNames[mNum] = mName;
	saveSettings();
}

function completeChallenges(bool gameOver)
{
	local Challenge c;
	local Human player;
	local name flagName;
	local int newDiff;
	
	player = Human(Owner);
	newDiff = convertDifficulty(player.combatDifficulty);
	
	c = firstChallenge;
	while(c != None)
	{
		if(c.completed[mission] != -1 && !player.FlagBase.GetBool(player.rootWindow.StringToName(c.class.name $ "_" $ string(mission) $ "_Failed")))
		{
			if(newDiff > c.completed[mission])
				c.completed[mission] = newDiff;
				
			if(notifyChallenges)
				player.clientMessage("Challenge completed: " $ c.ChallengeName $ " (" $ missionNames[mission] $ ")");
				
			flagName = player.rootWindow.StringToName(c.class.name $ "_" $ string(mission) $ "_Completed");
			player.flagBase.setBool(flagName, True);
			player.flagBase.SetExpiration(flagName, FLAG_Bool, 0);
		}
		
		if(gameOver)
		{
			if(!player.FlagBase.GetBool(player.rootWindow.StringToName(c.class.name $ "_Failed")))
			{
				if(newDiff > c.completed[0])
					c.completed[0] = newDiff;
					
				saveSettings();
			}
		}
			
		c = c.next;
	}
}

function SaveSettings()
{
	local Challenge c;
	
	c = firstChallenge;
	
	while(c != None)
	{
		c.SaveConfig();
		c = c.next;
	}
	
	saveConfig();
}

function notifyFailure(name cName)
{
	local challenge c;
	local DeusExPlayer player;
	
	player = DeusExPlayer(Owner);
	c = firstChallenge;
	while(c != None)
	{
		if(c.class.name == cName)
		{
			if(c.completed[mission] == -1 && player.flagBase.getBool(player.rootWindow.StringToName(c.class.name $ "_Failed")))
				return;
				
			player.clientMessage("Challenge failed: " $ c.ChallengeName);
			return;
		}
		
		c = c.next;
	}
}

function int convertDifficulty(float diff)
{
	switch(diff)
	{
		case 1.0:
			return 1;
			
		case 1.5:
			return 2;
			
		case 2.0: //Justice: Turns out hard actually ISNT harder than realistic.  Doy.
			return 3;
			
		case 4.0:
			return 4;
			
		case 4.1:
			return 5;
			
		default:
			return 0;
	}
}

defaultproperties
{
     challengeClasses(0)=Class'DeusEx.ChallengePacifist'
     challengeClasses(1)=Class'DeusEx.ChallengeNoGuns'
     challengeClasses(2)=Class'DeusEx.ChallengeOSP'
     challengeClasses(3)=Class'DeusEx.ChallengeNoAugs'
     challengeClasses(4)=Class'DeusEx.ChallengeNoSkills'
     missionNames(0)="Overall"
     bHidden=True
     bTravel=True
}
