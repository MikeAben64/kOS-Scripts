// Title: downrange
// Description: Ascent program for downrange missions.

runOncePath("0:/lib/launchFunctions.ks").

//**********************************

WAIT 2.
CLEARSCREEN.
countdown().
autoStage().
WAIT 0.
LOCK THROTTLE TO 1.
waitToApo().
