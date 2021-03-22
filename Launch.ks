// Launch Script 

// @author: Mike Aben (2021)
// @param: inclination, apoapsis, flightAt

// DESCRIPTION:
// Takes parameters for desired 
// inclination (-180 to 180] (negative
// is south), & apoapsis (in km),
// & flight attitude (inverted 'i', or not).
// Executes primary ignition and launch.
// Will pitch over in appropriate heading
// to achieve desired inclination.
// Cuts throttle when desired apoapsis
// is reached and circularizes at apoapsis.

// ***Parameters***
   // desired inclination for final orbit
PARAMETER desiredInclination.
   // desired altitude of final orbit
PARAMETER desiredApoapsis.	
   // inverted ascent? ('i' for inverted)
PARAMETER flightAt.

//*************************
//*** ASCENT PARAMETERS ***
//*************************
   // Desired altitude to begin pitching maneuver.
SET pitchStartingAlt to 250. 
   // Altitude at which pitch will be 45 degrees.
SET halfPitchedAlt to 12000.
   // Desired altitude for thrust to limit.
SET tLimitAlt to 20000.
   // TWR at above altitude
SET thrustAdj to 1.1.
   // TWR for final stage of ascent
SET finalThrustAdj to 0.9.
   // Desired altitude to lock to orbital prograde.
SET lockAlt to 40000.
   // Desired altitude to stage fairings.
SET fairingAlt to 50000.
   // Desired altitude to extend deployables.
SET deployAlt to 70000.
//*************************

   // Current thrust setting.
SET thrustSetting to 1.
   // Thrust limiter.
SET thrustLimiter to 1.
   // Are deployables deployed?
SET deployed to FALSE.
   // Is vessel locked to orbital prograde?
SET proLocked to FALSE.
   // Is throttle limitted?
SET thrustLimited to FALSE.
   // Is upper stage thrust limited?
SET upperLimited TO FALSE.
   // Is abort called?
SET aborted to FALSE.
   // Are fairings staged?
SET fairingStaged to FALSE.
   // Holds vessel's current pitch
SET vPitch to 90.
   // Holds vessel's current heading
SET vHeading to 0.

//**********************************

SET voice to getVoice(0).
SET voiceTickNote to NOTE(480, 0.1).
SET voiceTakeOffNote to NOTE(720, 0.5).

main().

   // Main program
FUNCTION main {
   WAIT 2.
   CLEARSCREEN. 
   setAbortTrigger().
   countdown().
   IF NOT aborted {
      SET oldThrust to AVAILABLETHRUST.
      pitchManuever().
   }
   IF NOT aborted {
      gravityTurn().
   }
   IF NOT aborted {
      meco().
      circNode().
      xMan().
   }
}

   // Pitch setting
FUNCTION myPitch {
   RETURN 90*halfPitchedAlt / (ALTITUDE + halfPitchedAlt).
}

   // Roll setting
FUNCTION myRoll {
   IF (flightAt = "i") {
      SET tempRoll to 270 - myHeading.
   } ELSE {
      SET tempRoll to 360 - myHeading.
   }
   RETURN tempRoll.
}

   //Heading setting
FUNCTION myHeading {
   SET roughHeading to 90 - desiredInclination.
   IF (roughHeading < 0) {
      SET roughHeading to 360 + roughHeading.
   }
      //taking into account Kerbin's rotation
   SET triAng to abs(90 - roughHeading).
      //vH calculation assumes orbital speed of 1320 m/s when vessel locks to prograde
   SET vH to sqrt(1774800 - 475200*cos(triAng)).
   SET correction to arcsin(180*sin(triAng) / vH).
   IF (desiredInclination > 0) {
      SET correction to -1*correction.
   } 
   IF ((roughHeading + correction) < 0) { 
      RETURN roughHeading + correction + 360.
   } ELSE {
      RETURN roughHeading + correction.
   }   
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
   STAGE.
         // checking for subnominal thrust
   IF (SHIP:AVAILABLETHRUSTAT(1.0) < 1.15*(MASS-clampMass())*CONSTANT:g0) {
      PRINT " ".
      PRINT "Subnominal Thrust Detected.".
      PRINT "Attempting Shutdown.".
      LOCK THROTTLE to 0.
         // proceed with launch
   } ELSE {
      WAIT 1. 
      STAGE.
      PRINT "LAUNCH!".
      voice:PLAY(voiceTakeOffNote).
      WAIT 0.1.
   }  
   WAIT 2.
}

   //PITCHING MANEUVER
FUNCTION pitchManuever {
   LOCK vPitch to 90 - VANG(UP:FOREVECTOR, FACING:FOREVECTOR).
   LOCK vHeading to MOD(360 - LATLNG(90, 0):BEARING,360).
   UNTIL (ALTITUDE > pitchStartingAlt) {
      IF ABS(vPitch-myPitch())>10 AND NOT aborted {
         autoAbort().
         BREAK.
      }
      WAIT 0.1.  
   }
   PRINT " ". 
   PRINT "Starting pitching maneuver.".
   SET initialHeading to myHeading().
   SET initialRoll to myRoll().
   LOCK STEERING to HEADING(initialHeading, myPitch())+ R(0, 0, initialRoll).
   WAIT 2.
}

   //LOCKING TO PROGRADE
FUNCTION lockToPrograde {
   PRINT "Locking to prograde.".
   LOCK STEERING to PROGRADE + R(0, 0, myRoll()).
   SET proLocked to TRUE.
}

   //Returns ship TWR
FUNCTION shipTWR {
   RETURN AVAILABLETHRUST*thrustSetting / (MASS*CONSTANT:g0).
}

   //LIMITS TWR to thrustAdj Setting
FUNCTION limitThrust {
      //force of gravity on vessel
   LOCK Fg to (BODY:MU/(BODY:RADIUS+ALTITUDE)^2)*MASS.
      //locks thrust
   IF (AVAILABLETHRUST > 0) {
      IF NOT thrustLimited {
         SET thrustSetting to thrustAdj*Fg / (AVAILABLETHRUST+0.001).
         PRINT " ".
         PRINT "Adjusting TWR to " + thrustAdj.
      } ELSE {
         SET thrustSetting to finalThrustAdj*Fg / (AVAILABLETHRUST+0.001).
         PRINT "Adjusting TWR to " + finalThrustAdj.
      }
      LOCK THROTTLE to thrustSetting.
      IF thrustLimited {
         SET upperLimited to TRUE.
      }
      SET thrustLimited to TRUE.
   } ELSE {
      //LOCK THROTTLE to 0.
      //PRINT " ".
      //PRINT "1202 ALARM".
      STAGE.
      WAIT 0.1.
   }
}

   //Main Engine Cut-off
FUNCTION meco {
   LOCK THROTTLE to 0.
   PRINT " ".
   PRINT "Engine Cut-off.".
   WAIT UNTIL ALTITUDE > lockAlt.
   IF NOT proLocked {
      lockToPrograde().
   }
   WAIT UNTIL ALTITUDE > deployAlt.
   IF NOT deployed {
      autoDeploy().
   }
}

   //Looks for events until MECO.
FUNCTION gravityTurn {.
   UNTIL (APOAPSIS > desiredApoapsis*1000) {
      IF (ALTITUDE > lockAlt) AND NOT proLocked {
         lockToPrograde().
      }
      IF (ALTITUDE > tLimitAlt) AND NOT thrustLimited {
         limitThrust().
      }
      IF (shipTWR() < thrustAdj - 0.1) AND thrustLimited AND NOT upperLimited {
         limitThrust().
      }
      IF (ALTITUDE > deployAlt) AND NOT deployed {
         autoDeploy().
      }
      IF (ALTITUDE > fairingAlt) AND NOT fairingStaged {
         autoFairing().
      }
      IF (desiredInclination<80 OR desiredInclination>100) {
         IF (ALTITUDE < lockAlt ) AND  NOT aborted {
            IF (ABS(vPitch-myPitch())>10) OR (ABS(vHeading-myHeading()) > 10) {
               autoAbort().
               BREAK.
            }
         } ELSE {
            IF (VANG(FACING:FOREVECTOR, PROGRADE:FOREVECTOR)>10  AND  NOT aborted) {
               autoAbort().
               BREAK.
            }      
         }
      }
      WAIT 0.1.
   }
}   

   //Aborts launch
FUNCTION autoAbort {
   LOCK THROTTLE to 0.
   IF (ALTITUDE < tLimitAlt) {
      ABORT ON.
   }
   PRINT " ".
   PRINT "Attitude control loss detected.".
   PRINT "ABORTING!".   
   SET aborted to TRUE.
}
   //Stages fairings
FUNCTION autoFairing {
   SET fairing to false.      //holds if vessel has a fairing
   LIST PARTS IN partList.    //LIST of parts on vessel
   FOR part IN partList {     //checks if fairing in partList
      IF (part:NAME = "fairingSize1" OR
	      part:NAME = "fairingSize2" OR
		  part:NAME = "fairingSize3" OR
		  part:NAME = "restock-fairing-base-0625-1" OR
		  part:NAME = "restock-fairing-base-1875-1" OR
		  part:NAME = "fairingSize1p5" OR
		  part:NAME = "fairingSize4") {
		     SET fairing to true.
           BREAK.
		  }
   }              //stages if vessel has a fairing
   IF fairing {
      AG5 ON.
      PRINT " ".
      PRINT "Staging Fairing.".
   }
   SET fairingStaged to TRUE.
}

   //Deploys equipment
FUNCTION autoDeploy {
        //all deployable equipment must be on action group 10
   AG10 ON.
   LIGHTS ON.
   PRINT " ".
   PRINT "Extending deployable equipment.".
   SET deployed to TRUE.
}

   //Watches for abort trigger
FUNCTION setAbortTrigger {
   ON ABORT {
         IF NOT aborted {
            LOCK THROTTLE to 0.
            ABORT ON.
            PRINT " ".
            PRINT "Abort has been triggered manually.".
            PRINT "ABORTING!".   
            SET aborted to TRUE.
         }
   }
}

   //Returns mass of launch clamps
FUNCTION clampMass {
   LIST PARTS IN partList.    //LIST of parts on vessel
   SET cMass to 0.
   FOR part IN partList {     //checks if part is a launch clamp
      IF (part:NAME = "launchClamp1") {
		     SET cMass to cMass + part:MASS.
		}
      PRINT "Clamp Mass:" + cMass.
      RETURN cMass.
   }   
}
   // creates node at apoapsis to circularize
FUNCTION circNode {
   WAIT UNTIL (ALTITUDE > 70000).
   SET futureVelocity to SQRT(VELOCITY:ORBIT:MAG^2-2*BODY:MU*(1/(BODY:RADIUS+ALTITUDE) - 1/(BODY:RADIUS+ORBIT:APOAPSIS))).
   SET circVelocity to SQRT(BODY:MU/(ORBIT:APOAPSIS+BODY:RADIUS)).
   SET newNode to NODE(TIME:SECONDS+ETA:APOAPSIS, 0, 0, circVelocity-futureVelocity).
   ADD newNode.
   PRINT " ".
   PRINT "Circularization burn plotted.".
}

   // Executes next maneuver
FUNCTION xMan {
   SAS OFF.
      // amount of time before end to reduce burn
   SET startReduceTime to 2.
      // desired TWR
   SET desiredTWR to 0.9.
      // holds data regarding maneuver node
   SET mNode to NEXTNODE.
      // start time of burn
   SET TWR to AVAILABLETHRUST / MASS*CONSTANT:g0.
      // limiting thrust if TWR is more than desired TWR
   IF (TWR > desiredTWR) {
      SET thrustLimiter to desiredTWR*MASS*CONSTANT:g0 / AVAILABLETHRUST.
   }
   SET startTime to calculateStartTime(mNode, startReduceTime).
      // start direction of burn
   SET startVector to mNode:BURNVECTOR.
   lockSteering(mNode).
   startBurn(startTime).
   WAIT UNTIL burnTime(mNode) < startReduceTime.
   reduceThrottle().
   endBurn(mNode, startVector).
}

   // calculates the start time of the burn
FUNCTION calculateStartTime {
   PARAMETER mNode.
   PARAMETER startReduceTime.
   RETURN TIME:SECONDS + mNode:ETA - halfBurnTime(mNode) - startReduceTime/2.
}

   // locks attitude to the burn vector
FUNCTION lockSteering {
   PARAMETER mNode.
   LOCK STEERING to mNode:BURNVECTOR.
   PRINT "Locking attitude to burn vector.".
}

   // maneuver ends when burn vector deviates by more than 3.5 degrees
FUNCTION maneuverComplete {
   PARAMETER mNode.
   PARAMETER startVector.
   RETURN VANG(startVector, mNode:BURNVECTOR) > 3.5.
}

   // calculates how long the burn will take
FUNCTION burnTime {
   PARAMETER mNode.
   SET bTime to -1.
   SET delV to mNode:BURNVECTOR:MAG. 
   SET finalMass to MASS / (CONSTANT:E^(delV/(currentISP()*CONSTANT:g0))).
   //SET startAcc to AVAILABLETHRUST / MASS.
   //SET finalAcc to AVAILABLETHRUST / finalMass.
      // checking to make sure engines haven't flamed out
   IF (AVAILABLETHRUST > 0) {
      //SET bTime to 2*delV / (startAcc+finalAcc).
      SET bTime to delV*(MASS - finalMass) / thrustLimiter / AVAILABLETHRUST / LN(MASS/finalMass).
   } 
   RETURN bTime.        
}

   // calculates how long to do half the burn
FUNCTION halfBurnTime {
   PARAMETER mNode.
   SET bTime to -1.
   SET delV to mNode:BURNVECTOR:MAG/2. 
   SET finalMass to MASS / (CONSTANT:E^(delV/(currentISP()*CONSTANT:g0))).
   //SET startAcc to AVAILABLETHRUST / MASS.
   //SET finalAcc to AVAILABLETHRUST / finalMass.
      // checking to make sure engines haven't flamed out
   IF (AVAILABLETHRUST > 0) {
      //SET bTime to 2*delV / (startAcc+finalAcc).
      SET bTime to delV*(MASS - finalMass) / thrustLimiter / AVAILABLETHRUST / LN(MASS/finalMass).
   } 
   RETURN bTime.        
}

   // calculates the combined ISP of active engines
FUNCTION currentISP {
   LIST ENGINES in engineList.
   SET sumOne to 0.
   SET sumTwo to 0.
   FOR eng in engineList {
      IF eng:IGNITION {
         SET sumOne to sumOne + eng:AVAILABLETHRUST.
         SET sumTwo to sumTwo + eng:AVAILABLETHRUST/eng:ISP.
      }
   }
   IF (sumTwo > 0) {
      RETURN sumOne / sumTwo.
      // returns -1 if no active engines
   } ELSE {
      RETURN -1.
   }
}

   // reduce throttle function
FUNCTION reduceThrottle {
   PRINT " ".
   PRINT "Reducing throttle.".
   SET reduceTime to startReduceTime*(-1)*LN(0.1)/0.9.
   SET startTime to TIME:SECONDS - 0.5.
   SET stopTime to TIME:SECONDS + reduceTime - 0.5.
   SET scale to CONSTANT:E^(-0.9/startReduceTime).
   LOCK THROTTLE to thrustLimiter*scale^(TIME:SECONDS - startTime).
   WAIT UNTIL TIME:SECONDS > stopTime.
   LOCK THROTTLE to 0.1.
}

   // starts the burn
FUNCTION startBurn {
   PARAMETER startTime.
   PRINT "Circularization burn to start in " + ROUND(startTime - TIME:SECONDS) + " seconds.".
   WAIT UNTIL TIME:SECONDS > (startTime-30).
      // 30 second countdown
   PRINT " ".
   PRINT "Starting burn in ...".
   PRINT "30 seconds".
   WAIT 10.
   PRINT "20 seconds".
   WAIT 10.
   PRINT "10 seconds".
   WAIT 5.
   PRINT "5".
   WAIT 1.
   PRINT "4".
   WAIT 1.
   PRINT "3".
   WAIT 1.
   PRINT "2".
   WAIT 1.
   PRINT "1".
   WAIT 1.
   PRINT "Engaging engines.".
   LOCK THROTTLE to thrustLimiter.
}

   // kills throttle when burn is complete
FUNCTION endBurn {
   PARAMETER mNode.
   PARAMETER startVector.
   WAIT UNTIL maneuverComplete(mNode, startVector).
   PRINT " ".
   PRINT "Burn Complete.".
   PRINT " ".
   LOCK THROTTLE to 0.
   UNLOCK STEERING.
   SAS ON.
   REMOVE mNode.
   WAIT 1.
   SWITCH TO 1.  
   PRINT "Switching volume to vessel.".
   PRINT " ".
   WAIT 2.
}

///END OF PROGRAM
