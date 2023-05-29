
constant PADDLE_HEIGHT 5
constant PADDLE_WIDTH 1
constant BALL_RADIUS 1
constant DISPLAY_WIDTH 128
constant DISPLAY_HEIGHT 64
constant INITIAL_DELAY 1

VAR ball_x
VAR ball_y
VAR ball_dx
VAR ball_dy
VAR paddle1_y
VAR paddle2_y
VAR score1
VAR score2

CLEAR AC
CLEAR A
CLEAR B
CLEAR C

STA ball_x
STA ball_y
STA ball_dx
STA ball_dy
STA paddle1_y
STA paddle2_y
STA score1
STA score2

ADD DISPLAY_WIDTH/2
STA ball_x
ADD DISPLAY_HEIGHT/2
STA ball_y

ADD -1
STA ball_dx
ADD 1
STA ball_dy

LOOP:
    CLEAR AC
    STA LED

    PRNT paddle1_y
    RECT 0, paddle1_y, PADDLE_WIDTH, PADDLE_HEIGHT
    PRNT paddle2_y
    RECT DISPLAY_WIDTH-PADDLE_WIDTH, paddle2_y, PADDLE_WIDTH, PADDLE_HEIGHT

    PRNT ball_x
    PRNT ball_y
    CIRC ball_x, ball_y, BALL_RADIUS

    ADD ball_dx
    STA ball_x
    ADD ball_dy
    STA ball_y

    SUB paddle1_y
    JMPZ PADDLE_COLLISION_1
    SUB PADDLE_HEIGHT
    JMPZ PADDLE_COLLISION_1
    ADD paddle2_y
    SUB DISPLAY_HEIGHT
    JMPZ PADDLE_COLLISION_2
    ADD PADDLE_HEIGHT
    JMPZ PADDLE_COLLISION_2

    ADD DISPLAY_WIDTH
    JMPZ WALL_COLLISION

    ADD DISPLAY_WIDTH/2
    JMPZ SCORE_2
    ADD DISPLAY_WIDTH/2
    JMPZ SCORE_1

    WAIT INITIAL_DELAY

    JMP LOOP

PADDLE_COLLISION_1:
    INV ball_dx
    JMP LOOP

PADDLE_COLLISION_2:
    INV ball_dx
    JMP LOOP

WALL_COLLISION:
    INV ball_dy
    JMP LOOP

SCORE_1:
    ADD score1
    ADD 1
    STA score1
    JMP LOOP

SCORE_2:
    ADD score2
    ADD 1
    STA score2
    JMP LOOP
