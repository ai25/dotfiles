function fish_user_key_bindings
    # Use vi key bindings
    fish_vi_key_bindings

    # Bind Ctrl+C to switch from insert mode to normal mode
    bind -M insert \cc 'commandline -f cancel; set fish_bind_mode default; commandline -f repaint-mode'

    # Keep Ctrl+W for backward-kill-word (already works in your terminal)
    # No need to explicitly bind it if it's already working as expected

    # Try only the Ctrl+Backspace binding that's most likely to work
    # without affecting regular backspace
    bind -M insert \e\[127\;5u backward-kill-word
end

# Set cursor shapes for different modes
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_replace underscore
set fish_cursor_visual block

# Remove greeting
set -g fish_greeting

# Check if we're in interactive mode
if status is-interactive
    fish_user_key_bindings
end

# sudo last command 
abbr --add !! 'eval sudo $history[1]'

set -gx PATH $PATH /home/ai6/.cargo/bin
set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk/
set -gx PATH $JAVA_HOME/bin $PATH
set -gx PATH ~/.npm-global/bin $PATH
set -gx PATH ~/.local/bin $PATH
set -gx QT_QPA_PLATFORMTHEME qt6ct

alias ls='eza --icons --group-directories-first'
alias cp='rsync -a --info=progress2'
alias mv='rsync -a --info=progress2 --remove-source-files'
alias rn='perl-rename'
