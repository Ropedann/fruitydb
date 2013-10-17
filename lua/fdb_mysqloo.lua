
local dbmeta = FDB.dbmeta

-- A query that does not block. onSuccess is called if query is succesfully executed and onError if we get an error
function dbmeta:Query(onSuccess, onError, query, ...)

    local db = self:RawDB()
    if not db then
        FDB.Error("RawDB not available!")
    end

    local fquery = FDB.ParseQuery(db, query, ...)
    if not fquery then
        FDB.Warn("Query not executed: fquery is nil")
        return
    end

    if FDB.IsDebug() then -- We double check for debug mode here because string operations are expensive-ish
        FDB.Debug(query .. " parsed to " .. fquery)
        FDB.Debug("Starting query " .. fquery)
    end

    local fdbself = self -- store self here, because we cant access 'self' from onSuccess

    local query = db:query(fquery)
    function query:onSuccess(data)
       fdbself.LastAffectedRows = query:affectedRows()
       fdbself.LastAutoIncrement = query:lastInsert()
       fdbself.LastRowCount = #data

       if FDB.IsDebug() then -- We double check for debug mode here because string operations are expensive-ish
           FDB.Debug("Query succeeded! AffectedRows " .. tostring(fdbself:GetAffectedRows()) .. " InsertedId " .. tostring(fdbself:GetInsertedId()) ..
                     " RowCount " .. tostring(fdbself:GetRowCount()))
       end
       if onSuccess then
          onSuccess(data)
       end
    end

    function query:onError(err, sql)
        FDB.Warn("Query failed! SQL: " .. sql .. ". Err: " .. err)
        if onError then
            onError(err, sql)
        end
    end

    query:start()

    return query

end

function dbmeta:IsConnected()
    return self.db ~= nil
end
function FDB.IsConnected()
    return FDB.latestdb and FDB.latestdb:IsConnected()
end

function dbmeta:RawDB()
    if not self:IsConnected() then
        local config = FDB.Config
        FDB.Connect(config.host, config.name, config.password, config.database, config.port)
        return self.db
    end
    return self.db
end
function dbmeta:Connect(host, name, password, dba, port, socket)
    host = host or "localhost"
    port = port or 3306
    socket = socket or ""

    local db = mysqloo.connect( host, name, password, dba, port, socket )
    self.db = db

    function db:onConnected()
        FDB.latestdb = self
        self.db = db
        FDB.Debug( "Connected to database!" )
    end

    local toerr
    function db:onConnectionFailed( err )
        toerr = err
        self.db = nil
        FDB.Error( "Connection to database failed! Error: " .. tostring(err) )
    end

    db:connect()
    db:wait()

    return self:IsConnected(), toerr
end