// Description: Boot File for Film Return Missions

IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   CD ("0:/NewStart").
   PRINT("Volume switched to archive.").
}

PRINT " ".
PRINT "Run FilmReturn(90, 35000).".