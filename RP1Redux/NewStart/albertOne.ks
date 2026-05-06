// Title: downrange
// Description: Ascent program for downrange missions.

runOncePath("0:/lib/launchFunctions.ks").

//**********************************

WAIT 2.
CLEARSCREEN.
countdown().
LOCK THROTTLE TO 1.
WAIT 10.
WAIT UNTIL shipTWR() < 1.
WAIT 2.
PRINT " ".
PRINT "Disengage Mechjeb.".
PRINT " ".
LOCK THROTTLE to 0.
WAIT UNTIL ALTITUDE > 100000.
STAGE.
RCS ON.
WAIT 2.
