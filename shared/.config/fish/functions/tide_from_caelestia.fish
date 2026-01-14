function tide_from_caelestia --description 'Apply Caelestia scheme.json colours to Tide'
    set -l scheme ~/.local/state/caelestia/scheme.json
    test -r $scheme; or begin
        echo "Cannot read $scheme" >&2
        return 1
    end

    # Helper: read .colours.<key> as lowercase hex (no #). Returns empty if missing.
    function __c --no-scope-shadowing
        jq -r --arg k "$argv[1]" '.colours[$k] // empty | ascii_downcase' $scheme
    end

    # Palette mapping (tweak if you like)
    set -l base (__c base)
    set -l mantle (__c mantle)
    set -l text (__c text)
    set -l overlay (__c overlay1)

    set -l blue (__c blue)
    set -l green (__c success) # nicer than the scheme's "green"
    set -l red (__c red)
    set -l yellow (__c peach) # warning colour
    set -l mauve (__c mauve)

    # Abort if anything important is missing
    for v in base mantle text overlay blue green red yellow mauve
        if test -z $$v
            echo "Missing colour '$v' in $scheme" >&2
            return 1
        end
    end

    # Frame/separators
    set -U tide_prompt_color_frame_and_connection $overlay
    set -U tide_prompt_color_separator_same_color $overlay

    # OS segment
    set -U tide_os_bg_color (__c secondary)
    set -U tide_os_color (__c onSecondary)

    # PWD segment
    set -U tide_pwd_bg_color (__c primaryFixedDim)
    set -U tide_pwd_color_anchors (__c onPrimaryFixed)
    set -U tide_pwd_color_dirs (__c onPrimaryFixed)
    set -U tide_pwd_color_truncated_dirs (__c mantle)

    # Git segment (+ states)
    set -U tide_git_bg_color (__c success)
    set -U tide_git_bg_color_unstable (__c red)
    set -U tide_git_bg_color_urgent (__c error)

    set -U tide_git_color_branch $base
    set -U tide_git_color_dirty $base
    set -U tide_git_color_staged $base
    set -U tide_git_color_untracked $base
    set -U tide_git_color_conflicted $base
    set -U tide_git_color_operation $base
    set -U tide_git_color_stash $base
    set -U tide_git_color_upstream $base

    # Prompt character
    set -U tide_character_color (__c primary)
    set -U tide_character_color_failure $red

    # Python / virtualenv segment
    # Use a “container” style background and readable foreground
    set -U tide_python_bg_color (__c surfaceContainerHigh)
    set -U tide_python_color (__c text)

    # Time segment
    set -U tide_time_bg_color (__c surfaceContainerHighest)
    set -U tide_time_color (__c text)

    set -U tide_status_bg_color (__c surfaceContainer)
    set -U tide_status_color (__c text)
    set -U tide_status_bg_color_failure (__c errorContainer)
    set -U tide_status_color_failure (__c onErrorContainer)

end
