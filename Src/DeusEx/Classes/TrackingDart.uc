//Justice: Projectile that chooses targets for the tracking aug
class TrackingDart extends DeusExProjectile;

auto simulated state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		if(damagee != None)
			if(DeusExPlayer(GetPlayerPawn()).augmentationSystem.findAugmentation(class'AugTarget') != None)
				AugTarget(DeusExPlayer(GetPlayerPawn()).augmentationSystem.findAugmentation(class'AugTarget')).setTarget(damagee);	
			
		Super.Explode(HitLocation, HitNormal);
	}
}

defaultproperties
{
     bEmitDanger=False
     ItemName="Tracking Dart"
     speed=2000.000000
     MaxSpeed=3000.000000
     SpawnSound=Sound'DeusExSounds.Weapons.MiniCrossbowFire'
}
