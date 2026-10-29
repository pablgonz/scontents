-- Configuration for the regression test of the remember key of scontents
-- (LuaTeX, latex-dev, as the tests in ./testfiles).
-- l3build loads build.lua first and then this file (checkconfigs).
-- l3build save -c config-remember test-040

-- The stored contents are written to \jobname.sct at the end of the first
-- run and read at the beginning of the second one, whose log is compared.
-- The .sct file is removed before the test, so the first run never finds
-- the one of a previous check.
testfiledir  = "./testfiles-remember"
checkruns    = 2
dynamicfiles = { "test-*.sct" }
