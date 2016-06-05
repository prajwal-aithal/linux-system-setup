#!/bin/bash

# Android Studio variables
export ANDROID_STUDIO="~/EvoluoLabs/android/android-studio/bin/"
export PATH=$PATH:"$ANDROID_STUDIO"
alias android-studio="$ANDROID_STUDIO/studio.sh"

# Clean bash history (launched every time bash is started)
alias history_cleaner=`python ~/.bash_history_cleaner.py`
history_cleaner

# rm alias
rm_script() {
	rmargs="$@"
	echo "rm $rmargs"
	echo -n "Sure (y/n)?: "
	read user_inp
	user_inp="$(echo $user_inp | awk '{print tolower($0)}')"
	if [ $user_inp == "y" -o $user_inp == "yes" ]
	then
		rm -v $rmargs
	else
		echo "rm not executed"
	fi
}
alias rm=rm_script

# grep alias
grep_scripter() {
	usage_msg="\n\nUsage: grelias  --exdir=<list of comma separated directories to be excluded>\n\t\t--exfile=<list of comma separated file patterns to be excluded>\n\t\t--includegit (Includes the .git directory which is by default ignored)"

	exclude_dirs=
	exclude_files=
	includegit=0
	other_args=
	for arg in "$@"
	do
		case $arg in
		--exdir=*)
			exdirpath="${arg#*=}"
			for exdir in ${exdirpath//,/ }
			do
				exclude_dirs="$exclude_dirs --exclude-dir=$exdir"
			done
			shift
			;;
		--exfile=*)
			exfilepath="${arg#*=}"
			for exfile in ${exfilepath//,/ }
			do
				exclude_files="$exclude_files --exclude=$exfile"
			done
			shift
			;;
		--includegit)
			includegit=1
			shift
			;;
		-?|-h|--help)
			grep --help
			echo -e "$usage_msg"
			return
			;;
		*)
			other_args="$other_args $arg"
			shift
			;;
		esac
	done

	# Exclude .git if --includegit is not specified
	if [ $includegit == 0 ]; then
		exclude_dirs="$exclude_dirs --exclude-dir=.git"
	fi

	( set -x; grep -rn $exclude_dirs $exclude_files $other_args )
}
alias grelias=grep_scripter
