class PortableSpiderBot extends SpiderBot2;

var float dTimer;

function PreBeginPlay()
{
	if(Pawn(Owner) != None)
	{
		SetAlliance(Pawn(Owner).Alliance);
		//Alliance = Pawn(Owner).Alliance;
	}
	
	super.PreBeginPlay();
}

defaultproperties
{
     EMPHitPoints=15
     bKeepWeaponDrawn=True
     bHateInjury=False
     bEmitDistress=False
     GroundSpeed=110.000000
     Health=40
     AttitudeToPlayer=ATTITUDE_Follow
     DrawScale=0.500000
     CollisionRadius=16.790001
     CollisionHeight=7.620000
     Mass=100.000000
     BindName="PortableSpiderBot"
     FamiliarName="Portable SpiderBot"
     UnfamiliarName="Portable SpiderBot"
}
