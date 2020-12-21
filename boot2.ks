// Title: Boot 2
// Description: Switchs the
// volume to archive.

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

SWITCH TO 0.

PRINT("Volume switched to archive.").