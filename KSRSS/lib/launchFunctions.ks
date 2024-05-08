
 //****************************************************
 // GLOBAL FUNCTIONS
 //****************************************************  
   
   // Performs 5 minute countdown, setting throttle
   // and steering then releases rocket
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
   // STAGE. <= Commented out in case of engine failures
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

   SET srfProLocked to FALSE.
   SET proLocked to FALSE.
   SET throttleMin to FALSE.
   SET msgPrinted to FALSE.
   SET thrustSetting to 1.
   SET targetETA to 55.

   SET throttlePID to PIDLOOP(1.02, 0.5, 0.03, 0, 1).
   SET throttlePID:SETPOINT to targetETA.

   LOCK THROTTLE to thrustSetting.

   UNTIL (APOAPSIS > desiredApoapsis) {    
         //Locks to surface prograde vector 
      IF (ALTITUDE > lockingAlt) AND NOT srfProLocked {
         lockToSrfPrograde(desiredHeading).
         SET srfProLocked to TRUE.
      }
         //Locks to orbital prograde vector
      IF (ALTITUDE > 50000) AND NOT proLocked {
         lockToPrograde(desiredHeading).
         set proLocked to TRUE.
      }
      WAIT 0.
         //Moderates thrust to keep time to apo at 55 seconds
      IF NOT throttleMin AND ETA:APOAPSIS > (targetETA - 5) {
         SET thrustSetting to throttlePID:UPDATE(TIME:SECONDS, ETA:APOAPSIS).
         IF thrustSetting < .95 AND NOT msgPrinted {
            PRINT " ".
            PRINT "Reducing Throttle.".
            SET msgPrinted to TRUE.
         }
         IF thrustSetting < 0.2 {
            SET thrustSetting to 0.2.
            SET throttleMin to TRUE.
         }
      }
   }
   meco().
}  

 //****************************************************
 // HELPER FUNCTIONS
 //**************************************************** 

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
FUNCTION lockToSrfPrograde {
   PARAMETER desiredHeading.
   PRINT " ".
   PRINT "Locking to surface prograde vector.".
   LOCK STEERING to SRFPROGRADE + R(0, 0, myRoll(desiredHeading)).
}

   //Locks craft to the orbital prograde vector
FUNCTION lockToPrograde {
   PARAMETER desiredHeading.
   PRINT " ".
   PRINT "Locking to orbital prograde vector.".
   LOCK STEERING to PROGRADE + R(0, 0, myRoll(desiredHeading)).
}

   // Cuts engines
FUNCTION meco {
   LOCK THROTTLE to 0.
   PRINT " ".
   PRINT "Engine Cut-off.".
}

   //Returns ship TWR ***WORK IN PROGRESS***
FUNCTION shipTWR {
      // Current thrust setting.
   SET thrustSetting to 1.
   RETURN AVAILABLETHRUST*thrustSetting / (MASS*CONSTANT:g0).
}