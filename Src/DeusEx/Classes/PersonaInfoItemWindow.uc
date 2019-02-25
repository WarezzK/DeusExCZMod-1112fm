//=============================================================================
// PersonaInfoItemWindow
//=============================================================================
class PersonaInfoItemWindow expands AlignWindow;

var DeusExPlayer player;
var TextWindow winLabel;
var TextWindow winText;
var Font fontText;
var Font fontTextHighlight;
var bool bHighlight;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	// Defaults for tile window
	SetChildVAlignment(VALIGN_Top);
	SetChildSpacing(10);

	winLabel = TextWindow(NewChild(Class'TextWindow'));
	winLabel.SetFont(fontText);
	winLabel.SetTextAlignments(HALIGN_Right, VALIGN_Top);
	winLabel.SetTextMargins(0, 0);
	winLabel.SetWidth(70);

	winText = TextWindow(NewChild(Class'TextWindow'));
	winText.SetTextAlignments(HALIGN_Left, VALIGN_Top);
	winText.SetFont(fontText);
	winText.SetTextMargins(0, 0);
	winText.SetWordWrap(True);

	// Get a pointer to the player
	player = DeusExPlayer(GetPlayerPawn());

	StyleChanged();
}

// ----------------------------------------------------------------------
// SetItemInfo()
// ----------------------------------------------------------------------

function SetItemInfo(coerce String newLabel, coerce String newText, optional bool bNewHighlight)
{
	winLabel.SetText(newLabel);
	winText.SetText(newText);
	SetHighlight(bNewHighlight);
}

function SetModInfo(coerce String newLabel, int count, optional bool bNewHighlight)
{
	local PersonaSkillTextWindow winBracket;
	local PersonaLevelIconWindow winIcons;
	local PersonaLevelIconOffWindow winIconsOff;
	
	local int countOff, bracketWidth, iconsWidth, iconsOffWidth;

	//a: paranoia
	if (count > 5)
	count = 5;

	bracketWidth  = 2;
	countOff      = 5 - count;
	iconsWidth    = 6 * count; //a: icon size is 5, but it draws 1px extra as padding.
	iconsOffWidth = 6 * countOff;

	winLabel.SetText(newLabel);
	
	winBracket = PersonaSkillTextWindow(winText.NewChild(Class'PersonaSkillTextWindow'));
	
	winBracket.SetWidth(bracketWidth);
	winBracket.SetTextMargins(0, 0);
	winBracket.SetText("[");
	winBracket.setSelected(true);
	
	//a: 0=1, we subtract when we set our level.
	if (count > 0)
	{
		winIcons = PersonaLevelIconWindow(winText.NewChild(Class'PersonaLevelIconWindow'));

		winIcons.SetWidth(iconsWidth);
		winIcons.SetLevel(count - 1);	
		winIcons.SetPos((bracketWidth + 2), 2);
		winIcons.SetSelected(true);
	}

	if (countOff > 0)
	{
		winIconsOff = PersonaLevelIconOffWindow(winText.NewChild(Class'PersonaLevelIconOffWindow'));
	
		winIconsOff.SetWidth(iconsOffWidth);
		winIconsOff.SetLevel(countOff - 1);	
		winIconsOff.SetPos((iconsWidth + bracketWidth + 2), 2);
	}
	
	winBracket = PersonaSkillTextWindow(winText.NewChild(Class'PersonaSkillTextWindow'));

	winBracket.SetWidth(bracketWidth);
	winBracket.SetPos((bracketWidth + iconsWidth + iconsOffWidth + 3), 0);
	winBracket.SetTextMargins(0, 0);
	winBracket.SetText("]");
	winBracket.setSelected(true);
}

// ----------------------------------------------------------------------
// SetItemText()
// ----------------------------------------------------------------------

function SetItemText(coerce string newText)
{
	winText.SetText(newText);
}

// ----------------------------------------------------------------------
// SetHighlight()
// ----------------------------------------------------------------------

function SetHighlight(bool bNewHighlight)
{
	bHighlight = bNewHighlight;

	if (bHighlight)
		winText.SetFont(fontTextHighlight);
	else
		winText.SetFont(fontText);

	StyleChanged();
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;

	theme = player.ThemeManager.GetCurrentHUDColorTheme();

	winLabel.SetTextColor(theme.GetColorFromName('HUDColor_NormalText'));

	if (bHighlight)
		winText.SetTextColor(theme.GetColorFromName('HUDColor_HeaderText'));
	else
		winText.SetTextColor(theme.GetColorFromName('HUDColor_NormalText'));
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     fontText=Font'DeusExUI.FontMenuSmall'
     fontTextHighlight=Font'DeusExUI.FontMenuHeaders'
}
