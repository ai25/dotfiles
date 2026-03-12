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
set -U tide_os_icon \uf303

# Remove greeting
set -g fish_greeting

# Check if we're in interactive mode
if status is-interactive
    fish_user_key_bindings
end

function __after_cmd --on-event fish_postexec
    tide_from_caelestia
end

# sudo last command 
abbr --add !! 'eval sudo $history[1]'

set -gx PATH $PATH /home/ai6/.cargo/bin
set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk/
set -gx PATH $JAVA_HOME/bin $PATH
set -gx PATH ~/.npm-global/bin $PATH
set -gx PATH ~/.local/bin $PATH
set -gx QT_QPA_PLATFORMTHEME qt6ct

alias cp='rsync -a --info=progress2'
alias mv='rsync -a --info=progress2 --remove-source-files'
alias rn='perl-rename'
# nvim typos
alias n='nvim'
alias nv='nvim'
alias nvi='nvim'
alias nivm='nvim'

if status is-interactive
    # Starship custom prompt
    # starship init fish | source

    # Direnv + Zoxide
    command -v direnv &>/dev/null && direnv hook fish | source
    command -v zoxide &>/dev/null && zoxide init fish --cmd cd | source

    # Better ls
    alias ls='eza --icons --group-directories-first -1'

    # Abbrs
    abbr lg lazygit
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l ls
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    fish_config theme choose "Catppuccin Mocha"
    functions -q tide_from_caelestia; and tide_from_caelestia
    # Custom colours
    cat ~/.local/state/caelestia/sequences.txt 2>/dev/null

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end

    function dl
        set URL $argv[1]
        set OUT "$HOME/Downloads/%(title)s.%(ext)s"

        if test -z "$URL"
            echo "Usage: dl <url>"
            return 1
        end

        set TARGET (yt-dlp --list-impersonate-targets | tail -n +4 | sed "s/[[:space:]]\+/:/g" | sed "s/:curl_cffi//g" | shuf -n 1)

        if yt-dlp \
                $URL \
                --impersonate $TARGET \
                # --downloader aria2c \
                # --downloader-args "aria2c:-x 4 -s 4 --max-tries=0 --console-log-level=warn" \
                --retries infinite \
                --no-ignore-errors \
                -f "bestvideo[height>=720]+bestaudio/best[height>=720]" \
                -o "$OUT"

            echo "Success!"
        else
            dl $URL
        end
    end

    function validate_file
        set -l file "$argv[1]"

        set -l validation_output (nice -n 19 ionice -c 3 \
        ffmpeg -v error -i "$file" -map 0 -c copy -f null - 2>&1)
        set -l ff_status $status

        if test $ff_status -ne 0
            echo "Validation failed (ffmpeg exit code $ff_status):"
            printf '%s\n' $validation_output
            return 1
        end

        set -l joined (string join \n -- $validation_output)

        if string match -rq -- '(Invalid NAL unit size|missing picture in access unit)' $joined
            echo "Validation failed (bitstream errors detected):"
            printf '%s\n' $validation_output
            return 1
        end

        if test (count $validation_output) -gt 0
            echo "Validation produced messages:"
            printf '%s\n' $validation_output
        end

        echo "File validated successfully"
        return 0
    end

    function validate_download
        set -l URL "$argv[1]"
        set -l OUT "$argv[2]"
        set -l DIR "$HOME/Downloads"
        set -l ATTEMPT 0

        if test -z "$URL" -o -z "$OUT"
            echo "Usage: validate_download <url> <title>"
            return 1
        end

        mkdir -p "$DIR"

        function try_download --argument-names url out dir
            set -l attempt_varname __vd_attempt

            # increment attempt counter stored in the parent scope via a global-ish var
            if not set -q $attempt_varname
                set -g $attempt_varname 0
            end
            set -g $attempt_varname (math $$attempt_varname + 1)
            set -l attempt $$attempt_varname

            echo "======================================="
            echo "Downloading $out, attempt #$attempt..."
            echo "======================================="

            if aria2c -x 6 -s 6 --max-tries=0 "$url" -d "$dir" -o "$out.mp4" --file-allocation=none
                if validate_file "$dir/$out.mp4"
                    echo "Download $out succeeded after $attempt attempts!"
                    set -e $attempt_varname
                    return 0
                else
                    notify-send "Error: $out contains corruption. Retrying..."
                    rm -f "$dir/$out.mp4"
                    try_download "$url" "$out" "$dir"
                end
            else
                try_download "$url" "$out" "$dir"
            end
        end

        try_download "$URL" "$OUT" "$DIR"
    end

end
