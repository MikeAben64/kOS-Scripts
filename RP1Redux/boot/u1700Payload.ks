// Description: Boot File for U-1250 Sounding Rocket

IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   CD ("0:/NewStart").
   PRINT("Volume switched to archive.").
   PRINT " ".
   PRINT "Run SoundingRecover.".
}
