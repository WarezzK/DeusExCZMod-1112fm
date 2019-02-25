//=============================================================================
// AmmoEMPGrenade.
//=============================================================================
class AmmoEMPGrenade extends DeusExAmmo;

//Justice: Modified for new demo skill

defaultproperties
{
     isGrenade=True
     AmmoAmount=1
     MaxAmmo=6
     PickupViewMesh=LodMesh'DeusExItems.TestBox'
     Icon=Texture'DeusExUI.Icons.BeltIconEMPGrenade'
     beltDescription="EMP GREN"
     Mesh=LodMesh'DeusExItems.TestBox'
     CollisionRadius=22.500000
     CollisionHeight=16.000000
     bCollideActors=True
}
