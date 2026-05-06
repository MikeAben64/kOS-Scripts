// Title: V2No_3
// Description: V2 No.3 mission program.

   // Desired heading
PARAMETER desiredHeading.
   // Altitude at which pitch will be 45 degrees.
SET halfPitchedAlt to 35000.
   // Desired deployment altitude for payload.
SET deployAlt to 80000.
   // Desired altitude to lock to orbital prograde.
SET lockAlt to 28000.
   // Desired deployment altitude for payload.
SET deployAlt to 80000.
   // Is vessel locked to orbital prograde?
SET proLocked to FALSE.


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
   pitchManuever().
   gravityTurn().
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
   WAIT 0.5. 
   LOCK THROTTLE to 1.
   WAIT 0.5.
   PRINT "Throttle to full.".
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
}
   // Returns appropriate roll for craft.
FUNCTION myRoll {
   RETURN 360 - desiredHeading.
}

   // Deploys payload
FUNCTION deployPayload {
   WAIT UNTIL ALTITUDE < deployAlt AND VERTICALSPEED < 0.
   STAGE.
   PRINT " ".
   PRINT "Deploying Payload...".
}

   //Looks for events until MECO.
FUNCTION gravityTurn {
   UNTIL (VERTICALSPEED < 0) {
      IF (ALTITUDE > lockAlt) AND NOT proLocked {
         lockToPrograde().
      }
      WAIT 0.1.
   }
}   

   //LOCKING TO PROGRADE
FUNCTION lockToPrograde {
   PRINT "Locking to prograde.".
   LOCK STEERING to SRFPROGRADE + R(0, 0, myRoll()).
   SET proLocked to TRUE.
}

   //PITCHING MANEUVER
FUNCTION pitchManuever {
   PRINT " ". 
   PRINT "Starting pitching maneuver.".
   SET initialHeading to myHeading().
   SET initialRoll to myRoll().
   LOCK STEERING to HEADING(initialHeading, myPitch())+ R(0, 0, initialRoll).
   WAIT 2.
}

   // Pitch setting
FUNCTION myPitch {
   RETURN 90*halfPitchedAlt / (ALTITUDE + halfPitchedAlt).
}

   //Heading setting
FUNCTION myHeading {
   RETURN desiredHeading.
}
