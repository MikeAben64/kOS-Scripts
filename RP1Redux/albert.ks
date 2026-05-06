// Title: V2No_4
// Description: V2 No.4 mission program.

   // Desired heading
SET desiredHeading to 90.
   // Desired deployment altitude for payload.
SET deployAlt to 120000.

   // Countdown beeps
SET voice to getVoice(0).
SET voiceTickNote to NOTE(480, 0.1).
SET voiceTakeOffNote to NOTE(720, 0.5).

//**********************************

main().

   // Main program
FUNCTION main {
   WAIT 2.
   CLEARSCREEN. 
   countdown().
   lockToPrograde().
   deployPayload().
   WAIT 5.
   PRINT " ".
   PRINT "Program ending ... Good Luck!".
   WAIT 2.
}

   //COUNTDOWN
FUNCTION countdown {
   SAS OFF.
   PRINT "5".
   voice:PLAY(voiceTickNote).
   WAIT 1. 
   PRINT "4".
   voice:PLAY(voiceTickNote).
   WAIT 1. 
   PRINT "3".
   voice:PLAY(voiceTickNote).
   WAIT 0.5.
   LOCK STEERING to UP + R(0, 0, 180).
   PRINT "Locking attitude control.".
   WAIT 0.5. 
   PRINT "2".
   voice:PLAY(voiceTickNote).
   WAIT 1. 
   PRINT "1".
   voice:PLAY(voiceTickNote).
   PRINT "IGNITION".
   WAIT 1. 
   STAGE.
   WAIT 2.5.
   PRINT "LAUNCH!".
   voice:PLAY(voiceTakeOffNote).  
   STAGE.
   WAIT 2.
   UNLOCK STEERING.
   PRINT " ".
   PRINT "Passing attitude control to MechJeb.".
}
   // Returns appropriate roll for craft.
FUNCTION myRoll {
   RETURN 360 - desiredHeading.
}

   // Locks to Surface Prograde when engine Flames Out
FUNCTION lockToPrograde {
   WAIT UNTIL (SHIP:AVAILABLETHRUST < 0.1).
   PRINT " ".
   PRINT "Locking to prograde.".
   LOCK STEERING to SRFPROGRADE + R(0, 0, myRoll()).
}

   // Deploys payload
FUNCTION deployPayload {
   WAIT UNTIL ALTITUDE > deployAlt.
   STAGE.
   PRINT " ".
   PRINT "Deploying Payload...".
}
