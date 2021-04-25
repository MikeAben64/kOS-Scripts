// Calculates Launch Time

// @author: Mike Aben (2021)

// DESCRIPTION:
// Calculates Launch Time for 
// going to Minmus

main().

//***********************************

   // Driver
FUNCTION main {
   launchTime().
}

FUNCTION launchTime {
   SET rawTime to 61 - 360*((TIME:DAY-1) / 426).
   IF (rawTime < 0) {
      SET rawTime to rawTime + 360.
   }
   SET hour to FLOOR(rawTime/60).
   SET minute to ROUND(rawTime - hour*60).
   IF (hour > 2) {
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