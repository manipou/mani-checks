local Config = lib.load('config')

local Checks = {}

CreateThread(function()
    local SQLSuccess, SQLChecks = pcall(function() return MySQL.query.await('SELECT * FROM `mani_checks`') end)
    if not SQLSuccess then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `mani_checks` (
                `id` VARCHAR(24) NOT NULL DEFAULT '' COLLATE 'utf8mb4_0900_ai_ci',
                `identifier` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_0900_ai_ci',
                `amount` INT(11) NOT NULL DEFAULT '0',
                UNIQUE INDEX `id` (`id`) USING BTREE
            )
            COLLATE='utf8mb4_0900_ai_ci'
            ENGINE=InnoDB;
        ]])

        SQLChecks = {}
    end

    for i = 1, #SQLChecks do
        local Check = SQLChecks[i]
        local CheckId = Check.id
        local Identifier = Check.identifier
        local Amount = Check.amount

        Checks[CheckId] = {
            Identifier = Identifier,
            Amount = Amount
        }
    end
end)

local function GenerateId()
    local Id = ''

    for i = 1, Config.IdLength do
        Id = Id .. string.char(math.random(97, 97 + 25))
    end

    return Id
end

lib.callback.register('mani-checks:server:VerifyCheck', function(Source, ItemSlot)
    local PlayerData = exports['mani-bridge']:GetPlayerData(Source)
    if not PlayerData then return false, 'Player Data Not Found' end

    local ItemData = exports['ox_inventory']:GetSlot(Source, ItemSlot)
    if ItemData.name ~= Config.Item then return false, 'Invalid Item' end

    local CheckId = ItemData.metadata.CheckId
    
    if not CheckId then return false, 'Invalid Check Data' end

    local Check = Checks[CheckId]
    if not Check then return false, 'Check Not Found' end

    if Check.Identifier ~= PlayerData.Identifier then return false, "You don't own this check" end

    if not exports['ox_inventory']:RemoveItem(Source, Config.Item, 1, ItemData.metadata, ItemSlot) then return false, 'Failed to remove check from inventory' end

    exports['mani-bridge']:AddMoney(Source, Config.MoneyType, Check.Amount)

    Checks[CheckId] = nil

    MySQL.query('DELETE FROM `mani_checks` WHERE id = ?', { CheckId })

    return true
end)

exports('RegisterCheck', function(CheckData)
    local CheckId = GenerateId()

    while Checks[CheckId] do
        CheckId = GenerateId()
        Wait(50)
    end

    exports['ox_inventory']:AddItem(CheckData.InvId, Config.Item, 1, {
        CheckId = CheckId,
        description = ('%s - %s kr'):format(CheckData.Name, CheckData.Amount)
    })

    Checks[CheckId] =  {
        Identifier = CheckData.Identifier,
        Amount = CheckData.Amount
    }

    MySQL.insert('INSERT INTO `mani_checks` (id, identifier, amount) VALUES (?, ?, ?)', {
        CheckId, CheckData.Identifier, CheckData.Amount
    })
end)