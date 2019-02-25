class PoisonKnife extends Shuriken;

auto simulated state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		ScriptedPawn(damagee).bUnStunnable = true;
		super.Explode(HitLocation, HitNormal);
	}
}

defaultproperties
{
     DamageType=Poison
     spawnWeaponClass=Class'DeusEx.WeaponPoisonKnives'
     ItemName="Poisoned Throwing Knife"
     Damage=10.000000
}
