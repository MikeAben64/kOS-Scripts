// Maneuver node executor

// @author: Mike Aben (2019)

// DESCRIPTION:
// Executes the next maneuver node. 
// Will stage if necessary.
// Currently only works with LFO engines

// THIS IS STILL A WORK IN PROGRESS!
// IN PARTICULAR, THE STAGING DURING THE BURN IS
// OFTEN NOT WORKING CORRECTLY. THE PROBLEM SEEMS
// TO BE IN CALCULATING THE BURN TIME.

// TO DO: 
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
      autoStage(mNode, startReduceTime).
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
   RETURN TIME:SECONDS + mNode:ETA - burnTime(mNode)/2 - startReduceTime/2.
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
         // holds amount of reaction mass in current stage
   SET stageFuelMass to getStageFuelMass(getStage()).
         // checks if there is enough fuel in the current stage
   IF (MASS - finalMass) < stageFuelMass {
      SET startAcc to AVAILABLETHRUST / MASS.
      SET finalAcc to AVAILABLETHRUST / finalMass.
         // checking to make sure engines haven't flamed out
      IF (AVAILABLETHRUST > 0) {
         SET bTime to 2*delV / (startAcc+finalAcc).
      } 
         // burn will cover multiple stages
   } ELSE {
      SET bTime to getMultiStageTime(mNode).
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

   // calculates the combined ISP of engines on designated stage
FUNCTION getStageISP {
   PARAMETER desStage.
   LIST ENGINES in engineList.
   SET sumOne to 0.
   SET sumTwo to 0.
   FOR eng in engineList {
      IF eng:STAGE = desStage {
         SET sumOne to sumOne + eng:POSSIBLETHRUST.
         SET sumTwo to sumTwo + eng:POSSIBLETHRUST/eng:VISP.
      }
   }
   IF (sumTwo > 0) {
      RETURN sumOne / sumTwo.
   } ELSE {
      RETURN 0.
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
   REMOVE mNode.
   WAIT 5.
}

   //Stages if engine thrust drops.
FUNCTION autoStage {
   PARAMETER mNode.
   PARAMETER startReduceTime.
   SET oldThrust to AVAILABLETHRUST.
   UNTIL (burnTime(mNode) < startReduceTime) {
      IF (AVAILABLETHRUST < (oldThrust)) {
         STAGE.
         PRINT " ".
         PRINT "Staging".
         WAIT 1.
         SET oldThrust to AVAILABLETHRUST.
      }
   }
}

   //Returns reaction mass in specified stage
FUNCTION getStageFuelMass {
   PARAMETER desStage.
   SET fuelMass to 0.
   SET tankList to getTankList().
   LIST ENGINES in engineList.
   FOR tank in tankList {
         // Checks to see if tank is also an engine.
         // All parts but engines are off by one
         // when STAGE is called (don't know why)
      SET stageModifier to 1.
      FOR eng in engineList {
         IF ( tank:NAME = eng:NAME ) {
            SET stageModifier to 0.
            BREAK.
         }
      }
         // only counts LF and OX as reaction mass
      IF tank:STAGE = (desStage - stageModifier) {
            // adds up reaction mass
         FOR resource in tank:RESOURCES {
            IF (resource:NAME = "LiquidFuel" OR
                resource:NAME = "Oxidizer") {
                  // both LF and OX have density of 0.005t / vol. unit
               SET fuelMass to fuelMass + 0.005*resource:AMOUNT.
            }
         }
      }
   }
   RETURN fuelMass.
}

   //Returns current stage number
FUNCTION getStage {
   SET currentStage to -1.
   LIST ENGINES in engineList.
   FOR eng in engineList {
      IF eng:IGNITION {
         SET currentStage to eng:STAGE.
      }
   }
   RETURN currentStage.
}

   //Calculates burnTime if staging is required
FUNCTION getMultiStageTime {
   PARAMETER mNode.
   SET burnDV to mNode:BURNVECTOR:MAG.
   SET bTime to 0.
   SET stageThrust to 0.
   SET j to getStage().
      // adding up burn times for each stage
   UNTIL j < 0 {
      SET stageThrust to getStageThrust(j).
      SET stageMass to getTotalStageMass(j).
      SET stageFuelMass to getStageFuelMass(j).
      IF stageMass > 0 {
         SET startAcc to stageThrust / stageMass.
      }
      IF (stageMass - stageFuelMass) > 0 {
         SET finalAcc to stageThrust / (stageMass - stageFuelMass).
         SET stageDV to getStageISP(j)*CONSTANT:g0*LN(stageMass/(stageMass-stageFuelMass)).
      }
      IF (stageDV < burnDV) {
         IF (startAcc+finalAcc) > 0 {
            SET bTime to bTime + 2*stageDV / (startAcc+finalAcc).
            SET burnDV to burnDV - stageDV.
         }
            // stage has enough fuel to complete burn
      } ELSE {
         IF (startAcc+finalAcc) > 0 {
            SET bTime to bTime + 2*burnDV / (startAcc+finalAcc).
         }
         BREAK.
      }
      SET j to j - 1.
   }
   RETURN bTime.
}

   //Returns all parts containing oxidizer
FUNCTION getTankList {
   SET tankList to LIST().
   LIST PARTS in partList.
   FOR part in partList {
      FOR resource in part:RESOURCES {
         IF (resource:NAME = "Oxidizer") {
            tankList:ADD(part).     
         }
      }
   }
   RETURN tankList.
}

   //Returns total thrust of specified stage
FUNCTION getStageThrust {
   PARAMETER desStage.
   SET stageThrust to 0.
   LIST ENGINES in engineList.
   FOR eng in engineList {
      IF (eng:STAGE = desStage) {
         SET stageThrust to stageThrust + eng:POSSIBLETHRUST.
      }
   }
   RETURN stageThrust.
}

   //Returns mass of stage plus all subsequent stages
FUNCTION getTotalStageMass {
   PARAMETER desStage.
   SET totalStageMass to 0.
   SET i to desStage.
   UNTIL i < 0 {
      SET totalStageMass to totalStageMass + getStageMass(i).
      SET i to i - 1.
   }
   RETURN totalStageMass.
}

   //Returns mass of specified stage
FUNCTION getStageMass {
   PARAMETER desStage.
   SET stageMass to 0.
   LIST PARTS in partList.
   LIST ENGINES in engineList.
   FOR part in partList {
         // Checks to see if part is also an engine.
         // All parts but engines are off by one
         // when STAGE is called (don't know why)
      SET stageModifier to 1.
      FOR eng in engineList {
         IF (eng:NAME = part:NAME) {
            SET stageModifier to 0.
            BREAK.
         }
      }
         // adds on the mass if in specified stage
      IF part:STAGE = (desStage - stageModifier) {
         SET stageMass to stageMass + part:MASS.
      }
   }
   RETURN stageMass.
}

///END OF PROGRAM