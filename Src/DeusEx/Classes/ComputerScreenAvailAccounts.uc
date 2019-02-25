//=============================================================================
// ComputerScreenAvailAccounts
//=============================================================================
class ComputerScreenAvailAccounts extends HUDBaseWindow;

var PersonaActionButtonWindow btnChangeAccount;
var PersonaHeaderTextWindow   winCurrentUser;
var PersonaListWindow         lstAccounts;
var NetworkTerminal           winTerm;
var Computers                 compOwner;		// what computer owns this window?
var ComputerScreenLogin       CompLogin;

// Defaults
var Texture texBackground;
var Texture texBorder;

var localized String ChangeAccountButtonLabel;
var localized String AllAccountsHeader;
var localized String CurrentAccountHeader;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	SetSize(206, 232);

	CreateControls();	
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	CreateChangeAccountButton();
	CreateCurrentUserWindow();
	CreateAccountsList();
	CreateHeaders();
}

// ----------------------------------------------------------------------
// CreateChangeAccountButton()
// ----------------------------------------------------------------------

function CreateChangeAccountButton()
{
	local PersonaButtonBarWindow winActionButtons;

	winActionButtons = PersonaButtonBarWindow(NewChild(Class'PersonaButtonBarWindow'));
	winActionButtons.SetPos(12, 169);
	winActionButtons.SetWidth(174);
	winActionButtons.FillAllSpace(False);

	btnChangeAccount = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnChangeAccount.SetButtonText(ChangeAccountButtonLabel);
}

// ----------------------------------------------------------------------
// CreateCurrentUserWindow()
// ----------------------------------------------------------------------

function CreateCurrentUserWindow()
{
	winCurrentUser = PersonaHeaderTextWindow(NewChild(Class'PersonaHeaderTextWindow'));
	winCurrentUser.SetPos(16, 29);
	winCurrentUser.SetSize(170, 12);
}

// ----------------------------------------------------------------------
// CreateAccountsList()
// ----------------------------------------------------------------------

function CreateAccountsList()
{
	local PersonaScrollAreaWindow winScroll;

	winScroll = PersonaScrollAreaWindow(NewChild(Class'PersonaScrollAreaWindow'));;
	winScroll.SetPos(14, 69);
	winScroll.SetSize(170, 97);

	lstAccounts = PersonaListWindow(winScroll.clipWindow.NewChild(Class'PersonaListWindow'));
	lstAccounts.EnableMultiSelect(False);
	lstAccounts.EnableAutoExpandColumns(False);
	lstAccounts.EnableHotKeys(False);
	lstAccounts.SetNumColumns(1);
	lstAccounts.SetColumnWidth(0, 170);
}

// ----------------------------------------------------------------------
// CreateHeaders()
// ----------------------------------------------------------------------

function CreateHeaders()
{
	local MenuUIHeaderWindow winHeader;

	winHeader = MenuUIHeaderWindow(NewChild(Class'MenuUIHeaderWindow'));
	winHeader.SetPos(12, 12);
	winHeader.SetText(CurrentAccountHeader);

	winHeader = MenuUIHeaderWindow(NewChild(Class'MenuUIHeaderWindow'));
	winHeader.SetPos(12, 53);
	winHeader.SetText(AllAccountsHeader);
}

// ----------------------------------------------------------------------
// DrawBackground()
// ----------------------------------------------------------------------

function DrawBackground(GC gc)
{
	gc.SetStyle(backgroundDrawStyle);
	gc.SetTileColor(colBackground);
	gc.DrawTexture(
		backgroundPosX, backgroundPosY, 
		backgroundWidth, backgroundHeight, 
		0, 0, texBackground);
}

// ----------------------------------------------------------------------
// DrawBorder()
// ----------------------------------------------------------------------

function DrawBorder(GC gc)
{
	if (bDrawBorder)
	{
		gc.SetStyle(borderDrawStyle);
		gc.SetTileColor(colBorder);
		gc.DrawTexture(0, 0, 206, 232, 0, 0, texBorder);
	}
}

// ----------------------------------------------------------------------
// SetNetworkTerminal()
// ----------------------------------------------------------------------

function SetNetworkTerminal(NetworkTerminal newTerm)
{
	winTerm = newTerm;
	UpdateCurrentUser();
}

// ----------------------------------------------------------------------
// SetCompOwner()
// ----------------------------------------------------------------------

function SetCompOwner(ElectronicDevices newCompOwner)
{
	local int compIndex;
	local int rowId;
	local int userRowIndex;
	local int userIndex;
	local int firstRowIndex;
	local int i;
	local DeusExPlayer player;
	local int j;
	
	player = DeusExPlayer( GetPlayerPawn() );

	compOwner = Computers(newCompOwner);
	firstRowIndex = -1;
	
	j = 0;

	// Loop through the names and add them to our listbox
	for (compIndex=0; compIndex<compOwner.NumUsers(); compIndex++)
	{
		if (!player.HasPass(compOwner.GetPassword(compIndex), compOwner.GetUserName(compIndex)))
		continue;
		
		else if (firstRowIndex == -1)
		firstRowIndex = j;
		
		lstAccounts.AddRow(Caps(compOwner.GetUserName(compIndex)));

		if (Caps(winTerm.GetUserName()) == Caps(compOwner.GetUserName(compIndex)))
		{
			userIndex    = compIndex;
			userRowIndex = j;
		}
			
		j++;
	}

	// Select the row that matches the current user
	
	if (firstRowIndex > -1)
	{
		rowId = lstAccounts.IndexToRowId(userRowIndex);
		
		if (CompLogin != None)
		lstAccounts.SetRow(rowId, False);
		
		else
		lstAccounts.SetRow(rowId, True);
		
		if (CompLogin != None)
		{
			if (compOwner.NumUsers() == 1)
			{
				CompLogin.SetLoginText(compOwner.GetUserName(userIndex), compOwner.GetPassword(userIndex));
			}
			
			else
			CompLogin.SetLoginText("", "");
			
			if (compOwner.NumUsers() == j)
			{
				if (winTerm != None)
				winTerm.CloseHackWindow();
			}
		}
	}
	
	else if (winTerm != None)
	winTerm.CloseAvailAccountsWindow();
}

// ----------------------------------------------------------------------
// UpdateCurrentUser()
// ----------------------------------------------------------------------

function UpdateCurrentUser()
{
	if (winTerm != None)
	{
		winCurrentUser.SetText(winTerm.GetUserName());
	}
}

// ----------------------------------------------------------------------
// ChangeSelectedAccount()
// ----------------------------------------------------------------------

function ChangeSelectedAccount()
{
	local int userIndex;
	local string uname;
	local string passw;
	local int userSkillLevel;
	local int compIndex;
	local int j;
	
	userIndex = -1;
	
	j = 0;
	
	for (compIndex=0; compIndex<compOwner.NumUsers(); compIndex++)
	{
		if (!player.HasPass(compOwner.GetPassword(compIndex), compOwner.GetUserName(compIndex)))
		{
			j++;
			
			continue;
		}
		
		if (compIndex == lstAccounts.RowIdToIndex(lstAccounts.GetSelectedRow()) + j)
		{
			userIndex = compIndex;
			
			break;
		}
	}
	
	if (userIndex > -1)
	{
	if (CompLogin != None)
	{
		uname = compOwner.GetUserName(userIndex);
		passw = compOwner.GetPassword(userIndex);

		CompLogin.SetLoginText(uname, passw);
	}
	
	if (winTerm != None)
		winTerm.ChangeAccount(userIndex);
	}
		
	UpdateCurrentUser();
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
		case btnChangeAccount:
			ChangeSelectedAccount();
			break;

		default:
			bHandled = False;
			break;
	}

	if (bHandled)
		return True;
	else
		return Super.ButtonActivated(buttonPressed);
}

// ----------------------------------------------------------------------
// VirtualKeyPressed()
//
// Called when a key is pressed; provides a virtual key value
// ----------------------------------------------------------------------

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	local bool bKeyHandled;
	bKeyHandled = True;

	switch( key ) 
	{	
		case IK_Escape:
			winTerm.ForceCloseScreen();	
			break;

		default:
			bKeyHandled = False;
	}

	if (bKeyHandled)
		return True;
	else
		return Super.VirtualKeyPressed(key, bRepeat);
}

// ----------------------------------------------------------------------
// ListRowActivated()
// ----------------------------------------------------------------------

event bool ListRowActivated(window list, int rowId)
{
	ChangeSelectedAccount();
	return TRUE;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     texBackground=Texture'DeusExUI.UserInterface.ComputerHackAccountsBackground'
     texBorder=Texture'DeusExUI.UserInterface.ComputerHackAccountsBorder'
     ChangeAccountButtonLabel="|&Change Account"
     AllAccountsHeader="Known Accounts"
     CurrentAccountHeader="Current User"
     backgroundWidth=188
     backgroundHeight=181
     backgroundPosX=6
     backgroundPosY=9
}
