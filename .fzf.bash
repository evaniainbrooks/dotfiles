# Setup fzf
# ---------
if [[ ! "$PATH" == */home/evan/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/evan/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/evan/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/evan/.fzf/shell/key-bindings.bash"
