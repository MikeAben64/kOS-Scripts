IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   CD ("0:/NewStart").

   PRINT "SETTINGS:".
   PRINT "  Per: -5800km".
   PRINT "  Apo: 500km".
   PRINT "  Turn OFF autostage.".
   PRINT " ".
   PRINT "ENGAGE MECHJEB.".
   PRINT " ".
   PRINT "RUN downrange(false, true) when ready.".
}
