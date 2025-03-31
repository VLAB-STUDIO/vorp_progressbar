local progressActive = false
local queue = {}

local function _internalStart(message, miliseconds, cb, theme, color, width, focus)
    if theme == nil then
        theme = "linear"
    end
    if color == nil then
        color = 'rgb(100, 0, 0)'
    end
    if width == nil then
        width = '20vw'
    end
    table.insert(queue, {
        message = message,
        callback = cb,
        focus = focus
    })
    if focus == nil or focus == true then
        SetNuiFocus(true, false)
    end
    progressActive = true
    SendNUIMessage({
        type = 'vp-open',
        message = message,
        mili = miliseconds,
        theme = theme,
        color = color,
        width = width
    })
end

exports('initiate', function()
    local self = {}
    self.start = _internalStart
    return self
end)

AddEventHandler('__cfx_export_progressBars_startUI', function(callback)
    callback(function (time, text)
        _internalStart(text, time, nil, nil, nil, nil, false)
    end)
end)

RegisterNUICallback('ProgressFinished', function(args, nuicb)
    if queue[1].focus ~= false then
        SetNuiFocus(false, false)
    end
    if queue[1].callback then
        queue[1].callback()
    end
    table.remove(queue, 1)
    progressActive = false
    nuicb('ok')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if progressActive then
            for _, control in ipairs(Config.BlockedControls) do
                DisableControlAction(0, control, true)
            end
        end
    end
end)