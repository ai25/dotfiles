-- custom/vtt.lua

local M = {}

-- Function to convert timestamp to seconds
local function timestamp_to_seconds(timestamp)
    local h, m, s, ms = timestamp:match("(%d+):(%d+):(%d+)%.(%d+)")
    return tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s) + tonumber(ms) / 1000
end

-- Function to convert seconds to timestamp
local function seconds_to_timestamp(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    local ms = math.floor((seconds % 1) * 1000)
    return string.format("%d:%02d:%02d.%03d", h, m, s, ms)
end

-- Function to increment timings from cursor position
function M.increment_timings_from_cursor()
    -- Prompt user for the increment value
    local increment = vim.fn.input("Enter time increment (format: [-]HH:MM:SS.mmm): ")
    if increment == "" then 
        print("Operation cancelled")
        return 
    end

    -- Convert increment to milliseconds
    local sign = increment:sub(1,1) == "-" and -1 or 1
    local h, m, s, ms = increment:match("(-?%d+):(%d+):(%d+)%.(%d+)")
    if not (h and m and s and ms) then
        print("Invalid time format. Please use HH:MM:SS.mmm")
        return
    end
    local total_ms = sign * ((math.abs(tonumber(h)) * 3600 + tonumber(m) * 60 + tonumber(s)) * 1000 + tonumber(ms))

    -- Get current cursor position
    local start_line = vim.fn.line('.')

    -- Function to add milliseconds to a timestamp
    local function add_ms_to_timestamp(timestamp, ms_to_add)
        local h, m, s, ms = timestamp:match("(%d+):(%d+):(%d+)%.(%d+)")
        if not (h and m and s and ms) then
            print("Invalid timestamp format: " .. timestamp)
            return nil
        end
        local total_ms = (tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s)) * 1000 + tonumber(ms) + ms_to_add
        if total_ms < 0 then total_ms = 0 end
        local new_h = math.floor(total_ms / 3600000)
        local new_m = math.floor((total_ms % 3600000) / 60000)
        local new_s = math.floor((total_ms % 60000) / 1000)
        local new_ms = total_ms % 1000
        return string.format("%d:%02d:%02d.%03d", new_h, new_m, new_s, new_ms)
    end

    -- Iterate through lines and update timestamps
    local updated_count = 0
    for i = start_line, vim.fn.line('$') do
        local line = vim.fn.getline(i)
        local start_time, end_time = line:match("(%d+:%d%d:%d%d%.%d%d%d) %-%-> (%d+:%d%d:%d%d%.%d%d%d)")
        if start_time and end_time then
            local new_start = add_ms_to_timestamp(start_time, total_ms)
            local new_end = add_ms_to_timestamp(end_time, total_ms)
            if new_start and new_end then
                local new_line = line:gsub(start_time .. " %-%-> " .. end_time, new_start .. " --> " .. new_end)
                vim.fn.setline(i, new_line)
                updated_count = updated_count + 1
            else
                print("Error processing line " .. i)
            end
        end
    end

    print(string.format("Updated %d timestamp(s) from line %d to end of file", updated_count, start_line))
end

-- Function to update the duration of the current timestamp and adjust subsequent subtitles
function M.update_timestamp_duration()
    -- Get the current line number
    local current_line_num = vim.fn.line('.')
    
    -- Get the current line
    local current_line = vim.fn.getline(current_line_num)
    
    -- Extract start and end times
    local start_time, end_time = current_line:match("(%d+:%d%d:%d%d%.%d%d%d) %-%-> (%d+:%d%d:%d%d%.%d%d%d)")
    
    if not (start_time and end_time) then
        print("No timestamp found on the current line.")
        return
    end
    
    -- Prompt user for the new duration
    local new_duration = vim.fn.input("Enter new duration in seconds: ")
    if new_duration == "" then 
        print("Operation cancelled")
        return 
    end
    
    -- Convert new_duration to a number
    new_duration = tonumber(new_duration)
    if not new_duration then
        print("Invalid duration. Please enter a number.")
        return
    end
    
    -- Calculate new end time
    local start_seconds = timestamp_to_seconds(start_time)
    local new_end_seconds = start_seconds + new_duration
    local new_end_time = seconds_to_timestamp(new_end_seconds)
    
    -- Update the current line
    local new_line = current_line:gsub(start_time .. " %-%-> " .. end_time, start_time .. " --> " .. new_end_time)
    vim.fn.setline(current_line_num, new_line)
    
    print("Updated current line: " .. new_line)
    
    -- Check and update subsequent lines if necessary
    local next_line_num = current_line_num + 1
    local total_lines = vim.fn.line('$')
    local updated_count = 1

    while next_line_num <= total_lines do
        local next_line = vim.fn.getline(next_line_num)
        local next_start_time, next_end_time = next_line:match("(%d+:%d%d:%d%d%.%d%d%d) %-%-> (%d+:%d%d:%d%d%.%d%d%d)")
        
        if next_start_time and next_end_time then
            local next_start_seconds = timestamp_to_seconds(next_start_time)
            local next_end_seconds = timestamp_to_seconds(next_end_time)
            
            print(string.format("Checking line %d: %s --> %s", next_line_num, next_start_time, next_end_time))
            print(string.format("New end: %.3f, Next start: %.3f", new_end_seconds, next_start_seconds))
            
            if new_end_seconds > next_start_seconds then
                -- Calculate the shift needed
                local shift = new_end_seconds - next_start_seconds
                
                -- Update the next subtitle's times
                local new_next_start_time = seconds_to_timestamp(next_start_seconds + shift)
                local new_next_end_time = seconds_to_timestamp(next_end_seconds + shift)
                
                local new_next_line = next_line:gsub(next_start_time .. " %-%-> " .. next_end_time, 
                                                     new_next_start_time .. " --> " .. new_next_end_time)
                vim.fn.setline(next_line_num, new_next_line)
                
                print("Updated line " .. next_line_num .. ": " .. new_next_line)
                
                new_end_seconds = timestamp_to_seconds(new_next_end_time)
                updated_count = updated_count + 1
            else
                print("No overlap, stopping updates")
                break  -- Exit if there's no overlap
            end
        end
        
        next_line_num = next_line_num + 1
    end
    
    print(string.format("Updated %d subtitle(s). New duration: %.3f seconds", updated_count, new_duration))
end

-- Function to insert a new subtitle entry
function M.insert_new_subtitle()
    local current_line = vim.fn.line('.')
    local prev_subtitle_end = "00:00:00.000"
    
    -- Search for the previous subtitle
    for i = current_line - 1, 1, -1 do
        local line_content = vim.fn.getline(i)
        local start_time, end_time = line_content:match("(%d+:%d+:%d+%.%d+) %-%-> (%d+:%d+:%d+%.%d+)")
        if start_time and end_time then
            prev_subtitle_end = end_time
            break
        end
    end
    
    -- Calculate new start and end times
    local start_seconds = timestamp_to_seconds(prev_subtitle_end) + 1
    local end_seconds = start_seconds + 5
    local new_start = seconds_to_timestamp(start_seconds)
    local new_end = seconds_to_timestamp(end_seconds)
    
    -- Insert the new subtitle
    local new_subtitle = string.format("%s --> %s", new_start, new_end)
    vim.api.nvim_put({new_subtitle, ''}, 'l', true, true)
    
    -- Move cursor to the line after the new subtitle
    vim.api.nvim_win_set_cursor(0, {current_line + 2, 0})
end

-- Helper function to safely perform substitution
local function safe_substitute(pattern, repl, flags)
    local line = vim.api.nvim_get_current_line()
    local new_line = line:gsub(pattern, repl)
    if new_line ~= line then
        vim.api.nvim_set_current_line(new_line)
        return true
    end
    return false
end

-- Function to increment timestamp by 1 second
function M.increment_timestamp()
    if not safe_substitute("(%d+:%d+:)(%d+)", function(prefix, seconds)
        return prefix .. string.format("%02d", (tonumber(seconds) + 1) % 60)
    end) then
        print("No timestamp found on the current line.")
    end
end

-- Function to decrement timestamp by 1 second
function M.decrement_timestamp()
    if not safe_substitute("(%d+:%d+:)(%d+)", function(prefix, seconds)
        return prefix .. string.format("%02d", (tonumber(seconds) - 1) % 60)
    end) then
        print("No timestamp found on the current line.")
    end
end

-- Function to increment timestamp milliseconds by 100
function M.increment_timestamp_ms()
    if not safe_substitute("(%d+:%d+:%d+%.)(%d+)", function(prefix, ms)
        return prefix .. string.format("%03d", math.min(999, tonumber(ms) + 100))
    end) then
        print("No timestamp found on the current line.")
    end
end

-- Function to decrement timestamp milliseconds by 100
function M.decrement_timestamp_ms()
    if not safe_substitute("(%d+:%d+:%d+%.)(%d+)", function(prefix, ms)
        return prefix .. string.format("%03d", math.max(0, tonumber(ms) - 100))
    end) then
        print("No timestamp found on the current line.")
    end
end

-- Function to toggle between source and translated text
function M.toggle_source_translated()
    local success, err = pcall(function()
        vim.cmd([[g/^$/,/^$/-1 move+1]])
    end)
    if not success then
        print("Error toggling source/translated text: " .. err)
    end
end

-- Function to reformat timestamps
function M.reformat_timestamps()
    local success, err = pcall(function()
        vim.cmd([[%s/\(\d\+:\d\+:\d\+\)\.\(\d\+\)/\1.\2/g]])
    end)
    if not success then
        print("Error reformatting timestamps: " .. err)
    end
end

-- Function to move to the next subtitle
function M.next_subtitle()
    local pattern = "%d+:%d+:%d+%.%d+ %-%-> %d+:%d+:%d+%.%d+"
    local current_line = vim.fn.line('.')
    local last_line = vim.fn.line('$')

    for i = current_line + 1, last_line do
        local line_content = vim.fn.getline(i)
        if line_content:match(pattern) then
            vim.api.nvim_win_set_cursor(0, {i, 0})
            print("Moved to next subtitle")
            return
        end
    end
    print("No next subtitle found")
end

-- Function to move to the previous subtitle
function M.prev_subtitle()
    local pattern = "%d+:%d+:%d+%.%d+ %-%-> %d+:%d+:%d+%.%d+"
    local current_line = vim.fn.line('.')

    for i = current_line - 1, 1, -1 do
        local line_content = vim.fn.getline(i)
        if line_content:match(pattern) then
            vim.api.nvim_win_set_cursor(0, {i, 0})
            print("Moved to previous subtitle")
            return
        end
    end
    print("No previous subtitle found")
end


return M
