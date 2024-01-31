# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# >>> coursier install directory >>>
export PATH="$PATH:/home/fmarini/.local/share/coursier/bin"
# <<< coursier install directory <<<

# BSC
# export PATH=/opt/bsc/bsc-2023.07-ubuntu-20.04/bin:$PATH
