class SpiderGrenade extends EMPGrenade;

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	super.DrawExplosionEffects(HitLocation, HitNormal);
	Spawn(class'PortableSpiderBot', owner,, HitLocation);
}

defaultproperties
{
     blastRadius=0.000000
     spawnWeaponClass=None
     ItemName="Spider Grenade"
     Damage=0.000000
}
