#!/usr/bin/env bash

set -e

PROGRAM_NAME="$(basename ${0})"
PROMPT="$1"
PROMPTS_FILE="/home/${USER}/.prompts"

help()
{
   echo ""
   echo "${PROGRAM_NAME}: $PROGRAM_NAME [prompt]"
   echo "	Save bash prompts for reuse. Prompts are saved to ${PROMPTS_FILE}."
   echo ""
   echo " 	Options:"
   echo "	  prompt	A bash prompt to save (must be double quoted)"
   echo "	  -h		Print this help"
   echo ""
}

for ARG in "$@"
do
    case $ARG in
		-h|-H)	help
			exit
			;;
		*)	continue
			;;
	esac
done

if [ -n "$PROMPT" ]
then
	echo "Expanded prompt: ${PROMPT@P}"
	read -n 2 -p "Save this prompt? (y/n)? "

	case "$REPLY" in
        y|Y)
			read -p "Enter prompt name: " PROMPT_NAME
			if [ "$(grep -e ^${PROMPT_NAME}$'\t' $PROMPTS_FILE | awk -F '\t' '{print $1}')" = "$PROMPT_NAME" ]
			then
				echo "Prompt with name "$PROMPT_NAME" already exists."
				exit 1
			fi
			echo -ne "${PROMPT_NAME}\t" >> $PROMPTS_FILE
			echo "$PROMPT" >> $PROMPTS_FILE
			echo "Saved \"${PROMPT_NAME}\"."
			exit 0
			;;
		*)	
			echo "Prompt not saved."
			exit 1
			;;
	esac
else
	if [ -f "$PROMPTS_FILE" ]
	then
		LINE_NO=1
		while IFS=$'\t' read -r name prompt
		do
			echo "${LINE_NO}). $name: ${prompt@P}"
			((LINE_NO++))
		done < "$PROMPTS_FILE"
		echo ""
		read -n 3 -p "Select prompt: " SELECTED_PROMPT
		if [[ "$SELECTED_PROMPT" =~ ^[[:digit:]]{1,3}$ ]]
		then
			PROMPT=$(sed "${SELECTED_PROMPT}q;d" $PROMPTS_FILE | awk -F '\t' '{print $2}')
			cat <<-EOF
				
				Run this command to apply prompt to current session:
					export PS1="${PROMPT}"

				Or, make the change permanent by modifying your .bashrc:
					echo 'export PS1="${PROMPT}"' >> /home/${USER}/.bashrc

			EOF
		else
			echo "Invalid entry."
			exit 1
		fi
	else
		echo "No prompts to display.s"
		exit 1
	fi
fi