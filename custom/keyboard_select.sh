#!/usr/bin/env bash

#
#  Select BT keyb if so desired
#

# Function to capture keypress
capture_keypress() {
    # Disable terminal line buffering and input echoing
    stty -echo -icanon

    # Read a single character
    IFS= read -r -n 1 key

    # Enable terminal line buffering and input echoing
    stty echo icanon

    # Get the octal representation of the captured key
    octal=$(printf "%o" "'$key'")

    # Print the captured key and its octal representation
    # echo "Key pressed: $key"
    # echo "Octal representation: $octal"
}

select_keyboard() {
    text="
Since most iOS keyboards do not havededicated PageUp, PageDn, Home and End
keys, this is a workarround to map Escape + arrows to those keys.
Currently this selection is only active inside tmux.
Be aware that the drawback of using this is that in order to generate Escape
inside tmux, you need to hit Esc twice. If this outweighs the benefit of
having the additional navigation keys only you can decide.

To make it slightly more cumbersome, there is no way to detect what
keyboard is connected from within iSH, but typically You wont change keyboard
between deploys of iSH, so just pick the one you used before.

If you want to enable this feature, hit the key you would use as Esc on your
keyboard. If you do not want to use this feature, hit enter

"
    # Brydge 10.2 MAX+
    # Jac Omnitype Keyboard
    # Yoozon 3.0 Keyboard
    # Bluetooth Keyboard

    echo
    echo "$text"

    capture_keypress
    abort_keys=(15 40) # enter or space

    if [[ " ${abort_keys[*]} " == *" $octal "* ]]; then
        echo "No special tmux Escape handling requested"
        exit 0
    fi

    echo "Escape prefixing will be mapped to: $octal"
}

#===============================================================
#
#   Main
#
#===============================================================

# RVV

# add bt-keyb script to .tmux.conf if /etc/opt/BT-keyboard found, run it to bind esc as prefix for PgUp/PgDn/Home/End via arrows

# install, last steps
# In case you use a BT keyboard and want to map Esc-arrows to PgUp/PgDn/Home/End inside tmux, select your keyboard from the list below. If you select none your keyb will still work, but no extra binding will happen inside tmux

# - Explain why and ask if any but keyb should be selected, if yes store in /etc/opt/BT-keyboard
select_keyboard
