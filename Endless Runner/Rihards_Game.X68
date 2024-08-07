*
* Title      : Endless Runner
* Written by : Rihards Ozols C00281617
* Date       : 08/03/2024
* Description: Endless Runner Project 1 Press Space and Then Enter to start
*space to jump. bonus available if reached ceartain scores
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

*-----------------------------------------------------------
* Section       : Trap Codes
* Description   : Trap Codes used throughout StarterKit
*-----------------------------------------------------------
* Trap CODES
TC_SCREEN   EQU         33          ; Screen size information trap code
TC_S_SIZE   EQU         00          ; Places 0 in D1.L to retrieve Screen width and height in D1.L
TC_KEYCODE  EQU         19          ; Check for pressed keys
TC_DBL_BUF  EQU         92          ; Double Buffer Screen Trap Code
TC_CURSR_P  EQU         11          ; Trap code cursor position
TC_EXIT     EQU         09          ; Exit Trapcode

*-----------------------------------------------------------
* Section       : Charater Setup
* Description   : Size of Player and Enemy and properties
* of these characters e.g Starting Positions and Sizes
*-----------------------------------------------------------
PLYR_W_INIT EQU         10          ; Players initial Width
PLYR_H_INIT EQU         06          ; Players initial Height

PLYR_DFLT_V EQU        -20          ; Default Player Velocity
PLYR_JUMP_V EQU        -15          ; Player Jump Velocity
PLYR_DFLT_G EQU         01          ; Player Default Gravity

GND_TRUE    EQU         01          ; Player on Ground True
GND_FALSE   EQU         00          ; Player on Ground False

RUN_INDEX   EQU         00          ; Player Run Sound Index  
JMP_INDEX   EQU         01          ; Player Jump Sound Index  
OPPS_INDEX  EQU         02          ; Player Opps Sound Index

ENMY_W_INIT EQU         08          ; Enemy initial Width
ENMY_H_INIT EQU         08          ; Enemy initial Height

ENMY2_W_INIT EQU        08          ; Enemy initial Width
ENMY2_H_INIT EQU        08          ; Enemy initial Height
*-----------------------------------------------------------
* Section       : Game Stats
* Description   : Points
*-----------------------------------------------------------
POINTS      EQU         01          ; Points added
LIVES       EQU         -1          ; LIVES
BONUS       EQU         03          ;BONUS   

*-----------------------------------------------------------
* Section       : Keyboard Keys
* Description   : Spacebar and Escape or two functioning keys
* Spacebar to JUMP and Escape to Exit Game
*-----------------------------------------------------------
SPACEBAR    EQU         $20         ; Spacebar ASCII Keycode
ESCAPE      EQU         $1B         ; Escape ASCII Keycode

*-----------------------------------------------------------
* Subroutine    : Initialise
* Description   : Initialise game data into memory such as 
* sounds and screen size
*-----------------------------------------------------------
INITIALISE:


    ; Screen Size
    MOVE.B  #TC_SCREEN, D0          ; access screen information
    MOVE.L  #TC_S_SIZE, D1          ; placing 0 in D1 triggers loading screen size information
    TRAP    #15                     ; interpret D0 and D1 for screen size
    MOVE.W  D1,         SCREEN_H    ; place screen height in memory location
    SWAP    D1                      ; Swap top and bottom word to retrive screen size
    MOVE.W  D1,         SCREEN_W    ; place screen width in memory location

    ; Place the Player at the center of the screen
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on X Axis
    MOVE.L  D1,         PLAYER_X    ; Players X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Players Y Position

    ; Initialise Player Score
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1          ; Init Score
    MOVE.L  D1,         PLAYER_SCORE
    
    ; Initialise Player Lives
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #03,        D1          ; Init Score
    MOVE.L  D1,         PLAYER_LIVES

    ; Initialise Player Velocity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.B  #PLYR_DFLT_V,D1         ; Init Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY

    ; Initialise Player Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #PLYR_DFLT_G,D1         ; Init Player Gravity
    MOVE.L  D1,         PLYR_GRAVITY

    ; Initialize Player on Ground
    MOVE.L  #GND_TRUE,  PLYR_ON_GND ; Init Player on Ground

    ; Initial Position for Enemy
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY_Y     ; Enemy Y Position
    
    ; Initial Position for Enemy2
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY2_X     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    MOVE.L   #200,      D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY2_Y    ; Enemy Y Position
    

    ; Enable the screen back buffer
	MOVE.B  #TC_DBL_BUF,D0      ; 92 Enables Double Buffer
    MOVE.B  #17,        D1          ; Combine Tasks
	TRAP	#15                 ; Trap (Perform action)
	
	    ; Enable the screen back buffer(see easy 68k help)
	MOVE.B  #TC_DBL_BUF,D0      ; 92 Enables Double Buffer
    MOVE.B  #17,        D1          ; Combine Tasks
	TRAP	#15                 ; Trap (Perform action)


    ; Clear the screen (see easy 68k help)
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W  #$FF00,     D1      ; Fill Screen Clear
	TRAP	#15                 ; Trap (Perform action)

    BSR    WELCOME                  ; BRANCH TO THE WELCOME SUBROUTINE
    BRA    GAMELOOP                 ; BRANCH TO THE WELCOME SUBROUTINE


WELCOME:
    BSR     ENDL
    LEA     MESSAGE,A1  ; ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          	   ; MOVE LITERAL 14 TO DO
    TRAP    #15             	   ; TRAP AND INTERPRET VALUE IN D0
    MOVE.B  #4,D0
    TRAP    #15
    RTS      




*-----------------------------------------------------------
* Subroutine    : Game
* Description   : Game including main GameLoop. GameLoop is like
* a while loop in that it runs forever until interupted
* (Input, Update, Draw). The Enemies Run at Player Jump to Avoid
*-----------------------------------------------------------

ENDL:
    MOVEM.L D0/A1,-(A7)
    MOVE    #14,D0
    LEA     CRLF,A1
    TRAP    #15
    MOVEM.L (A7)+,D0/A1
    RTS


    
GAMELOOP:
    ; Main Gameloop
    BSR     INPUT                   ; Check Keyboard Input
    BSR     UPDATE                  ; Update positions and points
    BSR     IS_PLAYER_ON_GND        ; Check if player is on ground
    BSR     CHECK_COLLISIONS        ; Check for Collisions on enemy 1
    BSR     CHECK_COLLISIONS2       ; Check for Collisions on enemy 2
    BSR     DRAW                    ; Draw the Scene
    BRA     GAMELOOP                ; Loop back to GameLoop

*-----------------------------------------------------------
* Subroutine    : Delay loops
* Description   : Slow game down
*-----------------------------------------------------------


DELAY3:
    MOVE.W  #5000,         D3       ;  delay counter set to 2000 
    BSR     DELAY_LOOP              ; Branch to delay loop
    RTS    

DELAY2:
    MOVE.W  #2000,         D3       ; delay counter set to 500 
    BSR     DELAY_LOOP              ; Branch to delay loop
    RTS    
  
  
DELAY:
    MOVE.W  #2250,         D3       ; delay counter set to 1250
    BSR     DELAY_LOOP              ; Branch to delay loop
    RTS 

DELAY_LOOP:
    SUBQ.W  #1,             D3      ; Decrement the delay counter
    BGT     DELAY_LOOP              ; If counter is greater than 0, continue looping
    RTS

*-----------------------------------------------------------
* Subroutine    : Input
* Description   : Process Keyboard Input
*-----------------------------------------------------------
INPUT:
    ; Process Input
    CLR.L   D1                      ; Clear Data Register
    MOVE.B  #TC_KEYCODE,D0          ; Listen for Keys
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  D1,         D2          ; Move last key D1 to D2
    CMP.B   #00,        D2          ; Key is pressed
    BEQ     PROCESS_INPUT           ; Process Key
    TRAP    #15                     ; Trap for Last Key
    ; Check if key still pressed
    CMP.B   #$FF,       D1          ; Is it still pressed
    BEQ     PROCESS_INPUT           ; Process Last Key
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Process Input
* Description   : Branch based on keys pressed
*-----------------------------------------------------------
PROCESS_INPUT:
    MOVE.L  D2,         CURRENT_KEY ; Put Current Key in Memory
    CMP.L   #ESCAPE,    CURRENT_KEY ; Is Current Key Escape
    BEQ     EXIT                    ; Exit if Escape
    CMP.L   #SPACEBAR,  CURRENT_KEY ; Is Current Key Spacebar
    BEQ     JUMP                    ; Jump
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Update
* Description   : Main update loop update Player and Enemies
*-----------------------------------------------------------
UPDATE:
    ; Update the Players Positon based on Velocity and Gravity
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.L  PLYR_VELOCITY, D1           ; Fetch Player Velocity
    MOVE.L  PLYR_GRAVITY, D2            ; Fetch Player Gravity
    ADD.L   D2,         D1              ; Add Gravity to Velocity
    MOVE.L  D1,         PLYR_VELOCITY   ; Update Player Velocity
    ADD.L   PLAYER_Y,   D1              ; Add Velocity to Player
    MOVE.L  D1,         PLAYER_Y        ; Update Players Y Position
    BSR MOVE1                           ; Branch to enemy1 movement
    BSR MOVE2                           ; Branch to enemy1 movement
    
    RTS 
    
MOVE1:
    ; Move the Enemy
    CLR.L   D1                          ; Clear the contents of D0
    MOVE.L  ENEMY_X,    D1              ; Move the Enemy X Position to D0
    CMP.L   #00,        D1              ; Compare 0 to enemy x
    BLE     RESET_ENEMY_POSITION        ; Reset Clear contents of D1 (XOR is faster)
    CLR.L   D1                          ; Enemy if off Screen
    BRA     MOVE_ENEMY                  ; Move the Enemy


MOVE2:   
    ; Move the Enemy2
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    CLR.L   D1                          ; Clear the contents of D0
    MOVE.L  ENEMY2_X,    D1             ; Move the Enemy X Position to D0
    CMP.L   #00,        D1              ; Compare 0 to enemy2 x
    BLE     RESET_ENEMY2_POSITION       ; Reset Enemy if off Screen
    BRA     MOVE_ENEMY2                 
                             

*-----------------------------------------------------------
* Subroutine    : Move Enemy
* Description   : Move Enemy Right to Left
*-----------------------------------------------------------
MOVE_ENEMY:
    SUB.L   #05,        ENEMY_X     	; Move enemy by X Value  
    RTS
    
 
MOVE_ENEMY2:
    SUB.L   #04,        ENEMY2_X     	; Move enemy by X Value         
    RTS
   


*-----------------------------------------------------------
* Subroutine    : Reset Enemy
* Description   : Reset Enemy if to passes 0 to Right of Screen
*-----------------------------------------------------------
RESET_ENEMY_POSITION:
    CLR.L   D1                      ; Clear contents of D1
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    RTS
    
RESET_ENEMY2_POSITION:
    CLR.L   D1                      ; Clear contents of D1
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY2_X    ; Enemy2 X Position
    RTS

*-----------------------------------------------------------
* Subroutine    : Draw
* Description   : Draw Screen
*-----------------------------------------------------------
DRAW: 
    ; Enable back buffer
    MOVE.B  #94,        D0
    TRAP    #15

    ; Clear the screen
    MOVE.B	#TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W	#$FF00,     D1          ; Clear contents
	TRAP    #15                     ; Trap (Perform action)

    BSR     DRAW_BACK
    BSR     DRAW_PLYR_DATA          	; Draw Draw Score, HUD, Player X and Y
    BSR     DRAW_PLAYER             	; Draw Player
    BSR     DRAW_ENEMY              	; Draw Enemy
    BSR     DRAW_ENEMY
    BSR     DELAY
    RTS                             	; Return to subroutine


DRAW_BACK:


   MOVE.B   #81, D0   Fill colour 
   MOVE.L   #GRAY, D1 
   TRAP     #15 

   MOVE.L   #0, D1                   	; X-coordinate start position
   MOVE.L   #0, D2                   	; Y-coordinate start position
   MOVE.L   #640, D3                 	; X-coordinate end position
   MOVE.L   #480, D4                 	; Y-coordinate end position
   MOVE.B   #87, D0                  	; Draw a line
   TRAP     #15
   
   MOVE.B   #81, D0   Fill colour  
   MOVE.L   #BLACK, D1 
   TRAP     #15                       	; Call to set color
   
   ;  Center line 
   MOVE.L   #0, D1                  	; X-coordinate start position
   MOVE.L   #248, D2                	; Y-coordinate start position
   MOVE.L   #660, D3                	; X-coordinate end position 
   MOVE.L   #10, D4                	; Y-coordinate end position
   MOVE.L   #87, D0                 	; Draw a line
   TRAP   #15 

*-----------------------------------------------------------
* Subroutine    : Draw Player Data
* Description   : Draw Player X, Y, Velocity, Gravity and OnGround
*-----------------------------------------------------------
DRAW_PLYR_DATA:
    CLR.L   D1                      	; Clear contents of D1 (XOR is faster)

    ; Player Score Message
    MOVE.B  #TC_CURSR_P,D0          	; Set Cursor Position
    MOVE.W  #$0201,     D1          	; Col 02, Row 01
    TRAP    #15                     	; Trap (Perform action)
    LEA     SCORE_MSG,  A1          	; Score Message
    MOVE    #13,        D0          	; No Line feed
    TRAP    #15                     	; Trap (Perform action)

    ; Player Score Value
    MOVE.B  #TC_CURSR_P,D0          	; Set Cursor Position
    MOVE.W  #$0901,     D1          	; Col 09, Row 01
    TRAP    #15                     	; Trap (Perform action)
    MOVE.B  #03,        D0         	; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         	; Move Score to D1.L
    TRAP    #15                     	; Trap (Perform action)
    
    ; Player X Message
    MOVE.B  #TC_CURSR_P,D0          	; Set Cursor Position
    MOVE.W  #$0202,     D1          	; Col 02, Row 02
    TRAP    #15                     	; Trap (Perform action)
    LEA     X_MSG,      A1          	; X Message
    MOVE    #13,        D0          	; No Line feed
    TRAP    #15                     	; Trap (Perform action)
    
    ; Player X
    MOVE.B  #TC_CURSR_P, D0          	; Set Cursor Position
    MOVE.W  #$0502,     D1          	; Col 05, Row 02
    TRAP    #15                     	; Trap (Perform action)
    MOVE.B  #03,        D0          	; Display number at D1.L
    MOVE.L  PLAYER_X,   D1          	; Move X to D1.L
    TRAP    #15                     	; Trap (Perform action)
    
    ; Player Lives Message
    MOVE.B  #TC_CURSR_P,D0          	; Set Cursor Position
    MOVE.W  #$1201,     D1          	; Col 12, Row 01
    TRAP    #15                     	; Trap (Perform action)
    LEA     LIVES_MSG,  A1          	; X Message
    MOVE    #13,        D0          	; No Line feed
    TRAP    #15                     	; Trap (Perform action)
    
    ; Player lives
    MOVE.B  #TC_CURSR_P, D0          	; Set Cursor Position
    MOVE.W  #$1901,     D1          	; Col 19, Row 01
    TRAP    #15                     	; Trap (Perform action)
    MOVE.B  #3,         D0          	; Display number at D1.L
    MOVE.L  PLAYER_LIVES,   D1          ; Move LIVES to D1.L
    TRAP    #15                     	; Trap (Perform action)
    
    ; Player Y Message
    MOVE.B  #TC_CURSR_P,D0          	; Set Cursor Position
    MOVE.W  #$1002,     D1          	; Col 10, Row 02
    TRAP    #15                     	; Trap (Perform action)
    LEA     Y_MSG,      A1          	; Y Message
    MOVE    #13,        D0          	; No Line feed
    TRAP    #15                     	; Trap (Perform action)
    
    ; Player Y
    MOVE.B  #TC_CURSR_P,D0         	; Set Cursor Position
    MOVE.W  #$1202,     D1          	; Col 12, Row 02
    TRAP    #15                     	; Trap (Perform action)
    MOVE.B  #03,        D0          	; Display number at D1.L
    MOVE.L  PLAYER_Y,   D1          	; Move X to D1.L
    TRAP    #15                     	; Trap (Perform action) 

    ; Player Velocity Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0203,     D1          ; Col 02, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     V_MSG,      A1          ; Velocity Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Velocity
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0503,     D1          ; Col 05, Row 03
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_VELOCITY,D1        ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Gravity Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1003,     D1          ; Col 10, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     G_MSG,      A1          ; G Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Gravity
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1203,     D1          ; Col 12, Row 03
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_GRAVITY,D1         ; Move Gravity to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; Player On Ground Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0204,     D1          ; Col 10, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     GND_MSG,    A1          ; On Ground Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player On Ground
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0604,     D1          ; Col 06, Row 04
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_ON_GND,D1          ; Move Play on Ground ? to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; Show Keys Pressed
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2001,     D1          ; Col 18, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     KEYCODE_MSG, A1         ; Keycode
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Show KeyCode
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$3001,     D1          ; Col 30, Row 1
    TRAP    #15                     ; Trap (Perform action)    
    MOVE.L  CURRENT_KEY,D1          ; Move Key Pressed to D1
    MOVE.B  #03,        D0          ; Display the contents of D1
    TRAP    #15                     ; Trap (Perform action)

    RTS  
    
*-----------------------------------------------------------
* Subroutine    : Player is on Ground
* Description   : Check if the Player is on or off Ground
*-----------------------------------------------------------
IS_PLAYER_ON_GND:
    ; Check if Player is on Ground
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D2                      ; Clear contents of D2 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  PLAYER_Y,   D2          ; Player Y Position
    CMP     D1,         D2          ; Compare middle of Screen with Players Y Position 
    BGE     SET_ON_GROUND           ; The Player is on the Ground Plane
    BLT     SET_OFF_GROUND          ; The Player is off the Ground
    RTS                             ; Return to subroutine


*-----------------------------------------------------------
* Subroutine    : On Ground
* Description   : Set the Player On Ground
*-----------------------------------------------------------
SET_ON_GROUND:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Reset the Player Y Position
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1          ; Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Set Player Velocity
    MOVE.L  #GND_TRUE,  PLYR_ON_GND ; Player is on Ground
    RTS

*-----------------------------------------------------------
* Subroutine    : Off Ground
* Description   : Set the Player Off Ground
*-----------------------------------------------------------
SET_OFF_GROUND:
    MOVE.L  #GND_FALSE, PLYR_ON_GND     ; Player if off Ground
    RTS                                 ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Jump
* Description   : Perform a Jump
*-----------------------------------------------------------
JUMP:
    CMP.L   #GND_TRUE,PLYR_ON_GND       ; Player is on the Ground ?
    BEQ     PERFORM_JUMP                ; Do Jump
    BRA     JUMP_DONE               
PERFORM_JUMP:
    MOVE.L  #PLYR_JUMP_V,PLYR_VELOCITY  ; Set the players velocity to true
    BSR     DELAY3
    RTS                                 ; Return to subroutine
JUMP_DONE:
    RTS                                 ; Return to subroutine


*-----------------------------------------------------------
* Subroutine    : Draw Player
* Description   : Draw Player Square
*-----------------------------------------------------------
DRAW_PLAYER:
    ; Set Pixel Colors
    MOVE.L  #WHITE,     D1          	; Set Background color
    MOVE.B  #80,        D0          	; Task for Background Color
    TRAP    #15                     	; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  PLAYER_X,   D1          	; X
    MOVE.L  PLAYER_Y,   D2          	; Y
    MOVE.L  PLAYER_X,   D3
    ADD.L   #PLYR_W_INIT,   D3      	; Width
    MOVE.L  PLAYER_Y,   D4 
    ADD.L   #PLYR_H_INIT,   D4      	; Height
    
    ; Draw Player
    MOVE.B  #87,        D0          	; Draw Player
    TRAP    #15                     	; Trap (Perform action)
    RTS                             	; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Enemy
* Description   : Draw Enemy Square
*-----------------------------------------------------------

DRAW_ENEMY:
    ; Set Pixel Colors
    MOVE.L  #RED,       D1          	; Set Background color
    MOVE.B  #80,        D0          	; Task for Background Color
    TRAP    #15                     	; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  ENEMY_X,    D1          	; X
    MOVE.L  ENEMY_Y,    D2          	; Y
    MOVE.L  ENEMY_X,    D3
    ADD.L   #ENMY_W_INIT,   D3      	; Width
    MOVE.L  ENEMY_Y,    D4 
    ADD.L   #ENMY_H_INIT,   D4      	; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          	; Draw Enemy
    TRAP    #15                     	; Trap (Perform action)
                                
DRAW_ENEMY2:    
    ; Set Pixel Colors
    MOVE.L  #RED,       D1          	; Set Background color
    MOVE.B  #80,        D0          	; Task for Background Color
    TRAP    #15                     	; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  ENEMY2_X,    D1          	; X
    MOVE.L  ENEMY2_Y,    D2          	; Y
    MOVE.L  ENEMY2_X,    D3
    ADD.L   #ENMY2_W_INIT,   D3      	; Width
    MOVE.L  ENEMY2_Y,    D4 
    ADD.L   #ENMY2_H_INIT,   D4      	; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          	; Draw Enemy
    TRAP    #15                     	; Trap (Perform action)
    RTS                             	; Return to subroutin

*-----------------------------------------------------------
* Subroutine    : Collision Check FOR ENEMY 2   
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* Enemy rectangles
* PLAYER_X <= ENEMY2_X + ENEMY2_W &&
* PLAYER_X + PLAYER_W >= ENEMY2_X &&
* PLAYER_Y <= ENEMY2_Y + ENEMY2_H &&
* PLAYER_H + PLAYER_Y >= ENEMY2_Y

*-----------------------------------------------------------
CHECK_COLLISIONS2:
    CLR.L   D1                              ; Clear D1
    CLR.L   D2                              ; Clear D2
    
    
PLAYER_X_LTE_TO_ENEMY2_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1                  ; Move Player X to D1
    MOVE.L  ENEMY2_X,    D2                 ; Move Enemy X to D2
    ADD.L   ENMY2_W_INIT,D2                 ; Set Enemy width X + Width
    CMP.L   D1,         D2                  ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY2_X ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE            ; If not no collision
    
    
PLAYER_X_PLUS_W_LTE_TO_ENEMY2_X:       
    ADD.L   PLYR_W_INIT,D1                  ; Move Player Width to D1
    MOVE.L  ENEMY2_X,    D2                 ; Move Enemy X to D2
    CMP.L   D1,         D2                  ; Do they OverLap ?
    BGE     PLAYER_Y_LTE_TO_ENEMY2_Y_PLUS_H ; More than or Equal
    BRA     COLLISION_CHECK_DONE            ; If not no collision  

 
PLAYER_Y_LTE_TO_ENEMY2_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,   D1                  ; Move Player Y to D1
    MOVE.L  ENEMY2_Y,    D2                 ; Move Enemy Y to D2
    ADD.L   ENMY_H_INIT,D2                  ; Set Enemy Height to D2
    CMP.L   D1,         D2                  ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY2_Y ; Less than or Equal
    BRA     COLLISION_CHECK_DONE            ; If not no collision 
    
    
PLAYER_Y_PLUS_H_LTE_TO_ENEMY2_Y:     
    ADD.L   PLYR_H_INIT,D1                  ; Add Player Height to D1
    MOVE.L  ENEMY2_Y,    D2                 ; Move Enemy Height to D2  
    CMP.L   D1,         D2                  ; Do they OverLap ?
    BGE     COLLISION                       ; Collision !
    BRA     COLLISION_CHECK_DONE            ; If not no collision-->
    
*-----------------------------------------------------------
* Subroutine    : Collision Check ENEMY 1
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* Enemy rectangles
* PLAYER_X <= ENEMY_X + ENEMY_W &&
* PLAYER_X + PLAYER_W >= ENEMY_X &&
* PLAYER_Y <= ENEMY_Y + ENEMY_H &&
* PLAYER_H + PLAYER_Y >= ENEMY_Y
*-----------------------------------------------------------


CHECK_COLLISIONS:
    CLR.L   D1                              ; Clear D1
    CLR.L   D2                              ; Clear D2
    
    
PLAYER_X_LTE_TO_ENEMY_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1                  ; Move Player X to D1
    MOVE.L  ENEMY_X,    D2                  ; Move Enemy X to D2
    ADD.L   ENMY_W_INIT,D2                  ; Set Enemy width X + Width
    CMP.L   D1,         D2                  ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE            ; If not no collision
    
    
PLAYER_X_PLUS_W_LTE_TO_ENEMY_X:             ; Check player is not  
    ADD.L   PLYR_W_INIT,D1                  ; Move Player Width to D1
    MOVE.L  ENEMY_X,    D2                  ; Move Enemy X to D2
    CMP.L   D1,         D2                  ; Do they OverLap ?
    BGE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; more than or Equal
    BRA     COLLISION_CHECK_DONE            ; If not no collision  

 
PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,   D1                  ; Move Player Y to D1
    MOVE.L  ENEMY_Y,    D2                  ; Move Enemy Y to D2
    ADD.L   ENMY_H_INIT,D2                  ; Set Enemy Height to D2
    CMP.L   D1,         D2                  ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE            ; If not no collision 
    
    
PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y:             ; Less than or Equal ?
    ADD.L   PLYR_H_INIT,D1                  ; Add Player Height to D1
    MOVE.L  ENEMY_Y,    D2                  ; Move Enemy Height to D2  
    CMP.L   D1,         D2                  ; Do they OverLap ?
    BGE     COLLISION                       ; Collision !
    BRA     COLLISION_CHECK_DONE            ; If not no collision
    
COLLISION_CHECK_DONE:                       ; No Collision, Update points
    CLR.L   D1
    ADD.L   #POINTS,    D1                  ; Move points upgrade to D1
    ADD.L   PLAYER_SCORE,D1                 ; Add to current player score
    MOVE.L  D1, PLAYER_SCORE                ; Update player score in memory
    BSR     DELAY2
    ADD.L   #BONUS,     D2
    CMP.L   #4000,  PLAYER_SCORE            ; Bonus 1 at score : 4000
    BEQ     BONUS_LIVES
    ADD.L   #BONUS,     D2
    CMP.L   #8000,  PLAYER_SCORE            ; Bonus 2 at score : 8000
    BEQ     BONUS_LIVES
    ADD.L   #BONUS,     D2
    CMP.L   #16000,  PLAYER_SCORE           ; Bonus 3 at score : 16000
    BEQ     BONUS_LIVES
    
    RTS                                     ; Return to subroutine

COLLISION:                                  ; Collision, take away life and check game over
    CLR.L   D1
    ADD.L   #LIVES, D1
    ADD.L   D1, PLAYER_LIVES
    CMP.L   #0, PLAYER_LIVES                ; Check if player has any lives left
    BEQ     GAME_OVER  

    RTS 




*-----------------------------------------------------------
* Subroutine    : BONUS
* Description   : BONUS 1 , 2 , 3
*-----------------------------------------------------------

BONUS_LIVES:
    CLR.L   D1
    ADD.L   #BONUS,     D1
    ADD.L   D1, PLAYER_LIVES
    RTS


    
GAME_OVER:
    LEA     GAME_OVER_MSG,A1  ; ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ; MOVE LITERAL 14 TO DO
    TRAP    #15             ; TRAP AND INTERPRET VALUE IN D0
    MOVE.B  #4,D0
    TRAP    #15
    BRA     EXIT

  
                       

*-----------------------------------------------------------
* Subroutine    : EXIT
* Description   : Exit message and End Game
*-----------------------------------------------------------
EXIT:
    ; Show if Exiting is Running
    MOVE.B  #TC_CURSR_P,D0                  		; Set Cursor Position
    MOVE.W  #$4004,     D1                  		; Col 40, Row 4
    TRAP    #15                             		; Trap (Perform action)
    LEA     EXIT_MSG,   A1                  		; Exit
    MOVE    #13,        D0                  		; No Line feed
    TRAP    #15                             		; Trap (Perform action)
    MOVE.B  #TC_EXIT,   D0                  		; Exit Code
    TRAP    #15                             		; Trap (Perform action)
    SIMHALT

*-----------------------------------------------------------
* Section       : Messages
* Description   : Messages to Print on Console
*-----------------------------------------------------------
CRLF:           DC.B    $0D,$0A,0
KEYCODE_MSG         DC.B    'KeyCode : ',0         	; Keycode Message
JUMP_MSG            DC.B    'Jump....',0           	; Jump Message
IDLE_MSG            DC.B    'Idle....',0           	; Idle Message
UPDATE_MSG          DC.B    'Update....',0         	; Update Message
DRAW_MSG            DC.B    'Draw....',0           	; Draw Message
MISS_MSG            DC.B    'Nice One!,',0
SCORE_MSG           DC.B    'Score: ',0 
LIVES_MSG           DC.B    'Lives: ',0 
GAME_OVER_MSG       DC.B    'Game Over ! Lives = 0 ',0 
X_MSG               DC.B    'X:', 0                 	; X Position Message
Y_MSG               DC.B    'Y:', 0                 	; Y Position Message
V_MSG               DC.B    'V:', 0                 	; Velocity Position Message
G_MSG               DC.B    'G:', 0                 	; Gravity Position Message
GND_MSG             DC.B    'GND:', 0               	; On Ground Position Message
MESSAGE             DC.B   'Welcome to my Running Simulator',0
                    DC.B   '**********************************************************************************',0
EXIT_MSG            DC.B    'Exiting....', 0        ; Exit Message

*-----------------------------------------------------------
* Section       : Graphic Colors
* Description   : Screen Pixel Color
*-----------------------------------------------------------
WHITE               EQU         $00FFFFFF 
RED                 EQU         $000000FF
GRAY                EQU         $00808080
BLUE                EQU         $00FF0000
BLACK               EQU         $0000000


*-----------------------------------------------------------
* Section       : Screen Size
* Description   : Screen Width and Height
*-----------------------------------------------------------
SCREEN_W            DS.W        01      		; Reserve Space for Screen Width
SCREEN_H            DS.W        01      		; Reserve Space for Screen Height

*-----------------------------------------------------------
* Section       : Keyboard Input
* Description   : Used for storing Keypresses
*-----------------------------------------------------------
CURRENT_KEY         DS.L        01      		; Reserve Space for Current Key Pressed

*-----------------------------------------------------------
* Section       : Character Positions
* Description   : Player and Enemy Position Memory Locations
*-----------------------------------------------------------
PLAYER_X            DS.L        01      		; Reserve Space for Player X Position
PLAYER_Y            DS.L        01      		; Reserve Space for Player Y Position


PLYR_VELOCITY       DS.L        01      		; Reserve Space for Player Velocity
PLYR_GRAVITY        DS.L        01      		; Reserve Space for Player Gravity
PLYR_ON_GND         DS.L        01      		; Reserve Space for Player on Ground

ENEMY_X             DS.L        01      		; Reserve Space for Enemy X Position
ENEMY_Y             DS.L        01      		; Reserve Space for Enemy Y Position

ENEMY2_X            DS.L        01      		; Reserve Space for Enemy X Position
ENEMY2_Y            DS.L        01      		; Reserve Space for Enemy Y Position

*-----------------------------------------------------------
* Section       : Character Stats
* Description   : Player lives
*-----------------------------------------------------------

PLAYER_LIVES        DS.L        01      		; Reserve Space for Player Lives
PLAYER_SCORE        DS.L        01      		; Reserve Space for Player Score


    END    START                        ; last line of source



