// Title: V2No4Boot
// Description: Low Space Planetary Photography.

IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   LIGHTS ON.
   PRINT "Volume switched to archive.".
   PRINT " ".
   PRINT "RUN v2no_4(5, 30000) when ready.".
   PRINT " ".
}