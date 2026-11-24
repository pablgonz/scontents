-- Configuration for the regression tests of scontents in ConTeXt LMTX
-- (context, LuaMetaTeX). The same test as config-context.lua (MkIV).
-- l3build loads build.lua first and then this file (checkconfigs).
-- l3build save -c config-lmtx test-031
testfiledir  = "./testfiles-lmtx"
checkformat  = "context"
checkengines = { "luatex" }
stdengine    = "luatex"

-- ConTeXt runs the document several times until it is stable, so the files
-- written by the first run already exist in the second one and the log
-- shows 'already exists' instead of 'Writing file'. With --once there is a
-- single run, as in the other sets of tests (checkruns = 1).
specialformats = {
  context = {
    luatex = { binary = "context", format = "", options = "--once" },
  },
}

-- ConTeXt writes to the log the fonts it loads and caches the first time
-- they are used: with an empty cache (as in GitHub Actions) the lines
-- 'fonts > otf loading ...' and 'otf reader > ...' appear in the middle of
-- the test, with a warm cache they do not. They are removed, the hook of
-- build.lua is kept for the rest of the lines.
local build_normalize_log_hook = normalize_log_hook
function normalize_log_hook(line)
  if string.match(line, "^fonts%s+>") or string.match(line, "^otf reader%s+>") then
    return ""
  end
  return build_normalize_log_hook(line)
end
