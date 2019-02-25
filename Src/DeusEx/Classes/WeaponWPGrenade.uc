class weaponWPGrenade extends WeaponGasGrenade;

/*
function PreBeginPlay()
{
	Skin = Texture(DynamicLoadObject("BioMod.Skins.WPGrenadeTex",class'Texture', True));
	super.PreBeginPlay();
}*/

function bool Facelift(bool bOn)
{
	if(!Super.Facelift(false))
		return false;

	if(bOn)
	{
		Skin = Texture(DynamicLoadObject("BioMod.Skins.WPGrenadeTex",class'Texture', True));
		Icon = Texture(DynamicLoadObject("BioMod.Icons.WPGrenadeBelt",class'Texture', True));
		largeIcon = Texture(DynamicLoadObject("BioMod.Icons.WPGrenadeInv",class'Texture', True));
	}

	if(!bOn || Skin == None)
		Skin = Default.Skin;

	return true;
}

function renderoverlays(canvas canvas)
{
     multiskins[2]=Texture(DynamicLoadObject("BioMod.Skins.WPGrenadeTex",class'Texture', True));
     Skin=none; //clear the 3rd person nade tex from the hand slot
     super.renderoverlays(canvas);
     multiskins[2]=none;
     Skin=Texture(DynamicLoadObject("BioMod.Skins.WPGrenadeTex",class'Texture', True));
}

defaultproperties
{
     AIFireDelay=5.000000
     AmmoName=Class'DeusEx.AmmoWPGrenade'
     ProjectileClass=Class'DeusEx.WPGrenade'
     ItemName="WP Grenade"
     Description="Upon detonation, the WP grenade will spread a cloud of particularized white phosphorus that ignites immediately upon contact with the air."
     beltDescription="WP GREN"
}
