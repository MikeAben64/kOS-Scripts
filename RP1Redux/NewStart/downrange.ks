// Title: downrange
// Description: Ascent program for downrange missions.

runOncePath("0:/lib/launchFunctions.ks").

//**********************************

WAIT 2.
CLEARSCREEN.
countdown().
LOCK THROTTLE TO 1.
WAIT 10.
waitToApo().
WAIT 1.
PRINT ("Deploying Payload...").
WAIT 1.
STAGE.
