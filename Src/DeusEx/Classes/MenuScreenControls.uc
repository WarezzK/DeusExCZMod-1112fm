//=============================================================================
// MenuScreenControls
// modified for new Autosave option by DX_Blaster
// initial version: 1.0 Aug 12, 2011 
// latest version: 1.02 Aug 21, 2011
//=============================================================================

class MenuScreenControls expands MenuUIScreenWindow;

// ----------------------------------------------------------------------
// SaveSettings()
// ----------------------------------------------------------------------

function SaveSettings()
{
	Super.SaveSettings();
	player.SaveConfig();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     choices(0)=Class'DeusEx.MenuChoice_AutoSave'
     choices(1)=Class'DeusEx.MenuChoice_AlwaysRun'
     choices(2)=Class'DeusEx.MenuChoice_ToggleCrouch'
     choices(3)=Class'DeusEx.MenuChoice_InvertMouse'
     choices(4)=Class'DeusEx.MenuChoice_MouseSensitivity'
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_OK)
     actionButtons(2)=(Action=AB_Reset)
     Title="Controls"
     ClientWidth=537
     ClientHeight=264
     helpPosY=210
}
