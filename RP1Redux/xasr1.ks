SET voice to getVoice(0).
SET tickNote to NOTE(480, 0.1).
SET launchNote to NOTE(720, 0.5).

CLEARSCREEN.

WAIT 1.
voice:PLAY(tickNote).
PRINT "5".
WAIT 1.
voice:PLAY(tickNote).
PRINT "4".
WAIT 1.
voice:PLAY(tickNote).
PRINT "3".
WAIT 0.5.
LOCK THROTTLE to 1.
PRINT "Throttle Locked to Full.".
WAIT 0.5.
voice:PLAY(tickNote).
PRINT "2".
WAIT 1.
voice:PLAY(tickNote).
PRINT "1".
WAIT 1.
PRINT "LAUNCH!".
voice:PLAY(launchNote).
STAGE.

WAIT 1.
WAIT UNTIL VERTICALSPEED < 0.
STAGE.
WAIT 2.
STAGE.

PRINT " ".
PRINT "Parachutes Armed!".
WAIT 1.
PRINT "Program shutting down ... Good Luck!".