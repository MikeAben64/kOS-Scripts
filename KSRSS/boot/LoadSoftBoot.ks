// Title: Basic Boot
// Description: Switches the
// volume to archive.

IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   
   COPYPATH("0:/exeMan", "").
   COPYPATH("0:/circAt", "").
   COPYPATH("0:/align", "").

   SWITCH TO 0.
   PRINT("Volume switched to archive.").
}
