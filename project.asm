################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Divnoor Chatha, 1010590237
# Student 2: Aksshatt Bariar, 1010071217
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
    
Width:     
    .word 23      # Width of the box
Height:    
    .word 25      # Height of the box
Height_empty_part:
    .word 11      # Width of the box's hollow part
Width_empty_part:
    .word 22      # Height of the box' hallow part
BorderColor:  
    .word 0xffffff  # Grey border color

# Array of possible colors for the initial capsule
ColorOptions:
    .word 0xff0000  # Red
    .word 0xffff00  # Yellow
    .word 0x0000ff  # Blue
Color_test:
    .word 0xff00ff
Background:
    .word 0x000000  # Black
    
VirusNumber:
    .word 4

##############################################################################
# Mutable Data
##############################################################################
# topPixelColor:
    # .word 0xff0000
# bottomPixelColor:
    # .word 0x00ff00
# capsuleTop:
    # .word 0x10008000
# capsuleBottom:
    # .word 0x10008000
field: 
    .space 16384  # Allocate space for a 32x32 array (128 bytes for words)
##############################################################################
# Code
##############################################################################
	.text
	.globl main

# Main function to initialize and start the game
main:
    lw $t0, ADDR_DSPL        # Load base address for display
    
    la $s0, field            # Load base address for the array i.e. the game map
    
    addi $s0, $s0, 648

    lw $t1, BorderColor             # Load color
    lw $a0, Width             # Load width of the box
    lw $a1, Height            # Load height of the box

    add $s2, $s0, $zero

    addi $t7, $zero, 2        # Constant for half width calculation
    div $t4, $a0, $t7         # Calculate half-width for the top boundary
    sub $t4, $t4, $t7         # Adjust to account for starting offset

    addi $t7, $zero, 0        # Initialize loop counter
    

draw_top_first:
    beq $t4, $t7, draw_top_second_before # Check if the first half of top is drawn
    sw $t1, 0($s2)
    addi $t7, $t7, 1
    addi $s2, $s2, 4
    j draw_top_first

draw_top_second_before:
    add $s3, $s2, $zero
    sw $t1, -132($s2)
    addi $s2, $s2, 20
    sw $t1, -128($s2)
    addi $t7, $zero, 0        # Reset loop counter    
    
draw_top_second:
    beq $t4, $t7, draw_vertical_before # Check if the second half of top is drawn
    sw $t1, 0($s2)
    addi $t7, $t7, 1
    addi $s2, $s2, 4
    j draw_top_second

draw_vertical_before:
    addi $t7, $zero, 0        # Reset loop counter
    add $s1, $s0, $zero       # Initialize y position on map
    
    
draw_vertical:
    beq $a1, $t7, draw_bottom_before # Check if all vertical lines are drawn
    sw $t1, 0($s2)
    sw $t1, 0($s1)
    addi $t7, $t7, 1
    addi $s2, $s2, 128
    addi $s1, $s1, 128
    j draw_vertical

draw_bottom_before:
    addi $t7, $zero, -1       # Adjust loop counter for bottom drawing
    
draw_bottom:
    beq $a0, $t7, next_capsule # Check if bottom line is fully drawn
    sw $t1, 0($s1)
    addi $t7, $t7, 1
    addi $s1, $s1, 4
    j draw_bottom

    
next_capsule: 
    # Generate random color for the first part of the capsule
    li $v0, 42                # Syscall for random number generation
    li $a0, 0                 # Random generator ID
    li $a1, 3                 # Generate a random number between 0 and 2 (inclusive)
    syscall

    # Load first color from ColorOptions based on random number
    la $t8, ColorOptions      # Load base address of color options
    sll $a0, $a0, 2           # Multiply random number by 4 to get the correct offset
    add $t8, $t8, $a0         # Get address of the selected color
    lw $t9, 0($t8)            # Load the selected color into $t9
    

    # sw $t9, topPixelColor
    sw $t9, 68($s3)     # Save location of top part of next capsule
    

    # Generate random color for the second part of the capsule
    li $v0, 42                # Syscall for another random number generation
    li $a0, 0                 # Random generator ID
    li $a1, 3                 # Generate a random number between 0 and 2 (inclusive)
    syscall

    # Load second color from ColorOptions based on the new random number
    la $t8, ColorOptions      # Load base address of color options
    sll $a0, $a0, 2           # Multiply random number by 4 to get the correct offset
    add $t8, $t8, $a0         # Get address of the selected color
    lw $t9, 0($t8)            # Load the selected color into $t9

    sw $t9, -60($s3)    # Save location of bottom part of next capsule
    
    
first_capsule:
    # Generate random color for the first part of the capsule
    li $v0, 42                # Syscall for random number generation
    li $a0, 0                 # Random generator ID
    li $a1, 3                 # Generate a random number between 0 and 2 (inclusive)
    syscall

    # Load first color from ColorOptions based on random number
    la $t8, ColorOptions      # Load base address of color options
    sll $a0, $a0, 2           # Multiply random number by 4 to get the correct offset
    add $t8, $t8, $a0         # Get address of the selected color
    lw $t9, 0($t8)            # Load the selected color into $t9

    sw $t9, 8($s3)
    
    

    # Generate random color for the second part of the capsule
    li $v0, 42                # Syscall for another random number generation
    li $a0, 0                 # Random generator ID
    li $a1, 3                 # Generate a random number between 0 and 2 (inclusive)
    syscall

    # Load second color from ColorOptions based on the new random number
    la $t8, ColorOptions      # Load base address of color options
    sll $a0, $a0, 2           # Multiply random number by 4 to get the correct offset
    add $t8, $t8, $a0         # Get address of the selected color
    lw $t9, 0($t8)            # Load the selected color into $t9

    sw $t9, -120($s3)
    
# Assume the base address of the display is in $t0
# Assume the base address of the field (game map) is in $s0
repaint:
    la $s0, field
    lw $t0, ADDR_DSPL
    addi $s6, $s6, 1672
paint_screen:
    beq $s6, $s7, game_loop
    lw $s5, 0($s0)
    sw $s5, 0($t0)
    addi $s0, $s0, 4
    addi $t0, $t0, 4
    addi $s7, $s7, 1
    j paint_screen 
    

    # lw $t4, VirusNumber # counter for virus
    
# virus:
# beq $t4, $zero, game_loop
    # li $t1, 0
    # li $t2, 4
    # li $t3, 128
    # addi $t1, $t6, 96 # load t1 with top left bottle location
    
    # # Generate random color for the virus
    # li $v0, 42                # Syscall for random number generation
    # li $a0, 0                 # Random generator ID
    # li $a1, 3                 # Generate a random number between 0 and 2 (inclusive)
    # syscall
    
    # # Load first color from ColorOptions based on random number
    # la $t8, ColorOptions      # Load base address of color options
    # sll $a0, $a0, 2           # Multiply random number by 4 to get the correct offset
    # add $t8, $t8, $a0         # Get address of the selected color
    # lw $t9, 0($t8)            # Load the selected color into $t9

    # # Generate random height for the virus
    # li $v0, 42                # Syscall for random number generation
    # li $a0, 0                 # Random generator ID
    # lw $a1, Height_empty_part            # Generate a random number between 0 and height (exclusive)
    # syscall
    
    # addi $a0, $a0, 13
    
    # mult, $t3, $t3, $a0 
    # add $t3, $t1, $t3 # width location of virus in t3

    # # Generate random width for the virus
    # li $v0, 42                # Syscall for random number generation
    # li $a0, 0                 # Random generator ID
    # lw $a1, Width_empty_part             # Generate a random number between 0 and height (exclusive)
    # syscall
    
    # mult, $t2, $t2, $a0 
    # add $t3, $t2, $t3
    # sw $t9, 0($t3)
    
    # subi $t4, $t4, 1
    # j virus

# Main game loop placeholder
game_loop:
    # Short delay for better handling of keyboard polling
    li $v0, 32                    # Syscall for sleep
    li $a0, 10                    # Sleep for 1 ms
    syscall
    
    lw $t0, ADDR_KBRD             # $t0 = base address for keyboard
    lw $t8, 0($t0)                # Load first word from keyboard
    beqz $t8, game_loop                # If no key pressed, continue polling

    lw $t2, 4($t0)                # Load the ASCII value of the pressed key

    # Check for 'w' key (rotate)
    li $t3, 0x77              # ASCII value for 'w'
    beq $t2, $t3, rotate_capsule

    # Check for 'a' key (move left)
    li $t3, 0x61              # ASCII value for 'a'
    beq $t2, $t3, move_left

    # Check for 'd' key (move right)
    li $t3, 0x64              # ASCII value for 'd'
    beq $t2, $t3, move_right

    # Check for 's' key (move down)
    li $t3, 0x73              # ASCII value for 's'
    beq $t2, $t3, move_down

    # Check for 'q' key (quit)
    li $t3, 0x71              # ASCII value for 'q'
    beq $t2, $t3, quit_game

    j game_loop               # Continue looping if no valid key is pressed
    
rotate_capsule:
  
    j game_loop

rotate_vertical:
    j game_loop
 

move_left:
    # Load the position of the capsule
    lw $t9, 8($s3)     # Load the color of the top part of the capsule
    lw $t8, -120($s3)  # Load the color of the bottom part of the capsule
    lw $t7, Background        # Load the color of the background
    
    sw $t7, 8($s3)
    sw $t7, -120($s3) 
    
    # Calculate the new position by adding the row offset
    addi $s3, $s3, -4        # Move down one row (128 is the row offset)

    # Store the colors at the new position to move the capsule
    sw $t9, 8($s3)            # Store top part of the capsule at new position
    sw $t8, -120($s3)         # Store bottom part of the capsule at new position

    # Update the display
    j repaint               # Re-paint the screen

move_right:
    # Load the position of the capsule
    lw $t9, 8($s3)     # Load the color of the top part of the capsule
    lw $t8, -120($s3)  # Load the color of the bottom part of the capsule
    lw $t7, Background        # Load the color of the background
    
    sw $t7, 8($s3)
    sw $t7, -120($s3) 
    
    # Calculate the new position by adding the row offset
    addi $s3, $s3, 4        # Move down one row (128 is the row offset)

    # Store the colors at the new position to move the capsule
    sw $t9, 8($s3)            # Store top part of the capsule at new position
    sw $t8, -120($s3)         # Store bottom part of the capsule at new position

    # Update the display
    j repaint               # Re-paint the screen
   
   
move_down:
    # Load the position of the capsule
    lw $t9, 8($s3)     # Load the color of the top part of the capsule
    lw $t8, -120($s3)  # Load the color of the bottom part of the capsule
    lw $t7, Background        # Load the color of the background
    
    sw $t7, 8($s3)
    sw $t7, -120($s3) 
    
    # Calculate the new position by adding the row offset
    addi $s3, $s3, 128        # Move down one row (128 is the row offset)

    # Store the colors at the new position to move the capsule
    sw $t9, 8($s3)            # Store top part of the capsule at new position
    sw $t8, -120($s3)         # Store bottom part of the capsule at new position

    # Update the display
    j repaint               # Re-paint the screen
           
    

quit_game:
    li $v0, 10                # Syscall to terminate the program
    syscall
