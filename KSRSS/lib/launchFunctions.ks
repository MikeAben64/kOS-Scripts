
   // Performs 5 minute countdown, setting throttle and steering
   // then releases rocket
GLOBAL FUNCTION countdown {
   // Countdown beeps
   SET voice to getVoice(0).
   SET voiceTickNote to NOTE(480, 0.1).
   SET voiceTakeOffNote to NOTE(720, 0.5).

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
   PRINT "LAUNCH!".
   voice:PLAY(voiceTakeOffNote).  
   //STAGE.
   WAIT 2.
}

   //Sets attitude for ascent profile
GLOBAL FUNCTION pitchManuever {
   PARAMETER desiredHeading IS 90.
   PARAMETER halfPitchedAlt IS 12000.

   PRINT " ". 
   PRINT "Starting pitching maneuver.".
   SET initialHeading to myHeading(desiredHeading).
   SET initialRoll to myRoll(desiredHeading).
   LOCK STEERING to HEADING(initialHeading, myPitch(halfPitchedAlt))+ R(0, 0, initialRoll).
   WAIT 2.
}

   //Performs gravity turn until desired apo is reached.
GLOBAL FUNCTION gravityTurn {
   PARAMETER desiredHeading IS 90.
   PARAMETER lockingAlt IS 20000.
   PARAMETER desiredApoapsis IS 80000.

   SET proLocked to FALSE.

   UNTIL (APOAPSIS > desiredApoapsis) {     
      IF (ALTITUDE > lockingAlt) AND NOT proLocked {
         lockToPrograde(desiredHeading).
         SET proLocked to TRUE.
      }
      WAIT 0.
   }
   meco().
}  

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

   //Locks craft to the surface prograde vector
FUNCTION lockToPrograde {
   PARAMETER desiredHeading.
   PRINT "Locking to prograde.".
   LOCK STEERING to SRFPROGRADE + R(0, 0, myRoll(desiredHeading)).
}

FUNCTION meco {
   LOCK THROTTLE to 0.
   PRINT " ".
   PRINT "Engine Cut-off.".
}
