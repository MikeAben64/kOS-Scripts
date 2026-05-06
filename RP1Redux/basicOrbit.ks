// Description: Default LKO program.

runOncePath("0:/lib/launchFunctions.ks").

//**********************************

PARAMETER mechJeb IS TRUE.
PARAMETER spoolUp IS 2.54.

WAIT 2.
CLEARSCREEN.
RCS ON.
countdown(mechJeb, spoolUp).
WAIT UNTIL PERIAPSIS > 140000.
PRINT " ".
PRINT "Orbit achieved.".
WAIT 2.