IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   CD ("0:/NewStart").

   PRINT "SETTINGS:".
   PRINT "  Per: -6200km".
   PRINT "  Apo: 250km".
   PRINT "  inc: 110".
   PRINT " ".
   PRINT "ENGAGE MECHJEB.".
   PRINT " ".
   PRINT "RUN downrange(true, false) when ready.".
}
