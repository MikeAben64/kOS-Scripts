// Title: BasicBoot
// Description: Switches the
// volume to archive.

IF (STATUS = "PRELAUNCH") {
   CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
   SWITCH TO 0.
   PRINT("Volume switched to archive.").
}