function fish_greeting
    # Date
    set -l today (date "+%a %b %-d")

    # Local IP (en0 = wifi, en1 = ethernet)
    set -l ip (ipconfig getifaddr en0 2>/dev/null)
    if test -z "$ip"
        set ip (ipconfig getifaddr en1 2>/dev/null)
    end
    if test -z "$ip"
        set ip offline
    end

    # Battery
    set -l batt_raw (pmset -g batt 2>/dev/null)
    set -l batt_pct (string match -r '[0-9]+%' -- $batt_raw)[1]
    set -l batt_str $batt_pct
    if string match -q "*AC Power*" -- $batt_raw
        set batt_str "$batt_pct +"
    end

    set -l dot (set_color 808080)"·"(set_color normal)
    echo "$today $dot $ip $dot $batt_str"
end
