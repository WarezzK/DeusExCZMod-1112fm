class Challenge extends Actor
	config(User);

var travel Challenge next;
var() localized string ChallengeName;
var() localized string Description;

var config int completed[30];

defaultproperties
{
     bHidden=True
     bTravel=True
}
