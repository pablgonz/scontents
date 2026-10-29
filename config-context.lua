-- Configuration for the regression tests of scontents in ConTeXt MkIV
-- (context --luatex, the package does not work under LuaMetaTeX).
-- l3build loads build.lua first and then this file (checkconfigs).
-- l3build save -c config-context test-030
testfiledir  = "./testfiles-context"
checkformat  = "context"
checkengines = { "luatex" }
stdengine    = "luatex"

-- ConTeXt runs the document several times until it is stable, so the files
-- written by the first run already exist in the second one and the log
-- shows 'already exists' instead of 'Writing file'. With --once there is a
-- single run, as in the other sets of tests (checkruns = 1).
specialformats = {
  context = {
    luatex = { binary = "context", format = "", options = "--luatex --once" },
  },
}
