exports('UseCheck', function(ItemData)
    local Success, Error = lib.callback.await('mani-checks:server:VerifyCheck', false, ItemData.slot)
    if not Success then lib.notify({ title = 'Check', description = Error, type = 'error' }) end
end)