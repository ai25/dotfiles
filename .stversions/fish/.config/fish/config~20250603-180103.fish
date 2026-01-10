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

