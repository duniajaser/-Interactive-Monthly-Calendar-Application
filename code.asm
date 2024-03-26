# Dunia Jaser 1201345
#-----------------------------DATA---------------------------------
.data  
openFileError:	.asciiz "Error! Opening the file.\n"
dataFile:	.asciiz "C:\\Users\\saad\\Desktop\\data.txt"
menu:	.asciiz "----------------------------MENU----------------------------------\n\nSelect one of the following options:\n1) View the calender.\n2) View statistics.\n3) Add a new appointment.\n4) Delete an appointment.\n5) Exit the program.\n"
choice1Choices:	.asciiz "------------------------------------------------------------------\n1. View per day\n2. View per set of days\n3. View for a given slot in a given day\nEnter your choice: \n"
invalidChoiceMsg: .asciiz "Invalid choice. Please enter a valid option.\n"
setOfDaySentence: .asciiz "Enter the number of set:\n"

dayPrompt: .asciiz "Enter the day number: "
dayErrorMsg: .asciiz "The day you entered is not existed in the calendar."
daySucessMsg: .asciiz "The day you entered is existed in the calendar."
errorMsg: .asciiz "The time slot you entered is out of range.\nThe working day start from 8AM to 5PM, Try again\n"
startSlotPrompt: .asciiz "Enter the start slot: "
endSlotPrompt: .asciiz "Enter the end slot: "
separator:      .asciiz ", "
newline:        .asciiz "\n"
deleteAddAppiontment: .asciiz "------------------------------------------------------------------\nWhich appointment you want to delete:\n1.Lectute (L).\n2. Metting (M).\n3. Office Hour (OH).\nEnter the type(1/2/3): \n"

numberOfLecturesPromot:  .asciiz "Number of Lectures (in hours): "
numberOfOHPromot:  .asciiz "Number of Office Houres (in hours): "
numberOfMeetingPromot:  .asciiz "Number of Meetings (in hours): "
choice2Choices:	.asciiz "------------------------------------------------------------------\n1. View average of Lectures per day.\n2. View ratio between number of Lectures and number of Office Hours.\nEnter your choice: \n"
avgLecturePerDayPromot: .asciiz "The average lectures per day: "
ratioL_OHPromot: .asciiz "The  ratio between total number of hours reserved for lectures and the total number of hours reserved OH: "
addNewday: .asciiz "This day will be added to the calendar."
promptTypeOfAppoi: .asciiz "Enter the type of appointment (L, OH, M): "
endSlotSmallerThanStart: .asciiz "The end slot must be greater than start slot.\n"
updaetOrAddAppiontment: .asciiz "------------------------------------------------------------------\nWhich appointment you want to add or update:\n1.Lectute (L).\n2. Metting (M).\n3. Office Hour (OH).\nEnter the type(L/OH/M): \n"
conflictFoundMsg: .asciiz "There is a conflict.\nPlease Try again.\n"

choice1: .asciiz "1"
choice2: .asciiz "2"
choice3: .asciiz "3"
choice4: .asciiz "4"
choice5: .asciiz "5"

LChar: .asciiz "L"
MChar: .asciiz "M"
OHChar: .asciiz "OH"

resultString: .space 20
resultType: .half 4
buffer: .space 1
buffer1: .space 1024
calendar: .space 4096
numOfDays: .space 2
choice: .space 2
day: .space 4
firstDayInCalendar: .space 2
lastDayInCalendar: .space 2
chosenDayAddress: .space 4
currentDayAddress: .space 4
resultAppointment: .space 256

appointment1: .space 30
appointment2: .space 30
appointment3: .space 30

sentenceToShow: .space 20
appointmentType: .space 2

startSlot: .space 4
endSlot: .space 4

resultOfAvgLectures: .float 0.0
numOfLAsFloat: .float 0.0
numOfDays1: .float 0.0
numOfOHAsFloat: .float 0.0

#----------------------------CODE----------------------------------
.globl main
.text
main:
	b openFile
openFile:
	la $s1, buffer
	la $s2, calendar
	li $s3, 0      # current line length
    	li $s6, 0 	   # Number of days
   	# open file
    	li $v0, 13     # syscall for open file
    	la $a0, dataFile    # input file name
    	li $a1, 0      # read flag
    	li $a2, 0      # ignore mode 
    	syscall       # open file 
    	move $s0, $v0  # save the file descriptor 
    	# Check if the file opened successfully
    	bnez $s0, read_loop
    	li $v0, 4
    	la $a0, openFileError
    	syscall
    	j endProgram
#------------------------------------------------------------------
read_loop:

    	# read byte from file
    	li $v0, 14     # syscall for read file
    	move $a0, $s0  # file descriptor 
    	move $a1, $s1  # address of dest buffer
    	li $a2, 1      # buffer length
    	syscall       # read byte from file

    	# keep reading until bytes read <= 0
    	blez $v0, read_done

    	# naively handle exceeding line size by exiting
    	slti $t0, $s3, 1024
    	beqz $t0, read_done

    	# if current byte is a newline, consume line
    	lb $s4, ($s1) #character from file
    
    	li $t0, 10
    	beq $s4, $t0, consume_line

    	# otherwise, append byte to calender
    
    	# Calculate the address: address = base_address + (30 * number_of_lines)
	li $t2, 30  # Line size is 30 bytes in calendar 
	mul $t3, $s6, $t2  # Multiply number_of_days by 30
	add $t4, $s3, $t3  # Add the result to the base address
	add $s7, $t4, $s2  # Calculate the final address
	sb $s4, ($s7)       # Store the byte in the calendar

    	# increment line length
    	addi $s3, $s3, 1

    	b read_loop
#------------------------------------------------------------------
consume_line:

    	# null terminate line
    	add $s7, $s2, $t4 
    	sb $zero, ($s7)
    	# reset bytes read
    	li $s3, 0
    	addi $s6, $s6, 1 # number of lines ++

    	b read_loop
#------------------------------------------------------------------
read_done:	
    	# close file
    	li $v0, 16     # syscall for close file
    	move $a0, $s0  # file descriptor to close
    	syscall       # close file
    	la $s1, numOfDays
    	sb $s6, ($s1)
    	# save the first and last day in the calender.
    	la $a0, calendar
    	la $a1, firstDayInCalendar
    	jal readUntilColon
    		
   		
   	
    	la $a0, numOfDays  # Load the address of the ASCII string
    	jal asciiToInt       # Call the conversion function
    	move $a2, $v0 # first day
    	
    	
   	la $a0, calendar
    	li $t2, 30  # Line size is 30 bytes in calendar 
    	subu $a2, $a2, 1 # las day index = num of days - 1
    	mul $t2, $a2, $t2  # Multiply number_of_days by 30
    	addu $a0,$a0, $t2
    		
    	la $a1, lastDayInCalendar
    	jal readUntilColon
    	
    	b printMenu
#------------------------------------------------------------------
calendarConten1t:
	jal resetRegistersValues 
	la $t0, calendar
	li $t1, 0 #current day
	li $t2, 30
	la $t6, numOfDays
	lb $t7, ($t6)
   	
day_:	beq $t1, $t7, printMenu
	mul $t3, $t2, $t1
	add $t3, $t3, $t0
	
	# print line (or consume it some other way)
	move $a0, $t3
	li $v0, 4
	syscall
	# print newline
    	li $a0, 10
    	li $v0, 11
   	syscall
   	
	addi $t1, $t1, 1
	b day_
#------------------------------------------------------------------
printMenu:
	#printing the menue 
	la $a0, menu		
	li $a1, 1024
	li $v0, 4
	syscall
	
	# get the choice from the user
	la $a0, choice
	li $v0, 8
	syscall
	
	la $a1, choice1
	jal compareIntegerChoices
	beqz $v0, choice1Branchs
	
	la $a1, choice2
	jal compareIntegerChoices
	beqz $v0, choice2Branchs
	
	la $a1, choice3
	jal compareIntegerChoices
	beqz $v0, choice3Branchs
	
	la $a1, choice4
	jal compareIntegerChoices
	beqz $v0, choice4Branchs
	
	la $a1, choice5
	jal compareIntegerChoices
	beqz $v0, endProgram	
	
	la $a0,invalidChoiceMsg
	li $a1, 1024
	li $v0, 4
	syscall
	j printMenu
	

#------------------------------------------------------------------
compareIntegerChoices:	
	 # Load values from the addresses in $a0 and $a1
    	lb $t0, 0($a0)  
    	lb $t1, 0($a1)   

    	# Compare the values
   	beq $t0, $t1, set_equal   # Branch to set_equal if the values are equal
   	 # If the values are not equal, set $v0 to 1
    	li $v0, 1
    	j done   # Jump to the end of the comparison

    	set_equal:
    	# Set $v0 to 0 if the values are equal
    	li $v0, 0

    	done:
    	jr $ra   # Return from the function
	
#------------------------------------------------------------------
choice1Branchs:
#reset registers values
	jal resetRegistersValues
	
	la $a0, choice1Choices		
	li $a1, 1024
	li $v0, 4
	syscall
	
	# Get user choice
    	li $v0, 5
   	syscall
    	move $t0, $v0
	
	# Process user choice
   	beq $t0, 1, viewPerDay
	beq $t0, 2, viewPerSetOfDays
    	beq $t0, 3, viewForGivenSlot

		
	# Handle invalid choice
    	li $v0, 4
    	la $a0, invalidChoiceMsg
    	syscall
	j choice1Branchs
	
#------------------------------------------------------------------
readUntilColon:
    	# $a0: input string address
    	# $a1: result string address

	li $t0, 0  # Counter for result string
	li $t3, 0  # Counter for read values

	readLoop:
    		# Load a byte from the input string
    		lb $t1, 0($a0)

    		# Check if it's the special character ":"
    		li $t2, ':'  # ASCII code for ":"
    		beq $t1, $t2, end_read  # If it's ":", exit the loop

    		# Store the byte in the result string
    		sb $t1, 0($a1)

    		# Move to the next byte in both strings
    		addi $a0, $a0, 1
    		addi $a1, $a1, 1

    		# Increment the counters
    		addi $t0, $t0, 1
    		addi $t3, $t3, 1

    		# Check if we've reached the end of the input string
    		beqz $t1, end_read

    		# Continue the loop
    		j readLoop

	end_read:
    		# Null-terminate the result string
    		sb $zero, 0($a1)
		sub $a1, $a1, $t3
    		# Return the address day in calendar
    		move $v0, $a1
    		jr $ra

#------------------------------------------------------------------    
asciiToInt:

    	# Initialize variables
    	li $v0, 0     # Resulting integer
    	li $t0, 10    # Multiplier for decimal places

	convertLoop:
    		lb $t1, 0($a0)  # Load the current character from the string
		
    		# Check for the null terminator (end of string)
    		beqz $t1, convertDone

    		# Convert ASCII character to integer ('0' to '9')
    		sub $t1, $t1, '0'

    		# Multiply the current result by 10 and add the new digit
    		mul $v0, $v0, $t0
    		add $v0, $v0, $t1

    		# Move to the next character in the string
    		addi $a0, $a0, 1

    		# Repeat the loop
    		j convertLoop

	convertDone:
    		jr $ra  # Return to the calling function
#------------------------------------------------------------------    
viewPerDay:
	
	li $v0, 4
    	la $a0, dayPrompt
    	syscall
    	# get the choice from the user
	li $v0, 5
	syscall
    		
    	move $s2, $v0 # user input day
    	
	la $s1, calendar
	li $t8, 0 #current day 
	
	la $a0, numOfDays  # Load the address of the ASCII string
    	lb $t6, 0($a0) # number of days
 	
	
	daysLoop:
		beq $t6, $t8, exitLoop
		li $t2, 30  # Line size is 30 bytes in calendar 
		mul $t3, $t2, $t8  # Multiply number_of_days by 30
		add $t4, $s1, $t3  # Add the result to the base address
		
		move $a0, $t4
    		la $a1, chosenDayAddress
    		move $a2, $s2
    		jal readUntilColon1
    		move $s4, $v0
    		addi $t8, $t8, 1
    		beqz $s4, daysLoop
    	exitLoop:
		bnez  $s4, printDay1
		
		li $v0, 4
    		la $a0, dayErrorMsg
    		syscall
    		
    		# print newline
    		li $a0, 10
    		li $v0, 11
   		syscall
   		bgtz $s3, contLoopSet # for print per set of days
    		b printMenu
    		
    	printDay1:
    		li $v0, 4
		la $a0, daySucessMsg
    		syscall
    		
    		# print newline
    		li $a0, 10
    		li $v0, 11
   		syscall
   	
    		move $a0, $t4 # address of wanted day
    		li $v0, 4
    		syscall
    		
    		# print newline
    		li $a0, 10
    		li $v0, 11
   		syscall
    
    		bgtz $s3, contLoopSet # for print per set of days
    		j printMenu
    			
#------------------------------------------------------------------    

readUntilColon1:
    	# $a0: input string address
    	# $a1: result string address
    	# $a2: user input

	li $t9, 0  # Counter for result string
	li $t3, 0  # Counter for read values
	li $v0, 0 #initialize

	readLoop1:
    		# Load a byte from the input string
    		lb $t1, 0($a0)

    		# Check if it's the special character ":"
    		li $t2, ':'  # ASCII code for ":"
    		bne  $t1, $t2, conti  		
 		beq $t1, $t2,compareDays1 # If it's ":", compare   
 	return:	beq $v1, 1, end_read1
 		b noDayFound
    		# Store the byte in the result string
    	conti:	sb $t1, 0($a1)

    		# Move to the next byte in both strings
    		addi $a0, $a0, 1
    		addi $a1, $a1, 1

    		# Increment the counters
    		addi $t9, $t9, 1
    		addi $t3, $t3, 1

    		# Check if we've reached the end of the input string
    		beqz $t1, end_read1

    		# Continue the loop
    		j readLoop1

	end_read1:
    		# Null-terminate the result string
    		sb $zero, 0($a1)
		sub $a1, $a1, $t3
    		# Return the address  
    		move $v0, $a1
    		jr $ra
    	noDayFound:
    		li $v0, 0
    		jr $ra
#------------------------------------------------------------------    
# Function: compareDays1
# Compares a string representing a day with a user input day
# Returns 1 if they are equal, 0 otherwise

compareDays1:
	li $v1, 0 #initialize
    	# Null-terminate the result string
    	sb $zero, 0($a1)
    	sub $a1, $a1, $t3 # address of current day in calendar
   	# Convert ASCII string to integer
   	j asciiToInt1
return1:
	move $s6, $v0    # $s2 now contains the integer value from the ASCII string
    	# $a2: user input
    	beq $s6, $a2, equal
    	j endCompare
	equal:
    		li $v1, 1
    		j return
	endCompare:
    		li $v1, 0
    		j return
#------------------------------------------------------------------    
# Input: $a1 - address of the ASCII string
# Output: $v0 - resulting integer
asciiToInt1:

   # Initialize variables
    li $v0, 0     # Resulting integer
    li $t3, 10    # Multiplier for decimal places
    move $a3, $a1

convertLoop1:
    lb $t7, 0($a3)  # Load the current character from the string

    # Check for the null terminator (end of string)
    beqz $t7, convertDone1

    # Convert ASCII character to integer ('0' to '9')
    sub $t7, $t7, '0'

    # Multiply the current result by 10 and add the new digit
    mul $v0, $v0, $t3
    add $v0, $v0, $t7

    # Move to the next character in the string
    addi $a3, $a3, 1
    # Repeat the loop
    j convertLoop1

convertDone1:
    j return1  # Return to the calling function
#------------------------------------------------------------------    
viewPerSetOfDays:
	la $a0,setOfDaySentence
	li $v0, 4
	syscall
    	# get the choice from the user
	li $v0, 5
	syscall
	move $s3, $v0
	li $s5, 0
	setLoop:
		beq $s3, $s5, endSetLoop
		j viewPerDay
	contLoopSet:	
    		addi $s5, $s5, 1
    		j setLoop
	endSetLoop:
		j printMenu

#------------------------------------------------------------------    
viewForGivenSlot:
	#reset registers values
	jal resetRegistersValues
	
	li $v0, 4
    	la $a0, dayPrompt
    	syscall
    	
    	# get the choice from the user
	li $v0, 5
	syscall
    		
    	move $s2, $v0 # user input day
    	
	la $s1, calendar
	la $t8, 0 #current day 
	
	la $a0, numOfDays  # Load the address of the ASCII string
    	lb $t6, 0($a0) # number of days
 	
	
	daysLoop_:
		beq $t6, $t8, exitLoop_
		li $t2, 30  # Line size is 30 bytes in calendar 
		mul $t3, $t2, $t8  # Multiply number_of_days by 30
		add $t4, $s1, $t3  # Add the result to the base address
		
		move $a0, $t4
    		la $a1, chosenDayAddress
    		move $a2, $s2
    		jal readUntilColon1
    		move $s4, $v0
    		addi $t8, $t8, 1
    		beqz $s4, daysLoop_
    	exitLoop_:
		bnez  $s4, printDay1_
		li $v0, 4
    		la $a0, dayErrorMsg
    		syscall
    		
    		# print newline
    		li $a0, 10
    		li $v0, 11
   		syscall
    		b printMenu
    		
    	printDay1_:
    		li $v0, 4
		la $a0, daySucessMsg
    		syscall
    		
    		# print newline
    		li $a0, 10
    		li $v0, 11
   		syscall
   	
   		# $t4 conatins the address of the wanted day to print lslot
    		
    		li $v0, 4
    		la $a0, startSlotPrompt
    		syscall
    	
    		# get the choice from the user
		li $v0, 5
		syscall
		
		move $a0, $v0 
		jal addTwelveIfInRange
		move $s0, $v0 # conatin start slot user
		move $a0, $v0 
		jal testNumberInRange

		li $v0, 4
    		la $a0, endSlotPrompt
    		syscall
    	
    		# get the choice from the user
		li $v0, 5
		syscall
		move $a0, $v0 
		jal addTwelveIfInRange
		move $s1, $v0 # conatin end slot user
		move $a0, $v0 
		jal testNumberInRange

		# $a0: input string address
    	# $a1: result string1 address
    	# $a2: result string2 address
    	# $a3: result string1 address
    	# $s0: start slot integer
    	# $s1: end slot integer
    	move $t8, $t4
	addi $t9, $t9, 1 # skipping ':'
    	
    	
    	addu $a0, $t4, $t9 #address of the appointment section of the day    	
  	la $a1, appointment1
  	la $a2, appointment2
  	la $a3, appointment3
  	jal readUntilComma
  
  	# Input: $a0 - address of the input string
	# Output: $v0 - 0 if "L" is found, 1 if "M" is found, 2 if "OH" is found, -1 otherwise
	la $a0, appointment1
	
	jal checkAndPrintAppointment
	la $a0,  appointmentType      # Load the byte from the memory address in $s7 into $a0
	# Print the character
	li $v0, 4          # System call code for printing a character
	syscall
	
	li $v0, 11
    	li $a0, 44
    	syscall
	

    	li $v0, 11
    	li $a0, 32  # ASCII code for space
    	syscall
	
	la $a0, appointment2
	jal checkAndPrintAppointment
	la $a0,  appointmentType      # Load the byte from the memory address in $s7 into $a0
	# Print the character
	li $v0, 4          # System call code for printing a character
	syscall
	
	li $v0, 11
    	li $a0, 44
    	syscall

	li $v0, 11
    	li $a0, 32  # ASCII code for space
    	syscall
    	
    	
    	la $a0, appointment3
	jal checkAndPrintAppointment
	la $a0,  appointmentType      # Load the byte from the memory address in $s7 into $a0
	# Print the character
	li $v0, 4          # System call code for printing a character
	syscall
	
	# Print newline
	li $a0, 10
	li $v0, 11
	syscall

	j printMenu
#------------------------------------------------------------------    
resetRegistersValues:
	li $v0, 0
	li $v1, 0
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0
	jr $ra
#------------------------------------------------------------------    
# Function to read a string until two commas and store substrings
# Input: $a0 - input string address
#        $a1 - result string1 address
#        $a2 - result string2 address
#        $a3 - result string3 address

readUntilComma:
    	li $t4, 0  # Counter for commas

	readLoop__:
    		lb $t5, 0($a0)  # Load a byte from the input string

    		# Check for null terminator
    		beqz $t5, endRead

    		# Check if the character is a comma
    		li $t6, ','  # ASCII code for comma
    		beq $t5, $t6, processComma

    		# Check the comma count and copy the character accordingly
    		beq $t4, 0, copyToString1
    		beq $t4, 1, copyToString2
    		beq $t4, 2, copyToString3
		
    		# Move to the next character in the input string
    		j moveNextChar

	processComma:
    		# Increment the comma count
    		addi $t4, $t4, 1

	moveNextChar:
    		# Move to the next character in the input string
    		addi $a0, $a0, 1

    		# Continue the loop
    		j readLoop__

	copyToString1:
		beq $t5, 32, moveNextChar  # ASCII code for space
    		# Copy the character to result string1
    		sb $t5, 0($a1)
    		addi $a1, $a1, 1
    		j moveNextChar

	copyToString2:
	    	beq $t5, 32, moveNextChar  # ASCII code for space
    		# Copy the character to result string2
    		sb $t5, 0($a2)
    		addi $a2, $a2, 1
    		j moveNextChar

	copyToString3:
		beq $t5, 32, moveNextChar  # ASCII code for space
    		# Copy the character to result string3
    		sb $t5, 0($a3)
    		addi $a3, $a3, 1
    		j moveNextChar

	endRead:
		
    		# Null-terminate the current result string
    		sb $zero, 0($a1)
    		sb $zero, 0($a2)
    		sb $zero, 0($a3)
    		
    		jr $ra
#------------------------------------------------------------------    
# Function: checkAppointmentType
# Checks the type of appointment in the given string
# Input: $a0 - address of the input string
# Output: $v0 - 0 if "L" is found, 1 if "M" is found, 2 if "OH" is found, -1 otherwise
checkAppointmentType:
    	li $v0, -1  # Default value indicating no valid type found

    	checkLoop:
        	lb $t0, 0($a0)  # Load a byte from the input string

        	# Check for null terminator
        	beqz $t0, endCheck

        	# Check for "L"
        	li $t1, 'L'  # ASCII code for "L"
        	beq $t0, $t1, foundL

        	# Check for "M"
        	li $t2, 'M'  # ASCII code for "M"
        	beq $t0, $t2, foundM

        	# Check for "O"
        	li $t3, 'O'  # ASCII code for "O"
        	beq $t0, $t3, checkOH

        	j moveNextChar_

    	foundL:
		li $v0, 0  # Set return value to 0
        	j endCheck

    	foundM:
        	li $v0, 1  # Set return value to 1
        	j endCheck

    	checkOH:
        	# Check for "H" (to complete "OH")
        	li $t4, 'H'  # ASCII code for "H"
        	lb $t5, 1($a0)  # Load the next byte from the input string
        	beq $t5, $t4, foundOH

        	j moveNextChar_

    	foundOH:
        	li $v0, 2  # Set return value to 2

    	moveNextChar_:
        	# Move to the next character in the input string
        	addi $a0, $a0, 1

        	# Continue the loop
        	j checkLoop

    	endCheck:
        	jr $ra  # Return from the function
#------------------------------------------------------------------    
# Function: addTwelveIfInRange
# Input: $a0 - input number
# Output: $v0 - result
addTwelveIfInRange:
    # Check if input number is between 1 and 5 (inclusive)
    blt $a0, 1, notInRange
    bgt $a0, 5, notInRange

    # Add 12 to the input number
    addi $v0, $a0, 12
    j endFunction

notInRange:
    # If not in the range, return the original input
    move $v0, $a0

endFunction:
    jr $ra  # Return from the function
#------------------------------------------------------------------    
# Function: testNumberInRange
# Input: $a0 - input number
# The working day start from 8AM to 5PM
testNumberInRange:
   	# Check if input number is between 8 and 17 (inclusive)
   	blt $a0, 8, outOfRange
    	bgt $a0, 17, outOfRange
   	 # If in range, return without printing an error
    	jr $ra
	outOfRange:
    		# Print an error message
    		li $v0, 4
    		la $a0, errorMsg
    		syscall
    		j printMenu
#------------------------------------------------------------------   
# Function to check and print an appointment if it falls within the specified range
# Input: $a0 - address of the appointment string
#        $s0 - start slot (user-specified)
#        $s1 - end slot (user-specified)
checkAndPrintAppointment:
    	j parseSlots
	
contPrint:

	blt $v0, 1,checkV1
	bgt $v0, 5, checkV1
	addi $v0, $v0, 12


checkV1:
	blt $v1, 1,contPrint1
	bgt $v1, 5, contPrint1
	addi $v1, $v1, 12
	
contPrint1:
    move $s2, $v0  # start slot of the appointment
    move $s3, $v1  # end slot of the appointment
    
    bgt $s1, $s2, nextCase1
    j endCheckAndPrintAppointment
    blt $s0, $s3, nextCase1
    j endCheckAndPrintAppointment
nextCase1:
	ble $s1, $s2, nextCase2
	bgt $s1, $s3, nextCase2
	bge $s0, $s2, nextCase2
	
	move $a0, $s2
    	li $v0, 1
    	syscall 	
    	li $v0, 11
    	li $a0, 32
    	syscall
    	li $v0, 11
    	li $a0, 45 
    	syscall
    	li $v0, 11
    	li $a0, 32
    	syscall
    	move $a0, $s1
    	li $v0, 1
    	syscall 
	li $v0, 11
    	li $a0, 32
    	syscall
    	
	j endCheckAndPrintAppointment
nextCase2:
	blt $s0, $s2, nextCase3
	bgt $s1, $s3, nextCase3
	
	move $a0, $s0
    	li $v0, 1
    	syscall 	
    	li $v0, 11
    	li $a0, 32
    	syscall
    	li $v0, 11
    	li $a0, 45 
    	syscall
    	li $v0, 11
    	li $a0, 32
    	syscall
    	move $a0, $s1
    	li $v0, 1
    	syscall 
	li $v0, 11
    	li $a0, 32
    	syscall
	j endCheckAndPrintAppointment
nextCase3:
	bge $s0, $s2, nextCase4
	blt $s1, $s3, nextCase4
	
	move $a0, $s2
    	li $v0, 1
    	syscall 	
    	li $v0, 11
    	li $a0, 32
    	syscall
    	li $v0, 11
    	li $a0, 45 
    	syscall
    	li $v0, 11
    	li $a0, 32
    	syscall
    	move $a0, $s3
    	li $v0, 1
    	syscall 
	li $v0, 11
    	li $a0, 32
    	syscall
	
	j endCheckAndPrintAppointment
nextCase4:
	blt $s0, $s2, endCheckAndPrintAppointment
	bge $s0, $s3, endCheckAndPrintAppointment
	ble $s1, $s3, endCheckAndPrintAppointment
	
	move $a0, $s0
    	li $v0, 1
    	syscall 	
    	li $v0, 11
    	li $a0, 32
    	syscall
    	li $v0, 11
    	li $a0, 45 
    	syscall
    	li $v0, 11
    	li $a0, 32
    	syscall
    	move $a0, $s3
    	li $v0, 1
    	syscall 
	li $v0, 11
    	li $a0, 32
    	syscall
	
endCheckAndPrintAppointment:
    	jr $ra

#------------------------------------------------------------------   
# Function to parse start and end slots from an appointment string
# Input: $a0 - address of the appointment string
# Output: $v0 - start slot
#         $v1 - end slot
#         $s7 - appointmentType (updated)
parseSlots:
    li $v0, 0  # start slot
    li $v1, 0  # end slot
    la $s7, appointmentType  # appointmentType (initialize to empty string)
    li $t9, 0 # 0 if start slot, 1 if end slot

    # Loop to parse characters until a non-digit is encountered
parseLoop:
    lb $t0, 0($a0)  # Load a byte from the appointment string
# Check for null terminator
    beqz $t0, endParse

    # Check if the character is a digit
    blt $t0, 48, checkHyphen  # Skip hyphen if not a digit
    bgt $t0, 57, checkAppointmentType1  # this means the appointment type
    beq $t9, 1, endSlotMaker

    # Convert ASCII to integer and update start slot
    sub $t0, $t0, 48
    mul $v0, $v0, 10
    add $v0, $v0, $t0

    j skip

endSlotMaker:
 	# Convert ASCII to integer and update start slot
    	sub $t0, $t0, 48
    	mul $v1, $v1, 10
    	add $v1, $v1, $t0
    	

skip:    # Move to the next character in the appointment string
    addi $a0, $a0, 1

    # Continue the loop
    j parseLoop

checkHyphen:
    # Check if the character is a hyphen
    bne $t0, 45, endParse
    addi $a0, $a0, 1
    li $t9, 1
    # Continue the loop
    j parseLoop
    
checkAppointmentType1:
    # Save the non-digit character to appointmentType
    sb $t0, ($s7)
    addi $s7, $s7, 1  # Move to the next position in appointmentType

    # Move to the next character in the appointment string
    addi $a0, $a0, 1

    # Continue the loop
    j parseLoop

endParse:
    # Null-terminate the appointmentType string
    sb $zero, ($s7)
    j contPrint
   
#------------------------------------------------------------------   
choice2Branchs:
	# $s5 contains number of L in hours
	# $s6 contains number of OH in hours
	# $s7 contains number of M in hours
	
	#reset registers values
	jal resetRegistersValues
	
	la $s1, calendar
	li $t8, 0 #current day 
	li $s3, 0 
	
	la $a0, numOfDays  # Load the address of the ASCII string
    	lb $t6, 0($a0) # number of days
    	
	daysLoop22:
		beq $t6, $t8, exitLoop22
		
		li $t2, 30  # Line size is 30 bytes in calendar 
		mul $s3, $t2, $t8  # Multiply number_of_days by 30
		add $t4, $s1, $s3  # Add the result to the base address
		# $t4 contain the address of the current day
		
		move $a0, $t4
    		la $a1, currentDayAddress
    		jal readUntilColon
    		
    		
    		addu $a0, $a0, $t0
    		#  $a0 has the address of appointment
  		la $a1, appointment1
  		la $a2, appointment2
  		la $a3, appointment3
  		jal readUntilComma  
  		
  		# Input: $a0 - address of the input string
		# Output: $v0 - 0 if "L" is found, 1 if "M" is found, 2 if "OH" is found, -1 otherwise
		la $a0, appointment1
		jal checkAppointmentType
		# $a0 conation the type 0 if "L" is found, 1 if "M" is found, 2 if "OH" is found.
		# $a1 address of the appointment
		move $a0, $v0
		la $a1, appointment1
		jal addToCountersM_OH_L
		
		
		la $a0, appointment2
		jal checkAppointmentType
    		move $a0, $v0
		la $a1, appointment2
		jal addToCountersM_OH_L
		
		la $a0, appointment3
		jal checkAppointmentType
    		move $a0, $v0
		la $a1, appointment3
		jal addToCountersM_OH_L
		
			
    		addi $t8, $t8, 1 # current day ++
    		j daysLoop22
    	exitLoop22:
	
    		la $a0, numberOfLecturesPromot
    		li $v0, 4
   		syscall
    		
    		move $a0, $s5
    		li $v0, 1
   		syscall
   		
    		# print newline
    		li $a0, 10
    		li $v0, 11
   		syscall
   		
   		
   		la $a0, numberOfOHPromot
    		li $v0, 4
   		syscall
    		
    		move $a0, $s6
    		li $v0, 1
   		syscall
   		
    		# print newline
    		li $a0, 10
    		li $v0, 11
   		syscall
    
    	
   		
   		la $a0, numberOfMeetingPromot
    		li $v0, 4
   		syscall
    		
    		move $a0, $s7
    		li $v0, 1
   		syscall
   		
    		# print newline
    		li $a0, 10
    		li $v0, 11
   		syscall
   		
   	la $a0, choice2Choices
    	li $v0, 4
   	syscall
   		
	# Get user choice
    	li $v0, 5
   	syscall
    	move $t0, $v0
	
	# Process user choice
   	beq $t0, 1, avergeOfLectures
	beq $t0, 2,  ratioBetweenLecturesAndOH
	
	# Handle invalid choice
    	li $v0, 4
    	la $a0, invalidChoiceMsg
    	syscall
    	j printMenu

avergeOfLectures:
        # Load the constant numOfDays to register $t0
	lb $t0, numOfDays
    	# Move the integer numOfDays to $f0                      
    	mtc1 $t0, $f0   
    	# Convert the integer numOfDays to a float in $f0                        
    	cvt.s.w $f0, $f0
    	# Store the floating-point result in the 'numOfDays1' variable                        
    	swc1 $f0, numOfDays1                       
		
	# Calculate and store the result of the number of L
    	move $t2, $s5
    	# Move the integer result to $f0                      
    	mtc1 $t2, $f0  
    	# Convert the integer result to a float in $f0                        
    	cvt.s.w $f0, $f0 
    	# Store the floating-point result in the 'numOfLAsFloat' variable                       
    	swc1 $f0, numOfLAsFloat                       

    	# Calculate and store the result of the average lectures per day
    	# Load the value of numOfDays1 into $f0
   	lwc1 $f0, numOfDays1
   	# Load the value of numOfLAsFloat into $f2                   
	lwc1 $f2, numOfLAsFloat  
	# Divide the value of numOfLAsFloat by the value of numOfLAsFloat                   
	div.s $f12, $f2, $f0  
	# Store the floating-point result in the 'resultOfAvgLectures' variable	                
	swc1 $f12, resultOfAvgLectures      

	la $a0, avgLecturePerDayPromot		
	li $v0, 4
	syscall 

	# Print the result of the resultOfAvgLectures 
    	# Load the floating-point resultOfAvgLectures from 'resultOfAvgLectures' variable
   	 lwc1 $f12, resultOfAvgLectures 
   	 # System call code 2 for printing a float                     
   	 li $v0, 2  
   	 # Print the result of the resultOfAvgLectures                            
    	syscall   
    	     
   	# print newline
    	li $a0, 10
    	li $v0, 11
   	syscall  
	j printMenu
	
ratioBetweenLecturesAndOH:
	# numOfOHAsFloat
	 # Load the constant OH to register $t0
	move $t0, $s6
    	# Move the integer OH to $f0                      
    	mtc1 $t0, $f0   
    	# Convert the integer OH to a float in $f0                        
    	cvt.s.w $f0, $f0
    	# Store the floating-point result in the 'numOfOHAsFloat' variable                        
    	swc1 $f0, numOfOHAsFloat                       
		
	# Calculate and store the result of the number of L
    	move $t2, $s5
    	# Move the integer result to $f0                      
    	mtc1 $t2, $f0  
    	# Convert the integer result to a float in $f0                        
    	cvt.s.w $f0, $f0 
    	# Store the floating-point result in the 'numOfLAsFloat' variable                       
    	swc1 $f0, numOfLAsFloat                       

    	# Calculate and store the result of  ratio between total number of hours reserved for lectures and the total number of hours reserved OH
    	# Load the value of numOfDays1 into $f0
   	lwc1 $f0, numOfOHAsFloat
   	# Load the value of numOfLAsFloat into $f2                   
	lwc1 $f2, numOfLAsFloat  
	# Divide the value of numOfLAsFloat by the value of numOfOHAsFloat                   
	div.s $f12, $f2, $f0  
	# Store the floating-point result in the 'resultOfAvgLectures' variable	                
	swc1 $f12, resultOfAvgLectures      

	la $a0, ratioL_OHPromot		
	li $v0, 4
	syscall 

	# Print the result of the resultOfAvgLectures 
    	# Load the floating-point resultOfAvgLectures from 'resultOfAvgLectures' variable
   	 lwc1 $f12, resultOfAvgLectures 
   	 # System call code 2 for printing a float                     
   	 li $v0, 2  
   	 # Print the result of the resultOfAvgLectures                            
    	syscall   
    	     
   	# print newline
    	li $a0, 10
    	li $v0, 11
   	syscall  

	j printMenu	
	
#------------------------------------------------------------------   
# $a0 conation the type 0 if "L" is found, 1 if "M" is found, 2 if "OH" is found.
# $a1 address of the appointment
# $s5 counter for L
# $s6 counter for OH
# $s7 counter for M
addToCountersM_OH_L:
	j parseSlotsForStatistics
	continueFunc:	
	blt $v0, 1,checkV1_
	bgt $v0, 5, checkV1_
	addi $v0, $v0, 12

checkV1_:
	blt $v1, 1,continueProcess
	bgt $v1, 5, continueProcess
	addi $v1, $v1, 12
	#$v0 - start slot
	#$v1 - end slot
continueProcess:
  	
  	li $t7, 0 #to put the difference
  	subu $t7, $v1, $v0
  	
  	beqz $a0, addL
  	beq $a0, 1, addM
  	beq $a0, 2, addOH
  	
  	j goBack
  	addL:
  		addu $s5, $s5, $t7
  		j goBack
  	addOH:
  		addu $s6, $s6, $t7
  		j goBack
  	addM: 
  		addu $s7, $s7, $t7
  		j goBack 
	
	goBack:	
		jr $ra

#------------------------------------------------------------------   
# Function to parse start and end slots from an appointment string
# Input: $a1 - address of the appointment string
# Output: $v0 - start slot
#         $v1 - end slot
parseSlotsForStatistics:
    li $v0, 0   # start slot
    li $v1, 0   # end slot
    li $t9, 0   # 0 if start slot, 1 if end slot

    # Loop to parse characters until a non-digit is encountered
parseLoop11:
    lb $t0, 0($a1)  # Load a byte from the appointment string

    # Check for null terminator
    beqz $t0, endParse11

    # Check if the character is a digit
    blt $t0, 48, checkHyphen1  # Skip hyphen if not a digit
    bgt $t0, 57, checkAppointmentType11  # this means the appointment type
    beq $t9, 1, endSlotMaker1

    # Convert ASCII to integer and update start slot
    sub $t0, $t0, 48
    mul $v0, $v0, 10
    add $v0, $v0, $t0

    j skip111

endSlotMaker1:
    # Convert ASCII to integer and update end slot
    sub $t0, $t0, 48
    mul $v1, $v1, 10
    add $v1, $v1, $t0

skip111:
    # Move to the next character in the appointment string
    addi $a1, $a1, 1

    # Continue the loop
    j parseLoop11

checkHyphen1:
    # Check if the character is a hyphen
    bne $t0, 45, endParse11
    addi $a1, $a1, 1
    li $t9, 1
    # Continue the loop
    j parseLoop11

checkAppointmentType11:
    # Move to the next character in the appointment string
    addi $a1, $a1, 1

    # Continue the loop
    j parseLoop11

endParse11:
    j continueFunc
#------------------------------------------------------------------   
choice3Branchs:
	jal resetRegistersValues
	
	la $a0, dayPrompt		
	li $v0, 4
	syscall
	
	# Read user input
        li $v0, 8            # System call for read_str
        la $a0, buffer1        # Load address of the buffer to store user input
        li $a1, 1024           # Maximum number of characters to read
        syscall
        
    	li $v0, 0     # Resulting integer
    	li $t0, 10    # Multiplier for decimal places
        la $a0, buffer1        # Load address of the buffer to store user input
	jal convert_to_int
     

    	move $s2, $v0 # store user input (day) in $s2
    	
	la $s1, calendar
	la $t8, 0 #current day 
	
	la $a0, numOfDays  # Load the address of the ASCII string
    	lb $t6, 0($a0) # number of days
 	
	daysLoop3:
		beq $t6, $t8, exitLoop3 
		li $t2, 30  # Line size is 30 bytes in calendar 
		mul $t3, $t2, $t8  # Multiply number_of_days by 30
		add $t4, $s1, $t3  # Add the result to the base address
		
		move $a0, $t4
    		la $a1, chosenDayAddress
    		move $a2, $s2
    		jal readUntilColon1
    		move $s4, $v0
    		addi $t8, $t8, 1
    		beqz $s4, daysLoop3
    	exitLoop3:
		bnez  $s4, DayExists
		# Print message indicating the day does not exist in the calendar
  		li $v0, 4
   		la $a0, dayErrorMsg
   		syscall
   		 # Print newline
    		li $a0, 10
   		li $v0, 11
    		syscall
    		j addAppointment
    			
    	DayExists:

    		li $v0, 4
		la $a0, daySucessMsg
    		syscall
    		# print newline
    		li $a0, 10
    		li $v0, 11
   		syscall
   		
   		move $a0, $t4 # address of wanted day
    		li $v0, 4
    		syscall
    		 # Print newline
    		li $a0, 10
   		li $v0, 11
    		syscall
    		j updaetAppointment
        
	j printMenu
#------------------------------------------------------------------   
# Function to convert a string to an integer in hexadecimal format
# Input: $a0 - address of the input string
# Output: $v0 - converted integer in hexadecimal format
convert_to_int:
        # Initialize $v0 to store the result
        li $v0, 0
    convert_loop:
        # Load the ASCII code of the current character into $t1
        lb $t1, 0($a0)
        beq $t1,10, end_convert # if the string end with new line character
          # Extract the lower 4 bits (half-byte)
        beqz $t1, end_convert
        andi $t1, $t1, 0x0F
        # Check for the null terminator (end of string)

        # Multiply the current result by 10
        mulu $v0, $v0, 10

        # Add the converted digit to the result
        add $v0, $v0, $t1
        # Move to the next character in the string
        addi $a0, $a0, 1
        # Repeat the loop
        j convert_loop

    end_convert:
        jr $ra	
#------------------------------------------------------------------   	
addAppointment:	
	 li $v0, 4         # syscall code for printing string
   	 la $a0, addNewday # load address of day prompt
  	 syscall           # print day prompt
  	 
  	 # print newline
    	li $a0, 10
    	li $v0, 11
   	syscall
	#enter the type of the appointment
   	# Print prompt
    	li $v0, 4
    	la $a0, promptTypeOfAppoi
    	syscall

    	# Read user input
    	li $v0, 8
    	la $a0, resultType
    	li $a1, 4  
    	syscall
    	
    	#-----
    	li $v0, 4         # syscall code for printing string
   	la $a0, startSlotPrompt # load address of day prompt
  	syscall           # print day prompt
  	# Read user input for day
    	li $v0, 8
    	la $a0, startSlot
    	li $a1, 4  
    	syscall
    	
  	la $a0, startSlot
  	jal convert_to_int
	move $t0, $v0 # t0 conatin start slot
  	
  	blt $t0, 1, cont2
  	bgt $t0, 5, cont2
  	
  	addi $t0, $t0, 12
  	
  cont2:
  	blt $t0, 8, errorFound
  	bgt $t0, 17, errorFound
  			
  	 li $v0, 4         # syscall code for printing string
   	 la $a0, endSlotPrompt # load address of day prompt
  	 syscall           # print day prompt
  	# Read user input for day
	li $v0, 8
    	la $a0, endSlot
    	li $a1, 4  
    	syscall
    	
  	la $a0, endSlot
  	jal convert_to_int
	move $t1, $v0 #contain end slot
  	blt $t1, 1, cont3
  	bgt $t1, 5, cont3
	addi $t1, $t1, 12
  cont3:
  	blt $t1, 8, errorFound
  	bgt $t1, 17, errorFound
  	#-----
  	bge $t0, $t1, errorFound1
  	# add appoitment:
  	la $a0, numOfDays  # Load the address of the ASCII string
    	lb $t6, 0($a0) # number of days
  	
    	li $t3, 30
	mulu $t6, $t3, $t6
	la $t5, calendar
	addu $t5, $t5, $t6 # $t5 contain the address to be added
	
    	# resultString
    	la $a0, buffer1
  	la $a1, startSlot
    	la $a2, endSlot
    	la $a3, resultType
    	move $t0, $t5
    	j concatenateStrings
doneAndReturn: 
	la $a0, numOfDays  # Load the address of the ASCII string
    	lb $t6, 0($a0) # $t6 number of days  	
    	addi $t6, $t6, 1 # numOfDay ++
  	la $s1, numOfDays
    	sb $t6, ($s1)  
    	j printMenu
	errorFound:
  		#promot that the entered value is not between 8 am - 5 pm
		li $v0, 4         # syscall code for printing string
   		la $a0, errorMsg # load address of day prompt
  		syscall  
		j printMenu
	errorFound1:
		li $v0, 4         # syscall code for printing string
   		la $a0, endSlotSmallerThanStart # load address of day prompt
  		syscall  
  		j printMenu
#------------------------------------------------------------------   	
concatenateStrings:
 # $a0, $a1, $a2, $a3: Addresses of input strings
        # $t0: Address of the result buffer
	 
        # Loop to concatenate str1
        jal copy_loop
        li $t7, ':' 
    	sb $t7, ($t0)              
        addi $t0, $t0, 1    
	li $t7, ' ' 
    	sb $t7, ($t0)             
        addi $t0, $t0, 1   
        
	move $a0, $a1
        # Loop to concatenate str2
        jal copy_loop
        li $t7, '-' 
    	sb $t7, ($t0)              
        addi $t0, $t0, 1    
     
	move $a0, $a2
        # Loop to concatenate str3
        jal copy_loop  
        li $t7, ' ' 
    	sb $t7, ($t0)             
        addi $t0, $t0, 1    
   
	move $a0, $a3
        # Loop to concatenate str4
        jal copy_loop

        # Null-terminate the result string
        sb $zero, 0($t0)

        j doneAndReturn  # Return from the function
#------------------------------------------------------------------   	
 copy_loop:
 	
        # $a0: Address of the current input string
        # $t0: Address of the result buffer
        loop:
            lb $t1, 0($a0)      # Load a byte from the current input string
            beqz $t1, end_copy  # If null terminator is reached, exit loop

            # Skip newline character (ASCII 10)
            beq $t1, 10, skip_newline
            sb $t1, 0($t0)      # Store the byte in the result buffer
            addi $t0, $t0, 1    # Move to the next available position in the result buffer
            skip_newline:

            addi $a0, $a0, 1    # Move to the next character in the input string
            j loop

        end_copy:
            jr $ra  # Return from the loop
#------------------------------------------------------------------   	
updaetAppointment:
	# $t4 contains address of the wanted day
	move $s3, $t4
    	# $t9 contain the number day length
    	addi $t9, $t9, 1 # skipping ':' character'
    	addu $t4, $t4, $t9
    	# now $t4 contain the appointment section of the chosen day 

	li $v0, 4         # syscall code for printing string
	la $a0, updaetOrAddAppiontment # load address of day prompt
  	syscall           # print day prompt
	
    	# Read user input
    	li $v0, 8
    	la $a0, resultType
    	li $a1, 4  
    	syscall
    	
    	#===
    	li $v0, 4         # syscall code for printing string
   	la $a0, startSlotPrompt # load address of day prompt
  	syscall           # print day prompt
  	# Read user input for day
    	li $v0, 8
    	la $a0, startSlot
    	li $a1, 4  
    	syscall
    	
  	la $a0, startSlot
  	jal convert_to_int
	move $t0, $v0 # t0 conatin start slot
  	
  	blt $t0, 1, cont22
  	bgt $t0, 5, cont22
  	
  	addi $t0, $t0, 12
  	
  cont22:
  	blt $t0, 8, errorFound
  	bgt $t0, 17, errorFound
  			
  	 li $v0, 4         # syscall code for printing string
   	 la $a0, endSlotPrompt # load address of day prompt
  	 syscall           # print day prompt
  	# Read user input for day
	li $v0, 8
    	la $a0, endSlot
    	li $a1, 4  
    	syscall
    	
  	la $a0, endSlot
  	jal convert_to_int
	move $t1, $v0 # t1 contain end slot
  	blt $t1, 1, cont33
  	bgt $t1, 5, cont33
	addi $t1, $t1, 12
  cont33:
  	blt $t1, 8, errorFound
  	bgt $t1, 17, errorFound
  	#-----
  	bge $t0, $t1, errorFound1
  	# add appoitment:
    	# ============


move $a3, $t4  # address of the appointment section of the day
la $a1, resultString
li $t9, 0  # Counter for commas
li $t7, 0  # Counter for buffer position

readLoop__1:
    lb $t5, 0($a3)  # Load a byte from the input/result buffer

    # Check if the character is a comma or null terminator
    li $t6, ','  # ASCII code for comma
    beq $t5, $t6, processComma1
    beqz $t5, endRead1

    # Copy the character to the buffer
    sb $t5, 0($a1)
    addi $a3, $a3, 1
    addi $a1, $a1, 1
    addi $t7, $t7, 1

    # Continue the loop
    j readLoop__1

processComma1:
    # Increment the comma count
    addi $t9, $t9, 1
    
       		#---------------------
    		la $a0, resultString
    		jal parseSlotsFunction
 
    		move $t2, $v0
		move $t3, $v1
		move $s0, $s7
		
		blt $t2, 1, nextStep
  		bgt $t2, 5, nextStep
  	
  		addi $t2, $t2, 12
	nextStep:	
		blt $t3, 1, nextStep1
  		bgt $t3, 5, nextStep1
  	
  		addi $t3, $t3, 12
	nextStep1:
	
		# check if there is any conflict	
		bgt $t1, $t2, nextC0
		blt $t0, $t3, nextC0
		j noConflictFound
		
	nextC0:	ble $t1, $t2, nextC1
		bgt $t1, $t3, nextC1
		bge $t0, $t2, nextC1
		j conflictFound
		
	nextC1: blt $t0, $t2, nextC2
		bgt $t1, $t2, nextC2
		j conflictFound
	nextC2:	bge $t0, $t2, nextC3
		blt $t1, $t3, nextC3
		j conflictFound
	nextC3: blt $t0, $t2, endCC
		bge $t0, $t3, endCC
		ble $t1, $t3, endCC
		j conflictFound
   	endCC:
   		j endUpdate
   		
		noConflictFound:
		j moveNextChar1
		
		conflictFound:
		li $s5, 1 
		li $v0, 4         # syscall code for printing string
		la $a0, conflictFoundMsg # load address of day prompt
  		syscall           # print day prompt

   		j endUpdate
        #---------------------

    # Move to the next character in the input/result buffer
 moveNextChar1:   addi $a3, $a3, 1

    # Continue the loop
    j readLoop__1

endRead1:
    	# Null-terminate the buffer
    	sb $zero, 0($a1)
	j endUpdate
addAppiontt:
	# add the appiotment to the calnder 
	
	move $a0, $s3
	jal findStringLength
	move $t0, $v0
	move $s0, $a0 # address of the last byte of the string
	
	#=====
		# add appoitment:
  	la $a0, numOfDays  # Load the address of the ASCII string
    	lb $t6, 0($a0) # number of days
    	# resultString
  	la $a1, startSlot
    	la $a2, endSlot
    	la $a3, resultType
    	move $t0, $s0
    	#----
	li $t7, ' ' 
    	sb $t7, ($t0)             
        addi $t0, $t0, 1   
	move $a0, $a1
        # Loop to concatenate str2
        jal copy_loop
        li $t7, '-' 
    	sb $t7, ($t0)              
        addi $t0, $t0, 1    
     
	move $a0, $a2
        # Loop to concatenate str3
        jal copy_loop  
        li $t7, ' ' 
    	sb $t7, ($t0)             
        addi $t0, $t0, 1    
   
	move $a0, $a3
        jal copy_loop
        # Null-terminate the result string
        sb $zero, 0($t0)

    	#----

	la $a0, numOfDays  # Load the address of the ASCII string
    	lb $t6, 0($a0) # $t6 number of days  	
    	addi $t6, $t6, 1 # numOfDay ++
  	la $s1, numOfDays
    	sb $t6, ($s1)  
    	j printMenu

endUpdate:
	# if $s5 is 1 then there is a conflict
	beqz $s5, addAppiontt
    j printMenu
#------------------------------------------------------------------   	
# Function to parse start and end slots from an appointment string
# Input: $a0 - address of the appointment string
# Output: $v0 - start slot
#         $v1 - end slot
#         $s7 - appointmentType (updated)
parseSlotsFunction:
    li $v0, 0  # start slot
    li $v1, 0  # end slot
    la $s7, appointmentType  # appointmentType (initialize to an empty string)
    li $t9, 0  # 0 if start slot, 1 if end slot

    # Loop to parse characters until a non-digit is encountered
parseLoop_:
    lb $t5, 0($a0)  # Load a byte from the appointment string

    # Check for null terminator
    beqz $t5, endParse_

    # Check if the character is a digit
    blt $t5, 48, checkHyphen_  # Skip hyphen if not a digit
    bgt $t5, 57, checkAppointmentType1_  # this means the appointment type
    beq $t9, 1, endSlotMaker_

    # Convert ASCII to integer and update start slot
    sub $t5, $t5, 48
    mul $v0, $v0, 10
    add $v0, $v0, $t5

    j skip_

endSlotMaker_:
    # Convert ASCII to integer and update end slot
    sub $t5, $t5, 48
    mul $v1, $v1, 10
    add $v1, $v1, $t5

skip_:  # Move to the next character in the appointment string
    addi $a0, $a0, 1

    # Continue the loop
    j parseLoop_

checkHyphen_:
    # Check if the character is a hyphen
    bne $t5, 45, checkSpace_
    addi $a0, $a0, 1
    li $t9, 1
    # Continue the loop
    j parseLoop_

checkSpace_:
    addi $a0, $a0, 1
    j parseLoop_

checkAppointmentType1_:
    # Save the non-digit character to appointmentType
    sb $t5, ($s7)
    addi $s7, $s7, 1  # Move to the next position in appointmentType

    # Move to the next character in the appointment string
    addi $a0, $a0, 1

    # Continue the loop
    j parseLoop_

endParse_:
    # Null-terminate the appointmentType string
    sb $zero, ($s7)
    jr $ra

#------------------------------------------------------------------   	
# Function to find the length of a string in bytes
# Input: $a0 - address of the input string
# Output: $v0 - length of the string in bytes

findStringLength:
    # Initialize length to 0
    li $v0, 0

    # Loop to iterate through each character of the string
    findLengthLoop:
        # Load a byte from the input string
        lb $t1, 0($a0)

        # Check for null terminator (end of string)
        beqz $t1, endFindLength

        # Increment the length
        addi $v0, $v0, 1

        # Move to the next character in the string
        addi $a0, $a0, 1

        # Repeat the loop
        j findLengthLoop

    endFindLength:
    	 # Replace the null terminator with the character to add
    	 li $a1, ','
        sb $a1, 0($a0)

        # Move to the next position after the added character
        addi $a0, $a0, 1
        jr $ra
#------------------------------------------------------------------   	
choice4Branchs:
	jal resetRegistersValues
	la $a0, dayPrompt		
	li $v0, 4
	syscall
	# Read user input
        li $v0, 8            # System call for read_str
        la $a0, buffer1        # Load address of the buffer to store user input
        li $a1, 1024           # Maximum number of characters to read
        syscall
        
    	li $v0, 0     # Resulting integer
    	li $t0, 10    # Multiplier for decimal places
        la $a0, buffer1        # Load address of the buffer to store user input
	jal convert_to_int

    	move $s2, $v0 # store user input (day) in $s2
    	
	la $s1, calendar
	la $t8, 0 #current day 
	
	la $a0, numOfDays  # Load the address of the ASCII string
    	lb $t6, 0($a0) # number of days
 	
	daysLoop3_:
		beq $t6, $t8, exitLoop3_
		li $t2, 30  # Line size is 30 bytes in calendar 
		mul $t3, $t2, $t8  # Multiply number_of_days by 30
		add $t4, $s1, $t3  # Add the result to the base address
		
		move $a0, $t4
    		la $a1, chosenDayAddress
    		move $a2, $s2
    		jal readUntilColon1
    		move $s4, $v0
    		addi $t8, $t8, 1
    		beqz $s4, daysLoop3_
    	exitLoop3_:
		bnez  $s4, DayExists_
		# Print message indicating the day does not exist in the calendar
  		li $v0, 4
   		la $a0, dayErrorMsg
   		syscall
   		 # Print newline
    		li $a0, 10
   		li $v0, 11
    		syscall	
    		j printMenu
    	DayExists_:
    		li $v0, 4
		la $a0, daySucessMsg
    		syscall
    		# print newline
    		li $a0, 10
    		li $v0, 11
   		syscall
   		
   		move $a0, $t4 # address of wanted day
    		li $v0, 4
    		syscall
    		 # Print newline
    		li $a0, 10
   		li $v0, 11
    		syscall
		#----
		# $t4 contains address of the wanted day
		move $s3, $t4
		#=======

		la $a0, deleteAddAppiontment
		li $v0, 4
		syscall
		# Read user input
    		li $v0, 8
    		la $a0,resultType
    		li $a1, 4
    		syscall

    	
    		#===
    		li $v0, 4         # syscall code for printing string
   		la $a0, startSlotPrompt # load address of day prompt
  		syscall           # print day prompt
  		# Read user input for day
    		li $v0, 8
    		la $a0, startSlot
    		li $a1, 4  
    		syscall
    	
  		la $a0, startSlot
  		jal convert_to_int
		move $t0, $v0 # t0 conatin start slot
  	
  		blt $t0, 1, cont222
  		bgt $t0, 5, cont222
  	
  		addi $t0, $t0, 12
  	
  	cont222:
  		blt $t0, 8, errorFound
  		bgt $t0, 17, errorFound
  			
  	 	li $v0, 4         # syscall code for printing string
   	 	la $a0, endSlotPrompt # load address of day prompt
  	 	syscall           # print day prompt
  		# Read user input for day
		li $v0, 8
    		la $a0, endSlot
    		li $a1, 4  
    		syscall
    	
  		la $a0, endSlot
  		jal convert_to_int
		move $t1, $v0 # t1 contain end slot
  		blt $t1, 1, cont333
  		bgt $t1, 5, cont333
		addi $t1, $t1, 12
 	 cont333:
  		blt $t1, 8, errorFound
  		bgt $t1, 17, errorFound
  		#-----
  		bge $t0, $t1, errorFound1
  		# add appoitment:
    		# ============

		
		# Specify the appointment to delete
    		move $s6, $t0  # Start slot to delete
    		move $s7, $t1   # End slot to delete
    		la $s0, resultAppointment
    		sb $zero, ($s0)
		la $s1, buffer1        # Load address of the buffer to store user input
		jal concatenateStrings1
		
		subi $s0, $s0, 1
		li $t0, ':'
		sb $t0, ($s0) 
		addi $s0, $s0, 1
        	sb $zero, 0($s0)  # Store the byte at the end of the first string
        		
		j deleteAppointmentFromDay


		
		j printMenu
#------------------------------------------------------------------ 
# Function to delete an appointment from a specific day
# Input: 
#        $s6 - start slot to delete
#        $s7 - end slot to delete
# Output: None (the modified day string is updated in-place)
deleteAppointmentFromDay:

    	# $t9 contain the number day length
    	addi $t9, $t9, 1 # skipping ':' character'
    	move $s5, $t4 # base address
    	addu $s4, $t4, $t9 # $s4 - address of the day (appointment) string
    	# now $a0 contain the appointment section of the chosen day 
	la $a1, resultString
	li $t8, 0  # Counter for commas
	li $t7, 0  # Counter for buffer position
	move $a3, $s4
readLoop__1_:
    	lb $t5, 0($a3)  # Load a byte from the input/result buffer
    # Check if the character is a comma or null terminator
    	li $t6, ','  # ASCII code for comma
    	beq $t5, $t6, processComma1_
    	beqz $t5, endRead1_
    	addi $t7, $t7, 1
    # Copy the character to the buffer
	sb $t5, 0($a1)
	addi $a3, $a3, 1
	addi $a1, $a1, 1
    # Continue the loop
    j readLoop__1_

processComma1_:
    # Increment the comma count
    addi $t8, $t8, 1
    addi $t7, $t7, 1
    
	
		la $a0, resultType 
		# Input: $a0 - address of the input string
		# Output: $v0 - converted integer in hexadecimal format
		jal convert_to_int
		move $v1, $v0
		la $a0, resultString
		# Input: $a0 - address of the input string
		#Output: $v0 - 0 if "L" is found, 1 if "M" is found, 2 if "OH" is found, -1 otherwise
		jal checkAppointmentType
		addi $v0, $v0, 1
		beq $v0, $v1, conflictFound__

		# $s6 - start slot to delete user input
		# $s7 - end slot to delete user input
    		la $a0, resultString
    		jal parseSlotsFunction

    		move $t2, $v0
		move $t3, $v1
		
		blt $t2, 1, nextStep_
  		bgt $t2, 5, nextStep_
  		addi $t2, $t2, 12
	nextStep_:	
		blt $t3, 1, nextStep1_
  		bgt $t3, 5, nextStep1_
  		addi $t3, $t3, 12
	nextStep1_:
	# test the slots
		
 		beq $t2, $s6, checkT3  # Branch to checkT3 if $t2 equals $s6
		beq $t3, $s7, bothEqual  # Branch to bothEqual if $t3 equals $s7
		j notEqual  # Jump to notEqual if any of the conditions is false

	checkT3:
    	# This block is executed only if $t2 equals $s6
    		beq $t3, $s7, bothEqual  # Branch to bothEqual if $t3 equals $s7
    		j notEqual  # Jump to notEqual if $t3 is not equal to $s7

	bothEqual:
    	 j moveNextChar1_

	notEqual:
  
		# not the slot that we want to delete
		la $s1, resultString 

		jal concatenateStrings1
		
		li $t0, ','
		sb $t0, ($s0) 
		addi $s0, $s0, 1
        	sb $zero, 0($s0)  # Store the byte at the end of the first string

	conflictFound__:
	la $a1, resultString # reset the buffer
	sb $zero, ($a1)	
	
   	moveNextChar1_:
   		addi $a3, $a3, 1
		j readLoop__1_
 
endRead1_:
		la $a0, resultType 
		# Input: $a0 - address of the input string
		# Output: $v0 - converted integer in hexadecimal format
		jal convert_to_int
		move $v1, $v0
		la $a0, resultString
		# Input: $a0 - address of the input string
		#Output: $v0 - 0 if "L" is found, 1 if "M" is found, 2 if "OH" is found, -1 otherwise
		jal checkAppointmentType
		addi $v0, $v0, 1
		beq $v0, $v1, conflictFound__1

		# $s6 - start slot to delete user input
		# $s7 - end slot to delete user input
    		la $a0, resultString
    		jal parseSlotsFunction

    		move $t2, $v0
		move $t3, $v1
		
		blt $t2, 1, nextStep_1
  		bgt $t2, 5, nextStep_1
  		addi $t2, $t2, 12
	nextStep_1:	
		blt $t3, 1, nextStep1_1
  		bgt $t3, 5, nextStep1_1
  		addi $t3, $t3, 12
	nextStep1_1:
	# test the slots
		
 		beq $t2, $s6, checkT3_ # Branch to checkT3 if $t2 equals $s6
		beq $t3, $s7, bothEqual1 # Branch to bothEqual if $t3 equals $s7
		j notEqual_  # Jump to notEqual if any of the conditions is false

	checkT3_:
    	# This block is executed only if $t2 equals $s6
    		beq $t3, $s7, bothEqual1  # Branch to bothEqual if $t3 equals $s7
    		j notEqual_  # Jump to notEqual if $t3 is not equal to $s7

	notEqual_:
  
		# not the slot that we want to delete
		la $s1, resultString # reset the buffer
		jal concatenateStrings1
		
		li $t0, ','
		sb $t0, ($s0) 
		addi $s0, $s0, 1
        	sb $zero, 0($s0)  # Store the byte at the end of the first string
		j moveNextChar1_1
		
	conflictFound__1:
	la $a1, resultString # reset the buffer
	sb $zero, ($a1)	
	
	bothEqual1:
   	moveNextChar1_1:

    	# Null-terminate the buffer
    	sb $zero, 0($a1)
    	
endDeleteLoop:
sb $zero, 0($s0)  # Store the byte at the end of the first string


        move $a0, $s5 
      
               
        # Loop to set each byte to zero
    li $t0, 0        # Initialize a register with zero
    li $t1, 30       # Number of bytes to set to zero

zeroLoop:
    sb $t0, 0($a0)   # Store zero at the current address
    addi $a0, $a0, 1  # Move to the next byte in the buffer
    # Decrement the counter and check if it's zero
    addi $t1, $t1, -1
    bnez $t1, zeroLoop
    
     
        la $a0, resultAppointment
        move $a1, $s5 
   
        jal strcpy             # Jump to the function

      

    	j printMenu

#------------------------------------------------------------------ 
# Function to copy a string from source to destination
strcpy:
    move $t1, $a0              # Copy source address to $t1
    move $t2, $a1              # Copy destination address to $t2
    sb $zero , 0($t2)             # Store the byte to destination
copy_loop_:
    lb $t0, 0($t1)             # Load a byte from source
    beqz $t0, copy_done_       # If the byte is null (end of string), exit loop

    sb $t0, 0($t2)             # Store the byte to destination
    addi $t1, $t1, 1           # Move to the next byte in the source
    addi $t2, $t2, 1           # Move to the next byte in the destination
    j copy_loop_

copy_done_:
    jr  $ra                     # Return to the calling function
#------------------------------------------------------------------ 
# Function: concatenateStrings
# Concatenates two null-terminated strings
# Input: $s0 - address of the first string to append to it
#        $s1 - address of the second string
# Output: None (modifies the string at $s0 in place)
concatenateStrings1:
    # Find the end of the first string

    findEndLoop:
        lb $t0, 0($s0)  # Load a byte from the string
        beqz $t0, endFindEndLoop  # If null terminator is found, exit loop
        addi $s0, $s0, 1  # Move to the next character
        j findEndLoop

    endFindEndLoop:
    # Now, $a0 points to the null terminator of the first string

    # Copy the second string to the end of the first string
    move $a1, $s1  # Address of the second string
    copyLoop:
        lb $t1, 0($a1)  # Load a byte from the second string
        sb $t1, 0($s0)  # Store the byte at the end of the first string
        beqz $t1, endCopyLoop  # If null terminator is found, exit loop
        addi $s0, $s0, 1  # Move to the next character in the first string
        addi $a1, $a1, 1  # Move to the next character in the second string
        j copyLoop

    endCopyLoop:
    jr $ra  # Return from the function
#------------------------------------------------------------------ 
calendarContent:
	la $t0, calendar
	li $t1, 0 #current day
	li $t2, 30
	la $t6, numOfDays
	lb $t7, ($t6)
   	
day_1:	beq $t1, $t7, finish
	mul $t3, $t2, $t1
	addu $t3, $t3, $t0
	
	 # Write to the file
    	li   $v0, 15         # syscall code for write to file (MIPS/Linux)
    	move $a0, $s0        # file descriptor
   	move   $a1, $t3    # load address of the content to write
    	li   $a2, 30        # number of bytes to write
    	syscall              # make the system call
    	
	li   $v0, 15         # syscall code for write to file (MIPS/Linux)
    	move $a0, $s0        # file descriptor
   	la   $a1, newline    # load address of the content to write
    	li   $a2, 2         # number of bytes to write
    	syscall              # make the system call
	
	addi $t1, $t1, 1
	b day_1
	
	finish:
    	jr $ra   # Return from the function
#------------------------------------------------------------------
endProgram:
	    # Open the file for writing
    	li   $v0, 13         # syscall code for open file (MIPS/Linux)
    	la   $a0, dataFile   # load address of the filename
    	li   $a1, 1          # flag: 1 for write, 0 for read
    	li   $a2, 0          # mode: ignored for write
    	syscall              # make the system call

    	move $s0, $v0        # save the file descriptor in $s0
    	jal calendarContent

    	# Close the file
    	li   $v0, 16         # syscall code for close file (MIPS/Linux)
    	move $a0, $s0        # file descriptor
    	syscall              # make the system call
    	
    	# exit the program
	li $v0, 10
	syscall
#------------------------------------------------------------------
