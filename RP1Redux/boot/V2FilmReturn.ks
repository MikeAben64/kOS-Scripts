IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   CD ("0:/NewStart").

   PRINT "SETTINGS:".
   PRINT "  Apo: 110km".
   PRINT "  Per: 0".
   PRINT "  Turn off autostage.".
   PRINT " ".
   PRINT "ENGAGE MECHJEB.".
   PRINT "RUN downrange when ready.".
}
