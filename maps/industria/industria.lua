local industria = {}

----------------
-- Meta
----------------
industria.name = 'Industria'
industria.width = 2432
industria.height = 3320


----------------
-- Spawn Points
----------------
industria.spawn = {}

industria.spawn[purple] = {
    x = 128,
    y = 128
}

industria.spawn[orange] = {
    x = industria.width - 128,
    y = industria.height - 128
}

return industria
