class PersonaLevelIconOffWindow extends PersonaLevelIconWindow;

event InitWindow()
{
	texLevel = Texture(DynamicLoadObject("NanoModUI.Icons.PersonaSkillsOffChicklet", Class'Texture', True));

	Super.InitWindow();
}

event DrawWindow(GC gc)
{
	local int levelCount;
	
	if (texLevel == None)
	return;
	
	gc.SetTileColor(colText);
	gc.SetStyle(DSTY_Translucent);

	for(levelCount=0; levelCount<=currentLevel; levelCount++)
	{
		gc.DrawTexture(levelCount * (iconSizeX + 1), 0, iconSizeX, iconSizeY, 
			0, 0, texLevel);
	}
}

defaultproperties
{
}
