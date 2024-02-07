// Spaceplane Launch Script 

// Need steeper ascent in lower atmosphere followed by decreased pitch in upper.

// @author: Mike Aben (2022)
// @param: inclination, apoapsis

// DESCRIPTION: Ascends a spaceplane into orbit. Takes two paramemters:
// desired inclination (keep small please) and altitude of final orbit (in km).
// Attach switch to closed cycle mode to action group 1.
// Attach any space deployable equipment to action group 10.
// MAY NOT EASILY GENERALIZE TO OTHER SPACEPLANES

//**************************
//*** PROGRAM PARAMETERS ***
//**************************

   // desired inclination of final orbit
PARAMETER desiredInclination.
   // desired altitude of final orbit
PARAMETER desiredApoapsis.	

//*************************
//*** ASCENT PARAMETERS ***
//*************************

   // altitude to switch from open air to closed cycle
SET closedCycleAlt to 18500.
   // altitude to raise landing gear
SET gearUpAlt to 90.
   // pitch at takeoff
SET startPitch to 15.
   // altitude of minimum pitch during open air mode
SET holdAlt to 25000.
   // minimum pitch during open air mode
SET holdPitch to 5.
   // 45 degree pitch during closed cycle mode
SET halfPitchedAlt to 12000.
   // Desired altitude to lock to orbital prograde.
SET lockAlt to 50000.
   // Estimated orbital velocity at lockAlt.
SET lockVelocity to 2500.
   // Desired altitude for thrust to limit.
SET tLimitAlt to 30000.
   // TWR for final stage of ascent
SET finalThrustAdj to 0.9.
   // Desired altitude to extend deployables.
SET deployAlt to 70000.

//**********************************

   // Current thrust setting.
SET thrustSetting to 1.
   // Is vessel locked to orbital prograde?
SET proLocked to FALSE.
   // Is throttle limitted?
SET thrustLimited to FALSE.
   // Are deployables deployed?
SET deployed to FALSE.

//**********************************

main().

   // Main program
FUNCTION main {
   WAIT 2.
   CLEARSCREEN. 
   WAIT 2.
   takeoff().
   openCycle().
   closedCycle().
   meco().
   circNode().
   xMan().  
}

   // Starts plane and heads down runway
FUNCTION takeoff {
   LIGHTS ON.
   LOCK STEERING to HEADING(90, .25).
   LOCK THROTTLE to thrustSetting.
   BRAKES OFF.
   WAIT 0.5.
   PRINT "Throttle to Full.".
   STAGE.
   WAIT UNTIL (AIRSPEED > 80).
}

   // Controls plane during air breathing mode
FUNCTION openCycle {
   SET initialHeading to myHeading().
   LOCK STEERING to HEADING(90, openCyclePitch).
   WAIT 0.5.
   PRINT "Nose Up.".
   WAIT UNTIL (ALTITUDE > gearUpAlt).
   GEAR OFF.
   WAIT 0.5.
   PRINT "Gear Up.".
   LOCK STEERING to HEADING(initialHeading, openCyclePitch).
   WAIT UNTIL (ALTITUDE > closedCycleAlt).
}

   // Heading setting
FUNCTION myHeading {
   SET roughHeading to 90 - desiredInclination.
   IF (roughHeading < 0) {
      SET roughHeading to 360 + roughHeading.
   }
      //taking into account Kerbin's rotation
   SET triAng to abs(90 - roughHeading).
   SET vH to sqrt(180^2 + lockVelocity^2 - 180*lockVelocity*cos(triAng)).
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

   // Sets pitch during air breathing mode
FUNCTION openCyclePitch {
   SET k to 180/holdAlt.
   SET a to (startPitch - holdPitch) / 2.
   SET b to (startPitch + holdPitch) / 2.
   SET localPitch to a*COS(k*ALTITUDE) + b.
   RETURN localPitch.
}

   // Sets pitch during closed cycle mode
FUNCTION closedCyclePitch {
   RETURN 90*halfPitchedAlt / (ALTITUDE + halfPitchedAlt).
}

   // Controls plane during closed cycle mode
FUNCTION closedCycle {
   LOCK STEERING to HEADING(initialHeading, closedCyclePitch).
   PRINT " ".
   PRINT "Pitching up and switching".
   PRINT "to Closed Cycle Mode.".
   WAIT 1.
   TOGGLE AG1.
   UNTIL (APOAPSIS > desiredApoapsis*1000) {
      IF (ALTITUDE > lockAlt) AND NOT proLocked {
         lockToPrograde().
      }
      IF (ALTITUDE > tLimitAlt) AND NOT thrustLimited {
         limitThrust().
      }
      IF (ALTITUDE > deployAlt) AND NOT deployed {
         autoDeploy().
      }
      WAIT 0.1.
   }   
}

   //LOCKING TO PROGRADE
FUNCTION lockToPrograde {
   PRINT " ".
   PRINT "Locking to prograde.".
   LOCK STEERING to PROGRADE.
   SET proLocked to TRUE.
}

   //LIMITS TWR to thrustAdj Setting
FUNCTION limitThrust {
      //force of gravity on vessel
   LOCK Fg to (BODY:MU/(BODY:RADIUS+ALTITUDE)^2)*MASS.
      //locks thrust
   IF (AVAILABLETHRUST > 0) {
      IF NOT thrustLimited {
         SET thrustSetting to finalThrustAdj*Fg / (AVAILABLETHRUST+0.001).
         PRINT " ".
         PRINT "Adjusting TWR to " + finalThrustAdj.
      } 
      LOCK THROTTLE to thrustSetting.
      SET thrustLimited to TRUE.
   }  
}   

   //Returns ship TWR
FUNCTION shipTWR {
   RETURN AVAILABLETHRUST*thrustSetting / (MASS*CONSTANT:g0).
}

   //Main Engine Cut-off
FUNCTION meco {
   LOCK THROTTLE to 0.
   PRINT " ".
   PRINT "Engine Cut-off.".
   WAIT UNTIL ALTITUDE > deployAlt.
   IF NOT deployed {
      autoDeploy().
   }
}

   //Deploys equipment
FUNCTION autoDeploy {
        //all deployable equipment must be on action group 10
   AG10 ON.
   PRINT " ".
   PRINT "Extending deployable equipment.".
   SET deployed to TRUE.
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