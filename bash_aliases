#!/bin/bash

# Android Studio variables
export ANDROID_STUDIO="~/UtilLabs/android/android-studio/bin/"
export PATH=$PATH:"$ANDROID_STUDIO"
alias android-studio="$ANDROID_STUDIO/studio.sh"

# Clean bash history (launched every time bash is started)
alias history_cleaner=`python ~/.bash_history_cleaner.py`
history_cleaner

function convert_to_lower {
	echo "$1" | awk '{print tolower($0)}'
}

#Safety aliases
function rm_safety_check {
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
function recursive_shred {
	find $1 -depth -type f -exec shred -v -n 8 -z -u {} \;
}
alias rec_shred=recursive_shred

# grep alias
function parser_grep {
	usageMsg=$(cat <<-END
Usage: grelias <normal grep options> [grelias options] <search term> [Path]
         --exdir=<path1,path2,..>    Excluded directories
         --exfile=<path1,path2,..>   Excluded file patterns
         --includegit                Include .git folders in the search (excluded by default)
         --includecscope             Include cscope.out files in the search (excluded by default)
         --help                      Prints this usage message
END
)
	exdirArgs=()
	exfileArgs=()
	otherArgs=()
	includeGit=0
	includeCscope=0

	while [ "$1" != "" ]; do
		currArg="$1"
		param=`echo $currArg | awk -F= '{print $1}'`
		value=`echo $currArg | awk -F= '{print $2}'`
		case $param in
		--exdir)
			IFS=',' read -ra exdirArr <<< "$value"
			for edir in "${exdirArr[@]}"
			do
				exdirArgs+=( " --exclude-dir='$edir'" )
			done
			;;
		--exfile)
			IFS=',' read -ra exfileArr <<< "$value"
			for efile in "${exfileArr[@]}"
			do
				exfileArgs+=( " --exclude='$efile'" )
			done
			;;
		--includegit)
			includeGit=1
			;;
		--includecscope)
			includeCscope=1
			;;
		-v)
			echo -n "grep -v implies selecting non-matching lines (invert match) and not verbose. Are you sure? (y/n): "
			read usrInp
			usrInp=`convert_to_lower "$usrInp"`
			if [ $usrInp == "y" -o $usrInp == "yes" ]; then
				otherArgs+=( "-v" )
			else
				echo "Abandoning current search."
				return
			fi
			;;
		--help)
			grep --help
			echo ""
			echo ""
			echo "$usageMsg"
			return
                        ;;
		*)
			otherArgs+=( "$param" )
			;;
		esac
		shift
	done

	if [ $includeGit == 0 ]; then
		exdirArgs+=( "--exclude-dir=.git" )
	fi
	if [ $includeCscope == 0 ]; then
		exfileArgs+=( "--exclude=cscope.out" )
	fi

        ( set -x ; eval `echo -e "grep -nr ${exdirArgs[@]} ${exfileArgs[@]} ${otherArgs[@]}"` )
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
