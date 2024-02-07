// align

// DESCRIPTION:
// Orients vessel for ideal solar panel exposure.
// Take a parameter for the orientation of
// solar panels: ('n' - normal, 'd' - dorsal)

// ***Parameter***
   // Orientation of solar panels
PARAMETER orientation.

main().

   // Main program
FUNCTION main {
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
