
    // Executes a maneuver node
GLOBAL FUNCTION exeMan {
   IF HASNODE {
      CLEARSCREEN.
      SAS OFF.

         // holds data regarding maneuver node
      SET mNode to NEXTNODE.
         // makes sure there are active engines
      IF (currentISP() < 0) {
         PRINT " ".
         PRINT "NO ACTIVE ENGINES.".
         WAIT UNTIL (currentISP() > 0).
      }
         // start time of burn
      SET startTime to calculateStartTime().
         // start direction of burn
      SET startVector to mNode:BURNVECTOR.
      lockSteering().
      startBurn().
      endBurn().
         // if no node in path, program ends
   } ELSE {
      PRINT " ".
      PRINT "No node in flight path.".
      PRINT " ".
   }
}

   // creates node at apoapsis or periapsis
GLOBAL FUNCTION circAt {
   PARAMETER loc IS "apo".
   IF loc = "apo" {
      SET futureVelocity to SQRT(VELOCITY:ORBIT:MAG^2-2*BODY:MU*(1/(BODY:RADIUS+ALTITUDE) - 1/(BODY:RADIUS+ORBIT:APOAPSIS))).
      SET circVelocity to SQRT(BODY:MU/(ORBIT:APOAPSIS+BODY:RADIUS)).
      SET newNode to NODE(TIME:SECONDS+ETA:APOAPSIS, 0, 0, circVelocity-futureVelocity).
   } ELSE {
      SET futureVelocity to SQRT(VELOCITY:ORBIT:MAG^2-2*BODY:MU*(1/(BODY:RADIUS+ALTITUDE) - 1/(BODY:RADIUS+ORBIT:PERIAPSIS))).
      SET circVelocity to SQRT(BODY:MU/(ORBIT:PERIAPSIS+BODY:RADIUS)).
      SET newNode to NODE(TIME:SECONDS+ETA:PERIAPSIS, 0, 0, circVelocity-futureVelocity).
   }
   ADD newNode.
}

   // aligns solar panels for max exposure
GLOBAL FUNCTION align {
   PARAMETER orientation IS "d".
   
   SAS OFF.
   IF (orientation = "d") {
      LOCK STEERING to HEADING(0, SHIP:GEOPOSITION:LAT - 90) + R(0, 0, 0).
   } ELSE {
      LOCK STEERING to HEADING(0, SHIP:GEOPOSITION:LAT) + R(0, 0, 0).
   }
   PRINT("Aligning ...").
   PRINT(" ").
   PRINT("Press 'delete' when done.").
   PRINT(" ").
   SET ch to TERMINAL:INPUT:GETCHAR().
   WAIT UNTIL ch = TERMINAL:INPUT:DELETERIGHT.
   SAS ON.
}

   // calculates the start time of the burn
FUNCTION calculateStartTime {
   RETURN TIME:SECONDS + mNode:ETA - burnTime() / 2.
}

   // locks attitude to the burn vector
FUNCTION lockSteering {
   LOCK STEERING to mNode:BURNVECTOR.
   PRINT " ".
   PRINT "Locking attitude to burn vector.".
}

   // maneuver ends when burn vector deviates by more than 3.5 degrees
FUNCTION maneuverComplete {
   RETURN VANG(startVector, mNode:BURNVECTOR) > 3.5.
}

   // calculates how long the burn will take
FUNCTION burnTime {
   SET bTime to -1.
   SET delV to mNode:BURNVECTOR:MAG. 
   SET finalMass to MASS / (CONSTANT:E^(delV/(currentISP()*CONSTANT:g0))).
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

   // starts the burn
FUNCTION startBurn {
   SET maxAcc to SHIP:MAXTHRUST / SHIP:MASS.
   SET throttleSet to 0.
   LOCK THROTTLE to throttleSet.

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

   SET throttleSet to MIN(mNode:DELTAV:MAG / maxAcc, 1).
}

   // kills throttle when burn is complete
FUNCTION endBurn {
   WAIT UNTIL maneuverComplete().
   PRINT " ".
   PRINT "Burn Complete.".
   PRINT " ".
   LOCK THROTTLE to 0.
   UNLOCK STEERING.
   SAS ON.
   WAIT 5.
}