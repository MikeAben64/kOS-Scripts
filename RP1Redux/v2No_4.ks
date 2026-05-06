// Title: V2No_3
// Description: V2 No.3 mission program.

runOncePath("0:/lib/launchFunctions.ks").

   // Desired heading
PARAMETER desiredHeading.
   // Altitude at which pitch will be 45 degrees.
PARAMETER halfPitchedAlt.

//***********************************

    // Desired altitude to lock to orbital prograde.
SET lockAlt to 28000.
    // Desired deployment altitude for payload.
SET deployAlt to 80000.

WAIT 2.
CLEARSCREEN. 
countdown(FALSE).
pitchManuever(desiredHeading, halfPitchedAlt).
gravityTurn(lockAlt).
deployPayload(deployAlt).
WAIT 5.
PRINT " ".
PRINT "Program ending ... Good Luck!".
WAIT 2.