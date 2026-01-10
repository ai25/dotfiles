function _tide_item_git
    # Detect remote origin and set icon
    set -l git_icon ""  # Default Git icon
    set -l remote_url (git config --get remote.origin.url 2>/dev/null)
    if test -n "$remote_url"
        if string match -q "*github.com*" "$remote_url"
            set git_icon ""  # GitHub icon
        else if string match -q "*gitlab.com*" "$remote_url"
            set git_icon ""  # GitLab icon
        end
    end

    if git branch --show-current 2>/dev/null | string shorten -"$tide_git_truncation_strategy"m$tide_git_truncation_length | read -l location
        git rev-parse --git-dir --is-inside-git-dir | read -fL gdir in_gdir
        set location $_tide_location_color$location
    else if test $pipestatus[1] != 0
        return
    else if git tag --points-at HEAD | string shorten -"$tide_git_truncation_strategy"m$tide_git_truncation_length | read location
        git rev-parse --git-dir --is-inside-git-dir | read -fL gdir in_gdir
        set location '#'$_tide_location_color$location
    else
        git rev-parse --git-dir --is-inside-git-dir --short HEAD | read -fL gdir in_gdir location
        set location @$_tide_location_color$location
    end

    # Operation
    if test -d $gdir/rebase-merge
        if not path is -v $gdir/rebase-merge/{msgnum,end}
            read -f step <$gdir/rebase-merge/msgnum
            read -f total_steps <$gdir/rebase-merge/end
        end
        test -f $gdir/rebase-merge/interactive && set -f operation rebase-i || set -f operation rebase-m
    else if test -d $gdir/rebase-apply
        if not path is -v $gdir/rebase-apply/{next,last}
            read -f step <$gdir/rebase-apply/next
            read -f total_steps <$gdir/rebase-apply/last
        end
        if test -f $gdir/rebase-apply/rebasing
            set -f operation rebase
        else if test -f $gdir/rebase-apply/applying
            set -f operation am
        else
            set -f operation am/rebase
        end
    else if test -f $gdir/MERGE_HEAD
        set -f operation merge
    else if test -f $gdir/CHERRY_PICK_HEAD
        set -f operation cherry-pick
    else if test -f $gdir/REVERT_HEAD
        set -f operation revert
    else if test -f $gdir/BISECT_LOG
        set -f operation bisect
    end

    # Git status/stash + Upstream behind/ahead
    test $in_gdir = true && set -l _set_dir_opt -C $gdir/..
    set -l stat (git $_set_dir_opt --no-optional-locks status --porcelain 2>/dev/null)
    string match -qr '(0|(?<stash>.*))\n(0|(?<conflicted>.*))\n(0|(?<staged>.*))
(0|(?<dirty>.*))\n(0|(?<untracked>.*))(\n(0|(?<behind>.*))\t(0|(?<ahead>.*)))?' \
        "$(git $_set_dir_opt stash list 2>/dev/null | count
        string match -r ^UU $stat | count
        string match -r ^[ADMR]. $stat | count
        string match -r ^.[ADMR] $stat | count
        string match -r '^\?\?' $stat | count
        git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)"

    if test -n "$operation$conflicted"
        set -g tide_git_bg_color $tide_git_bg_color_urgent
    else if test -n "$staged$dirty$untracked"
        set -g tide_git_bg_color $tide_git_bg_color_unstable
    end

    # Print the item with icons for each status
    _tide_print_item git $_tide_location_color$git_icon' ' (set_color white; echo -ns $location
        if test -n "$operation"
            set_color $tide_git_color_operation; echo -ns ' ⚙ '$operation
            if test -n "$step" -a -n "$total_steps"
                echo -ns ' '$step/$total_steps
            end
        end
        if test -n "$behind"
            set_color $tide_git_color_upstream; echo -ns ' ⇣ '$behind
        end
        if test -n "$ahead"
            set_color $tide_git_color_upstream; echo -ns ' ⇡ '$ahead
        end
        if test -n "$stash"
            set_color $tide_git_color_stash; echo -ns '  '$stash
        end
        if test -n "$conflicted"
            set_color $tide_git_color_conflicted; echo -ns ' ﲅ '$conflicted
        end
        if test -n "$staged"
            set_color $tide_git_color_staged; echo -ns '  '$staged
        end
        if test -n "$dirty"
            set_color $tide_git_color_dirty; echo -ns '  '$dirty
        end
        if test -n "$untracked"
            set_color $tide_git_color_untracked; echo -ns '  '$untracked
        end)
end
