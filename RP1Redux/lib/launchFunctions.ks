   // Countdown beeps
SET voice to getVoice(0).
SET voiceTickNote to NOTE(480, 0.1).
SET voiceTakeOffNote to NOTE(720, 0.5).
SET voice:VOLUME to 0.5.

SET proLocked to FALSE.

// *****************************************
// GLOBAL FUNCTIONS
// *****************************************

   //Countdown for unguided sounding rockets
GLOBAL FUNCTION simpleCountdown {
   PRINT "5".
   voice:PLAY(voiceTickNote).
   WAIT 1. 
   PRINT "4".
   voice:PLAY(voiceTickNote).
   WAIT 1. 
   PRINT "3".
   voice:PLAY(voiceTickNote).
   WAIT 0.5.
   LOCK THROTTLE to 1.
   PRINT "Throttle to full.".
   WAIT 0.5.
   PRINT "2".
   voice:PLAY(voiceTickNote).
   WAIT 1. 
   PRINT "1".
   voice:PLAY(voiceTickNote).
   WAIT 1. 
   PRINT "LAUNCH!".
   voice:PLAY(voiceTakeOffNote).  
   STAGE.
   WAIT 2.
}

GLOBAL FUNCTION countdown {
   PARAMETER mechJeb IS TRUE.
   PARAMETER spoolUp IS 2.5.

   SET scrubbed to FALSE.
   
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
   IF (NOT mechJeb){
      LOCK THROTTLE to 1.
      PRINT "Throttle to full.".
   }
   WAIT 0.5.
   PRINT "1".
   voice:PLAY(voiceTickNote).
   PRINT "IGNITION". 
   STAGE.
   WAIT spoolUp.
   IF shipTWR < 1 {
      PRINT " ".
      PRINT "Subnominal thrust detected.".
      WAIT 1.
      PRINT "Scrub launch.".
      PRINT " ".
      SET scrubbed to TRUE.
   }
   IF NOT scrubbed {
      PRINT "LAUNCH!".
      voice:PLAY(voiceTakeOffNote).  
      STAGE.
      WAIT 2.
      IF (mechJeb) {
         UNLOCK STEERING.
         PRINT " ".
         PRINT "Passing attitude control to MechJeb.".
      }
   }
}

   //PITCHING MANEUVER
GLOBAL FUNCTION pitchManuever {
   PARAMETER desiredHeading IS 90.
   PARAMETER halfPitchedAlt IS 35000.
   PRINT " ". 
   PRINT "Starting pitching maneuver.".
   SET initialHeading to myHeading(desiredHeading).
   SET initialRoll to myRoll(desiredHeading).
   LOCK STEERING to HEADING(initialHeading, myPitch(halfPitchedAlt))+ R(0, 0, initialRoll).
   WAIT 2.
}

   //Looks for events until MECO.
GLOBAL FUNCTION gravityTurn {
   PARAMETER desiredHeading.
   UNTIL (VERTICALSPEED < 0) {
      PARAMETER lockingAlt IS 20000.
      IF (ALTITUDE > lockingAlt) AND NOT proLocked {
         lockToPrograde(desiredHeading).
      }
      WAIT 0.1.
   }
} 

   //Stage rocket upon loss of thrust
GLOBAL FUNCTION autoStage {
   PARAMETER cutOffTWR IS 1.
   WAIT UNTIL (shipTWR() < cutOffTWR).
   PRINT " ".
   PRINT "Staging.".
   STAGE.
}

   //Waits until apogee and ends program
GLOBAL FUNCTION waitToApo {
   WAIT UNTIL (VERTICALSPEED < 0).
   PRINT " ".
   PRINT "Apogee reached.".
   PRINT " ".
   WAIT 0.
}

GLOBAL FUNCTION rangeAbort {
   WAIT UNTIL (ALTITUDE < 30000) AND (VERTICALSPEED < 0).
   PRINT " ".
   PRINT "Aborting Rocket in ...".
   PRINT " ".
   WAIT 1.
   PRINT "3".
   WAIT 1.
   PRINT "2".
   WAIT 1.
   PRINT "1".
   WAIT 1.
   ABORT ON.
   WAIT 0.
}

   // Deploys payload
GLOBAL FUNCTION deployPayload {
   PARAMETER deployingAlt IS 80000.
   WAIT UNTIL ALTITUDE < deployingAlt AND VERTICALSPEED < 0.
   WAIT 1.
   STAGE.
   WAIT 1.
   STAGE.
   PRINT " ".
   PRINT "Deploying Payload...".
}

// *****************************************
// HELPER FUNCTIONS
// *****************************************

   // Returns appropriate roll for craft.
FUNCTION myRoll {
   PARAMETER desiredHeading.
   RETURN 360 - desiredHeading.
}

   //Heading setting
FUNCTION myHeading {
   PARAMETER desiredHeading.
   RETURN desiredHeading.
}

   // Pitch setting
FUNCTION myPitch { 
   PARAMETER halfPitchedAlt.
   RETURN 90*halfPitchedAlt / (ALTITUDE + halfPitchedAlt).
}  

   //LOCKING TO PROGRADE
FUNCTION lockToPrograde {
   PARAMETER desiredHeading.
   PRINT "Locking to prograde.".
   LOCK STEERING to SRFPROGRADE + R(0, 0, myRoll(desiredHeading)).
   SET proLocked to TRUE.
}

   //Returns ship TWR 
FUNCTION shipTWR {
   RETURN AVAILABLETHRUST / (MASS*CONSTANT:g0).
}
