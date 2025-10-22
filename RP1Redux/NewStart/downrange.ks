// Title: downrange
// Description: Ascent program for downrange missions.

runOncePath("0:/lib/launchFunctions.ks").

//**********************************

PARAMETER payload is FALSE.
PARAMETER autostage is FALSE.

WAIT 2.
CLEARSCREEN.
countdown().
LOCK THROTTLE TO 1.
WAIT 10.
IF autostage {
    autoStage().
}
waitToApo().
IF payload {
    WAIT 1.
    PRINT ("Deploying Payload...").
    WAIT 1.
    STAGE.
}
