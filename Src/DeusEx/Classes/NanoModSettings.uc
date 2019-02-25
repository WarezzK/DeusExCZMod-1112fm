class NanoModSettings extends Actor
	config(User);
	
const currentVersion = "1.2";
	
var travel float version;

var config bool noMoreConsumables;
var config bool frobExplode;
var config bool lowerTargetWindow;
var config bool disableClientFlash;
var config bool enableCombatPoints;
var config bool disableGunSquelching;
var config bool invincibleCats;
var config bool doubleCarryingCap;
var config bool gepGunViewFix;
var config bool disableAutoFill;
var config bool colorAltAmmo;
var config bool disableHDTPWeapons;
var config bool enableHDTPHumans;
var config bool disableHDTPIcons;

var DeusExPlayer p;

var bool hasHDTP;

var Color colAmmoNonLethal;
var Color colAmmoFire;
var Color colAmmoAP;

var transient String infoMessage;

function SetPlayer(DeusExPlayer Player)
{
	p = Player;
	
	hasHDTP = ((DynamicLoadObject("HDTPItems.HDTPsodacan", class'mesh', True)) != None);
}

function checkVersion()
{
	//a: TODO: try to move and import my travel vars from player to NanoMod... Meh
}

function applyConfig()
{
	applyDoubleCarryingCap(doubleCarryingCap);
	applyInvincibleCats(invincibleCats);
}

function Color getAmmoTextColor(Class ammo, Color defColor)
{
	if (!colorAltAmmo)
	return defColor;
	
	if (ammo == Class'AmmoDartPoison')
		return colAmmoNonLethal;
		   
	if (ammo == Class'AmmoDartFlare' || ammo == Class'Ammo10mmEX' || ammo == Class'AmmoDragon' || ammo == Class'AmmoRocketWP' || ammo == Class'Ammo20mm')
		return colAmmoFire;
	
    if (ammo == Class'AmmoSabot')
		return colAmmoAP;
	  
	return defColor;
}

function applyInvincibleCats(bool setting)
{
	local Cat c;
	
	foreach p.AllActors(class'Cat', c)
		c.bInvincible = setting;
}

function applyDoubleCarryingCap(bool setting)
{
	local DeusExAmmo amItem;
	local DeusExPickup upItem;
	
	foreach p.AllActors(Class'DeusExAmmo', amItem)
	{
		if (setting)
		amItem.MaxAmmo = amItem.Default.MaxAmmo * 2;
		
		else
		{
			amItem.MaxAmmo = amItem.Default.MaxAmmo;
			
			if (amItem.Owner != p)
			continue;
			
			if (amItem.isGrenade && amItem.AmmoAmount > amItem.MaxAmmo + (p.SkillSystem.GetSkillLevel(class'SkillDemolition') * (amItem.MaxAmmo / 3)))
				amItem.AmmoAmount = amItem.MaxAmmo + (p.SkillSystem.GetSkillLevel(class'SkillDemolition') * (amItem.MaxAmmo / 3));
			
			else if (amItem.AmmoAmount > amItem.MaxAmmo)
			amItem.AmmoAmount = amItem.MaxAmmo;
			
			p.UpdateAmmoBeltText(amItem);
		}
	}
	
	foreach p.AllActors(Class'DeusExPickup', upItem)
	{
		if (!upItem.IsA('Medkit') && !upItem.IsA('Lockpick') && !upItem.IsA('MultiTool'))
		continue;
		
		if (setting)
		upItem.MaxCopies = upItem.Default.MaxCopies * 2;
		
		else
		{
			upItem.MaxCopies = upItem.Default.MaxCopies;
			
			if (upItem.Owner != p)
			continue;
			
			if (upItem.NumCopies > upItem.MaxCopies)
			upItem.NumCopies = upItem.MaxCopies;
			
			p.UpdateBeltText(upItem);
		}
	}
}

function addMessage(String msg)
{
	if (msg != "")
	infoMessage = infoMessage $ msg $ "|n";
}

function showMessage(optional String msg)
{
	local HUDInformationDisplay infoWindow;
	local TextWindow winText;
	
	hideMessage();
	
	if (msg != "")
	{
		if (infoMessage != "")
		infoMessage = infoMessage $ "|n";
		
		infoMessage = infoMessage $ msg;
	}
	
	if (infoMessage == "")
	return;
	
	DeusExRootWindow(p.rootWindow).hud.frobDisplay.Hide();
	DeusExRootWindow(p.rootWindow).hud.cross.SetCrosshair(False);
	
	infoWindow = DeusExRootWindow(p.rootWindow).hud.ShowInfoWindow();

	winText = infoWindow.AddTextWindow();
	winText.SetFont(Font'FontMenuHeaders');
	winText.SetText("---- NanoMod ----");
	winText.SetTextAlignments(HALIGN_Center, VALIGN_Center);
	
	winText = infoWindow.AddTextWindow();
	winText.SetText("|n" $ RTrim(infoMessage, "|n"));
	
	winText = infoWindow.AddTextWindow();
	winText.SetText("|n[ESC TO CLOSE]");
	winText.SetTextAlignments(HALIGN_Center, VALIGN_Center);
	
	infoMessage = "";
}

function bool hideMessage()
{
	local HUDInformationDisplay infoWindow;
	
	infoWindow = DeusExRootWindow(p.rootWindow).hud.info;
	
	if (!infoWindow.isVisible())
	return false;

	infoWindow.ClearTextWindows();
	infoWindow.Hide();
	
	DeusExRootWindow(p.rootWindow).hud.cross.SetCrosshair(p.bCrosshairVisible);
	DeusExRootWindow(p.rootWindow).hud.frobDisplay.Show();
	
	return true;
}

static final function string RTrim(coerce string H, optional string N)
{
	local int Nl, Hl;
	
	if (N == "")
	N = " ";
	
	Nl = len(N);
	Hl = len(H);
	
	while (Right(H, Nl) == N)
		H = Left(H, Hl -= Nl);
	
	return H;
}

defaultproperties
{
     version=1.200000
     colAmmoNonLethal=(G=255)
     colAmmoFire=(R=255,G=64)
     colAmmoAP=(R=128,B=255)
     bHidden=True
     bTravel=True
}
