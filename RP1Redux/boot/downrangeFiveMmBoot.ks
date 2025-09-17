IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.

   PRINT "SETTINGS:".
   PRINT "  Altitude: 300km".
   PRINT "  Path angle: 0".
   PRINT "  Shape: 45".
   PRINT " ".
   PRINT "ENGAGE MECHJEB".
   PRINT "RUN downrange when ready.".
}
