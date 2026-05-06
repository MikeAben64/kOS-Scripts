// Title: flightInstructions
// Description: Flight instructions for missions.

runOncePath("0:/lib/launchFunctions.ks").

//**********************************

PARAMETER missionNum.

IF missionNum = 1 {
    PRINT " ".
    PRINT "Deployment Distance: 500km".
    PRINT "90 degrees from KSC.".
    PRINT "Azimuth: 270 degrees.".
    PRINT "Go to SAS when needed.".
    PRINT "~60 degree pitch.".
    PRINT "Lock prograde at altitude.".
    PRINT "Drain propelants.".
    PRINT "Descent: Level Off @ 15km.".
} ELSE IF missionNum = 2 {
    PRINT " ".
    PRINT "Launch from Runway".
    PRINT "Target Altitude: 15000 m".
    PRINT "Climb Rate: 10 degrees.".
    PRINT "v_max: 640 m/s".
    PRINT "Further Instructions: turn".
    PRINT "around when altitude reached.".
} ELSE IF missionNum = 3 {
    PRINT " ".    
    PRINT "Luna 3 / Atlas 1c-Stentor".
    PRINT " ".
    PRINT "Ascent Parameters:".
    PRINT "Target Moon.".
    PRINT " Last Stage: 2".
    PRINT " Early Cutoff: 2".
    PRINT " Apo: 250".
    PRINT " Apo: 250".
    PRINT " Inc: moon.".
    PRINT " F-Roll: 90/90".
    PRINT " U-Stage: 0, 1".
    PRINT " Drop Solids Early: off.".
    PRINT " ".
    PRINT "ENGAGE MECHJEB!!!".
    PRINT " ".
} ELSE IF missionNum = 4 {
    PRINT " ".
    PRINT "Launch from Runway".
    PRINT "Target Altitude: 22100 m".
    PRINT "Climb Rate: 10 degrees.".
    PRINT "v_max: 280 m/s".
    PRINT "Further Instructions: turn".
    PRINT "around when altitude reached.".
} ELSE IF missionNum = 5 {
    PRINT " ".    
    PRINT "Mission: Explorer 9 / Atlas 1b-Castor 1-6".
    PRINT " ".
    PRINT "Ascent Parameters:".
    PRINT " Last Stage: 4".
    PRINT " Early Cutoff: 4".
    PRINT " Apo: 300".
    PRINT " Apo: 300".
    PRINT " Inc: current.".
    PRINT " F-Roll: 90/90".
    PRINT " U-Stage: 0".
    PRINT " Drop Solids Early: off.".
    PRINT " ".
    PRINT "ENGAGE MECHJEB!!!".
    PRINT " ".
    PRINT "RUN orbit.".
}