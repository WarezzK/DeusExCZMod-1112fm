//=============================================================================
// Fan1.
//=============================================================================
class Fan1 extends DeusExDecoration;

function bool Facelift(bool bOn)
{
	if(!Super.Facelift(bOn))
		return false;

	if(bOn)
		Mesh = mesh(DynamicLoadObject("HDTPDecos.HDTPFan1", class'mesh', True));

	if(Mesh == None || !bOn)
		Mesh = Default.Mesh;

	return true;
}

defaultproperties
{
     bHighlight=False
     bCanBeBase=True
     ItemName="Fan"
     bPushable=False
     Physics=PHYS_Rotating
     Mesh=LodMesh'DeusExDeco.Fan1'
     CollisionRadius=326.000000
     CollisionHeight=103.000000
     bCollideWorld=False
     bFixedRotationDir=True
     Mass=500.000000
     Buoyancy=100.000000
     RotationRate=(Yaw=8192)
     BindName="Fan"
}
