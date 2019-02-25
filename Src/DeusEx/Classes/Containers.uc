//=============================================================================
// Containers.
//=============================================================================
class Containers extends DeusExDecoration
	abstract;

var() int numThings;
var() bool bGenerateTrash;

//== Loot variables
/*var travel bool bLootable; //== Can be looted on frob
var() travel bool bLooted; //== If the item has already been looted so we can pick it up/etc.
var() travel bool bRandomize; //== If True, give some random inventory (if there's none already)
//var() bool bSearchMsgPrinted;*/

var localized string ContainerEmpty;
var localized string ContainerDiscard;
var localized string ContainerFound;
//
// copied from Engine.Decoration
//
function Destroyed()
{
	local actor dropped;
	local class<actor> tempClass;
	local int i;
	local Rotator rot;
	local Vector loc;
	local TrashPaper trash;
	local Rat vermin;

	// trace down to see if we are sitting on the ground
	loc = vect(0,0,0);
	loc.Z -= CollisionHeight + 8.0;
	loc += Location;

	// only generate trash if we are on the ground
	if (!FastTrace(loc) && bGenerateTrash)
	{
		// maybe spawn some paper
		for (i=0; i<4; i++)
		{
			if (FRand() < 0.75)
			{
				loc = Location;
				loc.X += (CollisionRadius / 2) - FRand() * CollisionRadius;
				loc.Y += (CollisionRadius / 2) - FRand() * CollisionRadius;
				loc.Z += (CollisionHeight / 2) - FRand() * CollisionHeight;
				trash = Spawn(class'TrashPaper',,, loc);
				if (trash != None)
				{
					trash.SetPhysics(PHYS_Rolling);
					trash.rot = RotRand(True);
					trash.rot.Yaw = 0;
					trash.dir = VRand() * 20 + vect(20,20,0);
					trash.dir.Z = 0;
				}
			}
		}

		// maybe spawn a rat
		if (FRand() < 0.5)
		{
			loc = Location;
			loc.Z -= CollisionHeight;
			vermin = Spawn(class'Rat',,, loc);
			if (vermin != None)
				vermin.bTransient = true;
		}
	}

	if( (Pawn(Base) != None) && (Pawn(Base).CarriedDecoration == self) )
		Pawn(Base).DropDecoration();
	if( (Contents!=None) && !Level.bStartup )
	{
		tempClass = Contents;
		if (Content2!=None && FRand()<0.3) tempClass = Content2;
		if (Content3!=None && FRand()<0.3) tempClass = Content3;

		for (i=0; i<numThings; i++)
		{
			loc = Location+VRand()*CollisionRadius;
			loc.Z = Location.Z;
			rot = rot(0,0,0);
			rot.Yaw = FRand() * 65535;
			dropped = Spawn(tempClass,,, loc, rot);
			if (dropped != None)
			{
				if(dropped.IsA('Credits'))
					Credits(dropped).numCredits = 1 + Rand(30);

				dropped.RemoteRole = ROLE_DumbProxy;
				dropped.SetPhysics(PHYS_Falling);
				dropped.bCollideWorld = true;
				dropped.Velocity = VRand() * 50;
				if ( inventory(dropped) != None )
					inventory(dropped).GotoState('Pickup', 'Dropped');
			}
		}
	}

	Super.Destroyed();
}

defaultproperties
{
     numThings=1
     ContainerEmpty="You don't find anything"
     ContainerDiscard="You discarded"
     ContainerFound="You found:"
     bFlammable=True
     bCanBeBase=True
}
