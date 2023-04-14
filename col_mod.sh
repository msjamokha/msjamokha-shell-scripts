#!/bin/sh
#
# col_mod : Delete columns or swap 2 columns, depending on user input.
#

prog_name=$(basename "$0")
fields_delete=
fields_swap=
ppe_op=
file_ppe=
delimiter=","

info_usage(){
	case "$1" in
		0)	cat <<- EOF
				When provided a file, this script can either swap two specific columns, or
				delete all of any number of specified columns.

				It makes the following assumptions:
					-The provided file has values separated by a delimiter character (default ",")
					-The user either wants to delete columns or swap, not both

				Output is sent to standard output by default.
			EOF
			;;
		1)	printf "Error: no arguments provided\n" >&2
			;;	
		2)	printf "Error: file %s not found or is not readable\n" "$2" >&2
			;;
		3)	printf "Error: bad or unknown argument provided: %s\n" "$2" >&2
			;;
		4)	printf "Error: duplicate argument provided for %s\n" "$2" >&2
			;;
		5)	printf "Error: \'%s\' is not a valid field\n" "$2" >&2
			;;
		6)	printf "Error: two operations specified, expected one\n" >&2
			;;
		7)	printf "Error: no operation specified, expected one\n" >&2
			;;
		8)	printf "Error: swap must be done on different fields\n" >&2
			;;
		9)	printf "Error: specified swap fields were out of range\n" >&2
			;;
	esac
	printf "\n%s: usage: %s [--swap col1,col2 | --delete col] [-d DELIMITER] --file FILE\n" "$prog_name" "$prog_name" 
	return
}

col_swap(){
	# Retrieve the column numbers from the swap argument
	IFS="," read col1 col2 <<- EOF
	$1
	EOF
	
	# Retrieve the total number of columns
	col_max=$(head -1 "$2" | sed "s/[^$delimiter]//g" | wc -c)

	# Determine if the user-specified swap numbers are out of range
	[ "$col1" -le "0" ] && info_usage "9" && return 1
	[ "$col2" -le "0" ] && info_usage "9" && return 1
	[ "$col1" -gt "$col_max" ] && info_usage "9" && return 1
	[ "$col2" -gt "$col_max" ] && info_usage "9" && return 1
	
	arg_awk="{ print "
	if [ "$col1" -lt "$col2" ]; then
		i=1
		while [ "$i" -lt "$col1" ]; do
			# arg_awk="$arg_awk"$(printf "\$$i \""$delimiter"\" ")
			arg_awk="$arg_awk"$(printf "$%s \"%s\" " "$i" "$delimiter")
			i=$((i+1))
		done
		arg_awk="$arg_awk"$(printf "$%s \"%s\" " "$col2" "$delimiter")
		i=$((i+1))
		while [ "$i" -lt "$col2" ]; do
			arg_awk="$arg_awk"$(printf "$%s \"%s\" " "$i" "$delimiter")
			i=$((i+1))
		done
		# i has reached col2 val
		if [ "$i" -eq "$col_max" ]; then
			arg_awk="$arg_awk"$(printf "$%s }" "$col1") 
		else
			arg_awk="$arg_awk"$(printf "$%s \"%s\" " "$col1" "$delimiter")
			i=$((i+1))
			while [ "$i" -lt "$col_max" ]; do
				arg_awk="$arg_awk"$(printf "$%s \"%s\" " "$i" "$delimiter")
				i=$((i+1))
			done
			arg_awk="$arg_awk"$(printf "$%s }" "$i")
		fi
	elif [ "$col1" -gt "$col2" ]; then
		i=1
		while [ "$i" -lt "$col2" ]; do
			arg_awk="$arg_awk"$(printf "$%s \"%s\" " "$i" "$delimiter")
			i=$((i+1))
		done
		arg_awk="$arg_awk"$(printf "$%s \"%s\" " "$col1" "$delimiter")
		i=$((i+1))
		while [ "$i" -lt "$col1" ]; do
			arg_awk="$arg_awk"$(printf "$%s \"%s\" " "$i" "$delimiter")
			i=$((i+1))
		done
		# i has reached col1 val
		if [ "$i" -eq "$col_max" ]; then
			arg_awk="$arg_awk"$(printf "$%s }" "$col2")
		else
			arg_awk="$arg_awk"$(printf "$%s \"%s\" " "$col2" "$delimiter")
			i=$((i+1))
			while [ "$i" -lt "$col_max" ]; do
				arg_awk="$arg_awk"$(printf "$%s \"%s\" " "$i" "$delimiter")
				i=$((i+1))
			done
			arg_awk="$arg_awk"$(printf "$%s }" "$i")
		fi
	else
		info_usage "8"
		return 1
	fi
	awk -F"$delimiter" "$arg_awk" "$2"
	return
}

col_del(){
	# Retrieve the total number of columns
	col_max=$(head -1 "$2" | sed "s/[^$delimiter]//g" | wc -c)
	arg_awk="{ print "

	i=1
	while [ "$i" -lt "$col_max" ]; do
		# If current field is not being deleted
		if [ "$i" -ne "$1" ]; then
			arg_awk="$arg_awk"$(printf "$%s " "$i")
			# If the max field is being deleted and is not next, place delimiter
			if [ "$1" -eq "$col_max" ] && [ "$((i+1))" -ne "$col_max" ]; then
				arg_awk="$arg_awk"$(printf "\"%s\" " "$delimiter")	
			# If the max field is not being deleted, always place delimiter
			elif [ "$1" -ne "$col_max" ]; then
				arg_awk="$arg_awk"$(printf "\"%s\" " "$delimiter")	
			fi
		fi
		i=$((i+1))
	done
	if [ "$i" -ne "$1" ]; then # If current field is last field and not being deleted
		arg_awk="$arg_awk"$(printf "$%s }" "$i")
	else # If current field is last field and being deleted
		arg_awk="$arg_awk"$(printf " }")
	fi

	awk -F"$delimiter" "$arg_awk" "$2"
	return
}

if [ -n "$1" ]; then # Check if arguments were supplied or not
	while [ -n "$1" ]; do # Loop through the supplied arguments
		case "$1" in
			--file)		shift
						# If the file exists and is accessible
						if [ -f "$1" ] && [ -r "$1" ]; then
							# If this is a duplicate argument
							[ -n "$file_ppe" ] && info_usage "4" "file" && exit 1
							file_ppe="$1"
						else
							info_usage "2" "$(basename "$1")"
							exit 1
						fi
						;;
			--delete)	shift
						# If this is a duplicate argument
						[ -n "$fields_delete" ] && info_usage "4" "delete" && exit 1
						# If swap was already specified
						[ -n "$fields_swap" ] && info_usage "6" && exit 1
						# If argument is not a number
						$(echo "$1" | grep -Eq "[^0-9]") && info_usage "5" "$1" && exit 1
						fields_delete="$1"
						ppe_op="delete"
						;;
			--swap)		shift
						# If this is a duplicate argument
						[ -n "$fields_swap" ] && info_usage "4" "swap" && exit 1
						# If delete was already specified
						[ -n "$fields_delete" ] && info_usage "6" && exit 1
						fields_swap="$1"
						ppe_op="swap"
						;;
			--help) 	info_usage "0"
						exit
						;;
			-d)			shift
						delimiter="$1"
						;;
			*)			info_usage "3" "$1"
						exit 1
						;;
		esac
		shift
	done
else
	info_usage "1"
	exit 1
fi
case "$ppe_op" in
	delete)	col_del "$fields_delete" "$file_ppe" || exit 1
			;;
	swap)	col_swap "$fields_swap" "$file_ppe" || exit 1
			;;
	*)		info_usage "7"
			exit 1
			;;
esac
