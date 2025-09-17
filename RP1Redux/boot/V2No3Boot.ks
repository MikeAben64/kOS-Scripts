// Title: V2No3Boot
// Description: Boot file for V2 No.3 mission.

IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   PRINT "Volume switched to archive.".
   PRINT " ".
   PRINT "RUN v2no_3(315) when ready.".
   PRINT " ".
}