class WeaponPoisonKnives extends WeaponShuriken;

function name WeaponDamageType()
{
	return 'Poison';
}

defaultproperties
{
     AmmoName=Class'DeusEx.AmmoPoisonKnife'
     ProjectileClass=Class'DeusEx.PoisonKnife'
     ItemName="Poisoned Throwing Knives"
     Description="A favorite weapon of assassins in the Far East for centuries, throwing knives can be deadly when wielded by a master but are more generally used when it becomes desirable to send a message. The message is usually 'Your death is coming on swift feet.'|n|nThese throwing knives have been coated with a deadly toxin which is virtually guaranteed to kill within seconds."
     beltDescription="PSN KNIFE"
}
