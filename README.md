# Formal
This is an iOS game, written with Swift, for multiple screen dimensions. ogallagher is the sole author for the whole project.


#Description
Formal is a difficult platformer with some unique features:
> Incorporates the device orientation heavily to control in-game gravity (so you'll end up holding your device upside-down more than most apps require)

> Most features in the game are controlled by gravity

> The avatar can only be moved when touching ground

> All graphics are drawn with CGGraphicsContext, though I plan on supplementing some drawing with loading image files to help counter latency

> It's not finished

> There are currently 21 levels


The project, from a programming perspective…
> Was written in Swift

> Has some useful classes that I created. I recommend taking a look at Formal-iOS-Swift-Game/PuzzlePlatformer/PuzzlePlatformer/Library.swift for them
>> The RigidPolygon class is what I’m using to make the blue square respond to outside forces both translationally and rotationally, which took me a while to create. The only improvement I might add would be to incorporate polygon-edge-with-neighboring-corner collision, but doing that isn’t worth it for how I’m using it.

>> The Vector class is what I’m using to do all the vector math in the project. Other’s have probably also made Vector classes for swift projects, but I had a hard time finding anything that I wanted to use. It’s been tested thoroughly through this game, so it should be good to use in another project

> Has room for improvement. For example, the method I use for collision between the player and surrounding islands is not perfect, and there is a glitch I haven't been able to fix, where the level selection buttons can overlap if swiped too fast. See the To-Do List for some glitches that have been solved are have yet to be solved.

> Stores all level information in a .txt file, and reads each level on demand

> Runs on a structure centered entirely on the useage of NSTimer.scheduledTimerWithTimeInterval(), which I use to have a constant game update loop (this makes it easier to program for those less familiar with standard iOS protocols, of which I am one)


#To-Do List
- [x] Create stationary islands
- [x] Create collisionCornerWithLine: rotational + translational
- [x] Create rotating islands
- [x] Collide with rotating islands on rounded edge
- [x] Draw rotating islands
- [x] Fix collision with rotating islands near the edges (make the bounding shape a pentagon, instead of a triangle to decrease pointedness near the edges)
- [x] Create spikes
- [x] Create spikes on rotating islands
- [x] Create doors
- [x] Draw spikes
- [x] Draw doors
- [x] Spikes' reaction with player
- [x] Fix spike range to player (too narrow)
- [x] Lessen reflection force off rounded rotating edge
- [x] Change player.myGravity based upon rotating island.angle to try lessening slide
- [x] Fix surfaceRotates logic problem
- [x] Player skin
- [x] Surface skins
- [x] Block skins
- [x] Spike skin
- [x] Door skin
- [x] Create level class, each of which contains an array of islands and items
- [x] Create an array of levels
- [x] Test spikes with pivots
- [x] Draw spikes with pivots
- [x] Test doors
- [x] Test doors with pivots
- [x] Draw doors
- [x] test a door item.action() to change level
- [x] Create save-data so the app remembers what level you’re on
- [x] Create sliding islands (suspended on guiding rails)
- [x] Add pivotal rotation capability to sliding islands
- [x] Test rotating, sliding islands
- [x] Rail skin
- [x] Create a menu/home (title, choose level)
- [x] Choose game name: Formal
- [x] Title skin
- [ ] Create background items in levels (for trees, bushes, clouds?, etc.)? Now that the game is less focused on the environment, I might not do this.
- [x] Create a button class (for levels, home)
- [x] Create level button skins
- [x] Create selected level button skins
- [x] Create enabled level button skins
- [x] Create locked level button skins
- [x] Create home button skin
- [x] Link level buttons to levelSelect
- [x] Create background skins
- [x] Add level-button swiping in home
- [x] highestLevel = drawing the level buttons
- [x] highestLevel = selection enabling
- [x] Start level design
- [x] Start associated level skins
- [x] Disable movement until first tap after each reset
- [x] Create game icon image
- [x] Reduce lag from drawing: try splitting drawing into multiple UIViews on top of each other
- [x] Create wraparound for level buttons
- [x] Reduce lag from drawing: split up drawing into even more UIViews: ButtonView, StaticView (for level stuff that isn’t drawn every loop)
- [ ] Add an AnimatedView (for level stuff that is animated with a period of more than 0.001)? It might be used for animated background items, if I ever add those.
- [x] Reset level button positions when reset is called
- [x] Get new bitmap editor — Piskel can’t have multiple files open and copy-paste between them.
- [x] After completing the "last" level, switch back to level #0
- [x] I NEED an easier way to create level blocks. Right now, I have to make locations EXACTLY in the center, and make borders line up EXACTLY between touching blocks.
- [x] Switch back to drawing…? It was so much easier…
- [x] Disable button presses if initialCursor.x != finalCursor.x ?
- [x] Create home button icon
- [x] Create text class for instructions in-game
- [x] Create OK button to disable level button interaction (selecting, swiping) and decrease alpha for unselected buttons OR find another way to fix the problem
- [x] Delete 2 spikes and add an extension to the base of level 4
- [x] Perhaps insert a new level 7 which looks more like level 1 with rotation
- [x] Move the current level 5 after first rotation level?
- [x] Add rails to the things drawn in StaticView
- [x] Change font to something more simplistic
- [x] Fix button press glitch (not always pressed; delete finalCursor requirement)
- [ ] Fix button slide glitch (if done too fast and too rapidly, the buttons overlap)
- [x] Add pivoting block items (blocks which sit on rotating blocks)
- [x] Fix menu glitch (automatically jumps to the level in the upper right-hand corner; doorsOpened should not be of consequence in the menu level)
- [x] Update drawing methods again — the lag is getting noticeable with pivoting ground levels?
- [x] Fix the last few levels (doors on 15, length of island #2 on 13)
- [x] Introduce scaling (in addition to centering) into levels, to better the experience for larger devices. Based upon screen width? 
- [x] AND/OR... make the extra unused screen space used for menu stuff (home button, level type, etc.) on the top (menu is not moved according to the gameplay view center)
- [x] Fix blocks with pivots glitch (reflection off of these blocks is done wrong; I suspect it's because the block is registered as canRotate)
- [x] Fix glitch where pivoting items don't... pivot. (The location of the anchor is NOT the same as the location given, due relation to center edit)
- [x] Level: spike "hoops"
- [ ] Perhaps add in fps limiter (like in MultTest)?
- [x] Level: 2PI, 2SI, spikes (now called Random)
- [x] Add increased friction when touching ground
- [ ] Add switch to enable rotating gravity? I haven't made a level with this yet, though.
- [x] Add turrets that shoot little red triangles
- [x] Add bullet class, a subclass of RigidPolygon to be shot from turrets
- [x] Add shrapnel class, which just ejects from a given point
- [x] Add islands that slide with another dock island
- [x] Change movement to not move in relation to touched sliding ground (if ground slides, add island.velocity to player.location + cancel player.myGravity)
- [x] Level: guillotine
- [x] Level: boat
- [x] Level: hatch
- [x] Level: skyscraper
- [x] Level: bridge
- [ ] Level: train = stay on the sliding platform
- [ ] Level: shell (first level with gravity switches)
- [x] Change bullets to circles (the rigid polygon collisions aren't worth the extra time to process, I think)
- [x] Create new bullet class based upon point-line collision
- [x] Fix bullet glitch; they seem to be colliding with the wrong coordinates. POSSIBLE PROBLEM: using the same vector names for different calculations effects previous calculations?
- [x] Add second door to level 12
- [x] Create shrapnel class, which ejects from an exploded bullet
- [x] Edit bullets so they explode after 5 collisions
- [x] Edit bullets so they don’t disappear if the player dies
- [x] Create button item class, which makes doors appear
- [x] Add locked doors, which unlock when a button-item is pressed
- [x] Fix button-item glitch, where you have to be on the button to unlock the door
- [x] Add button-item to and fix level 16
- [x] Put rotation indicator drawing in a different view, so it doesn't update as fast or after it reaches the end of its animation
- [x] Add text to level 16
- [x] Add level skipping
- [x] Keep track of beatenLevels
- [x] Color beaten levels differently
- [x] Create a better continue button (door on level 0)
- [x] Edit scaling methods so the view’s center is moved down until the bottom of the view is the bottom of the screen.
- [x] Fix level skipping glitch, where a level is unlocked but doesn’t exist
- [ ] Perhaps input rotation relational friction into pivoting islands as well?
- [x] Translate + scale buttons, actually (their locations and ranges need to change for accurate interaction)
- [x] Scale buttons, visually (because their increased spacing needs to be coupled with increased print size)
- [x] Translate items (hooked to centerX,centerY)
- [x] Scale items, visually, both static and not (just scale drawn locations and drawn sizes)
- [x] — Static
- [x] — Not
- [x] Translate islands (hooked to centerX,centerY)
- [x] Scale islands, visually, both static and not (just scale drawn locations and drawn sizes)
- [x] — Static
- [x] — Rotating
- [x] — Sliding
- [x] — Appearing
- [x] Scale bullets and shrapnel (scale drawn locations and sizes)
- [x] Translate player (hooked to centerX,centerY)
- [x] Scale player, visually (since the player is not tapped, just scale drawn location and size)
- [x] Translate and scale rotation indicator, visually (doesn’t have an actual location, anyway)
- [x] Switch scale to a Float (will be between 1 and 2)
- [x] Test scaling methods
- [x] Scale death boundaries
- [x] Fix glitch in scaling where width increases more than height
- [x] Do transformations from CENTER, not CORNER!!!!
- [x] — Islands
- [x] —— Rotating, Sliding, Appearing
- [x] —— Static
- [x] — Items
- [x] —— Rotating, Appearing, Reacting
- [x] ——— Spikes
- [x] ——— Doors
- [x] ——— Buttons
- [x] —— Static
- [x] ——— Spikes, Bullets Turrets
- [x] ——— Text
- [x] — Bullets + Shrapnel
- [x] — Player
- [x] — Buttons
- [x] Test new transformations (Test scaling methods — Round 2)
- [x] Fix wrong transformations: Player, buttons, moving spikes, doors
- [x] Test fixed transformations (Test scaling methods — Round 3)
- [x] Fix spikes on level 8
- [x] Test pivoting anchored islands (the anchor location detection might be thrown off…)
- [x] Test new death boundaries
- [x] Mark gameplay view frame in StaticView
- [ ] What should I do with the opened menu space? POSSIBILITIES: Show level # and name (make the text fill space?)
- [x] Fix sliding island positions (not centered around centerX and centerY?)
- [x] Add level parameter which isolates deviceMotion.gravity general use and application to player’s gravity
- [x] Use new parameter for level 19
- [x] Create new rotation indicators for: 
- [x] — no rotation (no longer doing this)
- [x] — rotation but not for gravity
- [x] - gravity switches
- [ ] Add coins to areas in levels that are difficult to reach, though not necessary to continue? What would the coins do, then, if anything?
- [x] Add sliding items (move according to a dock island’s velocity)
- [ ] Add text to level 19
- [x] Create drawing methods for sliding items under the RotatingAndSlidingView
- [x] Fix sliding items glitch (Solution: set island.rail[2] (parallel velocity) to change in location when the sliding island is at one of the rail's extremes)
- [ ] Level: antennae
- [ ] Level: intrusion (first turret level)
- [x] Edit turrets so they only shoot within π/2 radians of their eye (so they don’t shoot through the ground on which they sit)
- [x] Make the player die if crushed by a sliding block? (touching wall on opposite sides, with at least 1 being a sliding block) OR make levels so crushing never happens (edit rail, add spikes)
- [ ] Check if appearing islands are redrawn after they finish growing
- [x] Add spikes to corridor in level 20 
- [ ] Add text to level 20
- [x] Test islands that slide w/ another dock island
- [ ] Check how to make the app size better for iPads
- [x] Start level 21
- [x] Add text to level 21
- [x] Shrink the home button a bit
- [x] Create a pull-down menu in the upper right-hand corner that reveals the home button
- [ ] Player dies if crushed by 2 islands
- [ ] Fix bullets+shrapnel to have them always explode after (3?) collisions
- [x] Store levels in external file, so they aren't in the program's memory? Load each as demanded?
- [x] — Look up string functions in Swift (important: split string by character, get string between two tags): to find a string within another, source.rangeOfString(search). To find a string between two tag strings, source.rangeOfString("(?<=tag1)(?=tag2)")
- [x] — Look up how to read from an extrernal .txt file in Swift
- [x] — System for storage:
- [x] —— Create a text file with all the level information
- [x] ——— Store and read from file
- [x] ——— Transcribe levels
- [x] ———— 1
- [x] ———— 2
- [x] ———— 3
- [x] ———— 4
- [x] ———— 5
- [x] ———— 6
- [x] ———— 7
- [x] ———— 8
- [x] ———— 9
- [x] ———— 10
- [x] ———— 11
- [x] ———— 12
- [x] ———— 13
- [x] ———— 14
- [x] ———— 15
- [x] ———— 16
- [x] ———— 17
- [x] ———— 18
- [x] ———— 19
- [x] ———— 20
- [x] ———— 21
- [x] ——— Syntax = split levels by '\n', split level objects by '+', split object data by '=', split data components by ' ' and ','
- [x] ———— An example level: "5,A Level,0,0+island=0,0=1,1 2,2 3,3+spike=0,0=3.1416+door=0,0=0.5\n"
- [x] —— When a level is requested, find the level in the text file with that number and store it.
- [x] —— Only store one level at a time in the program.
- [x] Move level 14 to current spot of level 17, make it rotate not for gravity, change text
- [x] Fix glitch that arose when creating the pull-menu for the home button (now the player doesn't move at all!) >: (
- [x] Fix movement so swipes are not stored
- [x] Fix spikes and doors so their action sites match their positions
- [x] Double-tap on a level # to select, remove confirmation button (green arrow) at bottom of menu
- [ ] Help menu
- [x] Resize main menu after removing the confirmation button
- [x] Fix alignment in levels 14(√) and 21(√)
- [x] Thicken platforms in levels 15(N/A), 16(N/A), and 19(N/A) OR, if flick towards ground is nullified, this is not necessary :)
- [ ] Start compiling images for display (to replace some-not all-of the drawing methods: player, items, moving islands, bullets, shrapnel) to decrease Formal's overall latency?
- [x] Fix rotating doors in level 14
- [x] Fix glitch with new level system where the last level can't be unlocked
- [ ] Create a lauch screen (perhaps an animated introduction w/ Formal's icon)
- [ ] Information Menu: my name, latest update date, #levels, history, etc.
- [x] Don't draw rails anymore (they don't look that great and I didn't align them correctly)
- [x] Fix selection of level 21
- [x] Don't have buttons move if level.number != 0
- [x] Make player movement magnitude analog
- [ ] Level: Ducts (put in level 13's spot) = another like level 4, with rotating gravity
- [x] Nullify flick components directed toward the ground
- [ ] Level: Fences = vertical chimneys with segmented walls, where incoming bullets force player to control fall speed; gravity switches
- [x] Create gravity switches (type of item): they set player.velocity to zero, switch player.myGravity to their choice (choice is stored in angle), and then become inactive. 
- [x] Add initialGravity variable to levels
- [ ] Level: Current = path(s) of gravity switches where player must use sliding blocks to avoid death/entrapment and reach doors