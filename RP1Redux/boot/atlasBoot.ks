// Description: Boot file for Atlas Rocket

IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   PRINT("Volume switched to archive.").
   PRINT " ".
   PRINT "Engage MechJeb.".
   PRINT " ".
   PRINT "Run basicOrbit.".
}