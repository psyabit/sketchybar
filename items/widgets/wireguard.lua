local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local popup_width = 250

-- Funktion zum Verbinden des VPNs
local function connect_vpn()
    sbar.exec("wg-quick up wg0", function(result, exit_code)
        if exit_code == 0 then
            wireguard_widget:set({
                label = { string = "VPN: Verbunden" },
                icon = { string = icons.vpn.on, color = colors.green }
            })
        else
            wireguard_widget:set({
                label = { string = "VPN: Fehler" },
                icon = { string = icons.vpn.error, color = colors.red }
            })
        end
    end)
end

-- Funktion zum Trennen des VPNs
local function disconnect_vpn()
    sbar.exec("wg-quick down wg0", function(result, exit_code)
        if exit_code == 0 then
            wireguard_widget:set({
                label = { string = "VPN: Getrennt" },
                icon = { string = icons.vpn.off, color = colors.red }
            })
        else
            wireguard_widget:set({
                label = { string = "VPN: Fehler" },
                icon = { string = icons.vpn.error, color = colors.red }
            })
        end
    end)
end

-- Exportieren der Funktionen als Modul
local wireguard = {
    connect_vpn = connect_vpn,
    disconnect_vpn = disconnect_vpn
}

-- Widget hinzufügen
local wireguard_widget = sbar.add("item", "wireguard_widget", {
    position = "right",
    label = {
        string = "VPN: Unbekannt",
        font = { family = settings.font.numbers, size = 12.0 },
        color = colors.white,
    },
    icon = {
        string = icons.vpn.off, -- Passe das Icon nach Bedarf an
        color = colors.grey,
        font = { size = 16.0 },
    },
    background = {
        color = colors.bg2,
        border_color = colors.black,
        border_width = 1,
    },
    padding_left = 1,
    padding_right = 1,
    click_script = [[
        if [ "$(sudo wg show utun8 | grep 'interface: utun8')" ]; then
            lua -e 'require("wireguard").disconnect_vpn()'
        else
            lua -e 'require("wireguard").connect_vpn()'
        fi
    ]]
})

-- Initialer Status überprüfen
sbar.exec("sudo wg show utun8 | grep 'interface: utun8'", function(result, exit_code)
    if exit_code == 0 then
        wireguard_widget:set({
            label = { string = "VPN: Verbunden" },
            icon = { string = icons.vpn.on, color = colors.green }
        })
    else
        wireguard_widget:set({
            label = { string = "VPN: Getrennt" },
            icon = { string = icons.vpn.off, color = colors.red }
        })
    end
end)

return wireguard
    `` `
