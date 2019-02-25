//=============================================================================
// MissionScript.
//=============================================================================
class MissionScript extends Info
	transient;
//	abstract; //== No longer abstract since we need to spawn it if no Mission Script is specified for a level

//
// State machine for each mission
// All flags set by this mission controller script should be
// prefixed with MS_ for consistency
//

var float checkTime;
var DeusExPlayer Player;
var FlagBase flags;
var string localURL;
var DeusExLevelInfo dxInfo;

var String emailFrom[25];
var String emailTo[25];
var String emailCC[25];
var localized String emailSubject[25];
var localized String emailString[25];

var String missionName; //Justice: Name of the mission for challenge purposes
var bool autoSaveValid;

// ----------------------------------------------------------------------
// PostPostBeginPlay()
//
// Set the timer
// ----------------------------------------------------------------------

function PostPostBeginPlay()
{
	// start the script
	SetTimer(checkTime, True);
}

// ----------------------------------------------------------------------
// InitStateMachine()
//
// Get the player's flag base, get the map name, and set the player
// ----------------------------------------------------------------------

function InitStateMachine()
{
	local DeusExLevelInfo info;
	local int i;

	Player = DeusExPlayer(GetPlayerPawn());

	foreach AllActors(class'DeusExLevelInfo', info)
		dxInfo = info;

	if (Player != None)
	{
		flags = Player.FlagBase;

		// Get the mission number by extracting it from the
		// DeusExLevelInfo and then delete any expired flags.
		//
		// Also set the default mission expiration so flags
		// expire in the next mission unless explicitly set
		// differently when the flag is created.

		if (flags != None)
		{
			// Don't delete expired flags if we just loaded
			// a savegame
			if (flags.GetBool('PlayerTraveling'))
				flags.DeleteExpiredFlags(dxInfo.MissionNumber);

			flags.SetDefaultExpiration(dxInfo.MissionNumber + 1);

			localURL = Caps(dxInfo.mapName);

			for(i = 0; emailSubject[i] != ""; i++)
			{
				dxInfo.emailSubject[i] = emailSubject[i];
				dxInfo.emailFrom[i] = emailFrom[i];
				dxInfo.emailTo[i] = emailTo[i];
				dxInfo.emailString[i] = emailString[i];
			}

			log("**** InitStateMachine() -"@player@" started mission state machine for "@localURL);
		}
		else
		{
			log("**** InitStateMachine() - flagBase not set - mission state machine NOT initialized!");
		}
	}
	else
	{
		log("**** InitStateMachine() - player not set - mission state machine NOT initialized!");
	}
}

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local name flagName;
	local ScriptedPawn P;
	local int i, t;
	local bool skillon;
	
	local Inventory item; //Justice: vars for challenge system
	local Augmentation aug;
	local Skill skill;
	
	local WeaponModAccuracy WMA;
	local Computers PC;

	flags.DeleteFlag('PlayerTraveling', FLAG_Bool);
	flags.DeleteFlag('NPCInventoryChecked', FLAG_Bool);

	if(!flags.GetBool('SkillPointsPendingCurrent'))
	{
		i = flags.GetInt('PendingSkillPoints');
		if(i > 0 && player.NanoMod.enableCombatPoints)
		{
			Player.ClientMessage("Calculating cumulative stealth bonus for previous mission");
			Player.SkillPointsAdd(i);
		}

		flags.SetBool('SkillPointsPendingCurrent',True,, dxInfo.MissionNumber + 1);

		i = 0;
	}
	else
		i = flags.GetInt('PendingSkillPoints');

	// Check to see which NPCs should be dead from prevous missions
	foreach AllActors(class'ScriptedPawn', P)
	{
		//== Also handle pending skill points for stealth bonuses
		if(P.PendingSkillPoints > 0 && i > 0)
		{
			i -= P.PendingSkillPoints;
		}
		if (P.bImportant)
		{
			flagName = Player.rootWindow.StringToName(P.BindName$"_Dead");
			if (flags.GetBool(flagName))
				P.Destroy();
		}
	}

	flags.SetInt('PendingSkillPoints', i,, 0);

	// print the mission startup text only once per map
	flagName = Player.rootWindow.StringToName("M"$Caps(dxInfo.mapName)$"_StartupText");
	if (!flags.GetBool(flagName) && (dxInfo.startupMessage[0] != ""))
	{
		for (i=0; i<ArrayCount(dxInfo.startupMessage); i++)
			DeusExRootWindow(Player.rootWindow).hud.startDisplay.AddMessage(dxInfo.startupMessage[i]);
		DeusExRootWindow(Player.rootWindow).hud.startDisplay.StartMessage();
		flags.SetBool(flagName, True);
	}

	if(flags.GetFloat('Travel_GameSpeed') > 0.0)
		Level.Game.SetGameSpeed(flags.GetFloat('Travel_GameSpeed'));

	flagName = Player.rootWindow.StringToName("M"$dxInfo.MissionNumber$"MissionStart");
	if (!flags.GetBool(flagName))
	{
		// Remove completed Primary goals and all Secondary goals
		Player.ResetGoals();

		// Remove any Conversation History.
		Player.ResetConversationHistory();

		// Set this flag so we only get in here once per mission.
		flags.SetBool(flagName, True);
	}
	
	if(!flags.getBool('ChallengesAdded'))
	{
		item = player.inventory;
				
		Human(Player).ChallengeSystem.addMission(missionName);
		
		if(dxInfo != None)
		{
			if(dxInfo.MissionNumber > 1)
			{
				while(item != None)
				{
					if(item.bDisplayableInv && !item.IsA('NanoKeyRing'))
					{
						Human(player).failChallenge("ChallengeOSP");
						//player.clientMessage(item);
					}
			
					item = item.Inventory;
				}
		
				if(player.augmentationSystem != None)
				{
					aug = player.augmentationSystem.firstAug;
			
					while(aug != None)
					{
						if(!aug.IsA('AugLight') && !aug.IsA('AugIFF') && !aug.IsA('AugDatalink') && aug.bHasIt)
						{
							Human(player).failChallenge("ChallengeNoAugs", true);
							break;
						}
				
						aug = aug.next;
					}
				}
			}
			
			if(player.skillSystem != None && dxInfo.MissionNumber >= 1)
			{
				skill = player.SkillSystem.firstSkill;
				
				while(skill != None)
				{
					if(skill.currentLevel > 0)
					{
						Human(player).failChallenge("ChallengeNoSkills", true);
						break;
					}
							
					skill = skill.next;
				}
			}
		}
	}
	flags.SetBool('ChallengesAdded',True,, dxInfo.MissionNumber + 1);

	if (localURL == "11_PARIS_EVERETT" ||
		localURL == "09_NYC_SHIP" || localURL == "08_NYC_UNDERGROUND" || localURL == "04_NYC_NSFHQ" ||
		localURL == "04_NYC_HOTEL" || localURL == "02_NYC_UNDERGROUND" || localURL == "01_NYC_UNATCOHQ")
	{
		flagName = Player.rootWindow.StringToName("M"$localURL$"_WMAR");
		
		if (!flags.GetBool(flagName))
		{
			foreach AllActors(class'WeaponModAccuracy', WMA)
			{
				if (WMA.Owner == None)
				{
					if (Spawn(class'WeaponModReload', None, ,WMA.Location, WMA.Rotation) != None)
					{
						WMA.Destroy();
						
						flags.SetBool(flagName, True);
					}
				}
			}
		}
	}

	foreach AllActors(class'Computers', PC)
	{
		if (PC.IsA('CumputerPublic'))
		continue;
		
		for (t = 0; t < PC.NumUsers(); t++)
		{
			if (localURL == "06_HONGKONG_HELIBASE" || localURL == "06_HONGKONG_VERSALIFE" || localURL == "06_HONGKONG_MJ12LAB" || localURL == "06_HONGKONG_STORAGE" ||
				(localURL == "11_PARIS_CATHEDRAL" && PC.Name != 'ComputerSecurity2') || dxInfo.MissionNumber >= 14)
				PC.userList[t].accessLevel = AL_Advanced;
				
			else if (Class'NetworkTerminal'.static.hasSpecialOptions(PC, PC.userList[t].userName))
				PC.userList[t].accessLevel = AL_Advanced;
			
			else
				PC.userList[t].accessLevel = AL_Untrained;
		}
		
		if (localURL == "03_NYC_AIRFIELDHELIBASE" && PC.GetUserName(0) == "etodd")
		{
			if (flags.GetBool('MeetLebedev_Played') || flags.GetBool('JuanLebedev_Dead'))
			PC.UserList[0].accessLevel = AL_Untrained;
			
			else
			PC.UserList[0].accessLevel = AL_Advanced;
		}
		
		else if (localURL == "05_NYC_UNATCOHQ")
		{
			//a: just reset everything here for failsafe. it's a huge fucking mess in the editor.
			
			if (PC.Name == 'ComputerPersonal0')
			{
				PC.specialOptions[0].userName = "demiurge";
				PC.UserList[0].accessLevel = AL_Untrained;
				PC.UserList[1].accessLevel = AL_Untrained;
				PC.UserList[2].accessLevel = AL_Advanced;
			}
			
			if (PC.Name == 'ComputerPersonal3')
			{
				PC.specialOptions[0].userName = "demiurge";
				PC.specialOptions[1].userName = "demiurge";
				PC.UserList[0].accessLevel = AL_Untrained;
				PC.UserList[1].accessLevel = AL_Untrained;
				PC.UserList[2].accessLevel = AL_Untrained;
				PC.UserList[3].accessLevel = AL_Untrained;
				PC.UserList[4].accessLevel = AL_Advanced;
			}
		}

		else if (localURL == "06_HONGKONG_MJ12LAB")
		{
			if (PC.Name == 'ComputerPersonal0')
			{
				PC.userList[2].userName = "";
				PC.userList[3].userName = "";
			}
		}
		
		else if (localURL == "06_HONGKONG_STORAGE")
		{
			if (PC.Name == 'ComputerSecurity1')
				PC.userList[0].password = "SECURITY";
			
			if (PC.Name == 'ComputerPersonal0')
			{
				PC.userList[0].accessLevel = AL_Master;
				PC.userList[1].accessLevel = AL_Master;
			}
		}
		
		else if (localURL == "11_PARIS_EVERETT")
		{
			if (PC.Name == 'ComputerSecurity0')
			PC.UserList[0].accessLevel = AL_Master;
			
			if (PC.Name == 'ComputerSecurity1')
			{
				PC.specialOptions[0].Text = "";
				PC.specialOptions[1].Text = "";
			}
		}
		
		else if (localURL == "12_VANDENBERG_COMPUTER")
		{
			if (PC.Name == 'ComputerPersonal1')
			PC.UserList[0].accessLevel = AL_Master;
		}
		
		else if (localURL == "14_OCEANLAB_LAB")
		{
			if (PC.Name == 'ComputerSecurity0')
			{
				PC.userList[0].userName = "Oceanguard";
				PC.userList[0].Password = "Kraken";
			}
		}
		
		else if (localURL == "14_OCEANLAB_UC")
		{
			if (PC.Name == 'ComputerPersonal0')
				PC.userList[0].accessLevel = AL_Master;
		}
		
		else if (localURL == "15_AREA51_PAGE")
		{
			if (PC.Name == 'ComputerPersonal0')
				PC.userList[0].accessLevel = AL_Master;
		}
		
		if (localURL == "01_NYC_UNATCOISLAND" || localURL == "04_NYC_UNATCOISLAND" || localURL == "05_NYC_UNATCOISLAND")
		{
			if (localURL == "01_NYC_UNATCOISLAND")
			t = 1;
		
			else
			t = 0;
			
			if (Caps(PC.userList[t].userName) == "KLLOYD")
			{
				PC.userList[t].userName = "KLloyd";
				PC.userList[t].Password = "target";
			}
		}
	}

	if(autoSaveValid && Human(player).useAutosave && dxInfo != None && !(player.IsInState('Dying')) && !(player.IsInState('Paralyzed')) && !(player.IsInState('Interpolating')) && 
	player.dataLinkPlay == None && Level.Netmode == NM_Standalone && dxInfo.MissionNumber > 0 && dxInfo.MissionNumber < 98)
		Spawn(Class'Autosave'); //Justice: autosave after a very short delay in order to prevent crashes
}

// ----------------------------------------------------------------------
// PreTravel()
// 
// Set flags upon exit of a certain map
// ----------------------------------------------------------------------

function PreTravel()
{
	local int points;
	local ScriptedPawn pawn;

	// turn off the timer
	SetTimer(0, False);

	points = flags.getInt('PendingSkillPoints');

	foreach allActors(class'ScriptedPawn', pawn)
	{
		if(pawn.PendingSkillPoints > 0)
			points += pawn.PendingSkillPoints;
	}

	flags.SetInt('PendingSkillPoints', points,, 0);

	flags.SetFloat('Travel_GameSpeed', Level.Game.GameSpeed);

	// zero the flags so FirstFrame() gets executed at load
	flags = None;
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
	local NanoKey tempKey;
	local NanoKeyInfo keyInfo;
	
	// make sure our flags are initialized correctly
	if (flags == None)
	{
		InitStateMachine();

		//a: we do want to do this if the player just loaded a savegame
		if ((player != None) && (!flags.GetBool('PlayerTraveling')))
		{
			keyInfo = player.KeyList;
			tempKey = spawn(Class'NanoKey');
			
			if (keyInfo != None)
			{
				while(keyInfo != None)
				{
					tempKey.KeyID = keyInfo.KeyID;
					tempKey.Description = keyInfo.Description;
					
					tempKey = player.FixNanoKey(tempKey);
					
					if (tempKey.KeyID == '')
					player.KeyRing.RemoveKey(keyInfo.KeyID);
					
					else
					{
						keyInfo.KeyID 		= tempKey.KeyID;
						keyInfo.Description = tempKey.Description;
					}
					
					keyInfo = keyInfo.NextKey;
				}
			}
			
			tempKey.Destroy();
		}
		
		player.NanoMod.checkVersion();

		// Don't want to do this if the user just loaded a savegame
		if ((player != None) && (flags.GetBool('PlayerTraveling')))
			FirstFrame();
		
		if (player != None && player.versionType == 3)
			player.listItems();
	}
}

// ----------------------------------------------------------------------
// GetPatrolPoint()
// Y|y: Fixed to actually do something
// ----------------------------------------------------------------------

function PatrolPoint GetPatrolPoint(Name patrolTag, optional bool bRandom)
{
	local PatrolPoint aPoint;

	aPoint = None;

	while(aPoint == None)
	{
		foreach AllActors(class'PatrolPoint', aPoint, patrolTag)
		{
			if (bRandom)
			{
				if(FRand() < 0.5)
					break;
			}
			else
				break;
		}
	}

	return aPoint;
}

// ----------------------------------------------------------------------
// GetSpawnPoint()
// Y|y: Fixed to actually do something
// ----------------------------------------------------------------------

function SpawnPoint GetSpawnPoint(Name spawnTag, optional bool bRandom)
{
	local SpawnPoint aPoint;

	aPoint = None;

	while(aPoint == None)
	{
		foreach AllActors(class'SpawnPoint', aPoint, spawnTag)
		{
			if (bRandom)
			{
				if(FRand() < 0.5)
					break;
			}
			else
				break;
		}
	}

	return aPoint;
}

defaultproperties
{
     checkTime=1.000000
     localURL="NOTHING"
     missionName="DEFAULT"
     autoSaveValid=True
}
