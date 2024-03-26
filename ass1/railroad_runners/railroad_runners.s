################################################################################
# COMP1521 24T1 -- Assignment 1 -- Railroad Runners!
#
#
# !!! IMPORTANT !!!
# Before starting work on the assignment, make sure you set your tab-width to 8!
# It is also suggested to indent with tabs only.
# Instructions to configure your text editor can be found here:
#   https://cgi.cse.unsw.edu.au/~cs1521/24T1/resources/mips-editors.html
# !!! IMPORTANT !!!
#
#
# This program was written by Caitlyn Phan
# on 05/03/2024
#
# Version 1.0 (2024-02-27): Team COMP1521 <cs1521@cse.unsw.edu.au>
#
################################################################################

#![tabsize(8)]

# ------------------------------------------------------------------------------
#                                   Constants
# ------------------------------------------------------------------------------

# -------------------------------- C Constants ---------------------------------
TRUE = 1
FALSE = 0

JUMP_KEY = 'w'
LEFT_KEY = 'a'
CROUCH_KEY = 's'
RIGHT_KEY = 'd'
TICK_KEY = '\''
QUIT_KEY = 'q'

ACTION_DURATION = 3
CHUNK_DURATION = 10

SCROLL_SCORE_BONUS = 1
TRAIN_SCORE_BONUS = 1
BARRIER_SCORE_BONUS = 2
CASH_SCORE_BONUS = 3

MAP_HEIGHT = 20
MAP_WIDTH = 5
PLAYER_ROW = 1

PLAYER_RUNNING = 0
PLAYER_CROUCHING = 1
PLAYER_JUMPING = 2

STARTING_COLUMN = MAP_WIDTH / 2

TRAIN_CHAR = 't'
BARRIER_CHAR = 'b'
CASH_CHAR = 'c'
EMPTY_CHAR = ' '
WALL_CHAR = 'w'
RAIL_EDGE = '|'

SAFE_CHUNK_INDEX = 0
NUM_CHUNKS = 14

# --------------------- Useful Offset and Size Constants -----------------------

# struct BlockSpawner offsets
BLOCK_SPAWNER_NEXT_BLOCK_OFFSET = 0
BLOCK_SPAWNER_SAFE_COLUMN_OFFSET = 20
BLOCK_SPAWNER_SIZE = 24

# struct Player offsets
PLAYER_COLUMN_OFFSET = 0
PLAYER_STATE_OFFSET = 4
PLAYER_ACTION_TICKS_LEFT_OFFSET = 8
PLAYER_ON_TRAIN_OFFSET = 12
PLAYER_SCORE_OFFSET = 16
PLAYER_SIZE = 20

SIZEOF_PTR = 4


# ------------------------------------------------------------------------------
#                                 Data Segment
# ------------------------------------------------------------------------------
	.data

# !!! DO NOT ADD, REMOVE, OR MODIFY ANY OF THESE DEFINITIONS !!!

# ----------------------------- String Constants -------------------------------

print_welcome__msg_1:
	.asciiz "Welcome to Railroad Runners!\n"
print_welcome__msg_2_1:
	.asciiz "Use the following keys to control your character: ("
print_welcome__msg_2_2:
	.asciiz "):\n"
print_welcome__msg_3:
	.asciiz ": Move left\n"
print_welcome__msg_4:
	.asciiz ": Move right\n"
print_welcome__msg_5_1:
	.asciiz ": Crouch ("
print_welcome__msg_5_2:
	.asciiz ")\n"
print_welcome__msg_6_1:
	.asciiz ": Jump ("
print_welcome__msg_6_2:
	.asciiz ")\n"
print_welcome__msg_7_1:
	.asciiz "or press "
print_welcome__msg_7_2:
	.asciiz " to continue moving forward.\n"
print_welcome__msg_8_1:
	.asciiz "You must crouch under barriers ("
print_welcome__msg_8_2:
	.asciiz ")\n"
print_welcome__msg_9_1:
	.asciiz "and jump over trains ("
print_welcome__msg_9_2:
	.asciiz ").\n"
print_welcome__msg_10_1:
	.asciiz "You should avoid walls ("
print_welcome__msg_10_2:
	.asciiz ") and collect cash ("
print_welcome__msg_10_3:
	.asciiz ").\n"
print_welcome__msg_11:
	.asciiz "On top of collecting cash, running on trains and going under barriers will get you extra points.\n"
print_welcome__msg_12_1:
	.asciiz "When you've had enough, press "
print_welcome__msg_12_2:
	.asciiz " to quit. Have fun!\n"

get_command__invalid_input_msg:
	.asciiz "Invalid input!\n"

main__game_over_msg:
	.asciiz "Game over, thanks for playing 😊!\n"

display_game__score_msg:
	.asciiz "Score: "

handle_collision__barrier_msg:
	.asciiz "💥 You ran into a barrier! 😵\n"
handle_collision__train_msg:
	.asciiz "💥 You ran into a train! 😵\n"
handle_collision__wall_msg:
	.asciiz "💥 You ran into a wall! 😵\n"

maybe_pick_new_chunk__column_msg_1:
	.asciiz "Column "
maybe_pick_new_chunk__column_msg_2:
	.asciiz ": "
maybe_pick_new_chunk__safe_msg:
	.asciiz "New safe column: "

get_seed__prompt_msg:
	.asciiz "Enter a non-zero number for the seed: "
get_seed__prompt_invalid_msg:
	.asciiz "Invalid seed!\n"
get_seed__set_msg:
	.asciiz "Seed set to "

TRAIN_SPRITE:
	.asciiz "🚆"
BARRIER_SPRITE:
	.asciiz "🚧"
CASH_SPRITE:
	.asciiz "💵"
EMPTY_SPRITE:
	.asciiz "  "
WALL_SPRITE:
	.asciiz "🧱"

PLAYER_RUNNING_SPRITE:
	.asciiz "🏃"
PLAYER_CROUCHING_SPRITE:
	.asciiz "🧎"
PLAYER_JUMPING_SPRITE:
	.asciiz "🤸"

# ------------------------------- Chunk Layouts --------------------------------

SAFE_CHUNK: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, '\0',
CHUNK_1: # char[]
	.byte EMPTY_CHAR, CASH_CHAR, EMPTY_CHAR, WALL_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, BARRIER_CHAR, '\0',
CHUNK_2: # char[]
	.byte CASH_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, BARRIER_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, CASH_CHAR, '\0',
CHUNK_3: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, '\0',
CHUNK_4: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, EMPTY_CHAR, CASH_CHAR, '\0',
CHUNK_5: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, CASH_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, EMPTY_CHAR, TRAIN_CHAR, EMPTY_CHAR, EMPTY_CHAR, '\0',
CHUNK_6: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, CASH_CHAR, BARRIER_CHAR, EMPTY_CHAR, EMPTY_CHAR, CASH_CHAR, CASH_CHAR, EMPTY_CHAR, BARRIER_CHAR, '\0'
CHUNK_7: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, WALL_CHAR, WALL_CHAR, WALL_CHAR, WALL_CHAR, WALL_CHAR, WALL_CHAR, WALL_CHAR, '\0',
CHUNK_8: # char[]
	.byte CASH_CHAR, EMPTY_CHAR, CASH_CHAR, EMPTY_CHAR, CASH_CHAR, EMPTY_CHAR, CASH_CHAR, EMPTY_CHAR, CASH_CHAR, EMPTY_CHAR, '\0',
CHUNK_9: # char[]
	.byte CASH_CHAR, EMPTY_CHAR, EMPTY_CHAR, WALL_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, '\0',
CHUNK_10: # char[]
	.byte CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, '\0',
CHUNK_11: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, CASH_CHAR, WALL_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, '\0',
CHUNK_12: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, CASH_CHAR, '\0',
CHUNK_13: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, WALL_CHAR, WALL_CHAR, '\0',

CHUNKS:	# char*[]
	.word SAFE_CHUNK, CHUNK_1, CHUNK_2, CHUNK_3, CHUNK_4, CHUNK_5, CHUNK_6, CHUNK_7, CHUNK_8, CHUNK_9, CHUNK_10, CHUNK_11, CHUNK_12, CHUNK_13

# ----------------------------- Global Variables -------------------------------

g_block_spawner: # struct BlockSpawner
	# char *next_block[MAP_WIDTH], offset 0
	.word 0, 0, 0, 0, 0
	# int safe_column, offset 20
	.word STARTING_COLUMN

g_map: # char[MAP_HEIGHT][MAP_WIDTH]
	.space MAP_HEIGHT * MAP_WIDTH

g_player: # struct Player
	# int column, offset 0
	.word STARTING_COLUMN
	# int state, offset 4
	.word PLAYER_RUNNING
	# int action_ticks_left, offset 8
	.word 0
	# int on_train, offset 12
	.word FALSE
	# int score, offset 16
	.word 0

g_rng_state: # unsigned
	.word 1

# !!! Reminder to not not add to or modify any of the above !!!
# !!! strings or any other part of the data segment.        !!!

# ------------------------------------------------------------------------------
#                                 Text Segment
# ------------------------------------------------------------------------------
	.text

############################################################
####                                                    ####
####   Your journey begins here, intrepid adventurer!   ####
####                                                    ####
############################################################

################################################################################
#
# Implement the following functions,
# and check these boxes as you finish implementing each function.
#
#  SUBSET 0
#  - [ ] print_welcome
#  SUBSET 1
#  - [ ] get_command
#  - [ ] main
#  - [ ] init_map
#  SUBSET 2
#  - [ ] run_game
#  - [ ] display_game
#  - [ ] maybe_print_player
#  - [ ] handle_command
#  SUBSET 3
#  - [ ] handle_collision
#  - [ ] maybe_pick_new_chunk
#  - [ ] do_tick
#  PROVIDED
#  - [X] get_seed
#  - [X] rng
#  - [X] read_char
################################################################################

################################################################################
# .TEXT <print_welcome>
print_welcome:
	# Subset:   0
	#
	# Args:     None
	#
	# Returns:  None
	#
	# Frame:    [...]
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:
	#   - ...
	#
	# Structure:
	#   print_welcome
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

print_welcome__prologue:
print_welcome__body:
	la	$a0, print_welcome__msg_1   	# printf("Welcome to Railroad Runners!\n");	 	
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_2_1  	# printf("Use the following keys to control your character: (");	 	
	li	$v0, 4       
	syscall

	la	$a0, PLAYER_RUNNING_SPRITE   	# printf("🏃");	 	
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_2_2   	# printf("):\n");	 	
	li	$v0, 4       
	syscall

	la	$a0, LEFT_KEY  			# printf("a");	 	
	li	$v0, 11       
	syscall

	la	$a0, print_welcome__msg_3  	# printf(": Move left\n");	 	
	li	$v0, 4       
	syscall

	la	$a0, RIGHT_KEY 			# printf("d");	 	
	li	$v0, 11       
	syscall

	la	$a0, print_welcome__msg_4  	# printf(": Move right\n");	 	
	li	$v0, 4       
	syscall

	la	$a0, CROUCH_KEY			# printf("s");	 	
	li	$v0, 11       
	syscall

	la	$a0, print_welcome__msg_5_1  	# printf(": Crouch (");	 	
	li	$v0, 4       
	syscall

	la	$a0, PLAYER_CROUCHING_SPRITE	# printf("🧎");		
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_5_2  	# printf(")\n");	 	
	li	$v0, 4       
	syscall

	la	$a0, JUMP_KEY 			# printf("w");	 	
	li	$v0, 11       
	syscall

	la	$a0, print_welcome__msg_6_1  	# printf(": Jump (");	 	
	li	$v0, 4       
	syscall

	la	$a0, PLAYER_JUMPING_SPRITE	# printf("🤸");		
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_6_2  	# printf(")\n");	 	
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_7_1  	# printf("or press");	 	
	li	$v0, 4       
	syscall

	la	$a0, TICK_KEY 			# printf("\");	 	
	li	$v0, 11       
	syscall

	la	$a0, print_welcome__msg_7_2  	# printf(" to continue moving forward.\n");	 	
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_8_1  	# printf("You must crouch under barriers (");	 	
	li	$v0, 4       
	syscall

	la	$a0, BARRIER_SPRITE 		# printf("🚧"); 	
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_8_2  	# printf(")\n");	 	
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_9_1  	# printf("and jump over trains (");	 	
	li	$v0, 4       
	syscall

	la	$a0, TRAIN_SPRITE 		# printf("🚆");	
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_9_2  	# printf(").\n");	 	
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_10_1  	# printf("You should avoid walls (");	 	
	li	$v0, 4       
	syscall

	la	$a0, WALL_SPRITE 		# printf("🧱");	
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_10_2  	# printf(") and collect cash (");	 	
	li	$v0, 4       
	syscall

	la	$a0, CASH_SPRITE 		# printf("💵");	
	li	$v0, 4       
	syscall
	
	la	$a0, print_welcome__msg_10_3  	# printf(").\n");	 	
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_11  	# printf("On top of collecting cash, running on trains and going under barriers will get you extra points.\n");	 	
	li	$v0, 4       
	syscall

	la	$a0, print_welcome__msg_12_1  	# printf("When you've had enough, press ");	 	
	li	$v0, 4       
	syscall

	la	$a0, QUIT_KEY			# printf("q");	
	li	$v0, 11       
	syscall

	la	$a0, print_welcome__msg_12_2  	# printf(" to quit. Have fun!\n");	 	
	li	$v0, 4       
	syscall


print_welcome__epilogue:
	jr	$ra


################################################################################
# .TEXT <get_command>
	.text
get_command:
	# Subset:   1
	#
	# Args:     None
	#
	# Returns:  $v0: char
	#
	# Frame:    [...]
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:
	#   - $t0: char input
	#
	# Structure:
	#   get_command
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

get_command__prologue:
	begin               				# move frame pointer
    	push 	$ra            				# save $ra onto stack

get_command__body:

read_command_loop__init:
	jal	read_char				# read_char() - function call
	move	$t0, $v0				# input = returned value

read_command_loop__body:
	beq	$t0, QUIT_KEY, get_command__epilogue	# if (input == QUIT_KEY) { return input; }
	beq	$t0, JUMP_KEY, get_command__epilogue	# if (input == JUMP_KEY) { return input; }
	beq	$t0, LEFT_KEY, get_command__epilogue	# if (input == LEF_KEY) { return input; }
	beq	$t0, CROUCH_KEY, get_command__epilogue	# if (input == CROUCH_KEY) { return input; }
	beq	$t0, RIGHT_KEY, get_command__epilogue	# if (input == RIGHT_KEY) { return input; }
	beq	$t0, TICK_KEY, get_command__epilogue	# if (input == TICK_KEY) { return input; }

	la	$a0, get_command__invalid_input_msg  	# printf("Invalid input!\n");	 	
	li	$v0, 4       
	syscall

	b	read_command_loop__init			# goto read_command_loop__init;

get_command__epilogue:
	move	$v0, $t0				# return input
	pop   	$ra            				# recover $ra from stack
    	end                  				# move frame pointer back
	jr	$ra


################################################################################
# .TEXT <main>
	.text
main:
	# Subset:   1
	#
	# Args:     None
	#
	# Returns:  $v0: int
	#
	# Frame:    [...] what is being stored on the stack
	# Uses:     [...] everything that's being used, registers
	# Clobbers: [...] what is being ovewritten
	#
	# Locals:
	#   - ...
	#
	# Structure:
	#   main
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

main__prologue:
	begin               				# move frame pointer
    	push 	$ra            				# save $ra onto stack

main__body:
	jal	print_welcome				# print_welcome();
	jal	get_seed				# get_seed();
	
	li 	$a0, g_map				# init_map(g_map);
	jal	init_map

play_game_loop__body:
	li	$a0, g_map				# display_game(g_map, &g_player);
	li	$a1, g_player

	jal	display_game

play_game_loop__cond:
	jal	get_command				# get_command() argument
	move	$a3, $v0
	
	li	$a0, g_map				# run_game(g_map, &g_player, 
							# 	   &g_block_spawner, get_command())
	li	$a1, g_player
	li	$a2, g_block_spawner

	jal	run_game
	beq	$v0, 1, play_game_loop__body		# if (run_game) goto play_game_loop__body

main__epilogue:
	la	$a0, main__game_over_msg  		# printf("Game over, thanks for playing 😊!\n");	 	
	li	$v0, 4       
	syscall
	li	$v0, 0					# return 0;

	pop	$ra		
	end
	jr	$ra


################################################################################
# .TEXT <init_map>
	.text
init_map:
	# Subset:   1
	#
	# Args:
	#   - $a0: char map[MAP_HEIGHT][MAP_WIDTH]
	#
	# Returns:  None
	#
	# Frame:    [...]
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:
	#   - ...
	#
	# Structure:
	#   init_map
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

init_map__prologue:
	begin
init_map__body:
	move	$t2, $a0
height_loop__init:
	li	$t0, 0					# i = 0

height_loop__cond:
	bge	$t0, MAP_HEIGHT, on_to_map	# if (i >= MAP_HEIGHT) goto on_to_map
height_loop__body:

width_loop__init:
	li	$t1, 0					# j = 0

width_loop__cond:
	bge	$t1, MAP_WIDTH, height_loop__step 	#  if (j >= MAP_WIDTH) goto width_loop__step

width_loop__body:
	mul  	$t3, $t0, MAP_WIDTH				
	add  	$t4, $t3, $t1
	add  	$t6, $t4, $t2
	li	$t7, EMPTY_CHAR
	sb	$t7, ($t6)			# not sure what to do here to store empty_char inside the array at that index

	# if its a word instead of a byte, do 4(Nj + i)
width_loop__step:
	addi	$t1, $t1, 1				# j++ 
	b	width_loop__cond			# goto width_loop__cond

height_loop__step:
	addi	$t0, $t0, 1				# i++ 
	b	height_loop__cond			# goto height_loop__cond


on_to_map:
	li	$t8, 6
	mul  	$t3, MAP_WIDTH, $t8				
	add  	$t4, $t3, 0
	add  	$t6, $t4, $t2			
	li	$t7, WALL_CHAR
	sb	$t7, ($t6)		

	li	$t8, 6
	mul  	$t3, MAP_WIDTH, $t8				
	add  	$t4, $t3, 1
	add  	$t6, $t4, $t2	
	li	$t7, TRAIN_CHAR
	sb	$t7, ($t6)		

	li	$t8, 6
	mul  	$t3, MAP_WIDTH, $t8				
	add  	$t4, $t3, 2
	add  	$t6, $t4, $t2	
	li	$t7, CASH_CHAR
	sb	$t7, ($t6)		

	li	$t8, 8
	mul  	$t3, MAP_WIDTH, $t8				
	add  	$t4, $t3, 2
	add  	$t6, $t4, $t2	
	li	$t7, BARRIER_CHAR
	sb	$t7, ($t6)		

init_map__epilogue:
	end
	jr	$ra


################################################################################
# .TEXT <run_game>
	.text
run_game:
	# Subset:   2
	#
	# Args:
	#   - $a0: char map[MAP_HEIGHT][MAP_WIDTH]
	#   - $a1: struct Player *player
	#   - $a2: struct BlockSpawner *block_spawner
	#   - $a3: char input
	#
	# Returns:  $v0: int
	#
	# Frame:    [...]
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:
	#   - ...
	#
	# Structure:
	#   run_game
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

run_game__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2
	push	$s3

run_game__body:

    	move  	$t0, $a3       
	beq	$t0, QUIT_KEY, run_game__return_false
	move	$a3, $t0

	move  	$s0, $a0       
	move  	$s1, $a1       
	move 	$s2, $a2
	move	$s3, $a3

	jal	handle_command				# handle_command(map, player, block_spawner, input)

	move  	$a0, $s0       
	move  	$a1, $s1       

	jal	handle_collision			# handle_collision
	b	run_game__epilogue

run_game__return_false:
	li	$v0, 0
	
run_game__epilogue:
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	end

run_game__return:
	jr	$ra




################################################################################
# .TEXT <display_game>
	.text
display_game:
	# Subset:   2
	#
	# Args:
	#   - $a0: char map[MAP_HEIGHT][MAP_WIDTH]
	#   - $a1: struct Player *player
	#
	# Returns:  None
	#
	# Frame:    [...]
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:
	#   - ...
	#
	# Structure:
	#   display_game
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

display_game__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1
	push	$s2
	push	$s3
	push 	$s4
display_game__body:
	move	$s2, $a0
	move	$s3, $a1

display_height_loop__init:	
	li	$t1, 1					# int i = MAP_HEIGHT - 1
	sub	$s0, MAP_HEIGHT, $t1

display_height_loop__cond:
	bltz	$s0, display_height_loop__end		# while(i >= 0) {

display_height_loop__body:

display_width_loop__init:
	li	$s1, 0					# int j = 0

display_width_loop__cond:
	bge	$s1, MAP_WIDTH, display_width_loop__end # while (j < MAP_WIDTH) {

display_width_loop__body:
	la	$a0, RAIL_EDGE				# putchar(RAIL_EDGE)
	li	$v0, 11
	syscall

	move	$a0, $s3				# maybe_print_player(player, i , j)
	move	$a1, $s0
	move	$a2, $s1
	jal	maybe_print_player

	move	$t0, $v0 
	beq	$t0, 1, print_player_true		# if(!= TRUE) {

	mul  	$t3, $s0, MAP_WIDTH			# map_char = map[i][j]	
	add  	$t4, $t3, $s1
	add  	$t6, $t4, $s2
	lb	$t7, ($t6)
	move	$s4, $t7		

empty_sprite:
	bne	$s4, EMPTY_CHAR, barrier_sprite		# if (map_char == EMPTY_CHAR) {
	la	$a0, EMPTY_SPRITE			# printf(EMPTY_SPRITE)
	li	$v0, 4
	syscall

	b	print_player_true			# }

barrier_sprite:
	bne	$s4, BARRIER_CHAR, train_sprite		# if (map_char == EMPTY_CHAR) {
	la	$a0, BARRIER_SPRITE			# printf(BARRIER_SPRITE)
	li	$v0, 4
	syscall

	b	print_player_true			# }

train_sprite:
	bne	$s4, TRAIN_CHAR, cash_sprite		# if (map_char == TRAIN_CHAR) {
	la	$a0, TRAIN_SPRITE			# printf(TRAIN_SPRITE)
	li	$v0, 4
	syscall

	b	print_player_true			# }

cash_sprite:
	bne	$s4, CASH_CHAR, wall_sprite		# if (map_char == CASH_CHAR) {
	la	$a0, CASH_SPRITE			# printf(CASH_SPRITE)
	li	$v0, 4
	syscall

	b	print_player_true			# }

wall_sprite:
	bne	$s4, WALL_CHAR, print_player_true	# if (map_char == WALL_CHAR) {
	la	$a0, WALL_SPRITE			# printf(WALL_SPRITE)
	li	$v0, 4
	syscall						# }

print_player_true: 
	la	$a0, RAIL_EDGE				# putchar(RAIL_EDGE)
	li	$v0, 11
	syscall

display_width_loop__step:
	addi	$s1, $s1, 1				# j++
	b	display_width_loop__cond	

display_width_loop__end:
	la	$a0, '\n'				# putchar('\n')
	li	$v0, 11
	syscall						# }

display_height_loop__step:
	sub	$s0, $s0, 1				# i--
	b	display_height_loop__cond		# }

display_height_loop__end:
	la	$a0, display_game__score_msg		# printf("Score:")
	li	$v0, 4
	syscall						# 

	lw	$a0, PLAYER_SCORE_OFFSET($s3)		# printf("%d", player->column)
	li	$v0, 1
	syscall						# 

	la	$a0, '\n'				# printf("\n")
	li	$v0, 11
	syscall						# 


display_game__epilogue:
	pop	$s4
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra

	end
	jr	$ra


################################################################################
# .TEXT <maybe_print_player>
	.text
maybe_print_player:
	# Subset:   2
	#
	# Args:
	#   - $a0: struct Player *player
	#   - $a1: int row
	#   - $a2: int column
	#
	# Returns:  $v0: int
	#
	# Frame:    [...]
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:
	#   - ...
	#
	# Structure:
	#   maybe_print_player
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

maybe_print_player__prologue:
	begin
	move	$t0, $a0
	move	$t1, $a1
	move	$t2, $a2

maybe_print_player__body:
	# if (row == player &&
	bne	$t1, PLAYER_ROW, maybe_print_player__return_false # what do i do about this comment for style

	lw	$t3, PLAYER_COLUMN_OFFSET($t0)
	bne	$t2, $t3, maybe_print_player__return_false 	# column == player->column) {

if_player_running:
	lw	$t3, PLAYER_STATE_OFFSET($t0) 
	bne	$t3, PLAYER_RUNNING, if_player_crouching # same with this comment - if (player->state == PLAYER_RUNNING) {

	la	$a0, PLAYER_RUNNING_SPRITE		# printf(PLAYER_RUNNING_SPRITE) }
	li	$v0, 4
	syscall

	la	$v0, TRUE				# return TRUE;			
	b	maybe_print_player__epilogue

if_player_crouching:
	bne	$t3, PLAYER_CROUCHING, if_player_jumping # same with this comment - if (player->state == PLAYER_RUNNING) {

	la	$a0, PLAYER_CROUCHING_SPRITE		# printf(PLAYER_RUNNING_SPRITE) }
	li	$v0, 4
	syscall

	la	$v0, TRUE				# return TRUE;			
	b	maybe_print_player__epilogue

if_player_jumping:
	bne	$t3, PLAYER_JUMPING, return_true # same with this comment - if (player->state == PLAYER_RUNNING) {

	la	$a0, PLAYER_JUMPING_SPRITE		# printf(PLAYER_RUNNING_SPRITE) }
	li	$v0, 4
	syscall

return_true:
	la	$v0, TRUE				# return TRUE;			
	b	maybe_print_player__epilogue

maybe_print_player__return_false:
	la	$v0, FALSE

maybe_print_player__epilogue:
	end
	jr	$ra


################################################################################
# .TEXT <handle_command>
	.text
handle_command:
	# Subset:   2
	#
	# Args:
	#   - $a0: char map[MAP_HEIGHT][MAP_WIDTH]
	#   - $a1: struct Player *player
	#   - $a2: struct BlockSpawner *block_spawner
	#   - $a3: char input
	#
	# Returns:  None
	#
	# Frame:    [...]
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:
	#   - ...
	#
	# Structure:
	#   handle_command
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

handle_command__prologue:
	begin
	push 	$ra 

	move	$t0, $a0
	move	$t1, $a1
	move	$t2, $a2
	move	$t3, $a3
handle_command__body:
handle_command__left_key:
	bne	$t3, LEFT_KEY, handle_command__right_key# if (input == LEFT_KEY) {
	
	lw	$t4, PLAYER_COLUMN_OFFSET($t1)		# if (player->column > 0) {
	blez	$t4, handle_command__right_key

	sub	$t4, $t4, 1				# --player->column;}
	sw	$t4, PLAYER_COLUMN_OFFSET($t1)

	b	handle_command__epilogue		# )

handle_command__right_key:
	bne	$t3, RIGHT_KEY, handle_command__jump_key# if (input == RIGHT_KEY) {
	
	lw	$t4, PLAYER_COLUMN_OFFSET($t1)		# if (player->column < MAP_WIDTH - 1) {
	la	$t9, MAP_WIDTH				
	sub	$t5, $t9, 1
	bge	$t4, $t5, handle_command__jump_key

	addi	$t4, $t4, 1				# ++player->column;}
	sw	$t4, PLAYER_COLUMN_OFFSET($t1)

	b	handle_command__epilogue		# )

handle_command__jump_key:
	bne	$t3, JUMP_KEY, handle_command__crouch_key # if (input == JUMP_KEY) {

	lw	$t4, PLAYER_STATE_OFFSET($t1)		# if (player->state == PLAYER_RUNING)
	bne	$t4, PLAYER_RUNNING, handle_command__crouch_key

	la	$t9, PLAYER_JUMPING			# player->state = PLAYER_JUMPING;
	sw	$t9, PLAYER_STATE_OFFSET($t1);

	la	$t9, ACTION_DURATION			#  player->action_ticks_left = ACTION_DURATION; }
	sw	$t9, PLAYER_ACTION_TICKS_LEFT_OFFSET($t1)

	b	handle_command__epilogue		# }

handle_command__crouch_key:
	bne	$t3, CROUCH_KEY, handle_command__tick_key # if (input == CROUCH_KEY) {

	lw	$t4, PLAYER_STATE_OFFSET($t1)		# if (player->state == PLAYER_RUNING)
	bne	$t4, PLAYER_RUNNING, handle_command__tick_key

	la	$t9, PLAYER_CROUCHING			# player->state = PLAYER_CROUCHING;
	sw	$t9, PLAYER_STATE_OFFSET($t1);

	la	$t9, ACTION_DURATION			#  player->action_ticks_left = ACTION_DURATION; }
	sw	$t9, PLAYER_ACTION_TICKS_LEFT_OFFSET($t1)

	b	handle_command__epilogue		# }

handle_command__tick_key:
	bne	$t3, TICK_KEY, handle_command__epilogue # if (input == TICK_KEY) {

	move	$a0, $t0
	move	$a1, $t1
	move	$a2, $t2

	jal	do_tick					# do_tick(map, player, block_spawner); }

handle_command__epilogue:
	pop	$ra 
	end

	jr	$ra


################################################################################
# .TEXT <handle_collision>
	.text
handle_collision:
	# Subset:   3
	#
	# Args:
	#   - $a0: char map[MAP_HEIGHT][MAP_WIDTH]
	#   - $a1: struct Player *player
	#
	# Returns:  $v0: int
	#
	# Frame:    [...]
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:
	#   - ...
	#
	# Structure:
	#   handle_collision
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

handle_collision__prologue:
	begin

	move	$t0, $a0
	move	$t1, $a1
handle_collision__body:
	lw	$t2, PLAYER_COLUMN_OFFSET($t1)		# *map_char = &map[PLAYER_ROW][player->column]
	li	$t9, PLAYER_ROW
	mul  	$t7, $t9, MAP_WIDTH				
	add  	$t4, $t7, $t2
	add  	$t6, $t4, $t0
	lb	$t3, ($t6)

handle_collision__barrier:
	bne	$t3, BARRIER_CHAR, handle_collision__train # if (*map_char == BARROER_CHAR) {

	lw	$t2, PLAYER_STATE_OFFSET($t1)		# if (player->state != PLAYER_CROUCHING) {
	beq	$t2, PLAYER_CROUCHING, barrier__update_score

	la	$a0, handle_collision__barrier_msg	# printf("💥 You ran into a barrier! 😵\n");
	li	$v0, 4
	syscall

	la	$v0, FALSE				# return FALSE}
	b 	handle_collision__epilogue

barrier__update_score:
	lw	$t2, PLAYER_SCORE_OFFSET($t1)		# player->score
	add	$t2, $t2, BARRIER_SCORE_BONUS		# += BARRIER_SCORE_BONUS 
	sw	$t2, PLAYER_SCORE_OFFSET($t1)

handle_collision__train:
	bne	$t3, TRAIN_CHAR, train_else		# if (*map_char == TRAIN_CHAR) {

	lw	$t2, PLAYER_STATE_OFFSET($t1)		# if (player->state 
	beq	$t2, PLAYER_JUMPING, on_train_true	# != PLAYER_JUMPING

	lw	$t2, PLAYER_ON_TRAIN_OFFSET($t1)	# && player->on_train
	bnez	$t2, on_train_true			# != TRUE) {

	la	$a0, handle_collision__train_msg	# printf("💥 You ran into a train! 😵\n");
	li	$v0, 4
	syscall	

	li	$v0, FALSE				# return FALSE
	b	handle_collision__epilogue

on_train_true:
	li	$t9, TRUE				# player->on_train = TRUE
	sw	$t9, PLAYER_ON_TRAIN_OFFSET($t1)

not_jumping:
	beq	$t2, PLAYER_JUMPING, handle_collision__wall	# if (player->state != PLAYER_JUMPING) {

	lw	$t2, PLAYER_SCORE_OFFSET($t1)		# player->score += TRAIN_SCORE_BONUS }
	add	$t2, $t2, TRAIN_SCORE_BONUS		
	sw	$t2, PLAYER_SCORE_OFFSET($t1)

	b	handle_collision__wall			# }

train_else:						# else {
	la	$t9, FALSE
	sw	$t9, PLAYER_ON_TRAIN_OFFSET($t1)	# player->on_train = FALSE }

handle_collision__wall:
	bne	$t3, WALL_CHAR, handle_collision__cash	# if (*map_char == WALL_CHAR) {

	la	$a0, handle_collision__wall_msg		# printf("💥 You ran into a wall! 😵\n");
	li	$v0, 4
	syscall

	li	$v0, FALSE				# return FALSE 
	b	handle_collision__epilogue		# }

handle_collision__cash:
	bne	$t3, CASH_CHAR, handle_collision__return_true # if (*map_char == CASH_CHAR) {

	lw	$t2, PLAYER_SCORE_OFFSET($t1)		# player->score += CASH_STORE_BONUS
	add	$t2, $t2, CASH_SCORE_BONUS
	sw	$t2, PLAYER_SCORE_OFFSET($t1)

	la	$t9, EMPTY_CHAR				# *map_char = EMPTY_CHAR;
	sb	$t9, ($t6)				# }

handle_collision__return_true:
	la	$v0, TRUE				# return TRUE

handle_collision__epilogue:
	end
	
	jr	$ra

################################################################################
# .TEXT <maybe_pick_new_chunk>
	.text
maybe_pick_new_chunk:
	# Subset:   3
	#
	# Args:
	#   - $a0: struct BlockSpawner *block_spawner
	#
	# Returns:  None
	#
	# Frame:    [...]
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:
	#   - $s0 - struct BlockSpawner *block_spawner
	#   - $s1 - new_safe_column_required
	#   - $s2 - column
	#   - $s3 - *next_block_ptr
	#   - $s4 - **next_block_ptr
	#   - $s5 - chunk
	#
	# Structure:
	#   maybe_pick_new_chunk
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

maybe_pick_new_chunk__prologue:
	begin

	push	$ra
	push	$s0
	push	$s1
	push	$s2
	push	$s3
	push	$s4
	push	$s5
	push	$s6
	
	move	$s0, $a0
maybe_pick_new_chunk__body:
	la	$s1, FALSE				# int new_safe_column_required = FALSE

check_column_loop__init:
	li	$s2, 0					# int column = 0

check_column_loop__cond:
	bge	$s2, MAP_WIDTH, check_column_loop__end	# while (column < MAP_WIDTH) {

check_column_loop__body:
	#la	$t0, BLOCK_SPAWNER_NEXT_BLOCK_OFFSET($s0) # *next_block_ptr = block_spawner->next_block

	mul	$t8, $s2, 4				# **next_block_ptr = &block_spawner->next_block[col]
	add	$t9, $t8, $s0

	lw	$s3, ($t9) # s4 is an address point to smth else, lw from s4 to get **
	beq	$s3, TRUE, check_column_loop__step	# if (*next_block_ptr &&

	lb	$s4, ($s3)
	beq	$s4, TRUE, check_column_loop__step	# **next_block_ptr) continue 

	jal	rng					# rng()
	move	$t6, $v0
	remu	$s5, $t6, NUM_CHUNKS			# chunk = rng() % NUM_CHUNKS

	li	$v0, 4
	la	$a0, maybe_pick_new_chunk__column_msg_1 # printf("Column")
	syscall

	li	$v0, 1
	move	$a0, $s2
	syscall						# printf("%d", column)

	li	$v0, 11
	la	$a0, ':'				# printf(":")
	syscall

	li	$v0, 1
	move	$a0, $s5
	syscall						# printf("%d", chunk)

	li	$v0, 11
	li	$a0, '\n'
	syscall						# printf("\n")

	la	$t6, CHUNKS
	mul	$t8, $s5, 4
	add	$t9, $t8, $t6
	lw	$t0, ($t9)

	# la	$t5, BLOCK_SPAWNER_NEXT_BLOCK_OFFSET($s0) # *next_block_ptr  = CHUNKS[chunk]
	sw	$t0, ($s3)

	lw	$t7, BLOCK_SPAWNER_SAFE_COLUMN_OFFSET($s0)
	bne	$s2, $t7, check_column_loop__step	# if (column == block_spawner->safe_column) {

	li	$s1, TRUE				# new_safe_column_required = TRUE}

check_column_loop__step:
	addi	$s2, $s2, 1				# column++
	b	check_column_loop__cond

check_column_loop__end:
	bne	$s1, TRUE, maybe_pick_new_chunk__epilogue # if (new_safe_column_required)

	jal	rng					# rng()
	move	$t0, $v0
	remu	$t0, $t0, MAP_WIDTH			# safe_column = rng() % MAP_WIDTH

	li	$v0, 4
	la	$a0, maybe_pick_new_chunk__column_msg_2 # printf("New safe column: ")
	syscall

	li	$v0, 1
	move	$a0, $t0
	syscall						# printf("%d", column)

	li	$v0, 11
	la	$a0, '\n'				# printf("\n")
	syscall

	sw	$t0, BLOCK_SPAWNER_SAFE_COLUMN_OFFSET($s0) # block_spawner->safe_column = safe_column;

	la	$t6, CHUNKS
	la	$t1, SAFE_CHUNK_INDEX
	mul	$t8, $t1, 4
	add	$t9, $t8, $t6
	lw	$t5, ($t9)

	la	$t6, BLOCK_SPAWNER_NEXT_BLOCK_OFFSET($s0) # *next_block_ptr = block_spawner->next_block

	mul	$t8, $t0, 4				# **next_block_ptr = &block_spawner->next_block[col]
	add	$t9, $t6, $t8
	sw	$t5, ($t9)
	

maybe_pick_new_chunk__epilogue:
	pop	$s6
	pop	$s5
	pop	$s4
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop 	$ra 

	end
	jr	$ra


################################################################################
# .TEXT <do_tick>
	.text
do_tick:
	# Subset:   3
	#
	# Args:
	#   - $a0: char map[MAP_HEIGHT][MAP_WIDTH]
	#   - $a1: struct Player *player
	#   - $a2: struct BlockSpawner *block_spawner
	#
	# Returns:  None
	#
	# Frame:    [...]
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:
	#   - ...
	#
	# Structure:
	#   do_tick
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

do_tick__prologue:
do_tick__body:
do_tick__epilogue:
	jr	$ra

################################################################################
################################################################################
###                   PROVIDED FUNCTIONS — DO NOT CHANGE                     ###
################################################################################
################################################################################

################################################################################
# .TEXT <get_seed>
get_seed:
	# Args:     None
	#
	# Returns:  None
	#
	# Frame:    []
	# Uses:     [$v0, $a0]
	# Clobbers: [$v0, $a0]
	#
	# Locals:
	#   - $v0: seed
	#
	# Structure:
	#   get_seed
	#   -> [prologue]
	#     -> body
	#       -> invalid_seed
	#       -> seed_ok
	#   -> [epilogue]

get_seed__prologue:
get_seed__body:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, get_seed__prompt_msg
	syscall					# printf("Enter a non-zero number for the seed: ")

	li	$v0, 5				# syscall 5: read_int
	syscall					# scanf("%d", &seed);
	sw	$v0, g_rng_state		# g_rng_state = seed;

	bnez	$v0, get_seed__seed_ok		# if (seed == 0) {
get_seed__invalid_seed:
	li	$v0, 4				#   syscall 4: print_string
	la	$a0, get_seed__prompt_invalid_msg
	syscall					#   printf("Invalid seed!\n");

	li	$v0, 10				#   syscall 10: exit
	li	$a0, 1
	syscall					#   exit(1);

get_seed__seed_ok:				# }
	li	$v0, 4				# sycall 4: print_string
	la	$a0, get_seed__set_msg
	syscall					# printf("Seed set to ");

	li	$v0, 1				# syscall 1: print_int
	lw	$a0, g_rng_state
	syscall					# printf("%d", g_rng_state);

	li	$v0, 11				# syscall 11: print_char
	la	$a0, '\n'
	syscall					# putchar('\n');

get_seed__epilogue:
	jr	$ra				# return;


################################################################################
# .TEXT <rng>
rng:
	# Args:     None
	#
	# Returns:  $v0: unsigned
	#
	# Frame:    []
	# Uses:     [$v0, $a0, $t0, $t1, $t2]
	# Clobbers: [$v0, $a0, $t0, $t1, $t2]
	#
	# Locals:
	#   - $t0 = copy of g_rng_state
	#   - $t1 = bit
	#   - $t2 = temporary register for bit operations
	#
	# Structure:
	#   rng
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

rng__prologue:
rng__body:
	lw	$t0, g_rng_state

	srl	$t1, $t0, 31		# g_rng_state >> 31
	srl	$t2, $t0, 30		# g_rng_state >> 30
	xor	$t1, $t2		# bit = (g_rng_state >> 31) ^ (g_rng_state >> 30)

	srl	$t2, $t0, 28		# g_rng_state >> 28
	xor	$t1, $t2		# bit ^= (g_rng_state >> 28)

	srl	$t2, $t0, 0		# g_rng_state >> 0
	xor	$t1, $t2		# bit ^= (g_rng_state >> 0)

	sll	$t1, 31			# bit << 31
	srl	$t0, 1			# g_rng_state >> 1
	or	$t0, $t1		# g_rng_state = (g_rng_state >> 1) | (bit << 31)

	sw	$t0, g_rng_state	# store g_rng_state

	move	$v0, $t0		# return g_rng_state

rng__epilogue:
	jr	$ra


################################################################################
# .TEXT <read_char>
read_char:
	# Args:     None
	#
	# Returns:  $v0: unsigned
	#
	# Frame:    []
	# Uses:     [$v0]
	# Clobbers: [$v0]
	#
	# Locals:   None
	#
	# Structure:
	#   read_char
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

read_char__prologue:
read_char__body:
	li	$v0, 12			# syscall 12: read_char
	syscall				# return getchar();

read_char__epilogue:
	jr	$ra