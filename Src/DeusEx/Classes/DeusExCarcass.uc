//=============================================================================
// DeusExCarcass.
//=============================================================================
class DeusExCarcass extends Carcass;

struct InventoryItemCarcass  {
	var() class<Inventory> Inventory;
	var() int              count;
};

struct AddedInventory  {
	var() class     class;
	var() int       count;
};

var(Display) mesh Mesh2;		// mesh for secondary carcass
var(Display) mesh Mesh3;		// mesh for floating carcass
var(Inventory) InventoryItemCarcass InitialInventory[8];  // Initial inventory items held in the carcass
var AddedInventory  AddedInventoryItems[20];
var() bool bHighlight;

var String			KillerBindName;		// what was the bind name of whoever killed me?
var Name			KillerAlliance;		// what alliance killed me?
var bool			bGenerateFlies;		// should we make flies?
var FlyGenerator		flyGen;
var Name			Alliance;			// this body's alliance
var Name			CarcassName;		// original name of carcass
var int				MaxDamage;			// maximum amount of cumulative damage
var bool			bNotDead;			// this body is just unconscious
var() bool			bEmitCarcass;		// make other NPCs aware of this body
var bool		    bQueuedDestroy;	// For multiplayer, semaphore so you can't doublefrob bodies (since destroy is latent)

var bool			bInit;

// Used for Received Items window
var bool bSearchMsgPrinted;

var localized string msgSearching;
var localized string msgEmpty;
var localized string msgNotDead;
var localized string msgAnimalCarcass;
var localized string msgCannotPickup;
var localized String msgRecharged;
var localized string itemName;			// human readable name

var() bool bInvincible;
var bool bAnimalCarcass;

var bool bOnFire;
var float burnTimer;
var float BurnPeriod;

var class<Inventory> FrobItems[4]; // Items to spawn on frob.  Used to give items to corpses after they are spawned

//Justice: Stuff we need to know in order to kill unconscious people
var string deadName; 
var bool wasFemale;
var String flagName;
var bool wasImportant;

var bool underwater;
var float drownTimer;

function PreBeginPlay()
{
	local DeusExPlayer player;
	
	Super.PreBeginPlay();
	
	player = DeusExPlayer(GetPlayerPawn());

	if(Level.NetMode == NM_StandAlone && player != None)
	{
		if (player.NanoMod.hasHDTP && (player.NanoMod.enableHDTPHumans || bAnimalCarcass))
		Facelift(true);
	}
}

function bool Facelift(bool bOn)
{
	//== Only do this for DeusEx classes
	if(instr(String(Class.Name), ".") > -1 && bOn)
		if(instr(String(Class.Name), "DeusEx.") <= -1)
			return false;
	//else
	//	if((Class != Class(DynamicLoadObject("DeusEx."$ String(Class.Name), class'Class', True))) && bOn)
	//		return false;

	return true;
}

// ----------------------------------------------------------------------
// InitFor()
// ----------------------------------------------------------------------

function InitFor(Actor Other)
{
	if (Other != None)
	{
		// set as unconscious or add the pawns name to the description
		//== and now use the FamiliarName field to store the full, descriptive name
//		if (!bAnimalCarcass)
//		{
		
		if (bNotDead)
		{
			deadName = itemName $ " (" $ ScriptedPawn(Other).FamiliarName $ ")"; //Justice: Save these for later
			wasFemale = ScriptedPawn(Other).bIsFemale;	
			wasImportant = ScriptedPawn(Other).bImportant;
			flagName = Other.BindName;
			
			itemName = msgNotDead;
			FamiliarName = msgNotDead $ " (" $ ScriptedPawn(Other).FamiliarName $ ")";
		}
		else if (Other.IsA('ScriptedPawn'))
		{
			itemName = itemName $ " (" $ ScriptedPawn(Other).FamiliarName $ ")";
			FamiliarName = itemName;
		}
//		}

		Mass           = Other.Mass;
		Buoyancy       = Mass * 1.2;
		MaxDamage      = 0.8*Mass;
//		if (ScriptedPawn(Other) != None)
//		{
//			if (ScriptedPawn(Other).bBurnedToDeath)
//			{
//				CumulativeDamage = MaxDamage-1;
//			}
//		}

		SetScaleGlow();

		// Will this carcass spawn flies?
		if (bAnimalCarcass && !bNotDead)
		{
			itemName = msgAnimalCarcass;
			FamiliarName = itemName $ " (" $ ScriptedPawn(Other).FamiliarName $ ")";
			if (FRand() < 0.2)
				bGenerateFlies = true;
		}
		else if (!Other.IsA('Robot') && !bNotDead)
		{
			if (FRand() < 0.1)
				bGenerateFlies = true;
			bEmitCarcass = true;
		}

		if (Other.AnimSequence == 'DeathFront')
			Mesh = Mesh2;

		// set the instigator and tag information
		if (Other.Instigator != None)
		{
			KillerBindName = Other.Instigator.BindName;
			KillerAlliance = Other.Instigator.Alliance;
		}
		else
		{
			KillerBindName = Other.BindName;
			KillerAlliance = '';
		}
		Tag = Other.Tag;
		Alliance = Pawn(Other).Alliance;
		CarcassName = Other.Name;
	}
}

// ----------------------------------------------------------------------
// PostBeginPlay()
// ----------------------------------------------------------------------

function PostBeginPlay()
{
	local int i, j;
	local Inventory inv;

	bCollideWorld = true;

	// Use the carcass name by default
	CarcassName = Name;

	// Add initial inventory items
	for (i=0; i<8; i++)
	{
		if ((InitialInventory[i].inventory != None) && (InitialInventory[i].count > 0))
		{
			for (j=0; j<InitialInventory[i].count; j++)
			{
				inv = spawn(InitialInventory[i].inventory, self);
				if (inv != None)
				{
					inv.bHidden = True;
					inv.SetPhysics(PHYS_None);
					AddInventory(inv);
				}
			}
		}
	}

	// use the correct mesh
	if (Region.Zone.bWaterZone)
	{
		Mesh = Mesh3;
		bNotDead = False;		// you will die in water every time
	}

	if (bAnimalCarcass && !bNotDead)
		itemName = msgAnimalCarcass;

	MaxDamage = 0.8*Mass;
	SetScaleGlow();

	SetTimer(30.0, False);

	Super.PostBeginPlay();
}

// ----------------------------------------------------------------------
// ZoneChange()
// ----------------------------------------------------------------------

function ZoneChange(ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);

	// use the correct mesh for water
	if (NewZone.bWaterZone)
	{
		if(bOnFire)
			ExtinguishFire();

		Mesh = Mesh3;
	}
	
	underwater = NewZone.bWaterZone;
}

// ----------------------------------------------------------------------
// Destroyed()
// ----------------------------------------------------------------------

function Destroyed()
{
	if (flyGen != None)
	{
		flyGen.StopGenerator();
		flyGen = None;
	}

	Super.Destroyed();
}

// ----------------------------------------------------------------------
// Tick()
// ----------------------------------------------------------------------

function Tick(float deltaSeconds)
{
	local Fire f;
	local ParticleGenerator p;
	local vector loc;

	if (!bInit)
	{
		bInit = true;
		if (bEmitCarcass)
			AIStartEvent('Carcass', EAITYPE_Visual);
	}
	if (bOnFire)
	{
		
		foreach BasedActors(class'Fire',f)
		{
			loc = f.Location;
			if(loc.Z > Location.Z + (CollisionHeight * 0.300000))
				loc.Z -= ( FMax(loc.Z - (Location.Z - CollisionHeight), 3.50) * deltaSeconds );
			else if(loc.Z < Location.Z - (CollisionHeight * 0.300000))
				loc.Z += ( FMax((Location.Z + CollisionHeight) - loc.Z, 3.50) * deltaSeconds );
			f.SetLocation(loc);

			if(f.smokeGen != None)
				f.smokeGen.SetLocation(loc);

			if(f.fireGen != None)
				f.fireGen.SetLocation(loc);
		}
		if(CumulativeDamage < MaxDamage)
		{
			burnTimer += deltaSeconds;
			UpdateFire(deltaSeconds);
			//== If there are no visible fire effects then we need to stop burning, lest this get very confusing
			if (burnTimer >= BurnPeriod || f == None)
				ExtinguishFire();
		}
	}
	
	if(underwater && bNotDead) //Justice: Unconscious people are even more succeptible to drowning than normal
	{
		if(drownTimer <= 0)
		{
			TakeDamage(5, None, Location, vect(0,0,0), 'Drowned');
			drownTimer = 2.0;
		}
		else
			drownTimer -= deltaSeconds;
	}
	
	Super.Tick(deltaSeconds);
}

// ----------------------------------------------------------------------
// Timer()
// ----------------------------------------------------------------------

function Timer()
{
	if (bGenerateFlies && !bOnFire)
	{
		flyGen = Spawn(Class'FlyGenerator', , , Location, Rotation);
		if (flyGen != None)
			flyGen.SetBase(self);
	}
}

// ----------------------------------------------------------------------
// ChunkUp()
// ----------------------------------------------------------------------

function ChunkUp(int Damage)
{
	local int i;
	local float size;
	local Vector loc;
	local FleshFragment chunk;
	
	if (!bAnimalCarcass && Inventory != None)
		return;

	// gib the carcass
	size = (CollisionRadius + CollisionHeight) / 2;
	if (size > 10.0)
	{
		for (i=0; i<size/4.0; i++)
		{
			loc.X = (1-2*FRand()) * CollisionRadius;
			loc.Y = (1-2*FRand()) * CollisionRadius;
			loc.Z = (1-2*FRand()) * CollisionHeight;
			loc += Location;
			chunk = spawn(class'FleshFragment', None,, loc);
			if (chunk != None)
			{
				chunk.DrawScale = size / 25;
				chunk.SetCollisionSize(chunk.CollisionRadius / chunk.DrawScale, chunk.CollisionHeight / chunk.DrawScale);
				chunk.bFixedRotationDir = True;
				chunk.RotationRate = RotRand(False);
			}
		}
	}

	Super.ChunkUp(Damage);
}

// ----------------------------------------------------------------------
// TakeDamage()
// ----------------------------------------------------------------------

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitLocation, Vector momentum, name damageType)
{
	local int i;

	if (bInvincible)
		return;

	// only take "gib" damage from these damage types
	if ((damageType == 'Shot') || (damageType == 'Sabot') || (damageType == 'Exploded') || (damageType == 'Munch') ||
	    (damageType == 'Tantalus') || (damageType == 'Shell') || (damageType == 'Fell')) //Justice: Falling can gib you too!
	{
		if ((damageType != 'Munch') && (damageType != 'Tantalus'))
		{
         if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
         {
         }
         else
         {
            spawn(class'BloodSpurt',,,HitLocation);
            spawn(class'BloodDrop',,, HitLocation);
            for (i=0; i<Damage; i+=10)
               spawn(class'BloodDrop',,, HitLocation);
         }
		}

		// this section copied from Carcass::TakeDamage() and modified a little
		if (!bDecorative)
		{
			bBobbing = false;
			SetPhysics(PHYS_Falling);
		}
		if ((Physics == PHYS_None) && (Momentum.Z < 0))
			Momentum.Z *= -1;
		Velocity += 3 * momentum/(Mass + 200);
		if (DamageType == 'Shot' || DamageType == 'Shell')
			Damage *= 0.4;
		CumulativeDamage += Damage;
		if (CumulativeDamage >= MaxDamage)
		{
			if(bOnFire)
				ExtinguishFire();
				
			if(bNotDead) //Justice: Gibbing is no excuse for pretending you're alive!
				setDeathFlags(InstigatedBy);

			ChunkUp(Damage);
			
			CumulativeDamage = MaxDamage - 1;
		}
		
		if (bDecorative)
			Velocity = vect(0,0,0);
	}

	if(bNotDead)
	{
		//Justice: Only apply these damage types if the "corpse" is alive
		if(damageType == 'Drowned' || damageType == 'Radiation' || damageType == 'Burned' || damageType == 'Flamed' || damageType == 'PoisonGas' || damageType == 'HalonGas')
			CumulativeDamage += Damage;
		
		//Justice: Make it possible for unconscious NPCs to die
		if(!bAnimalCarcass && (damageType == 'Shot' || damageType == 'Sabot' || damageType == 'Exploded' || damageType == 'Munch' ||
		damageType == 'Tantalus' || damageType == 'Shell' || damageType == 'Fell' || damageType == 'Drowned' || damageType == 'Flamed' ||
		damageType == 'Burned' || damageType == 'Radiation' || damageType == 'PoisonGas' || damageType == 'HalonGas'))
		{
			if(CumulativeDamage * 10 >= MaxDamage)
			{
				bNotDead = False;
				itemName = deadName;
				FamiliarName = itemName;
			
				if (Region.Zone.bWaterZone)
				{
					if(wasFemale)
						PlaySound(sound'FemaleWaterDeath', SLOT_Pain,,,, 1.1 - 0.2*FRand());
					else
						PlaySound(sound'MaleWaterDeath', SLOT_Pain,,,, 1.1 - 0.2*FRand());
				}
				else
				{
					if(wasFemale)
						PlaySound(sound'FemaleDeath', SLOT_Pain,,,, 1.1 - 0.2*FRand());
					else
						PlaySound(sound'MaleDeath', SLOT_Pain,,,, 1.1 - 0.2*FRand());
				}
				
				AISendEvent('LoudNoise', EAITYPE_Audio);
				
				setDeathFlags(InstigatedBy);
			}
		}
	}
	
	SetScaleGlow();
}

// ----------------------------------------------------------------------
// SetScaleGlow()
//
// sets the scale glow for the carcass, based on damage
// ----------------------------------------------------------------------

function SetScaleGlow()
{
	local float pct;

	// scaleglow based on damage
	pct = FClamp(1.0-float(CumulativeDamage)/MaxDamage, 0.1, 1.0);
	ScaleGlow = pct;
}

// ----------------------------------------------------------------------
// Frob()
//
// search the body for inventory items and give them to the frobber
// ----------------------------------------------------------------------

function Frob(Actor Frobber, Inventory frobWith)
{
	local Inventory item, nextItem, startItem, tempitem;
	local Pawn P;
	local DeusExWeapon W;
	local bool bFoundSomething;
	local DeusExPlayer player;
	local ammo AmmoType;
	local bool bPickedItemUp, bHasSuperior, weapAmmoFull, weapCanPickup;
	local POVCorpse corpse;
	local DeusExPickup invItem;
	local int itemCount, FIcount;

//log("DeusExCarcass::Frob()--------------------------------");

	// Can we assume only the *PLAYER* would actually be frobbing carci?
	player = DeusExPlayer(Frobber);

	// No doublefrobbing in multiplayer.
	if (bQueuedDestroy)
		return;

	FIcount = 0;

	// if we've already been searched, let the player pick us up
	// don't pick up animal carcii
	if (!bAnimalCarcass)
	{
      // DEUS_EX AMSD Since we don't have animations for carrying corpses, and since it has no real use in multiplayer,
      // and since the PutInHand propagation doesn't just work, this is work we don't need to do.
      // Were you to do it, you'd need to check the respawning issue, destroy the POVcorpse it creates and point to the
      // one in inventory (like I did when giving the player starting inventory).
		if ((Inventory == None) && (player != None) && (player.inHand == None) && (Level.NetMode == NM_Standalone))
		{
			if (!bInvincible)
			{
				corpse = Spawn(class'POVCorpse');
				if (corpse != None)
				{
					// destroy the actual carcass and put the fake one
					// in the player's hands
					corpse.carcClassString = String(Class);
					corpse.KillerAlliance = KillerAlliance;
					corpse.KillerBindName = KillerBindName;
					corpse.Alliance = Alliance;
					corpse.bNotDead = bNotDead;
					corpse.bEmitCarcass = bEmitCarcass;
					corpse.CumulativeDamage = CumulativeDamage;
					corpse.MaxDamage = MaxDamage;
					corpse.CorpseItemName = itemName;
					corpse.CarcassName = CarcassName;
					corpse.FamiliarName = FamiliarName; //Make sure to track the nifty Familiar Name
					
					//Justice: Keep track of the unconscious vars as well
					corpse.deadName = deadName;
					corpse.wasFemale = wasFemale;
					corpse.wasImportant = wasImportant;
					corpse.flagName = flagName;
					
					corpse.Frob(player, None);
					corpse.SetBase(player);
					player.PutInHand(corpse);
					bQueuedDestroy=True;
					Destroy();
					return;
				}
			}
		}
	}

	bFoundSomething = False;
	bSearchMsgPrinted = False;
	P = Pawn(Frobber);
	if (P != None)
	{
		// Make sure the "Received Items" display is cleared
      // DEUS_EX AMSD Don't bother displaying in multiplayer.  For propagation
      // reasons it is a lot more of a hassle than it is worth.
		if ( (player != None) && (Level.NetMode == NM_Standalone) )
         DeusExRootWindow(player.rootWindow).hud.receivedItems.RemoveItems();

		if (Inventory != None)
		{
			//== If by some chance we get items that belong to the player, skip them and move the Inventory
			//==  variable to something
			while(Inventory.Owner == Frobber)
			{
				Inventory = Inventory.Inventory;
				if(Inventory == None)
					break;
			}

			item = Inventory;
			startItem = item;

			do
			{
				//log("===>DeusExCarcass:item="$item );

				if(item == None)
					break;

				while(item.Owner == Frobber)
				{
					item = item.Inventory;
					if(item == None)
						break;
				}

				if(item == None)
					break;

				nextItem = item.Inventory;

				if(nextItem != None)
				{
					while(nextItem.Owner == Frobber)
					{
						nextItem = nextItem.Inventory;
						item.Inventory = nextItem; //== Relink to the appropriate, un-player-owned item
						if(nextItem == None)
							break;
					}
				}

				bPickedItemUp = False;

				if (item.IsA('Ammo'))
				{
					// Only let the player pick up ammo that's already in a weapon

					if(DeusExAmmo(item) != None && !item.IsA('AmmoCombatKnife') && !DeusExAmmo(item).isGrenade && !item.IsA('AmmoShuriken') && !item.IsA('AmmoNone'))
					{
						if (DeusExAmmo(item).bIsNonStandard && (player.FindInventoryType(item.Class) != None || player.combatDifficulty > 4.0))
						{
							itemCount = Rand(Max(Ammo(item).Default.AmmoAmount/2, 4)) + 1;
							
							/*if(item.IsA('AmmoSabot') || item.IsA('Ammo10mmEX') || item.IsA('AmmoDragon'))
							{
								itemCount = 1 + Rand(12);
								if(Ammo(item).AmmoAmount >= 5 && Ammo(item).AmmoAmount <= 12)
									itemCount = Ammo(item).AmmoAmount;
							}
							else if(Ammo(item).AmmoAmount <= 4 && Ammo(item).AmmoAmount >= 1)
								itemCount = Ammo(item).AmmoAmount;
							else
								itemCount = 1 + Rand(4);*/

							//Ammo(item).AmmoAmount = itemCount;
							
							AmmoType = Ammo(player.FindInventoryType(item.Class));

							// EXCEPT for non-standard ammo -- Y|yukichigai
							if(AmmoType != None)
							{
								if (AmmoType.AmmoAmount >= AmmoType.MaxAmmo)
								{
									tempitem = spawn(item.Class, self);
									AmmoType.AmmoAmount = itemCount;
									
									P.ClientMessage("You cannot pickup the" @ item.itemName);
								}
								
								else
								{
									if (AmmoType.AmmoAmount + itemCount >= AmmoType.MaxAmmo)
									itemCount = (AmmoType.MaxAmmo - AmmoType.AmmoAmount);
									
									AmmoType.AddAmmo(itemCount);
									AddReceivedItem(player, AmmoType, itemCount);
								 
									// Update the ammo display on the object belt
									//player.UpdateAmmoBeltText(AmmoType);
									
									P.ClientMessage(AmmoType.PickupMessage @ AmmoType.itemArticle @ AmmoType.ItemName @ "("$itemCount$")", 'Pickup');
								}
								
								bFoundSomething = True;
							}
							//This is the code which would allow randomly-given ammo to be picked up by a player
							// regardless of if they have picked it up before.  This would (I feel) lead to
							// Shifter advancing the progress of the game prematurely, something which I am
							// endeavoring to avoid in the process of my coding -- Y|yukichigai
							else /* if(!DeusExAmmo(item).bIsNonStandard  && player.combatDifficulty > 4.0)*/ //== But in unrealistic, who cares?
							{
								tempitem = spawn(item.Class, player);
								Ammo(tempitem).AmmoAmount = itemCount;
								tempitem.InitialState='Idle2';
								tempitem.GiveTo(player);
								tempitem.setBase(player);
								//player.UpdateAmmoBeltText(Ammo(tempitem));
								P.ClientMessage(tempitem.PickupMessage @ tempitem.itemArticle @ tempitem.ItemName @ "("$itemCount$")", 'Pickup');
								AddReceivedItem(player, tempitem, itemCount);
								
								bFoundSomething = True;
							}
						}
					}
					
					bPickedItemUp = True;
					DeleteInventory(item);
					item.Destroy();
					item = None;
					
					//log("===>Ammo deleted" );
				}
				
				else if ( (item.IsA('DeusExWeapon')) )
				{
					//It's nice to know that EVERY F%$#ING NPC carries a combat knife,
					// but do we really need it f%$#ing filling our open slots?
					if(item.IsA('WeaponCombatKnife') && !DeusExWeapon(item).bUnique)
					{
						if(player.FindInventoryType(Class'DeusEx.WeaponCombatKnife') == None)
						{
							//If we have a Sword, Crowbar or Dragon's Tooth just get rid of the damn thing
							if(player.FindInventoryType(Class'DeusEx.WeaponSword') != None ||
							 player.FindInventoryType(Class'DeusEx.WeaponCrowbar') != None ||
							 player.FindInventoryType(Class'DeusEx.WeaponBaton') != None ||
							 player.FindInventoryType(Class'DeusEx.WeaponToxinBlade') != None ||
							 player.FindInventoryType(Class'DeusEx.WeaponNanoSword') != None ||
							player.FindInventoryType(Class'WeaponPrototypeSwordA') != None ||
							player.FindInventoryType(Class'WeaponPrototypeSwordB') != None ||
							player.FindInventoryType(Class'WeaponPrototypeSwordC') != None)
							{
								DeleteInventory(item);
								item.Destroy();
								//Create a pickup in case they really want it
								spawn(Class'DeusEx.WeaponCombatKnife', self);
								item = None;
								P.ClientMessage("You discarded a Combat Knife");
								bPickedItemUp = True;
								bFoundSomething = True;
							}
						}
					}
					
					else if(item.IsA('WeaponBaton') && !DeusExWeapon(item).bUnique)
					{
							//If we have a Sword, Crowbar or Dragon's Tooth just get rid of the damn thing
							if(player.FindInventoryType(Class'DeusEx.WeaponSword') != None ||
							 player.FindInventoryType(Class'DeusEx.WeaponCrowbar') != None ||
							 player.FindInventoryType(Class'DeusEx.WeaponBaton') != None ||
							 player.FindInventoryType(Class'WeaponBlackjack') != None ||
							 player.FindInventoryType(Class'DeusEx.WeaponNanoSword') != None ||
							player.FindInventoryType(Class'WeaponPrototypeSwordA') != None ||
							player.FindInventoryType(Class'WeaponPrototypeSwordB') != None ||
							player.FindInventoryType(Class'WeaponPrototypeSwordC') != None)
							{
								DeleteInventory(item);
								item.Destroy();
								//Create a pickup in case they really want it
								spawn(Class'DeusEx.WeaponBaton', self);
								//W = None;
								P.ClientMessage("You discarded a Baton");
								bPickedItemUp = True;
								item = None;
								bFoundSomething = True;
							}
					}
					
					else if(item.IsA('WeaponCrowbar') && !DeusExWeapon(item).bUnique)
					{
							//If we have a Sword, Crowbar or Dragon's Tooth just get rid of the damn thing
							if(player.FindInventoryType(Class'DeusEx.WeaponSword') != None ||
							 player.FindInventoryType(Class'DeusEx.WeaponNanoSword') != None ||
							 player.FindInventoryType(Class'DeusEx.WeaponCrowbar') != None ||
							player.FindInventoryType(Class'WeaponPrototypeSwordA') != None ||
							player.FindInventoryType(Class'WeaponPrototypeSwordB') != None ||
							player.FindInventoryType(Class'WeaponPrototypeSwordC') != None)
							{
								DeleteInventory(item);
								item.Destroy();
								//Create a pickup in case they really want it
								//spawn(Class'DeusEx.WeaponCombatKnife', self);
								item = None;
								//P.ClientMessage("You discarded a Crowbar (You have a better or an equal melee weapon)");
								bPickedItemUp = True;
							}
					}

					else if(item.IsA('WeaponSword') && !DeusExWeapon(item).bUnique)
					{
							//If we have a Sword, Crowbar or Dragon's Tooth just get rid of the damn thing
							if(player.FindInventoryType(Class'DeusEx.WeaponNanoSword') != None ||
							player.FindInventoryType(Class'WeaponPrototypeSwordA') != None ||
							(player.FindInventoryType(Class'WeaponSword') != None) ||
							player.FindInventoryType(Class'WeaponPrototypeSwordB') != None ||
							player.FindInventoryType(Class'WeaponPrototypeSwordC') != None)
							{
								DeleteInventory(item);
								item.Destroy();
								//Create a pickup in case they really want it
								//spawn(Class'DeusEx.WeaponCombatKnife', self);
								item = None;
								//P.ClientMessage("You discarded a Sword (You have a better or an equal melee weapon)");
								bPickedItemUp = True;
							}
					}
					
					else if(item.IsA('WeaponNanoSword') && !DeusExWeapon(item).bUnique)
					{
							if(player.FindInventoryType(Class'DeusEx.WeaponNanoSword') != None)
							{
								DeleteInventory(item);
								item.Destroy();
								item = None;
								bPickedItemUp = True;
							}
					}
				}
				
				else if (item.IsA('NanoKey'))
				{
					if (player != None)
					{
						if (player.PickupNanoKey(NanoKey(item)))
							AddReceivedItem(player, item, 1);
						
						bFoundSomething = True;
						DeleteInventory(item);
						item.Destroy();
						item = None;
					}
					
					bPickedItemUp = True;
				}
				else if (item.IsA('Credits'))		// I hate special cases
				{
					if (player != None)
					{
						AddReceivedItem(player, item, Credits(item).numCredits);
						player.Credits += Credits(item).numCredits;
						P.ClientMessage(Sprintf(Credits(item).msgCreditsAdded, Credits(item).numCredits));
						DeleteInventory(item);
						item.Destroy();
						item = None;
						bFoundSomething = True;
					}
					bPickedItemUp = True;
				}
				
				else if (item.IsA('WeaponMod') && bNotDead && wasImportant && WeaponMod(item).bFromRandom)
				{
					item = None;
					bPickedItemUp = True;
				}
				
				else if (item.IsA('Consumable') && player.NanoMod.noMoreConsumables)
				{
					DeleteInventory(item);
					item.Destroy();
					item = None;
					bPickedItemUp = True;
				}
				
				if (item != None)
				{
					bFoundSomething = True;
					bHasSuperior    = False;
						
					if (item.IsA('DeusExWeapon'))   // I *really* hate special cases
					{
						// Any weapons have their ammo set to a random number of rounds (1-4)
			               // unless it's a grenade, in which case we only want to dole out one.
				        //== Except now, where the amount to dole out is randomly determined by the
				        //==  default PickupAmmoCount variable

					    // DEUS_EX AMSD In multiplayer, give everything away.
					    W = DeusExWeapon(item);
		   
					    // Grenades and LAMs always pickup 1
					    if (W.IsA('WeaponGrenade') ||
							W.IsA('WeaponCombatKnife') )
								W.PickupAmmoCount = 1;
					    else if (Level.NetMode == NM_Standalone) //a: but.. what if it can't have any ammo at all? ah well.
							W.PickupAmmoCount = Rand(W.Default.PickupAmmoCount/2) + 1; //Rand(4) + 1;
							  
						// Okay, check to see if the player already has this weapon.  If so,
						// then just give the ammo and not the weapon.  Otherwise give
						// the weapon normally. 
						W = DeusExWeapon(player.FindInventoryType(item.Class));
						
						if (!player.NanoMod.disableGunSquelching)
						{
							if ((item.Class == Class'WeaponSawedOffShotgun' && 
							(player.FindInventoryType(Class'WeaponAssaultShotgun') != None || player.FindInventoryType(Class'WeaponBoomstick') != None)) ||
							(item.Class == Class'WeaponPistol' && (player.FindInventoryType(Class'WeaponStealthPistol') != None || player.FindInventoryType(Class'WeaponMagnum') != None)) || 
						    ((item.Class == Class'WeaponPistol' || item.Class == Class'WeaponMiniCrossbow' ||
							 item.Class == Class'WeaponProd' || item.Class == Class'WeaponPepperGun') &&  player.FindInventoryType(Class'WeaponAssaultGun') != None))
							{
								bHasSuperior = true;
							}
						}

						// If the player already has this item in his inventory, piece of cake,
						// we just give him the ammo.  However, if the Weapon is *not* in the 
						// player's inventory, first check to see if there's room for it.  If so,
						// then we'll give it to him normally.  If there's *NO* room, then we 
						// want to give the player the AMMO only (as if the player already had 
						// the weapon).
						
						weapAmmoFull  = False;
						weapCanPickup = (item != None && player.FindInventorySlot(item, True));
						
						//a: do this for all weapons we won't actually pick up
						if ((W != None || (W == None && (!weapCanPickup || bHasSuperior))) && !bPickedItemUp)
						{
							//log("===>Our weapon check");

							//a: grenades/etc cannot be depleted of their ammo if we don't have them and there is no room to actually pick them up
							if (Weapon(item) != None && !(W == None && !weapCanPickUp && (item.IsA('WeaponGrenade') || item.IsA('WeaponShuriken') || 
														 (item.IsA('WeaponCombatKnife') && !item.IsA('WeaponToxinBlade')))))
							{
								AmmoType = Ammo(player.FindInventoryType(Weapon(item).AmmoName));

								if(AmmoType == None && W != None)
									AmmoType = Ammo(Player.FindInventoryType(W.AmmoName));

								//a: this passes for weapons that we either already have ammo for, or if a weapon can't have ammo
								if (AmmoType != None || Weapon(item).AmmoName == Class'AmmoNone')
								{ //Justice: Demolition now affects the max grenades you can carry
								  //a: this passes if it's a non-empty ammo type and we have room for its ammo
									if(Weapon(item).AmmoName != Class'AmmoNone' && 
										(AmmoType.AmmoAmount < AmmoType.MaxAmmo || (DeusExAmmo(AmmoType).isGrenade && (AmmoType.AmmoAmount < AmmoType.MaxAmmo + (AmmoType.MaxAmmo / 3) * player.SkillSystem.GetSkillLevel(class'SkillDemolition')))))
									{
										//log("===>Found ammo on player" );
										
										if (!item.IsA('WeaponGrenade') && AmmoType.AmmoAmount + Weapon(item).PickupAmmoCount >= AmmoType.MaxAmmo)
										Weapon(item).PickupAmmoCount = AmmoType.MaxAmmo - AmmoType.AmmoAmount;
										
										AmmoType.AddAmmo(Weapon(item).PickupAmmoCount);
	
										if(item.IsA('WeaponShuriken'))
											AddReceivedItem(player, item, Weapon(item).PickupAmmoCount);
										else if(item.IsA('WeaponCombatKnife') || item.IsA('WeaponGrenade'))
											AddReceivedItem(player, item, 1);
										
										else
										AddReceivedItem(player, AmmoType, Weapon(item).PickupAmmoCount);
							   
										// Update the ammo display on the object belt
										player.UpdateAmmoBeltText(AmmoType);
										
										if(item.IsA('WeaponCombatKnife') || item.IsA('WeaponGrenade'))
										{
											// if this is an illegal ammo type, use the weapon name to print the message
											if (AmmoType.PickupViewMesh == Mesh'TestBox')
												P.ClientMessage(item.PickupMessage @ item.itemArticle @ item.itemName, 'Pickup');
											else
												P.ClientMessage(AmmoType.PickupMessage @ AmmoType.itemArticle @ AmmoType.itemName, 'Pickup');
										}
										
										else
										{
											// if this is an illegal ammo type, use the weapon name to print the message
											if (AmmoType.PickupViewMesh == Mesh'TestBox')
												P.ClientMessage(item.PickupMessage @ item.itemArticle @ item.itemName @ "("$Weapon(item).PickupAmmoCount$")", 'Pickup');
											else
												P.ClientMessage(AmmoType.PickupMessage @ AmmoType.itemArticle @ AmmoType.itemName @ "("$Weapon(item).PickupAmmoCount$")", 'Pickup');
										}
										
										// Mark it as 0 to prevent it from being added twice
										//Weapon(item).AmmoType.AmmoAmount = 0;
										Weapon(item).PickupAmmoCount = 0;
										
										if (W == None && bHasSuperior && (item.Class == Class'WeaponProd' || item.Class == Class'WeaponPepperGun'))
										{
											tempitem = spawn(item.Class,self);
											Weapon(tempitem).PickupAmmoCount = 0;
											
											P.ClientMessage("You discarded a" @ item.itemName);
										}
									}
									
									//a: okay so we're either full on ammo or it's a weapon that can't have ammo
									//(PS20 etc, or melee weapons which we only want one of anyway)
									else
									{
										weapAmmoFull = True;
										
										//log("===>Ammo full!" );
									}
								}
								
								//a: since the above check failed, this is non-empty ammo type that we don't have yet
								else
								{
									//log("===>Not found ammo on player!" );
									
									if (!item.IsA('WeaponGrenade') && !item.IsA('WeaponCombatKnife') && !item.IsA('WeaponShuriken'))
									{
										tempitem = spawn(Weapon(item).AmmoName, player);
										Ammo(tempitem).AmmoAmount = Weapon(item).PickupAmmoCount;
										tempitem.InitialState='Idle2';
										tempitem.GiveTo(player);
										tempitem.setBase(player);
										//player.UpdateAmmoBeltText(Ammo(tempitem));
										AddReceivedItem(player, tempitem, Weapon(item).PickupAmmoCount);
										P.ClientMessage(tempitem.PickupMessage @ tempitem.itemArticle @ tempitem.itemName @ "("$Weapon(item).PickupAmmoCount$")", 'Pickup');
										
										//Weapon(item).AmmoType.AmmoAmount = 0;
										Weapon(item).PickupAmmoCount = 0;
									}
								}
							}
							
							//a: errr.. apparently you can carry multiple of these now? Seems so...
							if (W != None && weapAmmoFull && weapCanPickup && (item.IsA('WeaponHideAGun') || item.IsA('WeaponLAW')))
							{
								tempitem = spawn(item.Class, player);
								tempitem.InitialState='Idle2';
								tempitem.GiveTo(player);
								tempitem.setBase(player);
								DeusExPlayer(P).FindInventorySlot(tempitem, false);
								AddReceivedItem(player, tempitem, 1);
								P.ClientMessage(tempitem.PickupMessage @ tempitem.itemArticle @ tempitem.itemName, 'Pickup');
							}
							
							//a: only spawn a copy of the weapon if we're full on its ammo or
							// if we don't have the weapon and can't, but might want to pick up
							else if (weapAmmoFull || (W == None && !weapCanPickup && !bHasSuperior))
							{
								if (W == None && !weapCanPickup && !bHasSuperior)
								P.ClientMessage(Sprintf(Player.InventoryFull, item.itemName));
								
								else
								{
									if (item.IsA('WeaponGrenade') || item.IsA('WeaponShuriken') || item.IsA('WeaponCombatKnife') || Weapon(item).AmmoName == Class'AmmoNone')
									P.ClientMessage(Sprintf(msgCannotPickup, item.itemName));
									
									else
									P.ClientMessage("You already have enough ammo from the" @ item.itemName);
								}
								
								tempitem = spawn(item.Class,self);
								
								//a: remember how the first thing we ever did was set the pickupammount to at least 1
								//without even checking what it was? yea.
								if (Weapon(item).AmmoName != Class'AmmoNone')
								Weapon(tempitem).PickupAmmoCount = Weapon(item).PickupAmmoCount;
								
								//Weapon(tempitem).AmmoType.AmmoAmount = Weapon(item).AmmoType.AmmoAmount;
							}
							
							DeleteInventory(item);
							item.Destroy();
							item = None;
							//log("===>weapon deleted" );
							
							bPickedItemUp = True;
						}
					}

					else if (item.IsA('DeusExAmmo'))
					{
						//a: this will never happen. right?
						//log("===>what?" );
						if (DeusExAmmo(item).AmmoAmount == 0)
							bPickedItemUp = True;
					}

					if (!bPickedItemUp)
					{
						// Special case if this is a DeusExPickup(), it can have multiple copies
						// and the player already has it.

						if ((item.IsA('DeusExPickup')) && (DeusExPickup(item).bCanHaveMultipleCopies) && (player.FindInventoryType(item.class) != None))
						{
							//log("===>Deus ex pickup" );
							invItem   = DeusExPickup(player.FindInventoryType(item.class));
							itemCount = DeusExPickup(item).numCopies;

							// Make sure the player doesn't have too many copies
							if ((invItem.MaxCopies > 0) && (DeusExPickup(item).numCopies + invItem.numCopies > invItem.MaxCopies))
							{	
								// Give the player the max #
								if ((invItem.MaxCopies - invItem.numCopies) > 0)
								{
									itemCount = (invItem.MaxCopies - invItem.numCopies);
									DeusExPickup(item).numCopies = itemCount;
									
									if (DeusExPickup(item).numCopies > 1)
									P.ClientMessage(invItem.PickupMessage @ invItem.itemArticle @ invItem.itemName @ "("$DeusExPickup(item).numCopies$")", 'Pickup');
									else
									P.ClientMessage(invItem.PickupMessage @ invItem.itemArticle @ invItem.itemName, 'Pickup');
									
									invItem.numCopies = invItem.MaxCopies;
									invItem.TransferSkin(item);
									AddReceivedItem(player, invItem, itemCount);
									DeleteInventory(item);
									item.Destroy();	
								}
								else
								{
									P.ClientMessage(Sprintf(msgCannotPickup, invItem.itemName));
									if(Level.NetMode == NM_Standalone)
									{
										invitem = DeusExPickup(spawn(item.Class,self));
										invitem.TransferSkin(item);
										DeleteInventory(item);
										item.Destroy();	
									}
								}
							}
							else
							{
								invItem.numCopies += itemCount;
								invItem.TransferSkin(item);
								DeleteInventory(item);
								item.Destroy();	
								
								if (itemCount > 1)
								P.ClientMessage(invItem.PickupMessage @ invItem.itemArticle @ invItem.itemName @ "("$itemCount$")", 'Pickup');
								
								else
								P.ClientMessage(invItem.PickupMessage @ invItem.itemArticle @ invItem.itemName, 'Pickup');
								
								AddReceivedItem(player, invItem, itemCount);
							}
						}
						else
						{
							//log("===>not deus ex pickup" );
							// check if the pawn is allowed to pick this up
							if ((P.Inventory == None) || (Level.Game.PickupQuery(P, item)))
							{
								if (item.IsA('DeusExWeapon'))
								{
									//a: we got this far.. so that means it's a weapon we can (and will) pick up
									//however, the first routine ever doesn't check if the weapon can even have any ammo
									//so.. reset the pickupammount. Paranoia.
									if (Weapon(item).AmmoName == Class'AmmoNone')
									Weapon(item).PickupAmmoCount = Weapon(item).Default.PickupAmmoCount;
									
									else
									{
										AmmoType = Ammo(player.FindInventoryType(Weapon(item).AmmoName));
										
										if (AmmoType != None)
										{
											if (AmmoType.AmmoAmount >= AmmoType.MaxAmmo)
											weapAmmoFull = true;
												
											else if (AmmoType.AmmoAmount + Weapon(item).PickupAmmoCount >=  AmmoType.MaxAmmo)
											Weapon(item).PickupAmmoCount = AmmoType.MaxAmmo - AmmoType.AmmoAmount;
										}
									}
								}
								
								DeusExPlayer(P).FrobTarget = item;
								if (DeusExPlayer(P).HandleItemPickup(Item) != False)
								{
                           						DeleteInventory(item);

                           						// DEUS_EX AMSD Belt info isn't always getting cleaned up.  Clean it up.
                           						item.bInObjectBelt=False;
                           						item.BeltPos=-1;
									item.SpawnCopy(P);

									// Show the item received in the ReceivedItems window and also 
									// display a line in the Log

									AddReceivedItem(player, item, 1);
									
									//a: this is the only place when we possibly wouldn't receive ammo for a weapon we're picking up.
									//let's fix that
									if(Weapon(item) != None && Weapon(item).AmmoName != Class'AmmoNone' && !item.IsA('WeaponGrenade') && !item.IsA('WeaponShuriken') && !item.IsA('WeaponCombatKnife'))
									{
										/*if(Weapon(item).PickupAmmoCount <= 0 && Weapon(item).Default.PickupAmmoCount > 0)
											Weapon(item).PickupAmmoCount = 1;*/
										
										//a: I don't remember why I did this but i could never get it to fire when testing. 
										//Can this actually ever fire?
										/*if (Weapon(item).AmmoType == None)
										{
											Weapon(item).AmmoType = Ammo(player.FindInventoryType(Weapon(item).AmmoName));
											
											if (Weapon(item).AmmoType == None)
											{
												Weapon(item).AmmoType = spawn(Weapon(item).AmmoName, player);
												Weapon(item).AmmoType.InitialState='Idle2';
												Weapon(item).AmmoType.GiveTo(player);
												Weapon(item).AmmoType.setBase(player);
												
												Weapon(item).AmmoType.AmmoAmount = Weapon(item).PickupAmmoCount;
											}
											
											else
											{
												if (Weapon(item).AmmoType.AmmoAmount >= Weapon(item).AmmoType.MaxAmmo)
												weapAmmoFull = true;
												
												else if (Weapon(item).AmmoType.AmmoAmount + Weapon(item).PickupAmmoCount >=  Weapon(item).AmmoType.MaxAmmo)
												Weapon(item).PickupAmmoCount = Weapon(item).AmmoType.MaxAmmo - Weapon(item).AmmoType.AmmoAmount;
												
												Weapon(item).AmmoType.AddAmmo(Weapon(item).PickupAmmoCount);
											}
										}*/
										
										if (!weapAmmoFull)
										{
											if(Weapon(item).AmmoType.Icon != Weapon(item).Icon && Weapon(item).AmmoType.Icon != None)
												AddReceivedItem(player, Weapon(item).AmmoType, Weapon(item).PickupAmmoCount);
											else //== For weapons like the shuriken we just add to the weapon pickup count
												AddReceivedItem(player, Weapon(item), Weapon(item).PickupAmmoCount);
										}
									}
									
									P.ClientMessage(Item.PickupMessage @ Item.itemArticle @ Item.itemName, 'Pickup');
									
									if (Weapon(item) != None && Weapon(item).AmmoName != Class'AmmoNone' && !item.IsA('WeaponGrenade') && !item.IsA('WeaponCombatKnife'))
									{
										if (!weapAmmoFull)
										P.ClientMessage(Weapon(item).AmmoType.PickupMessage @ Weapon(item).AmmoType.itemArticle @ Weapon(item).AmmoType.itemName @ "("$Weapon(item).PickupAmmoCount$")", 'Pickup');
									}

								}
								else if(Level.NetMode == NM_Standalone)
								{
									spawn(Item.Class,self);
									DeleteInventory(Item);
									Item.Destroy();
								}
							}
							else
							{
								DeleteInventory(item);
								item.Destroy();
								item = None;
							}
						}
					}
				}

				item = nextItem;
			}
			until ((item == None) || (item == startItem));
		}

//log("  bFoundSomething = " $ bFoundSomething);
	}

	//== Handle some special, script-given pickups if they are present
	while(FrobItems[FIcount] != None && FIcount <= 3)
	{
		item = spawn(FrobItems[FIcount],self);
		
		bFoundSomething = True;

		DeusExPlayer(P).FrobTarget = item;
		if (DeusExPlayer(P).HandleItemPickup(Item) != False)
		{

			// DEUS_EX AMSD Belt info isn't always getting cleaned up.  Clean it up.
			item.bInObjectBelt=False;
			item.BeltPos=-1;

			if(Weapon(item) != None)
			{
				if(Weapon(item).PickupAmmoCount == 0 && Weapon(item).Default.PickupAmmoCount > 0)
					Weapon(item).PickupAmmoCount = 1;
			}

			// Show the item received in the ReceivedItems window and also 
			// display a line in the Log
			AddReceivedItem(player, item, 1);

			//Pepper Gun needs more ammo on pickup
			if(item.IsA('WeaponPepperGun'))
			{
				AmmoType = Ammo(player.FindInventoryType(Class'DeusEx.AmmoPepper'));
				AmmoType.AddAmmo(Rand(34) + 17);
			}

		}
		
		FrobItems[FIcount] = None;

		FIcount++;
	}
	
	DisplayReceivedItems(player);
	
	if (!bFoundSomething)
			P.ClientMessage(msgEmpty);

   if ((player != None) && (Level.Netmode != NM_Standalone))
   {
      player.ClientMessage(Sprintf(msgRecharged, 25));
      
      PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);
      
      player.Energy += 25;
      if (player.Energy > player.EnergyMax)
         player.Energy = player.EnergyMax;
   }
   
	Super.Frob(Frobber, frobWith);
	
	//if (!bNotDead)
	//Destroy();

   if (/*(Level.Netmode != NM_Standalone) &&*/ player.NanoMod.frobExplode && !bNotDead && Player != None && DeusExWeapon(Player.inHand) != None)
   {
	   bQueuedDestroy = true;
	   ChunkUp(Rand(MaxDamage)+1);	  
   }
}

// ----------------------------------------------------------------------
// AddReceivedItem()
// ----------------------------------------------------------------------

function AddReceivedItem(DeusExPlayer player, Inventory item, int count)
{
	local int i;
	
	if (!bSearchMsgPrinted)
	{
		//player.ClientMessage(msgSearching);
		bSearchMsgPrinted = True;
	}

	for (i = 0; i < 20; i++)
	{
		if (AddedInventoryItems[i].class == None)
		{
			AddedInventoryItems[i].class = item.Class;
			AddedInventoryItems[i].count = count;
			
			break;
		}
		
		else if (AddedInventoryItems[i].class == item.Class)
		{
			AddedInventoryItems[i].count += count;
			
			break;
		}
	}
}

function DisplayReceivedItems(DeusExPlayer player)
{
	local Inventory item;
	local int i, count;
	local bool soundPlayed;

	local DeusExWeapon w;
	local Inventory altAmmo;
	
    for (i = 0; i < 20; i++)
	{
		if (AddedInventoryItems[i].class == None)
		break;
		
		if (AddedInventoryItems[i].class == Class'Credits')
		{
			item = spawn(Class'Credits');
			item.InitialState='Idle2';
			
			AddedInventoryItems[i].count = player.Credits;
			
		}
		
		else if (AddedInventoryItems[i].class == Class'NanoKey')
		{
			item = spawn(Class'NanoKey');
			item.InitialState='Idle2';
		}

		else
		{
			item = player.FindInventoryType(AddedInventoryItems[i].class);
		
			if (item == None)
			{
				AddedInventoryItems[i].class = None;
				
				continue;
			}
		}
	  
	   if (item.IsA('WeaponGrenade') || item.IsA('WeaponShuriken') || (item.IsA('WeaponCombatKnife') && !item.IsA('WeaponToxinBlade')))
	   count = Ammo(player.FindInventoryType(Weapon(item).AmmoName)).AmmoAmount;
	   
	   else if (item.IsA('DeusExPickup') && DeusExPickup(item).bCanHaveMultipleCopies)
	   count = DeusExPickup(item).NumCopies;
	   
	   else
	   count = AddedInventoryItems[i].count;
	   
	   DeusExRootWindow(player.rootWindow).hud.receivedItems.AddItem(item, count);
	   
	  /* if (!soundPlayed && (item.IsA('DeusExWeapon') || item.IsA('DeusExAmmo')))
	   {
			PlaySound(sound'WeaponPickup', SLOT_Interact, 0.5+FRand()*0.25, , 256, 0.95+FRand()*0.1);
			
			soundPlayed = true;
	   }
	   */
	   
	   if (AddedInventoryItems[i].class == Class'Credits' || AddedInventoryItems[i].class == Class'NanoKey')
	   {
	     item.Destroy();
		 
		 AddedInventoryItems[i].class = None;
		 
		 continue;
	   }

		// Make sure the object belt is updated
		if (item.IsA('Ammo'))
			player.UpdateAmmoBeltText(Ammo(item));
		else
			player.UpdateBeltText(item);

		// Deny 20mm and WP rockets off of bodies in multiplayer
		if ( Level.NetMode != NM_Standalone )
		{
			if ( item.IsA('WeaponAssaultGun') || item.IsA('WeaponGEPGun') )
			{
				w = DeusExWeapon(player.FindInventoryType(item.Class));
				if (( Ammo20mm(w.AmmoType) != None ) || ( AmmoRocketWP(w.AmmoType) != None ))
				{
					altAmmo = Spawn( w.AmmoNames[0] );
					DeusExAmmo(altAmmo).AmmoAmount = w.PickupAmmoCount;
					altAmmo.Frob(player,None);
					altAmmo.Destroy();
					w.AmmoType.Destroy();
					w.LoadAmmo( 0 );
				}
			}
		}
		
		AddedInventoryItems[i].class = None;
	}
}

// ----------------------------------------------------------------------
// GetItem()
//
// Does all the tedious steps of giving items to carcasses in one easy
// function.
// ----------------------------------------------------------------------

function GetItem(Inventory item)
{
	if(item != None)
	{
		if(Pawn(item.Owner) != None) //Remove from any other inventories
			Pawn(item.Owner).DeleteInventory(item);

		bCollideWorld = True;
		AddInventory(item);
		item.InitialState = 'Idle2';
		item.SetBase(Self);
		item.Instigator = None;
		item.BecomeItem();
		item.GoToState('Idle2');
		bCollideWorld = False;
	}
}


// ----------------------------------------------------------------------
// AddInventory()
//
// copied from Engine.Pawn
// Add Item to this carcasses inventory. 
// Returns true if successfully added, false if not.
// ----------------------------------------------------------------------

function bool AddInventory( inventory NewItem )
{
	// Skip if already in the inventory.
	local inventory Inv;

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if( Inv == NewItem )
			return false;

	// The item should not have been destroyed if we get here.
	assert(NewItem!=None);

	// Add to front of inventory chain.
	NewItem.SetOwner(Self);
	NewItem.Inventory = Inventory;
	NewItem.InitialState = 'Idle2';
	Inventory = NewItem;

	return true;
}

// ----------------------------------------------------------------------
// DeleteInventory()
// 
// copied from Engine.Pawn
// Remove Item from this pawn's inventory, if it exists.
// Returns true if it existed and was deleted, false if it did not exist.
// ----------------------------------------------------------------------

function bool DeleteInventory( inventory Item )
{
	// If this item is in our inventory chain, unlink it.
	local actor Link;

	for( Link = Self; Link!=None; Link=Link.Inventory )
	{
		if( Link.Inventory == Item )
		{
			Link.Inventory = Item.Inventory;
			break;
		}
	}
   Item.SetOwner(None);
}

//-----------------------------------------------------------------------
// I am Jack's Fire
//-----------------------------------------------------------------------

function CatchFire()
{
	local Fire f;
	local int i;
	local vector loc;

	if (bOnFire || Region.Zone.bWaterZone || BurnPeriod <= 0 || bInvincible)
		return;

	bOnFire = True;
	burnTimer = 0;

	for (i=0; i<8; i++)
	{
		loc.X = 0.5*CollisionRadius * (1.0-2.0*FRand());
		loc.Y = 0.5*CollisionRadius * (1.0-2.0*FRand());
		loc.Z = 0.300000*CollisionHeight * (1.000000-2.000000*FRand());
		loc += Location;
		f = Spawn(class'Fire', Self,, loc);
		if (f != None)
		{
			f.DrawScale = 0.5*FRand() + 1.0;

			// turn off the sound and lights for all but the first one
			if (i > 0)
			{
				f.AmbientSound = None;
				f.LightType = LT_None;
			}

			// turn on/off extra fire and smoke
			if (FRand() < 0.5)
				f.smokeGen.Destroy();
			if (FRand() < 0.5)
				f.AddFire();
		}
	}

}

function ExtinguishFire()
{
	local Fire f;

	bOnFire = False;
	burnTimer = 0;

	foreach BasedActors(class'Fire', f)
	{
		if(f.smokeGen != None)
			f.smokeGen.SetBase(f);
		if(f.fireGen != None)
			f.fireGen.SetBase(f);
		f.Destroy();
	}
}

function UpdateFire(float deltaSeconds)
{
	if(bOnFire)
	{
		// continually burn and do damage
		//  Munch damage will not make blood spurts
		TakeDamage(Int(6 * deltaSeconds),None,vect(0,0,0),vect(0,0,0),'Munch');
	}
}

// ----------------------------------------------------------------------
// auto state Dead
// ----------------------------------------------------------------------

auto state Dead
{
	function Timer()
	{
		// overrides goddamned lifespan crap
      // DEUS_EX AMSD In multiplayer, we want corpses to have lifespans.  
      if (Level.NetMode == NM_Standalone)		
         Global.Timer();
      else
         Super.Timer();
	}

	function HandleLanding()
	{
		local Vector HitLocation, HitNormal, EndTrace;
		local Actor hit;
		local BloodPool pool;

		if (!bNotDead)
		{
			// trace down about 20 feet if we're not in water
			if (!Region.Zone.bWaterZone)
			{
				EndTrace = Location - vect(0,0,320);
				hit = Trace(HitLocation, HitNormal, EndTrace, Location, False);
            if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
            {
               pool = None;
            }
            else
            {
               pool = spawn(class'BloodPool',,, HitLocation+HitNormal, Rotator(HitNormal));
            }
				if (pool != None)
				{
					pool.maxDrawScale = CollisionRadius / 40.0;

					if(pool.Texture != pool.Default.Texture) //== HDTP scale-down
						pool.maxDrawScale /= 16;
				}
			}

			// alert NPCs that I'm food
			AIStartEvent('Food', EAITYPE_Visual);
		}

		// by default, the collision radius is small so there won't be as
		// many problems spawning carcii
		// expand the collision radius back to where it's supposed to be
		// don't change animal carcass collisions
		if (!bAnimalCarcass)
			SetCollisionSize(40.0, Default.CollisionHeight);

		// alert NPCs that I'm really disgusting
		if (bEmitCarcass)
			AIStartEvent('Carcass', EAITYPE_Visual);
	}

Begin:
	while (Physics == PHYS_Falling)
	{
		Sleep(1.0);
	}
	HandleLanding();
}

//Justice: Set the death flags properly if the carcass goes from unconscious to dead
function setDeathFlags(Pawn InstigatedBy)
{
	local DeusExPlayer player;
	local name deathFlag;
	
	player = DeusExPlayer(getPlayerPawn());
	
	if(wasImportant)
	{
		deathFlag = player.rootWindow.StringToName(flagName$"_Dead");
		player.flagBase.SetBool(deathFlag, True);
		player.flagBase.SetExpiration(deathFlag, FLAG_Bool, 0);
		deathFlag = player.rootWindow.StringToName(flagName$"_Unconscious");
		player.flagBase.SetBool(deathFlag, False);
		player.flagBase.SetExpiration(deathFlag, FLAG_Bool, 0);
	}
	
	if((killerBindName == player.bindName || InstigatedBy == player) && !bAnimalCarcass) //Justice: Fail the pacifist challenge if the player kills somebody
		Human(Player).failChallenge("ChallengePacifist");
}

//Justice: Corpses take falling damage
function Landed(vector HitNormal)
{
	super.Landed(HitNormal);
	
	if (Velocity.Z < -700)
		TakeDamage(-0.14 * (Velocity.Z + 700), None, Location, Velocity, 'fell');
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     bHighlight=True
     msgSearching="You found:"
     msgEmpty="You don't find anything"
     msgNotDead="Unconscious"
     msgAnimalCarcass="Animal Carcass"
     msgCannotPickup="You cannot pickup the %s"
     msgRecharged="Recharged %d points"
     ItemName="Dead Body"
     BurnPeriod=10.000000
     drownTimer=2.000000
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.000000
     CollisionRadius=20.000000
     CollisionHeight=7.000000
     bCollideWorld=False
     Mass=150.000000
     Buoyancy=170.000000
     BindName="DeadBody"
     bVisionImportant=True
}
