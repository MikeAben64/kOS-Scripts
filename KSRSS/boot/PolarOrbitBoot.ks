// Title: Polar Orbit Boot
// Description: Switches the
// volume to archive.

IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   PRINT("Volume switched to archive.").
   PRINT " ".
   PRINT "Run orbit(185, 100000)".
}