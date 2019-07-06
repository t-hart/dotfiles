source ~/.aliases/aliases.fish

switch (uname)
    case Darwin
        set -gx EDITOR "vim"
        set -U fish_user_paths $HOME/.cargo/bin $HOME/.yarn/bin ./node_modules $HOME/.local/bin
    case '*'
        set -gx EDITOR "emacsclient -t"
        bind \b 'backward-kill-word'
        bind \e\[4~ 'kill-word'
end
set -gx VISUAL $EDITOR

# disable greeting
set fish_greeting

function fish_user_key_bindings
  fish_default_key_bindings
  bind \cN accept-autosuggestion
end

set -g fish_key_bindings fish_user_key_bindings

# ssh
setenv SSH_ENV $HOME/.ssh/environment

if type -q direnv
    direnv hook fish | source
end
