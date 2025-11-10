IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   CD ("0:/NewStart").

   PRINT "SETTINGS:".
   PRINT "  Alt: 160km".
   PRINT "  Vel: 52.7 m/s".
   PRINT "  shape: 50%".
   PRINT " ".
   PRINT "ENGAGE MECHJEB.".
   PRINT " ".
   PRINT "RUN albertOne when ready.".
}
