Delphi Games Creator - Beta 3
=============================

(PLEASE READ ALL OF THIS TEXT)

First and important note - This beta release of DGC does not contain any
documentation updates. Most of the changes in beta 3 are to the sprite 
engine or new components, and you will need to look at the demo programs
to find out how to use these new facilities. The help file should still be 
useful for the other components like the main DGC component. Use the 
source code provided for function/property reference. 

Whats in Beta 3?
================

Sprite Engine
-------------
Paul Bearne (the author of Zapper) and I have been working hard on the new
sprite engine. It has been completely rewritten and allows sprites to
be created easily and have them automatically animated and moved by DGC. 
Different sprite types can be created with different types of movement. 
For example, you can create a TDGCRacecar for a race game, a TDGCThruster 
for Asteroids, a TDGCBouncer and TDGCPlayer8 for Space Invaders. Even the 
player contolled sprites can be moved for you automatically by DGC. 
A brief description on how the new sprite engine works follows this section'. 
I suggest you read it as there is currently no other documentation on the 
sprite engine. The new sprite engine is quite easy to use so looking at the 
demo programs should help (look at the source for demo4. It has lots of 
comments).

New Components
--------------
Paul Bearne has developed some new components:

	Effects Component
	-----------------
	This component will let you add transition effects to your programs.
	You use a new editor (similar to the image library) to choose images
	and define a transition effect from one image to the next. Again,
	take a look at demo7 for more information.

	Hi Score Component
	------------------
	This is a great component for quickly adding a high score table to your
	game. The component will display the current hiscore and capture new
	names.

	Starfield component
	-------------------
	Instantly add a scrolling starfield to your game. Choose the 
	number of stars, speed and direction. This is used in demo5.
 
 
Some Minor bug fixes and enhancements.
--------------------------------------
1. Fixed application switching problems with demo's.
2. Added Replay method to the TDGCSoundBuffer class.
3. Added 1024x768x8 to available resolutions.
4. Image Editor problem with enabling/disabling speed buttons fixed.
5. Image Editor allows images to be repositioned in list.


Introduction to the new sprite engine
=====================================
This is a brief introduction to the new sprite engine. I suggest after
reading this section you take a look at the demo programs and the 
dgcspts.pas file containing the sprite classes if you want further 
information.

All sprite classes derive from the TDGCSprite class and have a standard
set of attributes. For example, all sprites move in a defined (Limits)
rectangle and have X, Y, Direction and Velocity properties. The Limits 
rectangle defaults to entire screen but can be larger or smaller. 
Each sprite has a direction and velocity (some have acceleration values 
as well). The direction must be a value from 0-31 where 0 = North and 
16 = South etc. When a sprite moves and hits the side of the Limits 
rectangle you can choose an action to occur. This action could be to 
let it bounce of the side, wrap to the other side, stop or call an event. 
An action can be set for each side of the Limits rectangle. Each sprite 
can have a different animation for each of the possible 32 directions. 
Animation slot 0 is the animation for the sprite moving up or North. 
You only need to fill in the animation slots for the directions your  
sprite in going to move in. For example, if your sprite is only going 
to move up and down then you only need to fill in animation slots 0 and 
16. This will become clearer when you look at the demo programs. Paul 
Bearne is currently looking at a world coordinate system for the sprite 
engine and a early demos are looking good. Paul has written two pretty
cool games using the current sprite engine and the source is available
in request. One is a shoot-em-up called Zapper and the other is an
Asteroids clone. 

(Note: A TDGCJumper class has not been written. This will come later and
be for Mario type games. This will fit it with later developments for
a world coordinate system and a map editor for tile based games).


Requirements
============
DGC will work with DirectX versions 1-3. If you have any problems running
the demo programs please make sure you can run the demo programs that
come with the DirectX SDK BEFORE sending me or Paul Bearne an EMAil. It
appears that some graphics cards/drivers are not 100% DirectX compatible 
and problems may not be due to DGC. If you have problems try running the
ROIDS.EXE and WORMHOLE.EXE demos that come with the DirectX SDK. 
WORMHOLE.EXE demonstrates palette animation and a moving animation of a
wormhole should be displayed. 

Installing the components
=========================

NOTE: MAKE SURE YOU DO NOT HAVE ANY OTHER VERSION OF THE DDRAW.PAS OR DSOUND.PAS
FILES ON YOUR PC. IF YOU DO THEN DELETE OR RENAME THEM.

1. Make sure you uninstall any previous version of DGC.

2. Make sure you switch off the 'Break on Exception' option from the
   Delphi Tools|Options menu.

2. From the Delphi 'Components' menu select 'Install' and add the 
   'dgcreg.pas' file from the bin directory (if you do not have a bin
   directory then you did not use the -d option in pkunzip).

3. After the rebuild of the component library a DGC tab should appear 
   with five new components. At this point the best thing to do is load,
   compile and run the demo programs. Have a look at the source and learn. 

4. Read the dgc.hlp file in the help directory for more information but 
   remember there is no help on the new sprite engine.


If you have any problems don't hesitate to contact me or Paul Bearne.

Have Fun and let us have anything you do.

John Pullen
zeus@dircon.co.uk

Paul Bearne
P.M.Bearne@exeter.ac.uk

 







   