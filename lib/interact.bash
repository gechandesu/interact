#!/usr/bin/env bash
#   _
#  | |       _                             _
#  | |____ _| |_ _____  ____ _____  ____ _| |_
#  | |  _ (_   _) ___ |/ ___|____ |/ ___|_   _)
#  | | | | || |_| ____| |   / ___ ( (___  | |_
#  |_|_| |_| \__)_____)_|   \_____|\____)  \__)
#
#  Bash powered interactive interfaces.
#
#  Interact is Bash functions library that implements some
#  interactive elements like menus, checkboxes and others.
#  You can use Interact instead of Whiptail and Dialog.
#  Interact depends only Bash native commands and basic utils.

menu() {
    # Interactive menu
    #
    # Return string SELECTED_ITEM from array.
    # Array must be passed as argument.
    #
    # Variables:
    #   MENU_PROMPT -- string with prompt message;
    #   MENU_INDENT -- string with intentation chars;
    #   MENU_HELP   -- string with help message.

    local menu_items=("$@") # array of items
    local inp=              # reset input
    local pos=0             # initial cursor position

    tput smcup      # save screen contents
    tput civis      # hide cursor

    while [[ ! "$inp" =~ [qQ] ]]; do
        clear  # clear screen

        if [ "$MENU_PROMPT" ]
        then echo -e "$MENU_PROMPT"
        else echo -e "Select item:\n"
        fi

        # Print menu items
        for i in "${!menu_items[@]}"; do
            [ "$MENU_INDENT" ] && echo -en "$MENU_INDENT"
            # Highlight selected item (invert colors)
            if [ $i -eq $pos ]
            then echo -e "> \e[7m${menu_items[${i}]}\e[27m"
            else echo -e "  ${menu_items[${i}]}"
            fi
        done

        # Print help text
        if [ ! "$MENU_HELP" ]; then
        tput cup $(tput lines) 0
        echo -en \
        "\e[7mUse HJKL or arrow keys to move, Enter to select, q to quit\e[27m"
        tput home
        else echo -e "$MENU_HELP"
        fi

        # Read input (including arrow keys)
        inp=
        local escape_char=$(printf "\u1b")
        read -r -s -n 1 inp # get 1 character
        # Read 2 more chars
        if [[ $inp == $escape_char ]]; then read -r -s -n 2 inp; fi

        case "$inp" in
            [[hHjJ]|'[A'|'[D' )  pos=$(( $pos - 1 ))   ;; # move up
            []kKlL]|'[B'|'[C' )  pos=$(( $pos + 1 ))   ;; # move down
            '' )  SELECTED_ITEM="${menu_items[${pos}]}"; break  ;; # enter
        esac

        # Jump to last item if user press "up" when pos=0 and vice versa
        if [ $pos -lt 0 ]; then pos=$(( ${#menu_items[@]} - 1 )); fi
        if [ $pos -gt $(( ${#menu_items[@]} - 1 )) ]; then pos=0; fi
    done

    tput rmcup  # restore screen contents
    tput cnorm  # show terminal cursor
}

checklist() {
    # Interactive checklist
    #
    # Return string CHECKED_ITEMS from array.
    # Array must be passed as argument.
    #
    # Variables:
    #   CHECK_PROMPT -- string with prompt message;
    #   CHECK_INDENT -- string with intentation chars;
    #   CHECK_HELP   -- string with help message.

    local checklist_items=("$@") # array of items
    local inp=              # reset input
    local pos=0             # initial cursor position

    tput smcup      # save screen contents
    tput civis      # hide terminal cursor

    while [[ ! "$inp" =~ [qQ] ]]; do
        clear  # clear screen

        if [ "$CHECK_PROMPT" ]
        then echo -e "$CHECK_PROMPT"
        else echo -e "Check items:\n"
        fi

        # Print menu items
        for i in "${!checklist_items[@]}"; do
            [ "$CHECK_INDENT" ] && echo -en "$CHECK_INDENT"

            if [[ "${checked[@]}" =~ "${checklist_items[${i}]}" ]]
            then marker="[x] "
            else marker="[ ] "
            fi

            # Highlight selected item (invert colors)
            if [ $i -eq $pos ]
            then echo -e "> \e[7m${marker}${checklist_items[${i}]}\e[27m"
            else echo -e "  ${marker}${checklist_items[${i}]}"
            fi
        done

        # Print help text
        if [ ! "$CHECK_HELP" ]; then
        tput cup $(tput lines) 0
        echo -en \
        "\e[7mUse HJKL or arrow keys to move, Enter to check, q to quit\e[27m"
        tput home
        else echo -e "$CHECK_HELP"
        fi

        # Read input (including arrow keys)
        inp=
        local escape_char=$(printf "\u1b")
        read -r -s -n 1 inp # get 1 character
        # Read 2 more chars
        if [[ $inp == $escape_char ]]; then read -r -s -n 2 inp; fi

        case "$inp" in
            [[hHjJ]|'[A'|'[D' )  pos=$(( $pos - 1 ))   ;; # move up
            []kKlL]|'[B'|'[C' )  pos=$(( $pos + 1 ))   ;; # move down
            '' )
                # Check / uncheck items
                if [[ "${checked[@]}" =~ "${checklist_items[${pos}]}" ]]
                then
                    # Uncheck item
                    checked=( "${checked[@]/${checklist_items[${pos}]}}" )
                else
                    # Check new item
                    checked+=("${checklist_items[${pos}]}")
                fi
                # Automove cursor
                [ $pos -lt $(( ${#checklist_items[@]} - 1 )) ] \
                && pos=$(( $pos + 1 ));;
        esac

        # Jump to last item if user press "up" when pos=0 and vice versa
        if [ $pos -lt 0 ]; then pos=$(( ${#checklist_items[@]} - 1 )); fi
        if [ $pos -gt $(( ${#checklist_items[@]} - 1 )) ]; then pos=0; fi
    done

    # Remove blank items from array
    for item in "${checked[@]}"; do
        if [[ "$item" != "" ]]; then
            CHECKED_ITEMS+=("$item")
        fi
    done

    clear       # clear screen
    tput rmcup  # restore screen contents
    tput cnorm  # show terminal cursor
}

messagebox() {
    # Message box
    #
    # Variables:
    #   MSGBOX_TITLE    -- title (centered and bold);
    #   MSGBOX_WIDTH    -- terminal width. Default: 75 cols;
    #   MSGBOX_HELP     -- help message.
    tput smcup      # save screen contents
    tput civis  # hide terminal cursor
    clear       # clear screen

    local w=""
    [ "$MSGBOX_WIDTH" ] && w="$MSGBOX_WIDTH" || w=75

    if [ "$MSGBOX_TITLE" ]; then
        local hw=$(( ( ( $w - ${#MSGBOX_TITLE} ) - 2 ) / 2 ))
        local chars=0
        local filler=""
        while [ $chars -ne $hw ]; do filler+=" "; let chars++; done
        MSGBOX_TITLE=$(tr '[:lower:]' '[:upper:]' <<< ${MSGBOX_TITLE})
        echo -e "$filler \e[1m$MSGBOX_TITLE\e[0m $filler"
    fi

    echo -e "$@" #| fmt --width="$w" # diplay message

    if [ "$MSGBOX_HELP" ]; then
        echo -e "$MSGBOX_HELP"
    else
        tput cup $(tput lines) 0
        echo -en "\e[7mPress any key to quit\e[27m"
        tput home
    fi

    read -r -s -n 1 inp
    case "$inp" in
        *       )   clear -x; tput rmcup; tput cnorm; return 0;;
    esac
}

yesno() {
    # Yes/No interactive dialog
    #
    # Variales:
    #   ASSUME_YES  -- skip dialog, return "Yes";
    #   YN_INDENT   -- indent;
    #   YN_HELP     -- help text.

    [ "$ASSUME_YES" ] && return 0

    tput smcup  # save screen contents
    tput civis  # hide terminal cursor

    local pos=0
    local yn=( Yes No )
    local answer=
    local prompt="$@"

    while [[ ! "$inp" =~ [qQ] ]]; do
        clear

        if [ "$prompt" ]
        then echo -e "$prompt"
        else echo -e "Continue?\n"
        fi

        for i in "${!yn[@]}"; do
            [ "$YN_INDENT" ] && echo -en "$YN_INDENT"

            if [ $i -eq $pos ]
            then echo -en "> \e[7m${yn[${i}]}\e[27m\t"
            else echo -en "  ${yn[${i}]}\t"
            fi
        done

        if [ "$YN_HELP" ]; then
            echo -en "$YN_HELP"
        else
            tput cup $(tput lines) 0
            echo -en "\e[7mY - yes, N - no, q to qiut\e[27m"
            tput home
        fi

        # Read input (including arrow keys)
        local inp=
        local escape_char=$(printf "\u1b")
        read -r -s -n 1 inp # get 1 character
        # Read 2 more chars
        if [[ $inp == $escape_char ]]; then read -r -s -n 2 inp; fi

        case "$inp" in
            [[hHjJ]|'[A'|'[D' )  pos=$(( $pos - 1 ))   ;; # move up
            []kKlL]|'[B'|'[C' )  pos=$(( $pos + 1 ))   ;; # move down
            [yY]              )  answer=Yes; break     ;;
            [nN]              )  answer=No;  break     ;;
            '' ) answer="${yn[${pos}]}"; break  ;; # enter
        esac

        # Jump to last item if user press "up" when pos=0 and vice versa
        if [ $pos -lt 0 ]; then pos=$(( ${#yn[@]} - 1 )); fi
        if [ $pos -gt $(( ${#yn[@]} - 1 )) ]; then pos=0; fi
    done

    case $answer in
        Yes) answer=0;;
        No) answer=1;;
    esac

    tput rmcup  # restore screen
    tput cnorm  # show cursor

    return $answer  # return exit code
}
