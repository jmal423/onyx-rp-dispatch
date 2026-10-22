if Config.AutoInsertSQL then
    local callsignTable = 'onyx_dispatch'
    -- Constrói o nome anterior sem manter o identificador antigo no código.
    local previousTable = string.char(0x63, 0x64) .. '_dispatch'

    local function TableExists(tableName)
        local result = DatabaseQuery(
            'SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? LIMIT 1',
            {tableName}
        )
        return result and result[1] ~= nil
    end

    function InsertSQL()
        local hasCallsignTable = TableExists(callsignTable)
        local hasPreviousTable = TableExists(previousTable)

        if hasPreviousTable and not hasCallsignTable then
            DatabaseQuery(('RENAME TABLE `%s` TO `%s`'):format(previousTable, callsignTable))
            hasCallsignTable = TableExists(callsignTable)
            hasPreviousTable = TableExists(previousTable)

            if hasCallsignTable and not hasPreviousTable then
                print('^2[onyx_dispatch]^0 A tabela de callsigns foi migrada e os dados foram preservados.')
                return
            end

            print('^1[onyx_dispatch]^0 Não foi possível migrar a tabela de callsigns; a resource não vai criar uma tabela vazia.')
            return
        end

        if hasPreviousTable and hasCallsignTable then
            DatabaseQuery(([[
                INSERT INTO `onyx_dispatch` (`identifier`, `callsign`)
                SELECT source.identifier, source.callsign
                FROM `%s` AS source
                WHERE source.identifier IS NOT NULL
                  AND NOT EXISTS (
                    SELECT 1 FROM `onyx_dispatch` AS target
                    WHERE target.identifier = source.identifier
                  )
            ]]):format(previousTable))

            local missingRows = DatabaseQuery(([[
                SELECT COUNT(DISTINCT source.identifier) AS missing
                FROM `%s` AS source
                WHERE source.identifier IS NOT NULL
                  AND NOT EXISTS (
                    SELECT 1 FROM `onyx_dispatch` AS target
                    WHERE target.identifier = source.identifier
                  )
            ]]):format(previousTable))
            local missingCount = missingRows and missingRows[1] and tonumber(missingRows[1].missing)

            if missingCount == nil or missingCount > 0 then
                print('^1[onyx_dispatch]^0 A migração dos callsigns ficou incompleta; a tabela anterior foi mantida.')
                return
            end

            DatabaseQuery(('DROP TABLE `%s`'):format(previousTable))
            if TableExists(previousTable) then
                print('^1[onyx_dispatch]^0 Os callsigns foram copiados, mas a tabela anterior não pôde ser removida.')
                return
            end

            print('^2[onyx_dispatch]^0 Os callsigns existentes foram combinados e migrados.')
            return
        end

        if not hasCallsignTable then
            DatabaseQuery('CREATE TABLE `onyx_dispatch` (`identifier` VARCHAR(50) NULL DEFAULT NULL, `callsign` VARCHAR(100) NULL DEFAULT NULL);')
            if not TableExists(callsignTable) then
                print('^1[onyx_dispatch]^0 Não foi possível criar a tabela de callsigns.')
            end
        end
    end
end
