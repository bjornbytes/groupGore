local git2 = require 'git2'

local rep = git2.Repository('../.git')

print(git2.Commit.lookup(rep, git2.OID.hex('359d698f400934488b68c166d1675612b4993e10')):message())

