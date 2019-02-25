class ChallengeMenu expands MenuUIScreenWindow;

var MenuUIInfoButtonWindow   winNameBorder;
var MenuUIListWindow         lstChallenges;
var MenuUIHelpWindow winChallengeInfo;
var ButtonWindow             btnLeftArrow;
var ButtonWindow             btnRightArrow;
var MenuUICheckboxWindow	chkNotify;

var int		selectedRowId;
var int mission;

var localized String headerChallengesLabel;
var localized String headerCompletedLabel;
var localized String headerStatusLabel;
var localized String NotifyLabel;

var MenuUILabelWindow missionLabel;

var ChallengeManager challengeSystem;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	mission = 0;
	
	ResetToDefaults();

	// Need to do this because of the edit control used for 
	// saving games.
	SetMouseFocusMode(MFOCUS_Click);

	Show();
	//SetFocusWindow(editName);

	StyleChanged();
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	Super.CreateControls();

	challengeSystem = Human(Player).ChallengeSystem;
	
	CreateTextHeaders();
	CreateChallengeListWindow();
	CreateChallengeInfoWindow();
	CreateLeftArrowButton();
	CreateRightArrowButton();
	CreateNotifyCheckBox();
}

// ----------------------------------------------------------------------
// CreateTextHeaders()
// ----------------------------------------------------------------------

function CreateTextHeaders()
{
	local MenuUILabelWindow winLabel;
	
	CreateMenuLabel(18,  17, HeaderChallengesLabel,       winClient);
	
	winLabel = CreateMenuLabel(346,  18, HeaderStatusLabel,   winClient);
	winLabel.SetFont(Font'FontMenuSmall');

	winLabel = CreateMenuLabel(460,  18, HeaderCompletedLabel, winClient);
	winLabel.SetFont(Font'FontMenuSmall');
	
	missionLabel = CreateMenuLabel( 55, 357, ChallengeSystem.missionNames[mission],   winClient);
}

function CreateLeftArrowButton()
{
	btnLeftArrow = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));

	btnLeftArrow.SetPos(18, 357);
	btnLeftArrow.SetSize(14, 15);

	btnLeftArrow.SetButtonTextures(
		Texture'MenuLeftArrow_Normal', 
		Texture'MenuLeftArrow_Pressed');
}

function CreateRightArrowButton()
{
	btnRightArrow = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));

	btnRightArrow.SetPos(33, 357);
	btnRightArrow.SetSize(14, 15);

	btnRightArrow.SetButtonTextures(
		Texture'MenuRightArrow_Normal', 
		Texture'MenuRightArrow_Pressed');
}

function CreateChallengeListWindow()
{
	lstChallenges = MenuUIListWindow(winClient.NewChild(Class'MenuUIListWindow'));

	lstChallenges.SetSize(487, 145);
	//lstChallenges.SetPos(172,41);
	lstChallenges.SetPos(18,41);
	lstChallenges.EnableMultiSelect(False);
	lstChallenges.EnableAutoExpandColumns(False);
	lstChallenges.SetNumColumns(3);

	lstChallenges.SetColumnWidth(0, 328);
	lstChallenges.SetColumnWidth(1,  66);
	lstChallenges.SetColumnWidth(2,  93);
	lstChallenges.SetColumnAlignment(1, HALIGN_Left);
	lstChallenges.SetColumnAlignment(2, HALIGN_Right);

	lstChallenges.SetColumnFont(0, Font'FontMenuHeaders');
	lstChallenges.SetSortColumn(0, False);
	lstChallenges.EnableAutoSort(True);
}

function CreateChallengeInfoWindow()
{
	winChallengeInfo = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
	winChallengeInfo.SetSize(487, 145);
	winChallengeInfo.SetPos(18, 203);
}

function CreateNotifyCheckbox()
{
	chkNotify = MenuUICheckboxWindow(winClient.NewChild(Class'MenuUICheckboxWindow'));

	chkNotify.SetPos(432, 357);
	chkNotify.SetText(NotifyLabel);
	chkNotify.SetFont(Font'FontMenuSmall');
	chkNotify.SetToggle(challengeSystem.notifyChallenges);
}

function PopulateChallengeList()
{
	local Challenge c;
	local int rowIndex;
	
	c = challengeSystem.firstChallenge;
	
	while(c != None)
	{
		if(c.completed[mission] != -1)
		{
			rowIndex = lstChallenges.AddRow(BuildChallengeString(c));
			lstChallenges.SetRowClientObject(rowIndex, c);
		}
		c = c.next;
	}
	
	lstChallenges.Sort();
	lstChallenges.SetRow(lstChallenges.IndexToRowId(0), False);
}

function String BuildChallengeString(Challenge challenge)
{
	local String challengeString;
	local String status;
	local String completed;
	local String notify;
	
	status = "In progess";
	
	if(player.getLevelInfo().MissionNumber < 1)
		status = "--";
	else if(mission == 0)
	{
		if(player.FlagBase.GetBool(player.rootWindow.StringToName(challenge.class.name $ "_Failed")))
			status = "Failed";
	}
	else
	{
		if(player.FlagBase.GetBool(player.rootWindow.StringToName(challenge.class.name $ "_" $ string(mission) $ "_Failed")))
			status = "Failed";
		else if(player.FlagBase.GetBool(player.rootWindow.StringToName(challenge.class.name $ "_" $ string(mission) $ "_Completed")))
			status = "Completed";
	}
	
	switch(challenge.completed[mission])
	{
		case 1:
			completed = "Easy    ";
			break;
	
		case 2:
			completed = "Medium  ";
			break;
		
		case 3:
			completed = "Hard    ";
			break;
		
		case 4:
			completed = "Realistic";
			break;
			
		case 5:
			completed = "Unrealistic";
			break;
		
		default:
			completed = "--    ";
			break;
	}
	
	challengeString = challenge.ChallengeName $ ";" $ status $ ";" $ completed;
	
	return challengeString;
}

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;

	bHandled = True;

	switch( buttonPressed )
	{
		case btnLeftArrow:
			prevMission();
			refreshMission();
			break;
			
		case btnRightArrow:
			nextMission();
			refreshMission();
			break;
			
		default:
			bHandled = False;
			break;
	}

	if ( !bHandled )
		bHandled = Super.ButtonActivated(buttonPressed);

	return bHandled;
}

// ----------------------------------------------------------------------
// ListSelectedChanged()
// ----------------------------------------------------------------------

event bool ListSelectionChanged(window list, int numSelections, int focusRowId)
{
	local Challenge challenge;
	
	challenge = challenge(ListWindow(list).GetRowClientObject(focusRowId));
	selectedRowId = focusRowId;

	winChallengeInfo.SetText(challenge.description);

	return True;
}

// ----------------------------------------------------------------------
// ResetToDefaults()
//
// Meant to be called in derived class
// ----------------------------------------------------------------------

function ResetToDefaults()
{
	PopulateChallengeList();	
}

// ----------------------------------------------------------------------
// ProcessAction()
// ----------------------------------------------------------------------

function ProcessAction(String actionKey)
{
	/*if (actionKey == "OK")
	{
	}*/
}

// ----------------------------------------------------------------------
// BoxOptionSelected()
// ----------------------------------------------------------------------

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
	// Destroy the msgbox!  
	root.PopWindow();

	//editName.SetText(player.TruePlayerName);
	//editName.MoveInsertionPoint(MOVEINSERT_End);
	//editName.SetSelectedArea(0, Len(editName.GetText()));
	//SetFocusWindow(editName);

	return True;
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;
	local Color colButtonFace;

	Super.StyleChanged();

	theme = player.ThemeManager.GetCurrentMenuColorTheme();

	// Title colors
	colButtonFace = theme.GetColorFromName('MenuColor_ButtonFace');
}

function SaveSettings()
{
	challengeSystem.saveSettings();
}

function nextMission()
{
	local int i;
	
	i = mission + 1;
	
	while(i < 30)
	{
		if(challengeSystem.missionNames[i] != "")
		{
			mission = i;
			return;
		}
		
		i++;
	}
	
	mission = 0;
}

function prevMission()
{
	local int i;
	
	i = mission - 1;
	
	while(i >= 0)
	{
		if(challengeSystem.missionNames[i] != "")
		{
			mission = i;
			return;
		}
		
		i--;
	}
	
	//Justice: If we get here, we're at -1, so loop back around
	i = 29;
	while(i >= 0)
	{
		if(challengeSystem.missionNames[i] != "")
		{
			mission = i;
			return;
		}
		
		i--;
	}
}

function RefreshMission()
{
	lstChallenges.deleteAllRows();
	populateChallengeList();
	
	missionLabel.setText(ChallengeSystem.missionNames[mission]);
}

event bool ToggleChanged(Window button, bool bNewToggle)
{	
	if (button == chkNotify)
	{
		challengeSystem.NotifyChallenges = bNewToggle;
		challengeSystem.saveConfig();
		return True;
	}
	else
	{
		return False;
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     headerChallengesLabel="Challenges"
     headerCompletedLabel="Completed"
     headerStatusLabel="Status"
     NotifyLabel="Notifications"
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_OK)
     Title="Challenges"
     ClientWidth=523
     ClientHeight=389
     bUsesHelpWindow=False
     bEscapeSavesSettings=False
}
