// Title: Basic Boot
// Description: Switches the
// volume to archive.

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SWITCH TO 0.
PRINT("Volume switched to archive.").

IF (STATUS = "PRELAUNCH") {
   
   COPYPATH("0:/exeMan", "").
   COPYPATH("0:/circAt", "").
   COPYPATH("0:/align", "").

}
