#!/bin/bash

# Android Studio variables
export ANDROID_STUDIO="~/UtilLabs/android/android-studio/bin/"
export PATH=$PATH:"$ANDROID_STUDIO"
alias android-studio="$ANDROID_STUDIO/studio.sh"

# Clean bash history (launched every time bash is started)
alias history_cleaner=`python ~/.bash_history_cleaner.py`
history_cleaner

convert_to_lower() {
	echo "$1" | awk '{print tolower($0)}'
}

#Safety aliases
rm_safety_check() {
	echo "Arguments supplied: $@"
	echo -n "Want to proceed? Are you sure you dont want to use shred (y/n)?: "
	read surety
	surety=`convert_to_lower "$surety"`
	if [ "$surety" == "y" -o "$surety" == "yes" ]
		then
		( set -x ; /bin/rm -v "$@" )
	else
		echo "rm not executed"
	fi
}
alias rm=rm_safety_check

# File shredding
recursive_shred() {
	find $1 -depth -type f -exec shred -v -n 8 -z -u {} \;
}
alias rec_shred=recursive_shred

# grep alias
parser_grep() {
	usage_msg=$(cat <<-END
Usage: grelias <normal grep options> [grelias options] <search term> [Path]
         --exdir=<path1,path2,..>    Excluded directories
         --exfile=<path1,path2,..>   Excluded file patterns
         --includegit                Include .git folders in the search (excluded by default)
         --includecscope             Include cscope.out files in the search (excluded by default)
         --help                      Prints this usage message
END
)
	exdir_args=()
	exfile_args=()
	other_args=()
	includegit=0
	includecscope=0

	while [ "$1" != "" ]; do
		curr_arg="$1"
		param=`echo $curr_arg | awk -F= '{print $1}'`
		value=`echo $curr_arg | awk -F= '{print $2}'`
		case $param in
		--exdir)
			IFS=',' read -ra exdir_arr <<< "$value"
			for edir in "${exdir_arr[@]}"
			do
				exdir_args+=( " --exclude-dir='$edir'" )
			done
			;;
		--exfile)
			IFS=',' read -ra exfile_arr <<< "$value"
			for efile in "${exfile_arr[@]}"
			do
				exfile_args+=( " --exclude='$efile'" )
			done
			;;
		--includegit)
			includegit=1
			;;
		--includecscope)
			includecscope=1
			;;
		-v)
			echo -n "grep -v implies selecting non-matching lines (invert match) and not verbose. Are you sure? (y/n): "
			read usrinp
			usrinp=`convert_to_lower "$usrinp"`
			if [ $usrinp == "y" -o $usrinp == "yes" ]; then
				other_args+=( "-v" )
			else
				echo "Abandoning current search."
				return
			fi
			;;
		--help)
			grep --help
			echo ""
			echo ""
			echo "$usage_msg"
			return
                        ;;
		*)
			other_args+=( "$param" )
			;;
		esac
		shift
	done

	if [ $includegit == 0 ]; then
		exdir_args+=( "--exclude-dir=.git" )
	fi
	if [ $includecscope == 0 ]; then
		exfile_args+=( "--exclude=cscope.out" )
	fi

        ( set -x ; eval `echo -e "grep -nr ${exdir_args[@]} ${exfile_args[@]} ${other_args[@]}"` )
}
export MERGE_DELIM="<<<|>>>"
alias grelias=parser_grep

# PS1 prompt setting
if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[0m\]'
else
	PS1='${debian_chroot:+($debian_chroot)}\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[0m\]'
fi

# History macros
HISTCONTROL=ignoredups:erasedups
HISTSIZE=3000
HISTFILESIZE=5000
