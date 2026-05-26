-- Tokyo Night palette, dark/light follows GNOME color-scheme.
local function is_dark()
    local p = io.popen("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
    if not p then return true end
    local out = p:read("*a") or ""
    p:close()
    return not out:find("light")
end

if is_dark() then
    return {
        accent           = "rgb(7aa2f7)",
        accent_inactive  = "rgba(414868aa)",
        shadow           = 0xee1a1a1a,
    }
else
    return {
        accent           = "rgb(2e7de9)",
        accent_inactive  = "rgba(a8aecbaa)",
        shadow           = 0xee1a1a1a,
    }
end
