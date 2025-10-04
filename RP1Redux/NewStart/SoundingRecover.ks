// Description: Ascent program for unguided sounding rockets.

runOncePath("0:/lib/launchFunctions.ks").

//**********************************

CLEARSCREEN.
simpleCountdown().
waitToApo().
deployPayload(100000).
WAIT 5.