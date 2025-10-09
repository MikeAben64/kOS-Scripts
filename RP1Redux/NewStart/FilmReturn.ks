// Title: FilmReturn
// Description: V2 No.1 Film Return mission program.

runOncePath("0:/lib/launchFunctions.ks").

   // Desired heading
PARAMETER desiredHeading IS 90.
   // Altitude at which pitch will be 45 degrees.
PARAMETER halfPitchedAlt IS 35000.

//***********************************

    // Desired altitude to lock to orbital prograde.
SET lockAlt to 28000.
    // Desired deployment altitude for payload.
SET deployAlt to 100000.

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