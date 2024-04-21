// Title: downrange
// Description: Ascent program for downrange missions.

runOncePath("0:/lib/launchFunctions.ks").

//**********************************

WAIT 2.
CLEARSCREEN.
countdown().
LOCK THROTTLE TO 1.
WAIT 10.
autoStage(1.2).
WAIT 5.
autoStage(2).
WAIT 0.
waitToApo().
