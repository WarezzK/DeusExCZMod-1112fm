class NanoModSettingsMenu expands MenuUIScreenWindow;

var MenuUIListWindow            listWindow;
var MenuUIHelpWindow 		    infoWindow, sepWindow;
var MenuUICheckboxWindow	    toggleButton;
var MenuUINormalLargeTextWindow bgWindow;

const   lineHeight        = 12;
const   lineHeightHeader  = 13;
const   lineHeightInfo    = 11;

var int selectedRowIndex;
var int padSize;
var int colWidth;
var int marginTop;
var int marginRight;
var int settingsCount;

var localized String headerSettingsLabel;
var localized String headerValueLabel;
var localized String headerDefaultLabel;
var localized String ToggleLabel;

struct SettingsStruct  {
	var name    setting;
	var string  title;
	var string  description;
	var bool    value;
	var bool    default;
};

var SettingsStruct Settings[13];

function SetSettingsData()
{
	local int i;
	
	Settings[i].setting      = 'disableAutoFill';
	Settings[i].value        =  !Player.NanoMod.disableAutoFill;
	Settings[i].default      =  True;
	Settings[i].title        = "Auto-Fill Entered Passwords And Keycodes";
	Settings[i].description  = "Whenever you enter a successful login/password into a computer terminal or enter a valid keycode on a keypad, it is remembered and will automatically be filled in for every device that requires it thereafter.|n";
	Settings[i].description  = Settings[i].description $ "Terminals that have multiple accounts are fully supported.";
	i++;
	Settings[i].setting      = 'enableCombatPoints';
	Settings[i].value        =  Player.NanoMod.enableCombatPoints;
	Settings[i].default      =  False;
	Settings[i].title        = "Skill Points For Kills And Stealth";
	Settings[i].description  = "Restores Shifter's skill point system for killing enemies and/or for being sneaky about it.";
	i++;
	Settings[i].setting      = 'doubleCarryingCap';
	Settings[i].value        =  Player.NanoMod.doubleCarryingCap;
	Settings[i].default      =  False;
	Settings[i].title        = "Double Carrying Capacity Of Ammo And Tools";
	Settings[i].description  = "You can carry twice as much of all Ammo, Grenades, Throwing Knives, Combat Knives, Lockpicks, Multitools, and Med Kits.|n|n";
	Settings[i].description  = Settings[i].description $ "WARNING: If you turn this OFF later, any excess ammo that you have over the default cap will be removed!";
	i++;
	Settings[i].setting      = 'colorAltAmmo';
	Settings[i].value        =  Player.NanoMod.colorAltAmmo;
	Settings[i].default      =  False;
	Settings[i].title        = "Color-Coded Alternate Ammo";
	Settings[i].description  = "Alternate ammunition loaded in weapons will be color-coded on your belt icons according to their type.|n|n";
	Settings[i].description  = Settings[i].description $ "NOTE: May not be entirely readable in all themes, but the whole point is not to read - but to immidiately tell which ammo type is loaded in a weapon.";
	i++;
	Settings[i].setting      = 'disableGunSquelching';
	Settings[i].value        = !Player.NanoMod.disableGunSquelching;
	Settings[i].default      = True;
	Settings[i].title        = "Purge Inferior Guns From Bodies";
	Settings[i].description  = "When looting bodies, you will always acquire ammo from any weapons they are holding. But additionally, some weapons may also be purged depending on what you have in your inventory:|n";
	Settings[i].description  = Settings[i].description $ "- If you have a Stealth Pistol or the Magnum: regular Pistols will be purged.|n- If you have an Assault Shotgun or the Boomstick: Sawed-off Shotguns will be purged.|n";
	Settings[i].description  = Settings[i].description $ "- If you have an Assault Rifle: regular Pistols and Mini-Crossbows will be purged, while Pepper Guns and Riot Prods will be dropped to the ground.|n|n";
	Settings[i].description  = Settings[i].description $ "NOTE: All weapons will be dropped to the ground instead of being purged when you can't carry any more of their ammo.|n";
	i++;
	Settings[i].setting      = 'noMoreConsumables';
	Settings[i].value        = Player.NanoMod.noMoreConsumables;
	Settings[i].default      = False;
	Settings[i].title        = "Purge Consumables From Bodies";
	Settings[i].description  = "Purge all miscellaneous consumables when looting bodies.|nConsumables are: Cigarettes, Alcohol, Drugs, Soy Food, Candy, and Sodas.";
	i++;
	Settings[i].setting      = 'frobExplode';
	Settings[i].value        = Player.NanoMod.frobExplode;
	Settings[i].default      = False;
	Settings[i].title        = "Chunk Up Dead Bodies After Looting";
	Settings[i].description  = "Looting dead bodies while having a weapon out will cause them to gloriously chunk into pieces.|nThis is more useful than you think. And oh how is it so very satisfying.|nTurn this on and you won't believe how you could ever live without it! GLORIOUS!";
	i++;
	Settings[i].setting      = 'disableClientFlash';
	Settings[i].value        = !Player.NanoMod.disableClientFlash;
	Settings[i].default      = True;
	Settings[i].title        = "Screen Flash When Taking Damage / Healing";
	Settings[i].description  = "Is that red and blue screen filter annoying you whenever you take damage or getting healed by the Regen Aug?|nWell, turn it off, then!";
	i++;
	Settings[i].setting      = 'lowerTargetWindow';
	Settings[i].value        = Player.NanoMod.lowerTargetWindow;
	Settings[i].default      = False;
	Settings[i].title        = "Lower Position Of The Targeting Aug Window";
	Settings[i].description  = "If your Targeting Aug video feed window covers up the Damaged Absorbed notifications, you can use this setting to lower its position a bit.";
	i++;
	Settings[i].setting      = 'gepGunViewFix';
	Settings[i].value        = Player.NanoMod.gepGunViewFix;
	Settings[i].default      = False;
	Settings[i].title        = "GEP Gun / LAW FOV Fix";
	Settings[i].description  = "If your GEP Gun's and LAW's model positions in first person view are breaking away from the screen, you may try this setting.";
	
	if (Player.NanoMod.hasHDTP)
	{
		i++;
		Settings[i].setting      = 'disableHDTPWeapons';
		Settings[i].value        = !Player.NanoMod.disableHDTPWeapons;
		Settings[i].default      = True;
		Settings[i].title        = "HDTP Weapon Models";
		Settings[i].description  = "Most weapons, projectiles, and some icons.";
		i++;
		Settings[i].setting      = 'disableHDTPIcons';
		Settings[i].value        = !Player.NanoMod.disableHDTPIcons;
		Settings[i].default      = True;
		Settings[i].title        = "HDTP Weapon Icons";
		Settings[i].description  = "Crowbar, Pistol, and Sniper Rifle icons. Useful to disable if you are using a custom set of icons, like from unifiedDuesEx -- or, if you just don't like them.|nEnabling this does nothing if the HDTP Weapon Models are disabled.|n";
		Settings[i].description  = Settings[i].description $ "|nNOTE: Please read the ReadMe, almost nothing else from unifiedDeusEx is compatible!";
		i++;
		Settings[i].setting      = 'enableHDTPHumans';
		Settings[i].value        = Player.NanoMod.enableHDTPHumans;
		Settings[i].default      = False;
		Settings[i].title        = "HDTP Human Models";
		Settings[i].description  = "JC and some scripted human actors.";
	}
}

function SaveSettings()
{
	Player.NanoMod.noMoreConsumables    = Settings[getSettingIndex('noMoreConsumables')].value;
	Player.NanoMod.disableGunSquelching = !Settings[getSettingIndex('disableGunSquelching')].value;
	Player.NanoMod.enableCombatPoints   = Settings[getSettingIndex('enableCombatPoints')].value;
	Player.NanoMod.gepGunViewFix        = Settings[getSettingIndex('gepGunViewFix')].value;
	Player.NanoMod.lowerTargetWindow    = Settings[getSettingIndex('lowerTargetWindow')].value;
	Player.NanoMod.disableClientFlash   = !Settings[getSettingIndex('disableClientFlash')].value;
	Player.NanoMod.frobExplode          = Settings[getSettingIndex('frobExplode')].value;
	Player.NanoMod.doubleCarryingCap    = Settings[getSettingIndex('doubleCarryingCap')].value;
	Player.NanoMod.disableAutoFill      = !Settings[getSettingIndex('disableAutoFill')].value;
	Player.NanoMod.colorAltAmmo         = Settings[getSettingIndex('colorAltAmmo')].value;
	
	if (Player.NanoMod.hasHDTP)
	{
		if (Player.NanoMod.disableHDTPWeapons == Settings[getSettingIndex('disableHDTPWeapons')].value ||
			Player.NanoMod.disableHDTPIcons   == Settings[getSettingIndex('disableHDTPIcons')].value ||
			Player.NanoMod.enableHDTPHumans   != Settings[getSettingIndex('enableHDTPHumans')].value)
			{
				Player.NanoMod.disableHDTPWeapons = !Settings[getSettingIndex('disableHDTPWeapons')].value;
				Player.NanoMod.disableHDTPIcons   = !Settings[getSettingIndex('disableHDTPIcons')].value;
				Player.NanoMod.enableHDTPHumans   = Settings[getSettingIndex('enableHDTPHumans')].value;
				
				Player.globalFacelift(true);
			}
	}
	
	Player.NanoMod.saveConfig();
	Player.NanoMod.applyConfig();
}

event InitWindow()
{
	settingsCount = ArrayCount(Settings);
	
	if (!DeusExPlayer(GetPlayerPawn()).NanoMod.hasHDTP)
	settingsCount -= 3;
	
	ClientHeight += (settingsCount * lineHeight);
	marginRight   = ClientWidth - (padSize * 2);
	
	Super.InitWindow();
	
	SetSettingsData();
	PopulateListWindow();	

	// Need to do this because of the edit control used for 
	// saving games.
	SetMouseFocusMode(MFOCUS_Click);

	Show();

	StyleChanged();
}

function CreateControls()
{
	Super.CreateControls();
	
	CreateBGWindow();
	CreateListHeaders();
	CreateListWindow();
	CreateToggleButton();
	CreateInfoWindow();
}

function CreateBGWindow()
{
	bgWindow = MenuUINormalLargeTextWindow(winClient.NewChild(Class'MenuUINormalLargeTextWindow'));
	
	bgWindow.SetSize(ClientWidth, ClientHeight);
	bgWindow.SetPos(0,0);
}

function CreateListHeaders()
{
	local MenuUILabelWindow winLabel;
	local int offsetX;
	
	offsetX = marginRight - (colWidth * 2);
	
    winLabel = CreateMenuLabel(padSize, padSize, HeaderSettingsLabel, winClient);
	winLabel.SetWidth(offsetX);
	winLabel.SetTextAlignments(HALIGN_Left, VALIGN_Top);

	winLabel = CreateMenuLabel((offsetX + padSize), padSize, HeaderValueLabel, winClient);
	winLabel.SetWidth(colWidth);
	winLabel.SetTextAlignments(HALIGN_Right, VALIGN_Top);
	
	winLabel = CreateMenuLabel((offsetX + padSize + colWidth), padSize, HeaderDefaultLabel, winClient);
	winLabel.SetWidth(colWidth);
	winLabel.SetTextAlignments(HALIGN_Right, VALIGN_Top);
	
	marginTop += (padSize + lineHeightHeader);
}

function CreateListWindow()
{
	local int listHeight;

	marginTop += lineHeight;
	listheight = (settingsCount * lineHeight);
	listWindow = MenuUIListWindow(winClient.NewChild(Class'MenuUIListWindow'));

	listWindow.SetSize(marginRight, listheight);
	listWindow.SetPos(padSize, marginTop);
	listWindow.EnableMultiSelect(False);
	listWindow.EnableAutoExpandColumns(False);
	
	listWindow.SetNumColumns(3);
	listWindow.SetColumnWidth(0, (marginRight - (colWidth * 2)));
	listWindow.SetColumnFont(0, Font'FontMenuHeaders');
	listWindow.SetColumnWidth(1, colWidth);
	listWindow.SetColumnWidth(2, colWidth);
	listWindow.SetColumnAlignment(1, HALIGN_RIGHT);
	listWindow.SetColumnAlignment(2, HALIGN_Right);
	
	marginTop += listHeight;
}

function CreateToggleButton()
{
	marginTop   += lineHeight;
	toggleButton = MenuUICheckboxWindow(winClient.NewChild(Class'MenuUICheckboxWindow'));

	toggleButton.SetPos(padSize, marginTop);
	toggleButton.SetText(ToggleLabel);
	toggleButton.SetFont(Font'FontMenuHeaders');
	
	toggleButton.SetToggle(Settings[selectedRowIndex].value);
	
	marginTop += lineHeightHeader;
}

function CreateInfoWindow()
{
	local int sepHeight;
	
	marginTop += lineHeight;
	sepHeight  = 1;
	infoWindow = MenuUIHelpWindow(winClient.NewChild(Class'MenuUIHelpWindow'));
	sepWindow  = MenuUIHelpWindow(winClient.NewChild(Class'MenuUIHelpWindow'));
	
	sepWindow.SetSize(marginRight, sepHeight);
	sepWindow.SetPos(padSize, marginTop);
	
	marginTop += (lineHeightInfo + sepHeight);
	
	infoWindow.SetSize(marginRight, (ClientHeight - marginTop - padSize));
	infoWindow.SetPos(padSize, marginTop);
	infoWindow.SetTextAlignments(HALIGN_Left, VALIGN_Top);
	infoWindow.SetTextMargins(0, 0);
}

event StyleChanged()
{
	local ColorTheme theme;
	local Texture texBG;

	Super.StyleChanged();
	
	texBG = Texture(DynamicLoadObject("NanoModUI.Backgrounds.SettingsMenuBG", Class'Texture', True));
	theme = player.ThemeManager.GetCurrentMenuColorTheme();
	
	if (texBG != None)
	{
		if (Player.GetMenuTranslucency())
		bgWindow.SetBackgroundStyle(DSTY_Translucent);
			
		else
		bgWindow.SetBackgroundStyle(DSTY_Masked);
		
		bgWindow.SetBackground(texBG);
		bgWindow.SetTileColor(theme.GetColorFromName('MenuColor_Background'));
	}
	
	else
	{
		bgWindow.SetBackgroundStyle(DSTY_Normal);
		bgWindow.SetBackground(Texture'Solid');
		bgWindow.SetTileColor(colBlack);
	}

	sepWindow.SetBackgroundStyle(DSTY_Normal);
	sepWindow.SetBackground(Texture'Solid');
	sepWindow.SetTileColor(theme.GetColorFromName('MenuColor_HelpText'));
}

function PopulateListWindow()
{
	local int rowIndex, i;
	
	for (i = 0; i < settingsCount; i++)
	{
		rowIndex = listWindow.AddRow(BuildListHeaderString(Settings[i]));
		listWindow.SetRow(rowIndex, True);
	}
	
	listWindow.SetRow(listWindow.IndexToRowId(0), False);
	listWindow.SelectRow(listWindow.IndexToRowId(0));
	
	selectedRowIndex = 0;
}

function string BuildListHeaderString(SettingsStruct info)
{
	local string ret;
	
	ret = info.title $ ";";
	ret = ret $ boolToValue(info.value) $ ";";
	ret = ret $ boolToValue(info.default);
	
	return ret;
}

function string boolToValue(bool value)
{
	if (value)
	return "ENABLED";
	
	return "Disabled";
}

function int getSettingIndex(name setting)
{
	local int i;
	
	for (i = 0; i < settingsCount; i++)
	{
		if (Settings[i].setting == setting)
		return i;
	}
	
	return -1;
}

function ProcessAction(String actionKey)
{
	local int i;
	
	if (actionKey == "APPLY")
	{
		SaveSettings();
		
		root.PopWindow();
	}
	
	if (actionKey == "DEFAULTS")
	{
		for (i = 0; i < settingsCount; i++)
		{
			Settings[i].value = Settings[i].default;
		
			listWindow.SetField(listWindow.IndexToRowId(i), 1, boolToValue(Settings[i].value));
		}
		
		if (selectedRowIndex != 0)
		{
			selectedRowIndex = 0;
			
			listWindow.SetRow(listWindow.IndexToRowId(0), False);
			listWindow.SelectRow(listWindow.IndexToRowId(0));
		}
		
		else
			toggleButton.SetToggle(Settings[0].default);
		
		SetFocusWindow(listWindow);
	}
}

event bool ListSelectionChanged(window list, int numSelections, int focusRowId)
{
	local SettingsStruct info;
	
	selectedRowIndex = listWindow.RowIdToIndex(focusRowId);
	
	if (selectedRowIndex < 0 || selectedRowIndex >= settingsCount)
	return false;
	
	info = Settings[selectedRowIndex];

	infoWindow.SetText(info.description);
	
	if (toggleButton != None)
	toggleButton.SetToggle(Settings[selectedRowIndex].value);

	return True;
}

event bool ListRowActivated(window list, int rowId)
{
	selectedRowIndex = listWindow.RowIdToIndex(rowId);
	
	toggleButton.SetToggle(!Settings[selectedRowIndex].value);
	
	return true;
}

event bool ToggleChanged(Window button, bool bNewToggle)
{	
	Settings[selectedRowIndex].value = bNewToggle;
	
	listWindow.SetField(listWindow.IndexToRowId(selectedRowIndex), 1, boolToValue(bNewToggle));
	
	SetFocusWindow(listWindow);
	
	return True;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     padSize=15
     colWidth=80
     headerSettingsLabel="Setting"
     headerValueLabel="Current"
     headerDefaultLabel="Default"
     ToggleLabel="Enabled"
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Apply",Key="APPLY")
     actionButtons(2)=(Action=AB_Other,Text="|&Restore Defaults",Key="DEFAULTS")
     Title="NanoMod Settings"
     ClientWidth=455
     ClientHeight=203
     bUsesHelpWindow=False
     bEscapeSavesSettings=False
}
