// Description: Ascent program for WAC Corporal / Tiny Tim sounding rocket.

runOncePath("0:/lib/launchFunctions.ks").

//**********************************

CLEARSCREEN.
simpleCountdown().
autoStage(5).
WAIT UNTIL VERTICALSPEED < 0.
PRINT " ".
PRINT "Apogee Reached.".
WAIT UNTIL ALTITUDE < 30000.
PRINT " ".
PRINT "Aborting Rocket in ...".
PRINT " ".
WAIT 1.
PRINT "3".
WAIT 1.
PRINT "2".
WAIT 1.
PRINT "1".
WAIT 1.
ABORT ON.