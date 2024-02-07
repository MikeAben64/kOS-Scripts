// Title: V2No4Boot
// Description: Boot file for V2 No.3 mission.

IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   LIGHTS ON.
   PRINT "Volume switched to archive.".
   PRINT " ".
   PRINT "RUN v2no_4(315, 30000) when ready.".
   PRINT " ".
}