// Title: Boot 1 
// Description: Loads xman and circat scripts
// into the vessel's drive, then switch the
// volume to archive.

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

COPYPATH("0:/xman", "").
COPYPATH("0:/circat", "").
SWITCH TO 0.

PRINT("Software copied to vessel.").
PRINT("Volume switched to archive.").

//flight recorder
//SET startingAlt TO SHIP:ALTITUDE.
//SET logFile TO "0:/logs/FlightLog-Y" + TIME:YEAR + "-D" + TIME:DAY + "-" + TIME:HOUR + "-" + TIME:MINUTE + ".csv".

//WAIT UNTIL (SHIP:ALTITUDE > startingAlt + 1).

//UNTIL (SHIP:ALTITUDE > 80000) {
  // LOG ALTITUDE TO logFile.
  // WAIT 5.
//}