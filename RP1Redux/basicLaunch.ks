// Title: basicLaunch
// Description: Default ascent program.

runOncePath("0:/lib/launchFunctions.ks").

//**********************************

PARAMETER mechJeb IS TRUE.
PARAMETER spoolUp IS 2.5.

WAIT 2.
CLEARSCREEN.
countdown(mechJeb, spoolUp).
LOCK THROTTLE TO 1.
WAIT 10.
WAIT UNTIL VERTICALSPEED < 0.
PRINT "Program shutdown.".