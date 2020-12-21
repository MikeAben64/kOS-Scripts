// Calculates Launch Time

// @author: Mike Aben (2020)
// @param: ejection angle

// DESCRIPTION:
// Calculates Launch Time for 
// Interplanetary parking orbits

   // parameters
PARAMETER ejection.

main().

//***********************************

   // Driver
FUNCTION main {
   launchTime().
}

FUNCTION launchTime {
   SET rawTime to 163 - ejection.
   IF (rawTime < 0) {
      SET rawTime to rawTime + 360.
   }
   SET hour to FLOOR(rawTime/60).
   SET minute to ROUND(rawTime - hour*60).
   IF (hour > 3) {
      SET hour to hour - 3.
   }
   CLEARSCREEN.
   PRINT "Launch Times: ".
   IF (minute < 10) {
      PRINT hour + ":0" + minute.
      PRINT (hour+3) + ":0" + minute.
   } ELSE {
      PRINT hour + ":" + minute.
      PRINT (hour+3) + ":" + minute.   
   }
   PRINT " ".
}

/// END OF PROGRAM