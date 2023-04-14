#!/bin/sh
#
# mastermind : An implementation of the code breaker game "Mastermind"
# for the POSIX shell. 10 symbols, 4 digit codes.
#

info_mesg(){
# Provide feedback for bad user input for a specific numbered scenario
	case "$1" in
		1)	printf "Invalid amount of guesses. Try again.\n"
		;;
		2)	printf "Too many digits. Try again.\n"
		;;
		3)	printf "Your guess must be 4-digits long.\n"
		;;
		4)	printf "Your guess must only consist of numbers.\n"
		;;
	esac
}

is_integer(){
# Output "1" if input 1 is an integer
	case "$1" in
		# The string is not an integer
		*[![:digit:]]*)		return 0
		;;
		# The string is blank
		'')					return 0
		;;
		# None of the above
		*)					return 1
		;;
	esac
}

check_code(){
	# Compares the guessed code (2) to the correct code (1)

	# White and Red points
	red_score=0
	white_score=0

	# Markers for guess & answer digit positions that already gave red points for that turn
	red_marker1=""
	red_marker2=""
	red_marker3=""
	red_marker4=""
	
	# Markers for answer digit positions that already gave white points for that turn
	white_marker1=""
	white_marker2=""
	white_marker3=""
	white_marker4=""

	# Look for the red points
	i=1
	while [ "$i" -lt 5 ]; do
		ans_digit=$(echo "$1" | cut -c "$i")
		guess_digit=$(echo "$2" | cut -c "$i")

		# If a red point is found, block the position from counting white points
		case "$i" in
			1)	if [ "$ans_digit" = "$guess_digit" ]; then
					red_score=$((red_score+1))
					# Mark the guess digit position to prevent guessing with it again
					red_marker1="$i"
				fi
				;;
			2)	if [ "$ans_digit" = "$guess_digit" ]; then
					red_score=$((red_score+1))
					# Mark the guess digit position to prevent guessing with it again
					red_marker2="$i"
				fi
				;;
			3)	if [ "$ans_digit" = "$guess_digit" ]; then
					red_score=$((red_score+1))
					# Mark the guess digit position to prevent guessing with it agian
					red_marker3="$i"
				fi
				;;
			4)	if [ "$ans_digit" = "$guess_digit" ]; then
					red_score=$((red_score+1))
					# Mark the guess digit position to prevent guessing with it again
					red_marker4="$i"
				fi
				;;
		esac
		i=$((i+1))
	done

	# Look for the white points
	i=1
	while [ "$i" -lt 5 ]; do
		# Check if the guess digit already gave a red point
		white_check=0
		case "$i" in
			1)	[ "$i" != "$red_marker1" ] && white_check=1 
				;;
			2)	[ "$i" != "$red_marker2" ] && white_check=1	
				;;
			3)	[ "$i" != "$red_marker3" ] && white_check=1 
				;;
			4)	[ "$i" != "$red_marker4" ] && white_check=1
				;;
		esac
		guess_digit=$(echo "$2" | cut -c "$i")
		if [ "$white_check" -eq 1 ]; then
			j=1
			while [ "$j" -lt 5 ]; do
				ans_digit=$(echo "$1" | cut -c "$j")
				case "$j" in
					1)	# If answer digit didn't already give red point and if there's a match
						if [ "$guess_digit" = "$ans_digit" ] && [ "$j" != "$red_marker1" ]; then
							# If guess digit didn't already give a white point
							if echo "$guess_digit" | grep -q "$white_marker1"; then
								# Add white points and add mark the answer position as "already scored"
								white_score=$((white_score+1))
								white_marker1="$white_marker1""$j"
							fi
						fi
						;;
					2)	# If answer digit didn't already give red point and if there's a match
						if [ "$guess_digit" = "$ans_digit" ] && [ "$j" != "$red_marker2" ]; then
							# If guess digit didn't already give a white point
							if echo "$guess_digit" | grep -q "$white_marker2"; then
								# Add white points and add mark the answer position as "already scored"
								white_score=$((white_score+1))
								white_marker2="$white_marker2""$j"
							fi
						fi
						;;
					3)	# If answer digit didn't already give red point and if there's a match
						if [ "$guess_digit" = "$ans_digit" ] && [ "$j" != "$red_marker3" ]; then
							# If guess digit didn't already give a white point
							if echo "$guess_digit" | grep -q "$white_marker3"; then
								# Add white points and add mark the answer position as "already scored"
								white_score=$((white_score+1))
								white_marker3="$white_marker3""$j"
							fi
						fi
						;;
					4)	# If answer digit didn't already give red point and if there's a match
						if [ "$guess_digit" = "$ans_digit" ] && [ "$j" != "$red_marker4" ]; then
							# If guess digit didn't already give a white point
							if echo "$guess_digit" | grep -q "$white_marker4"; then
								# Add white points and add mark the answer position as "already scored"
								white_score=$((white_score+1))
								white_marker4="$white_marker4""$j"
							fi
						fi
						;;
				esac
				j=$((j+1))
			done
		fi
		i=$((i+1))
	done
	# Output the score of this guess
	printf "\nRed x %d\nWhite x %d\n" "$red_score" "$white_score"
	# Return 0 if the guess was correct
	if [ "$red_score" -eq 4 ]; then
		return 0
	else
		return 1
	fi
}

clear
printf "Mastermind for the POSIX Shell\nWritten by Mikal Jamokha\n"
printf "\nThe code consists of 4-digits, which can be any number from 0 through 9.\n"

# Determine the player name
printf "\nEnter your name (default: %s) > " "$USER"
read
username="${REPLY:-$USER}"

# Determine the number of allowed guesses
input_loop=1
while [ "$input_loop" -eq "1" ]; do
	# ui_prompt="\nEnter the maximum number of guesses > "
	printf "\nEnter the maximum number of guesses (default: 20) > "
	read
	max_guess="${REPLY:-20}"
	if is_integer "$max_guess"; then
		printf "\n"
		info_mesg "1"
	elif [ "$max_guess" -le "0" ]; then
		printf "\n"
		info_mesg "1"
	else
		input_loop=0
	fi
done

# Generate the secret code
rand_num="$(od -A n -t u -N 2 /dev/urandom | tr -d ' ')"
n_code=$(echo "$rand_num" | cut -c 1-4)

# Begin the game
turn_num=1
input_loop=1
clear
# Prompt for a guess while there are guesses remaining
while [ "$turn_num" -le "$max_guess" ]; do
	# Clear the guess string
	a_code=
	printf "Turn %d/%d\n" "$turn_num" "$max_guess"
	# Keep prompting for a guess until a valid guess code is received
	while [ "$input_loop" -eq "1" ]; do
		printf "Enter 4-digit guess > " ; read
		# If the guess has too many or too few digits
		if [ "${#REPLY}" -ne "4" ]; then
			info_mesg "3"
		# If the guess is not an integer
		elif is_integer "$REPLY"; then
			info_mesg "4"
		# Valid input received, loop can be closed
		else
			a_code="$REPLY"
			input_loop=0
		fi
	done
	# If the guess was correct then end the game
	if check_code "$n_code" "$a_code"; then
		printf "\n%s won the game in %d turns.\n" "$username" "$turn_num"
		break
	# The guess was wrong and the player uses up one of their guesses
	else
		turn_num=$((turn_num+1))	
	fi
	input_loop=1
done
# If the player runs out of turns, then they lose the game
[ "$turn_num" -gt "$max_guess" ] && printf "You are out of turns!\nThe answer was: %d\n" "$n_code"
# Visual feedback that the game script has finished executing gracefully
printf "\nGAME OVER\n"
