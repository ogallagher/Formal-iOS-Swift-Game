# PuzzlePlatformer-iOS-Game
This is my first iOS game and my second iOS app, though my first was really inefficient and didn't do much.


#Description
A difficult platformer with some unique features:
> Incorporates the device orientation heavily to control in-game gravity

> Most features in the levels are controlled by the gravity

> The avatar can only be moved when touching ground

> All graphics are drawn with CGGraphicsContext

> It's not finished; I haven't even thought of a name for it yet. It's on my to-do list.


The project, from a programming perspective…
> Was written in Swift

> Has some useful classes that I created. I recommend taking a look at PuzzlePlatformer-iOS-Game/PuzzlePlatformer/PuzzlePlatformer/Library.swift for them
>> The RigidPolygon class is what I’m using to make the blue square respond to outside forces both translationally and rotationally, which took me a while to create. The only improvement I might add would be to incorporate polygon-edge-with-neighboring-corner collision, but doing that isn’t worth it for how I’m using it.

>> The Vector class is what I’m using to do all the vector math in the project. Other’s have probably also made Vector classes for swift projects, but I had a hard time finding anything that I wanted to use. It’s been tested thoroughly through this game, so it should be good to use in another project


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
- [ ] Choose game name
- [x] Title skin
- [ ] Create background items in levels (for trees, bushes, clouds?, etc.) ? Now that the game is less focused on the environment, I might not do this.
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
- [ ] Create game icon image
- [x] Reduce lag from drawing: try splitting drawing into multiple UIViews on top of each other
- [x] Create wraparound for level buttons
- [x] Reduce lag from drawing: split up drawing into even more UIViews: ButtonView, StaticView (for level stuff that isn’t drawn every loop)
- [ ] Add an AnimatedView (for level stuff that is animated with a period of more than 0.001)?
- [x] Reset level button positions when reset is called
- [x] Get new bitmap editor — Piskel can’t have multiple files open and copy-paste between them.
- [x] After completing the "last" level, switch back to level #0
- [x] I NEED an easier way to create level blocks. Right now, I have to make locations EXACTLY in the center, and make borders line up EXACTLY between touching blocks.
- [x] Switch back to drawing…? It was so much easier…
- [ ] Disable button presses if initialCursor.x != finalCursor.x ?
- [ ] Create home button icon
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
- [ ] Add in mid-air movement, just not upwards (like I did in Multiplayer Testing)?
- [ ] Perhaps add in fps limiter (like in MultTest)?
- [x] Level: 2PI, 2SI, spikes
- [x] Add increased friction when touching ground
- [ ] Add switch to enable rotating gravity
- [x] Add turrets that shoot little red triangles
- [x] Add bullet class, a subclass of RigidPolygon to be shot from turrets
- [x] Add shrapnel class, which just ejects from a given point
- [ ] Add islands that slide with another anchor island
- [ ] Change movement to not move in relation to touched sliding ground (if ground slides, add ground velocity to player.velocity)
- [ ] Levels that "connect" to each other...?
- [ ] Level: sliding hatch, no rotation
- [ ] Level: sliding U
- [ ] Level: looks like a seashell
- [x] Level: static obstacle course
- [x] Level: finish the rotating bridge
- [ ] Level: sliding obstacle course
- [ ] Level: sliding + G-switch
- [x] Change bullets to circles (the rigid polygon collisions aren't worth the extra time to process, I think)
- [x] Create new bullet class based upon point-line collision
- [x] Fix bullet glitch; they seem to be colliding with the wrong coordinates. POSSIBLE PROBLEM: using the same vector names for different calculations effects previous calculations?
- [x] Add second door to level 12
- [x] Create shrapnel class, which ejects from an exploded bullet
- [ ] Edit bullets so they explode after X collisions
- [x] Edit bullets so they don’t disappear if the player dies
- [ ] Edit shrapnel so they are removed ONLY when the level resets AND changes
- [x] Create button item class, which makes doors appear
- [x] Add locked doors, which unlock when a button-item is pressed
- [x] Fix button-item glitch, where you have to be on the button to unlock the door
- [x] Add button-item to and fix level 16
- [ ] Put rotation indicator drawing in a different view, so it doesn't update after it reaches the end of its animation
- [x] Add text to level 16
- [x] Add level skipping
- [x] Keep track of beatenLevels
- [x] Color beaten levels differently
- [x] Create a better continue button (door on level 0)
- [x] Edit scaling methods so the view’s center is moved down until the bottom of the view is the bottom of the screen.
- [x] Fix level skipping glitch, where a level is unlocked but doesn’t exist
- [ ] Perhaps input rotation relational friction into pivoting islands as well ?
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
- [ ] What should I do with the opened menu space?
- [x] Fix sliding island positions (not centered around centerX and centerY?)
- [x] Add level parameter which isolates deviceMotion.gravity general use and application to player’s gravity
- [x] Use new parameter for level 19
- [ ] Create new rotation indicator: rotation; not gravityRotation
- [ ] Add coins to areas in levels that are difficult to reach, though not necessary to continue? What would the coins do, then, if anything?
- [x] Add sliding items (move according to a dock island’s velocity)

