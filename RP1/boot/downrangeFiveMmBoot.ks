// Title: downrangeFiveMm
// Description: Boot file for the downrange 5000km contract

IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   PRINT("Volume switched to archive.").
   PRINT " ".
   PRINT "SETTINGS:".
   PRINT "  Orbital Altitude: 300km".
   PRINT "  Orbital inc: current".
   PRINT "  Flight path angle: 0".
   PRINT "  Turn shape: 45".
   PRINT " ".
   PRINT "ENGAGE MECHJEB".
   PRINT "RUN downrange when ready.".
   PRINT " ".
}
