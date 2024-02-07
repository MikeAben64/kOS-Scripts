// Maneuver node executor

// @author: Mike Aben (2019)

// DESCRIPTION:
// Executes the next maneuver node. 
// heading and then maintains heading

// TO DO: 
//   Handle staging events.
//   Manage Timewarping.

main().

//***********************************

   // Driver
FUNCTION main {
   xMan().
}

   // Executes next maneuver
FUNCTION xMan {
   IF HASNODE {
      CLEARSCREEN.
      SAS OFF.
         // amount of time before end to reduce burn
      SET startReduceTime to 2.
         // holds data regarding maneuver node
      SET mNode to NEXTNODE.
         // makes sure there are active engines
      IF (currentISP() < 0) {
         PRINT " ".
         PRINT "NO ACTIVE ENGINES.".
         WAIT UNTIL (currentISP() > 0).
      }
         // start time of burn
      SET startTime to calculateStartTime(mNode, startReduceTime).
         // start direction of burn
      SET startVector to mNode:BURNVECTOR.
      lockSteering(mNode).
      startBurn(startTime).
      WAIT UNTIL burnTime(mNode) < startReduceTime.
      reduceThrottle().
      endBurn(mNode, startVector).
         // if no node in path, program ends
   } ELSE {
      PRINT " ".
      PRINT "No node in flight path.".
      PRINT " ".
   }
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
   PRINT " ".
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
      SET bTime to delV*(MASS - finalMass) / AVAILABLETHRUST / LN(MASS/finalMass).
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
      SET bTime to delV*(MASS - finalMass) / AVAILABLETHRUST / LN(MASS/finalMass).
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
   LOCK THROTTLE to scale^(TIME:SECONDS - startTime).
   WAIT UNTIL TIME:SECONDS > stopTime.
   LOCK THROTTLE to 0.1.
}

   // starts the burn
FUNCTION startBurn {
   PARAMETER startTime.
      // 3 second countdown
   WAIT UNTIL TIME:SECONDS > (startTime-3).
   PRINT " ".
   PRINT "Starting burn in ...".
   PRINT "3".
   WAIT 1.
   PRINT "2".
   WAIT 1.
   PRINT "1".
   WAIT 1.
   PRINT "Locking throttle to full.".
   LOCK THROTTLE to 1.
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
   // REMOVE mNode.
   WAIT 5.
}

///END OF PROGRAM