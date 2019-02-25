class CharacterListCommandlet extends Commandlet;

event int Main(string arg)
{
   local int i, max;
   max = int(arg);
   if(max<=0)
      max=256;
   log("Character list:");
   for(i=0;i<max;i++)
      log(i @ "::" @ chr(i));
}

defaultproperties
{
}
