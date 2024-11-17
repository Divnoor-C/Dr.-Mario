################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
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
Color:  
    .word 0xffffff  # Grey border color

# Array of possible colors for the initial capsule
ColorOptions:
    .word 0xff0000  # Red
    .word 0x00ff00  # Green
    .word 0x0000ff  # Blue

##############################################################################
# Mutable Data
##############################################################################
CapsuleX:
    .word 8        # Initial X position of the capsule
CapsuleY:
    .word 128      # Initial Y position of the capsule
CapsuleOrientation:
    .word 0        # Initial orientation: 0 for vertical, 1 for horizontal
##############################################################################
# Code
##############################################################################
	.text
	.globl main

# Main function to initialize and start the game
main:
    lw $t0, ADDR_DSPL        # Load base address for display
    addi $t0, $t0, 648        # Start at 8th line (y-position)

    lw $t1, Color             # Load color
    lw $a0, Width             # Load width of the box
    lw $a1, Height            # Load height of the box

    add $t2, $t0, $zero       # Initialize x position for drawing
    add $t3, $t0, $zero       # Initialize y position for drawing

    addi $t7, $zero, 2        # Constant for half width calculation
    div $t4, $a0, $t7         # Calculate half-width for the top boundary
    sub $t4, $t4, $t7         # Adjust to account for starting offset

    addi $t7, $zero, 0        # Initialize loop counter

draw_top_first:
    beq $t4, $t7, draw_top_second_before # Check if the first half of top is drawn
    sw $t1, 0($t2)            # Draw pixel
    addi $t7, $t7, 1
    addi $t2, $t2, 4          # Move to next pixel
    j draw_top_first

draw_top_second_before:
    add $t6, $t2, $zero       # Save current x position
    sw $t1, -132($t2)         # Draw left pixel at the top
    addi $t2, $t2, 20         # Create gap of 5 pixels
    sw $t1, -128($t2)         # Draw right pixel at the top
    addi $t7, $zero, 0        # Reset loop counter

draw_top_second:
    beq $t4, $t7, draw_vertical_before # Check if the second half of top is drawn
    sw $t1, 0($t2)            # Draw pixel
    addi $t7, $t7, 1
    addi $t2, $t2, 4          # Move to next pixel
    j draw_top_second

draw_vertical_before:
    addi $t7, $zero, 0        # Reset loop counter
    add $t5, $t0, $zero       # Initialize y position for vertical draw

draw_vertical:
    beq $a1, $t7, draw_bottom_before # Check if all vertical lines are drawn
    sw $t1, 0($t2)            # Draw left vertical pixel
    sw $t1, 0($t5)            # Draw right vertical pixel
    addi $t7, $t7, 1
    addi $t2, $t2, 128        # Move down one row (256 / 2 for pixel width)
    addi $t5, $t5, 128        # Move down one row for right side
    j draw_vertical

draw_bottom_before:
    addi $t7, $zero, -1       # Adjust loop counter for bottom drawing

draw_bottom:
    beq $a0, $t7, first_capsule # Check if bottom line is fully drawn
    sw $t1, 0($t5)            # Draw pixel
    addi $t7, $t7, 1
    addi $t5, $t5, 4          # Move to next pixel
    j draw_bottom

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

    # Draw the first part of the capsule using the first random color
    sw $t9, 8($t6)

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

    # Draw the second part of the capsule using the second random color
    sw $t9, -120($t6)

# Main game loop placeholder
game_loop:
    # Add a short delay for better handling of keyboard polling
    li $v0, 32                    # Syscall for sleep
    li $a0, 1                     # Sleep for 1 ms
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
    # Load current orientation
    lw $t6, CapsuleOrientation
    xori $t6, $t6, 1          # Toggle between 0 (vertical) and 1 (horizontal)
    sw $t6, CapsuleOrientation

    # Adjust the capsule's coordinates based on new orientation
    # If rotating from vertical to horizontal
    beqz $t6, rotate_horizontal
    
    # Rotating from horizontal to vertical
    lw $t4, CapsuleX
    addi $t4, $t4, -4         # Adjust X to shift left
    sw $t4, CapsuleX          # Update X position
    j game_loop

rotate_horizontal:
    lw $t5, CapsuleY
    addi $t5, $t5, -128       # Adjust Y to shift up
    sw $t5, CapsuleY          # Update Y position
    j game_loop

move_left:
    # Load current X position
    lw $t4, CapsuleX
    addi $t4, $t4, -4         # Move left by one unit
    sw $t4, CapsuleX          # Update X position
    j game_loop

move_right:
    # Load current X position
    lw $t4, CapsuleX
    addi $t4, $t4, 4          # Move right by one unit
    sw $t4, CapsuleX          # Update X position
    j game_loop

move_down:
    # Load current Y position
    lw $t5, CapsuleY
    addi $t5, $t5, 128        # Move down by one row (based on pixel size)
    sw $t5, CapsuleY          # Update Y position
    j game_loop

quit_game:
    li $v0, 10                # Syscall to terminate the program
    syscall
