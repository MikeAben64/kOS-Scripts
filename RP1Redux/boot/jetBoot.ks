IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SET TERMINAL:WIDTH to 40.
   SET TERMINAL:HEIGHT to 30.
   SWITCH TO 0.
   CD ("0:/NewStart").

   RUNPATH("0:/NewStart/flightInstructions.ks", "2").
}
