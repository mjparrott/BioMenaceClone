%Bio Menace remake
%Set the screen
View.Set ("graphics:560;380,offscreenonly")

%Type
type purpleGuy :
		record
				x : int
				y : int
				tempX : int
				image : unchecked ^int
				imageNumber : int
				jumpingSpeed : int
				jumpingSpeedX : int
				direction : string
				attacking : boolean
				canJump : boolean
				startTime : int
		end record

type deadPurpleGuy :
		record
				deadX : int
				deadY : int
				startTime : int
		end record
		
type ladder :
		record
				x1 : int
				x2 : int
				y1 : int
				y2 : int %All positions relative to position on map
		end record


%Constants
const WALKING_SPEED := 8
const GRAVITY := 2
const JUMPING_SPEED := 25
const DELAY := 60
const JUMP_LENGTH := 20

%Enemy constants
const ENEMY_SPEED := 3
const ENEMY_JUMPING_SPEED_X := 7
const ENEMY_JUMPING_SPEED := 15

%Pictures
%Walking right
var stillr : int := Pic.FileNew ("biomenace/character_standr1.bmp")
var walkingr : array 1 .. 3 of int
walkingr (1) := Pic.FileNew ("biomenace/character_standr2.bmp")
walkingr (2) := Pic.FileNew ("biomenace/character_standr3.bmp")
walkingr (3) := Pic.FileNew ("biomenace/character_standr4.bmp")
%Walking left
var stilll : int := Pic.FileNew ("biomenace/character_standl1.bmp")
var walkingl : array 1 .. 3 of int
walkingl (1) := Pic.FileNew ("biomenace/character_standl2.bmp")
walkingl (2) := Pic.FileNew ("biomenace/character_standl3.bmp")
walkingl (3) := Pic.FileNew ("biomenace/character_standl4.bmp")
%Shooting images
var shootingr : array 1 .. 2 of int
shootingr (1) := Pic.FileNew ("biomenace/character_standrs1.bmp")
shootingr (2) := Pic.FileNew ("biomenace/character_standrs2.bmp")
var shootingl : array 1 .. 2 of int
shootingl (1) := Pic.FileNew ("biomenace/character_standls1.bmp")
shootingl (2) := Pic.FileNew ("biomenace/character_standls2.bmp")
%Jumping images
var jumpr : int := Pic.FileNew ("biomenace/character_jumpr.bmp")
var jumpshotr : int := Pic.FileNew ("biomenace/character_jumpr2.bmp")
var jumpl : int := Pic.FileNew ("biomenace/character_jumpl.bmp")
var jumpshotl : int := Pic.FileNew ("biomenace/character_jumpl2.bmp")
%Crouching
var crouchshootr : array 1 .. 2 of int
crouchshootr (1) := Pic.FileNew ("biomenace/character_crouchr1.bmp")
crouchshootr (2) := Pic.FileNew ("biomenace/character_crouchr2.bmp")
var crouchshootl : array 1 .. 2 of int
crouchshootl (1) := Pic.FileNew ("biomenace/character_crouchl1.bmp")
crouchshootl (2) := Pic.FileNew ("biomenace/character_crouchl2.bmp")
%Background
var citycentre : int := Pic.FileNew ("biomenace/citycentre.jpg")
%Purple enemies
var purpr1 : int := Pic.FileNew ("biomenace/enemy_purpr1.bmp")
var purpr2 : int := Pic.FileNew ("biomenace/enemy_purpr2.bmp")
var purpr3 : int := Pic.FileNew ("biomenace/enemy_purpr3.bmp")
var purpl1 : int := Pic.FileNew ("biomenace/enemy_purpl1.bmp")
var purpl2 : int := Pic.FileNew ("biomenace/enemy_purpl2.bmp")
var purpl3 : int := Pic.FileNew ("biomenace/enemy_purpl3.bmp")
%Death poo
var deathpoo : int := Pic.FileNew ("biomenace/deathpoo.bmp")
%Ladder images
var ladder1 : int := Pic.FileNew( "biomenace/character_ladder1.bmp" )
var ladder2 : int := Pic.FileNew( "biomenace/character_ladder2.bmp" )

var imageToBlit : unchecked ^int
new imageToBlit
^imageToBlit := stillr %What you start off doing

%Variables
var x, y : int := 0
x := 320
y := 30
var backX, backY : int := 0
var tempX : int := x
var direction : string := "right"
var shooting : boolean := false
var walking : boolean := false
var jumping : boolean := false
var crouching : boolean := false
var jumpingSpeed : int := JUMPING_SPEED
var platformY : int := y
var shotImage : int := 1

var walkImage : int := 3

var getHurt : boolean := true
var numberOfPurples : int := 3
var purpleEnemies : flexible array 1 .. numberOfPurples of purpleGuy
var purpleGuyX : array 1 .. numberOfPurples of int
var deadGuys : flexible array 1 .. 0 of deadPurpleGuy
purpleGuyX (1) := 600
purpleGuyX (2) := 900
purpleGuyX (3) := 1200
for i : 1 .. numberOfPurples
		purpleEnemies (i).x := purpleGuyX (i)
		purpleEnemies (i).tempX := purpleGuyX (i)
		purpleEnemies (i).imageNumber := 1
		purpleEnemies (i).jumpingSpeedX := ENEMY_JUMPING_SPEED_X
		purpleEnemies (i).jumpingSpeed := ENEMY_JUMPING_SPEED
		purpleEnemies (i).attacking := false
		purpleEnemies (i).canJump := true
		purpleEnemies (i).startTime := 0
		new purpleEnemies (i).image
		if Rand.Int (1, 2) = 1 then
				purpleEnemies (i).direction := "right"
				^ (purpleEnemies (i).image) := purpr1
		else
				purpleEnemies (i).direction := "left"
				^ (purpleEnemies (i).image) := purpl1
		end if
		purpleEnemies (i).y := 30
end for

%Ladders
var ladders : array 1 .. 1 of ladder %size = number of ladders in level
ladders( 1 ).x1 := 16
ladders( 1 ).y1 := 653
ladders( 1 ).x2 := 31
ladders( 1 ).y2 := 401 %Far left of the level

var chars : array char of boolean
var lastChars : array char of boolean %For keyboard input

/***********
 *Procedures*
 *Functions**
 ************/
process playNoise (filename : string)
		Music.PlayFile (filename)
end playNoise
proc die
		var skeletonOne : int := Pic.FileNew ("biomenace/skeleton1.bmp")
		fork playNoise ("biomenace/sound/death.wav")
		for i : 1 .. 7
				y := i * 5 + 30
				Pic.Draw (citycentre, backX, backY, picCopy)
				Pic.Draw (skeletonOne, x, y, picMerge)
				View.Update
				delay (DELAY)
				cls
		end for
		for decreasing i : 6 .. 1
				y := i * 5 + 30
				Pic.Draw (citycentre, backX, backY, picCopy)
				Pic.Draw (skeletonOne, x, y, picMerge)
				View.Update
				delay (DELAY)
				cls
		end for
		Pic.Draw (citycentre, backX, backY, picCopy)
		Pic.ScreenLoad ("biomenace/skeleton2.bmp", x, 30, picMerge)
		View.Update
		delay (1500)
		cls
end die

process playMusic
		loop
				Music.PlayFile ("biomenace/Music/downtown.mp3")
		end loop
end playMusic

%Introduction
colorback( black )
 cls
 for i : 1 .. 50
 Draw.Dot( Rand.Int( 1, maxx ), Rand.Int( 1, maxy ), white )
 end for
 Pic.ScreenLoad( "biomenace/apogee.bmp", 250, 200, picMerge )
 Pic.Draw( stillr, 280, 200 + 45, picMerge )
 View.Update
 Music.PlayFile( "biomenace/sound/intro.wav" )
 delay( 1000 )

%play level music
fork playMusic
/*************
 *Main Program*
 *************/
loop
		%Input
		lastChars := chars %The keys that were pressed during the last iteration
		Input.KeyDown (chars)
		if chars (KEY_ESC) then
				die
				exit
		end if
		tempX := x
		for i : 1 .. upper (purpleEnemies)
				purpleEnemies (i).tempX := purpleEnemies (i).x
		end for
		if chars (KEY_LEFT_ARROW) then
				x := x - WALKING_SPEED
				walking := true
				direction := "left"
		end if
		if chars (KEY_RIGHT_ARROW) then
				x := x + WALKING_SPEED
				walking := true
				direction := "right"
		end if
		if chars (KEY_CTRL) then
				jumping := true
		end if
		if chars (KEY_DOWN_ARROW) then
				crouching := true
		end if
		if chars (KEY_ALT) then
				if shotImage = 1 then
						shotImage := 2
				else
						shotImage := 1
				end if
				if shotImage = 2 or not lastChars (' ') then
						fork playNoise ("biomenace/sound/shot3.wav")
				end if
				shooting := true
		end if
		%Ladders


		%Scrolling background
		if (x > 340) and (abs (backX) + WALKING_SPEED < Pic.Width (citycentre) - maxx) then
				x := tempX
				backX -= WALKING_SPEED
		end if
		if (x < 300) and (abs (backX) > 0) then
				x := tempX
				backX += WALKING_SPEED
		end if

		if (x > maxx - Pic.Width ( ^imageToBlit)) then
				x := maxx - Pic.Width ( ^imageToBlit)
		end if
		if (x < 0) then
				x := 0
		end if


		%Getting the purple enemies to move
		for i : 1 .. upper (purpleEnemies)
				if (x - purpleEnemies (i).x - backX < 35 and x - purpleEnemies (i).x - backX > 0) and purpleEnemies (i).canJump and not purpleEnemies (i).attacking then
						purpleEnemies (i).attacking := true
						purpleEnemies (i).canJump := false
						purpleEnemies (i).x := purpleEnemies (i).x + purpleEnemies (i).jumpingSpeedX
						purpleEnemies (i).y := purpleEnemies (i).y + purpleEnemies (i).jumpingSpeed
						purpleEnemies (i).jumpingSpeed := purpleEnemies (i).jumpingSpeed - GRAVITY
						^ (purpleEnemies (i).image) := purpr3
				end if
				if (purpleEnemies (i).x - backX - x < 35 and purpleEnemies (i).x - backX - x > 0) and purpleEnemies (i).canJump and not purpleEnemies (i).attacking then
						purpleEnemies (i).attacking := true
						purpleEnemies (i).canJump := false
						purpleEnemies (i).x := purpleEnemies (i).x - purpleEnemies (i).jumpingSpeedX
						purpleEnemies (i).y := purpleEnemies (i).y + purpleEnemies (i).jumpingSpeed
						purpleEnemies (i).jumpingSpeed := purpleEnemies (i).jumpingSpeed - GRAVITY
						^ (purpleEnemies (i).image) := purpl3
				end if

				if not purpleEnemies (i).attacking then
						if (purpleEnemies (i).x + backX > x) then
								purpleEnemies (i).x := purpleEnemies (i).x - ENEMY_SPEED
								purpleEnemies (i).direction := "left"
						end if
						if (purpleEnemies (i).x + backX < x) then
								purpleEnemies (i).x := purpleEnemies (i).x + ENEMY_SPEED
								purpleEnemies (i).direction := "right"
						end if
						if (purpleEnemies (i).imageNumber = 1) then
								purpleEnemies (i).imageNumber := 2
						elsif (purpleEnemies (i).imageNumber = 2) then
								purpleEnemies (i).imageNumber := 1
						end if
						if (purpleEnemies (i).direction = "right" and not purpleEnemies (i).attacking) then
								if (purpleEnemies (i).imageNumber = 1) then
										^ (purpleEnemies (i).image) := purpr2
								else
										^ (purpleEnemies (i).image) := purpr1
								end if
						end if
						if (purpleEnemies (i).direction = "left" and not purpleEnemies (i).attacking) then
								if (purpleEnemies (i).imageNumber = 1) then
										^ (purpleEnemies (i).image) := purpl2
								else
										^ (purpleEnemies (i).image) := purpl1
								end if
						end if
				end if

		end for


		/*********************************
		*Getting the proper image to blit*
		*********************************/
		if crouching then
				if direction = "right" then
						^imageToBlit := crouchshootr (1)
				else
						^imageToBlit := crouchshootl (1)
				end if
				if shooting then
						if direction = "right" then
								^imageToBlit := crouchshootr (shotImage)
						else
								^imageToBlit := crouchshootl (shotImage)
						end if
				end if
				x := tempX
		end if

		if shooting and not crouching and direction = "right" then
				^imageToBlit := shootingr (shotImage)
				if not jumping then
						x := tempX
				end if
		elsif shooting and not crouching and direction = "left" then
				^imageToBlit := shootingl (shotImage)
				if not jumping then
						x := tempX
				end if
		end if

		if jumping then
				if direction = "right" then
						y := y + jumpingSpeed
						jumpingSpeed := jumpingSpeed - GRAVITY
						^imageToBlit := jumpr
				else
						y := y + jumpingSpeed
						jumpingSpeed := jumpingSpeed - GRAVITY
						^imageToBlit := jumpl
				end if
				if shooting then
						if shotImage = 2 then
								if direction = "right" then
										^imageToBlit := jumpshotr
								elsif direction = "left" then
										^imageToBlit := jumpshotl
								end if
						end if
				end if
		end if

		if direction = "right" and not shooting and walking then
				if not jumping then
						if walkImage = 3 then
								^imageToBlit := walkingr (3)
								walkImage := 4
						elsif walkImage = 4 then
								^imageToBlit := walkingr (2)
								walkImage := 3
						end if
				end if
		end if
		if direction = "left" and not shooting and not jumping and walking then
				if not jumping then
						if walkImage = 3 then
								^imageToBlit := walkingl (3)
								walkImage := 4
						elsif walkImage = 4 then
								^imageToBlit := walkingl (2)
								walkImage := 3
						end if
				end if
		end if

		if not shooting and not walking and not jumping and not crouching then
				if direction = "right" then
						^imageToBlit := stillr
				else
						^imageToBlit := stilll
				end if
				shotImage := 1
		end if


		%Shooting the purple enemies
		for i : 1 .. upper (purpleEnemies)
				if y = platformY and ( ^imageToBlit = crouchshootr (1) or ^imageToBlit = crouchshootr (2) or ^imageToBlit = crouchshootl (1) or ^imageToBlit = crouchshootl (2)) and shooting and
								purpleEnemies (i).x < maxx - 5 - backX then
						if direction = "right" and purpleEnemies (i).x + backX > x then
								new deadGuys, upper (deadGuys) + 1
								deadGuys (upper (deadGuys)).deadX := purpleEnemies (i).x
								deadGuys (upper (deadGuys)).deadY := purpleEnemies (i).y
								deadGuys (upper (deadGuys)).startTime := Time.Elapsed
								purpleEnemies (i) := purpleEnemies (upper (purpleEnemies))
								new purpleEnemies, upper (purpleEnemies) - 1
								exit
						end if
						if direction = "left" and purpleEnemies (i).x + backX < x then
								new deadGuys, upper (deadGuys) + 1
								deadGuys (upper (deadGuys)).deadX := purpleEnemies (i).x
								deadGuys (upper (deadGuys)).deadY := purpleEnemies (i).y
								deadGuys (upper (deadGuys)).startTime := Time.Elapsed
								purpleEnemies (i) := purpleEnemies (upper (purpleEnemies))
								new purpleEnemies, upper (purpleEnemies) - 1
								exit
						end if
				end if
		end for

		%Check to see if the dead objects should still be there
		for i : 1 .. upper (deadGuys)
				if Time.Elapsed - deadGuys (i).startTime > 2000 then
						deadGuys (i) := deadGuys (upper (deadGuys))
						new deadGuys, upper (deadGuys) - 1
						exit
				end if
		end for

		%Drawing
		Pic.Draw (citycentre, backX, backY, picCopy)
		%Blit dead poos
		for i : 1 .. upper (deadGuys)
				Pic.Draw (deathpoo, deadGuys (i).deadX + backX, deadGuys (i).deadY, picMerge)
		end for
		%Blit purple enemies
		for i : 1 .. upper (purpleEnemies)
				Pic.Draw ( ^ (purpleEnemies (i).image), purpleEnemies (i).x + backX, purpleEnemies (i).y, picMerge)
		end for
		%Blit bio-menace character
		if shooting and crouching and direction = "left" and shotImage = 2 then
				Pic.Draw (crouchshootl (shotImage), x - (Pic.Width (crouchshootl (2)) - Pic.Width (crouchshootl (1))), y, picMerge)
		elsif shooting and direction = "left" and not jumping then
				Pic.Draw ( ^imageToBlit, x - (Pic.Width (shootingl (shotImage)) - Pic.Width (stilll)), y, picMerge)
		elsif shooting and jumping and direction = "left" and shotImage = 2 then
				Pic.Draw ( ^imageToBlit, x - (Pic.Width (jumpshotl) - Pic.Width (jumpl)), y, picMerge)
		else
				Pic.Draw ( ^imageToBlit, x, y, picMerge)
		end if
		View.Update


		%Finishing up the loop
		shooting := false
		walking := false
		crouching := false
		if jumping and y = platformY then
				jumpingSpeed := JUMPING_SPEED
				platformY := y
				jumping := false
		end if
		for i : 1 .. upper (purpleEnemies)
				if purpleEnemies (i).startTime not= 0 then
						if Time.Elapsed - purpleEnemies (i).startTime > 4000 then
								purpleEnemies (i).startTime := 0
								purpleEnemies (i).canJump := true
						end if
				end if
				if purpleEnemies (i).attacking and y = platformY then
						purpleEnemies (i).jumpingSpeed := ENEMY_JUMPING_SPEED
						purpleEnemies (i).y := platformY
						purpleEnemies (i).attacking := false
						purpleEnemies (i).canJump := false
						purpleEnemies (i).startTime := Time.Elapsed
				end if
		end for
		delay (DELAY)
		cls

end loop


