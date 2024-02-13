RUNONCEPATH("0:/lib/launchFunctions.ks").

PARAMETER head IS 90.
PARAMETER hPitchAlt IS 12000.

clearscreen.
countdown().
pitchManuever(head, hPitchAlt).
gravityTurn().

print " ".
print "You are on your own. Good Luck!!!".
