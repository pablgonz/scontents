-- Configuration for the regression tests of scontents in plain TeX.
-- l3build loads build.lua first and then this file (checkconfigs).
-- l3build save -c config-plain test-020
testfiledir  = "./testfiles-plain"
checkformat  = "tex"
checkengines = { "pdftex" }
stdengine    = "pdftex"
