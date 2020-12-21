// Maneuver Node Creator

// @author: Mike Aben (2019)

// DESCRIPTION:
// Will create a manuever node to circularize 
// at either apoapsis or periapsis (as specified
// by the user).

   // parameters
PARAMETER location.

main().

   // Driver
FUNCTION main {
   circAt(location).
}

   // creates node at apoapsis or periapsis
FUNCTION circAt {
   PARAMETER loc.
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