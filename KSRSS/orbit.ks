RUNONCEPATH("0:/lib/launchFunctions.ks").
RUNONCEPATH("0:/lib/maneuverFunctions.ks").

PARAMETER head IS 90.
PARAMETER desiredApoapis is 80000.

SET hPitchAlt to 18000.
SET proLockAlt to 20000.
SET fairDeployAlt to 50000.

clearscreen.
countdown().
pitchManuever(head, hPitchAlt).
gravityTurn(head, proLockAlt, fairDeployAlt, desiredApoapis).
WAIT UNTIL ALTITUDE > 70000 AND THROTTLE < 0.1.
AG10 ON.
circAt().
exeMan().

print " ".
print "You are on your own. Good Luck!!!".