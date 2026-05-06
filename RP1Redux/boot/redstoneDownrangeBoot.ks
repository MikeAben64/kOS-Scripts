IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SET TERMINAL:WIDTH to 40.
   SET TERMINAL:HEIGHT to 30.
   SWITCH TO 0.
   CD ("0:/NewStart").

   PRINT "SETTINGS:".
   PRINT "  Alt: 150km".
   PRINT "  Shape: 45%".
   PRINT "  Turn ON autostage & hotstaging.".
   PRINT " ".
   PRINT "ENGAGE MECHJEB.".
   PRINT " ".
   PRINT "RUN downrange.".
}
