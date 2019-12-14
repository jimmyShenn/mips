      .text
      .globl main
main:
########################################################
##    Your test code starts here.                     ##
## You may add test data in the .data segment. ## ########################################################

 
      lw $t1, test1
      la $a0, test2
      move $t2, $a0
      lb $t3, test3
      

      la $a0, finaltest1
      move $a1, $t1    # test printf_d
      jal printf       # call printf 
                  
      la $a0, finaltest2 # test printf_perc
      move $a1, $t2    # test printf_s
      jal printf
    
      la $a0, finaltest3 # test printf_S
      move $a1, $t3
      jal printf

      la $a0, finaltest4 # test printf_S
      jal printf
 
      la $a0, finaltest5 # test printf_S
      move $a1, $t2
      jal printf     
      li  $v0,10       # 10 is exit system call
      syscall   


## printf.asm
##
## Register Usage:
## $a0,$s0 - pointer to format string
## $a1,$s1 - format argument 1 (optional)
## $a2,$s2 - format argument 2 (optional)
## $a3,$s3 - format argument 3 (optional)
## $s4 - count of formats processed.
## $s5 - char at $s4.
## $s6 - pointer to printf buffer
##
## Source Courtesy D. J. E.
.text
.globl printf
printf:
      subu  $sp, $sp, 36
      sw    $ra, 32($sp)
      sw    $fp, 28($sp)
      sw    $s0, 24($sp)
      sw    $s1, 20($sp)
      sw    $s2, 16($sp)
      sw    $s3, 12($sp)
      sw    $s4, 8($sp)
      sw    $s5, 4($sp)
      sw    $s6, 0($sp)
      addu  $fp, $sp, 36
      move  $s0, $a0
      move  $s1, $a1
      move  $s2, $a2
      move  $s3, $a3
      li $s4,0
      la $s6, printf_buf
# set up the stack frame
# save local variables
printf_loop:
      lb    $s5, 0($s0)
      addu  $s0, $s0, 1
      beq   $s5, '%', printf_fmt
      beq   $0, $s5, printf_end     # if zero, finish
printf_putc:
      sb    $s5, 0($s6) # otherwise, put this char
      sb    $0, 1($s6)  # into the print buffer
      
# grab the arguments
# fmt string
# arg1, optional
# arg2, optional
# arg3, optional
#set#offmt=0
# set s6 = base of buffer
# process each character at fmt
      # get the next character
# $s0 pointer increases
      move  $a0, $s6    # and print it using syscall
      li    $v0, 4
      syscall
      j     printf_loop
printf_fmt:
      lb    $s5, 0($s0) # get the char after '%'
      addu  $s0, $s0, 1
      
      # check if already processed 3 args.
      beq   $s4, 3, printf_loop
      # if 'd', then print as a decimal integer
      beq   $s5, 'd', printf_int
      # if 's', then print as a string
      beq   $s5, 's', printf_str
      # if 'c', then print as an ASCII char
      beq   $s5, 'c', printf_char
      # if '%', then print as a '%'
      beq   $s5, '%', printf_perc
      # if 'S', then print as a string
      beq   $s5, 'S', printf_S
      j     printf_loop
printf_shift_args:
      move  $s1, $s2
      move  $s2, $s3
      addi  $s4, $s4, 1 # increment no. of args processed
      j     printf_loop
printf_int: # printf('%d', 100)
      move $a0, $s1 # print the value stored in $s1
      li $v0, 1
      syscall
      j printf_shift_args
############################################################# ## You may add code to process string, char, “%” here. ## #############################################################
printf_char:
      sb        $s1, 0($s6)   # fill the buffer
      sb        $0, 1($s6)    # and then a null.
      move	$a0, $s6      # print char
      li	$v0, 4
      syscall
      j printf_shift_args

printf_S:
     move $s7, $s1            # set s7 = s1
loop:
      lb  $t0,  0($s7)            # load a char to $t0
      beq $t0,  0, printf_str     # end
      blt $t0, 'a', not_lower     # next one
      bgt $t0, 'z', not_lower     # next one
      sub $t0, $t0, 32            # convert lower case to upper case
      sb  $t0, 0($s7)             # store $t0 to $t7
    
not_lower:
     addu $s7, $s7, 1            # next char
     j   loop

printf_str:
      move	$a0, $s1     # do a print_string syscall of $s1
      li	$v0, 4       # print str
      syscall
      j printf_shift_args      
printf_perc:
      li        $s5, '%' 
      sb        $s5, 0($s6)  # fill the buffer
      sb        $0, 1($s6)   # and then a null
      move      $a0, $s6     #print %
      li        $v0, 4   
      syscall     
      j printf_loop
      
printf_end:
      lw    $ra, 32($sp)
      lw    $fp, 28($sp)
      lw    $s0, 24($sp)
      lw    $s1, 20($sp)
      lw    $s2, 16($sp)
      lw    $s3, 12($sp)
      lw    $s4, 8($sp)
      lw    $s5, 4($sp)
      lw    $s6, 0($sp)
      addu  $sp, $sp, 36
      jr    $ra
exit:

li    $v0, 10
      syscall
############################################################## ## You may add whatever necessary in the .data segment. ## ##############################################################
            .data
printf_buf: .space 2
test1:  .word 8
test2:  .asciiz "teststring"
test3:  .byte  'd'

finaltest1: .asciiz "test1:%d\n" 
finaltest2: .asciiz "test2:%s\n"
finaltest3: .asciiz "test3:%c\n"
finaltest4: .asciiz "test4:%%\n"
finaltest5: .asciiz "test5:%S\n "
## end of printf.asm ##
