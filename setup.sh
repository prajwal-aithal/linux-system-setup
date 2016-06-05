#!/bin/bash

usage() {
	echo "Usage: $0 [--help]"
	echo "	Sets up basic custom script in new Linux system"
	exit 1
}

confirm_file_remove() {
	file=$1
	issudo=$2

	echo -n "  Removing $file. Continue (y/n)?: "
	read user_inp
	user_inp="$(echo $user_inp | awk '{print tolower($0)}')"
	if [ $user_inp == "y" -o $user_inp == "yes" ]
	then
		echo "    Removing $file."
		if $issudo; then
			( set -x; sudo rm $file )
		else
			( set -x; rm $file )
		fi
		return 1
	else
		echo "    Current copy of $file not removed"
		return 0
	fi
}

verify_file_link() {
	targetfile=$1
	sourcefile=$2
	issudo=$3

	confirm_file_remove $targetfile $issudo
	rm_confirm=$?
	if [ $rm_confirm == 1 ]
	then
		echo "  Linking $targetfile to $sourcefile"
		if $issudo; then
			( set -x; sudo ln -s $sourcefile $targetfile )
		else
			( set -x; ln -s $sourcefile $targetfile )
		fi
	fi
}

verify_file_copy() {
	sourcefile=$1
	targetfile=$2
	issudo=$3

	confirm_file_remove $targetfile $issudo
	rm_confirm=$?
	if [ $rm_confirm == 1 ]
	then
		echo "  Copying $sourcefile to $targetfile"
		if $issudo; then
			( set -x; sudo cp $sourcefile $targetfile )
		else
			( set -x; cp $sourcefile $targetfile )
		fi
	fi
}

for arg in "$@"
do
	case $arg in
	-h|--help)
		usage
		;;
	*)
		usage
		;;
	esac
done

# Find the script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Setting up contents of $script_dir"

# Setup .bash_history_cleaner.py (removes current copy)
echo -e "\nBash history cleaner script setup"
verify_file_link ~/.bash_history.json $script_dir/bash_history.json false
verify_file_link ~/.bash_history_cleaner.py $script_dir/bash_history_cleaner.py false

echo -e "\nBash aliases setup"
# Setup .bash_aliases to link to the bash_aliases of this repo
# Removes the current copy of .bash_aliases
verify_file_link ~/.bash_aliases $script_dir/bash_aliases false

echo -e "\nAd-blocker hosts setup"
# Setting custom hosts file
verify_file_copy $script_dir/ad-blocker-hosts /etc/hosts true
