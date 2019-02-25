//=============================================================================
// Total new Autosave Option by DX_Blaster 
// initial version: 1.0 Aug 12 2011
// 'bAutoSave' is a new Global variable, stored in the User.ini
//=============================================================================

//=============================================================================
// MenuChoice_AutoSave
//=============================================================================

class MenuChoice_AutoSave extends MenuChoice_EnabledDisabled;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	//SetValue(int(!player.bAutoSave));
	SetValue(int(!Human(player).useAutosave));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
	Human(player).useAutosave = !bool(GetValue());
}

// ----------------------------------------------------------------------
// -------------------------------	---------------------------------------

function ResetToDefault()
{
	//SetValue(int(!Human(player).useAutosave));
	SetValue(int(false));
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     HelpText="If set to Enabled, the game will automatically be saved when transitioning between maps"
     actionText="Autosave |&Game"
}
