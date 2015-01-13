FruityDB
========

A MeekroDB like abstraction for Garry's Mod's MysqlOO.

## Usage

```lua
local db, err = FDB.Connect("sqlite" --[[can be "mysqloo" or "tmysql4" also]], {
    -- There are not needed when using sqlite
    host = "localhost",
    user = "root",
    password = "",
    database = "the_db",
    port = 3306, -- mysql port
    socket = "" -- unix socket for mysql
})
if not db then error("db connection failed: " .. err) end

-- Query
db:Query("SELECT * FROM table", _, function(data)
    PrintTable(data)
end)

-- Helper functions
db:QueryFirstRow("SELECT * FROM table", _, PrintTable)
db:QueryFirstField("SELECT * FROM table", _, print)

-- Error handling
db:Query("SELEC * FROM table", _, _, function(err, sql)
    print("SQL Error: ", err)
    print("When running query: ", sql)
end)

-- Escaping parameters
db:Query("SELECT * FROM table WHERE groupid = %d AND name = %s", {42, "John"})

-- Placeholder variables:
-- %d and %i = number
-- %s        = string
-- %l        = literal  (don't use with user input)
-- %b        = backticked string (don't use with user input)
-- %o        = object (escapes based on type; supports number, string and table)
-- %to       = table of objects (parses into a SQL list)
-- %tb       = table of backticked strings (parses into a SQL list)

-- Insertion
db:Insert("table", {
    groupid = 36,
    name = "Mike"
})

-- Deletion
db:Delete("table", "id = %d AND name = %s", 36, "Mike")

```
