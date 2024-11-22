# Disable save/restore mechanism as documented in /etc/zshrc_Apple_Terminal
SHELL_SESSIONS_DISABLE=1

# Make sure path doesn't contain duplicates
typeset -U path

# Visual Studio Code
# https://code.visualstudio.com/docs/setup/mac#_alternative-manual-instructions
path=($path '/Applications/Visual Studio Code.app/Contents/Resources/app/bin')

# Araxis Merge
# https://www.araxis.com/merge/macos/installing.en
path=($path'/Applications/Araxis Merge.app/Contents/Utilities')
