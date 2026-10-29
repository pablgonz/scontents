--[[
   Configuration script for l3build from the scontents package.
   At the moment the possible targets that can be passed are:
   * tag        : Update the version and date
   * doc        : Generate the documentation [-q]
   * unpack     : Unpacks the source files [-q]
   * install    : Install the package locally, you can use
                  it in conjunction with [--full] [--dry-run]
   * uninstall  : Uninstall the package locally
   * clean      : Clean the directory tree and the files ignored by git
                  (only lists them with --dry-run; never removes files
                  that git does not ignore)
   * ctan       : Generate the compressed package (.zip); it first checks that
                  the PDFs of /test-pkg and /samples are up to date
   * upload     : Upload the package to ctan, you must add
                  -F ctan.ann in conjunction with [--debug]
   * tagcheck   : Check version and date in files
   * check      : Run the regression tests: /testfiles (LuaTeX, latex-dev),
                  /testfiles-remember (two runs, key remember),
                  /testfiles-plain (pdfTeX, plain) and /testfiles-context
                  (ConTeXt MkIV); l3build check test-001 runs only that test
                  and -c config-plain, -c config-remember or -c
                  config-context only that set
   * save       : Save the reference (.tlg) of a test after reviewing its
                  output: l3build save test-001, l3build save -c
                  config-remember test-040, l3build save -c config-plain
                  test-020, l3build save -c config-context test-030
   * testSE     : Compile and validate the files in /test-pkg with plain TeX,
                  LaTeX (latex>dvips>ps2pdf, pdflatex and tagged lualatex)
                  and ConTeXt, PDFs copied there
   * example    : Compile the files in /samples (one run, two for
                  scontents-exa-12), PDFs copied there
   The targets testSE and example accept file names (with or without .tex)
   to run only those files: l3build example scontents-exa-2
   * release    : It performs the checks before generating a public
                  release (on git and ctan), commits the PDFs that
                  example, testSE and ctan regenerate and creates the
                  git tag.
--]]

-- General package identification
module     = "scontents"
pkgversion = "2.8"
pkgdate    = "2026-11-01"

-- Configuration of files for build and installation
maindir       = "."
sourcefiledir = "./sources"
textfiledir   = "./sources"
sourcefiles   = {"**/*.dtx", "**/*.ins"}
installfiles  = {"**/*.sty", "**/*.tex", "**/*.mkiv"}
tdslocations  = {
  "tex/generic/scontents/scontents.tex",
  "tex/generic/scontents/scontents-code.tex",
  "tex/latex/scontents/scontents.sty",
  "tex/context/third/scontents/t-scontents.mkiv",
  "doc/latex/scontents/scontents.pdf",
  "doc/latex/scontents/README.md",
  "source/latex/scontents/scontents.dtx",
  "source/latex/scontents/scontents.ins"
}

-- Unpacking files from scontents.ins
unpackfiles = { "scontents.ins" }
unpackopts  = "--interaction=batchmode"
unpackexe   = "luatex"

-- Regression tests (l3build check / save): the .lvt files in ./testfiles.
-- The package needs the development format, so the tests run with
-- latex-dev. Tests without tagging (test-001...) compare the contents
-- written to the log and the boxes with what is printed; tests with tagging
-- (test-010...) compare the tag tree (\SHOWPDFTAGS); test-100 has the
-- messages. One run is enough: no test uses references.
testfiledir  = "./testfiles"
checkengines = { "luatex" }
stdengine    = "luatex"
checkformat  = "latex-dev"
checkruns    = 1

-- The same package is also tested in plain TeX and in ConTeXt, and the key
-- remember with two runs, each set of tests has its own directory and its
-- configuration file (config-remember.lua, config-plain.lua and
-- config-context.lua), loaded after this file.
checkconfigs = { "build", "config-remember", "config-plain", "config-context" }

-- test-003, test-020, test-030 and test-100 write files with the write-*
-- keys; they are removed before each test so that the messages (writing /
-- not writing / overwriting) are always the same.
dynamicfiles = { "test-*-*.tsc" }

-- The structure elements of the tagged tests carry sequential ids
-- (ID.00012, ...): one node more or less would shift all the following ones
-- and flood the diff, so the ids are not compared. The count, skip and dimen
-- registers allocated by the package (\l__scontents_..._int=\count...) are
-- only written when it is loaded after \START (test-005): they are internal
-- and change when the package adds one, so they are removed.
function normalize_log_hook(line)
  local register = string.match(line, "^\\[lgc]__scontents_[%w_]+=\\(%a+)[%d.]+$")
  if register == "count" or register == "skip" or register == "dimen" then
    return ""
  end
  return (string.gsub(line, 'id="ID%.%d+"', 'id="ID.NN"'))
end

-- Typesetting scontents documentation step by step :)
-- The documentation uses mylhmc.lua and mylhmc.sty from sources/ (they are
-- not part of the package and are not distributed) and the examples of
-- sources/samples and sources/test-pkg are copied as they are, nothing is
-- checked here.
function docinit_hook()
  local errorlevel = (cp("*.tex", unpackdir, typesetdir) + cp("*.sty", unpackdir, typesetdir))
  if errorlevel ~= 0 then
    error("** Error!!: Can't copy .tex and .sty files from "..unpackdir.." to "..typesetdir)
  end
  errorlevel = (cp("mylhmc.lua", sourcefiledir, typesetdir) + cp("mylhmc.sty", sourcefiledir, typesetdir))
  if errorlevel ~= 0 then
    error("** Error!!: Can't copy mylhmc.lua and mylhmc.sty files from "..sourcefiledir.." to "..typesetdir)
  end
  local smpdir = sourcefiledir.."/samples"
  if direxists(smpdir) then
    cp("*.tex", smpdir, typesetdir)
    cp("*.pdf", smpdir, typesetdir)
  end
  return 0
end

function typeset(file)
  local file = jobname(sourcefiledir.."/scontents.dtx")
  local runs = {
    "lualatex-dev -draftmode -interaction=batchmode ",
    "lualatex-dev -draftmode -interaction=batchmode ",
    "lualatex-dev -interaction=batchmode ",
  }
  for _, cmd in ipairs(runs) do
    print("** Running: "..cmd..file..".dtx")
    local errorlevel = runcmd(cmd..file..".dtx >"..os_null, typesetdir, {"TEXINPUTS","LUAINPUTS"})
    if errorlevel ~= 0 then
      local f = io.open(typesetdir.."/"..file..".log", "r")
      if f then
        print(f:read("*all"))
        f:close()
      end
      cp(file..".log", typesetdir, maindir)
      error("** Error!!: "..cmd..file..".dtx")
    end
  end
  return 0
end

-- Configuration for ctan
ctanreadme = "CTANREADME.md"
ctanpkg    = "scontents"
ctanzip    = ctanpkg.."-"..pkgversion
packtdszip = false

--  Configuration for package distribution in ctan
uploadconfig = {
  author       = "Pablo González L",
  uploader     = "Pablo González L",
  email        = "pablgonz@yahoo.com",
  pkg          = ctanpkg,
  version      = pkgversion .. " " .. pkgdate,
  license      = "lppl1.3c",
  summary      = "Stores LaTeX contents in memory or files",
  description  = [[This package stores valid LaTeX code in memory (sequences) using the l3seq module of expl3. The stored content (including verbatim) can be used as many times as desired in the document, additionally can be written to external files if desired.]],
  topic        = { "File management", "Experimental LaTeX3" },
  ctanPath     = "/macros/latex/contrib/" .. ctanpkg,
  repository   = "https://github.com/pablgonz/" .. module,
  bugtracker   = "https://github.com/pablgonz/" .. module .. "/issues",
  support      = "https://github.com/pablgonz/" .. module .. "/issues",
  note         = [[Uploaded automatically by l3build...]],
  announcement_file="ctan.ann",
  update       = true
}

-- Clean files (scontents.pdf is versioned in git, so clean must not remove it)
cleanfiles = {ctanzip..".curlopt", ctanzip..".zip"}

-- Update package date and version
tagfiles = {
  "sources/scontents.ins",
  "sources/scontents.dtx",
  "sources/CTANREADME.md",
  "ctan.ann"
}

-- Line length helper (80 chars layout)
local function os_message(text)
  local mymax = 77 - string.len(text) - string.len("done")
  if mymax < 1 then mymax = 1 end
  print(text .. " " .. string.rep(".", mymax) .. " done")
end

-- Helper to safely read file content
local function read_file(filepath)
  local f = io.open(filepath, "r")
  if not f then return nil end
  local content = f:read("*all")
  f:close()
  return content
end

-- Update function: the version and date are always taken from build.lua
function update_tag(file, content, tagname, tagdate)
  tagname = pkgversion
  tagdate = pkgdate

  if string.match(file, "scontents%.ins$") then
    content = string.gsub(content, "date=%d%d%d%d%-%d%d%-%d%d", "date=" .. tagdate)
    content = string.gsub(content, "version=%d+%.%d+%w?", "version=" .. tagname)
  end
  if string.match(file, "scontents%.dtx$") then
    content = string.gsub(content, "\\ScontentsFileDate{(.-)}", "\\ScontentsFileDate{" .. tagdate .. "}")
    content = string.gsub(content, "\\ScontentsCoreFileDate{(.-)}", "\\ScontentsCoreFileDate{" .. tagdate .. "}")
    content = string.gsub(content, "\\ScontentsFileVersion{(.-)}", "\\ScontentsFileVersion{" .. tagname .. "}")
  end
  if string.match(file, "CTANREADME%.md$") then
    content = string.gsub(content, "Release v%d+%.%d+%a*%s*\\%[%d%d%d%d%-%d%d%-%d%d\\%]", "Release v" .. tagname .. " \\[" .. tagdate .. "\\]")
  end
  if string.match(file, "ctan%.ann$") then
    content = string.gsub(content, "v%d+%.%d+%w? %d%d%d%d%-%d%d%-%d%d", "v" .. tagname .. " " .. tagdate)
  end

  print("** " .. file .. " has been tagged with version " .. tagname .. " and date " .. tagdate)
  return content
end

-- Individual verification functions
local function check_dtx_tags()
  local content = read_file("sources/scontents.dtx")
  if not content then return false end
  local m_pkgd  = string.match(content, "\\ScontentsFileDate{(.-)}")
  local m_cored = string.match(content, "\\ScontentsCoreFileDate{(.-)}")
  local m_pkgv  = string.match(content, "\\ScontentsFileVersion{(.-)}")
  if m_pkgv ~= pkgversion or m_pkgd ~= pkgdate or m_cored ~= pkgdate then
    print("** Warning: Mismatches found in sources/scontents.dtx")
    return false
  end
  os_message("Checking version and date in scontents.dtx")
  return true
end

local function check_readme_tags()
  local content = read_file("sources/CTANREADME.md")
  if not content then return false end
  local m_readmev, m_readmed = string.match(content, "Release%s+(v%d+%.%d+%a*)%s+\\%[(%d%d%d%d%-%d%d%-%d%d)\\%]")
  if "v" .. pkgversion ~= m_readmev or pkgdate ~= m_readmed then
    print("** Warning: Mismatches found in sources/CTANREADME.md")
    return false
  end
  os_message("Checking version and date in CTANREADME.md")
  return true
end

-- Unified verification runner
local function check_all_tags()
  local ok_dtx = check_dtx_tags()
  local ok_readme = check_readme_tags()
  return ok_dtx and ok_readme
end

-- Standalone audit target: l3build tagcheck
target_list.tagcheck = {
  desc = "Check version and date in files",
  help = "Reports every file whose version or date differs from build.lua.",
  func = function()
    if check_all_tags() then return 0 end
    return 1
  end,
}

-- Helper function to generate an isolated build environment
local function system_temp_dir()
  local is_windows = package.config:sub(1, 1) == "\\"
  if is_windows then
    return os.getenv("TEMP") or os.getenv("TMP") or "C:\\Windows\\Temp"
  else
    return os.getenv("TMPDIR") or "/tmp"
  end
end

local function make_tmp_dir()
  -- Unified tag verification before unpacking
  if not check_all_tags() then
    error("** Error!!: Tag verification failed before preparing environment")
  end

  local sep = package.config:sub(1, 1)
  local base = system_temp_dir()
  local tmpname = os.tmpname()
  local unique = tmpname:match("([^/\\]+)$") or tostring(os.time())
  os.remove(tmpname) -- os.tmpname() sometimes creates an empty file; not needed

  tmpdir = base .. sep .. "scontents-build-" .. unique -- Global variable consumed by custom targets

  -- Create temporary directory
  local errorlevel = mkdir(tmpdir)
  if errorlevel ~= 0 then
    error("** Error!!: Could not create temporary directory " .. tmpdir)
  else
    os_message("Creating temporary directory " .. tmpdir)
  end

  -- Copy source files (.dtx and .ins)
  errorlevel = cp("*.dtx", sourcefiledir, tmpdir) + cp("*.ins", sourcefiledir, tmpdir)
  if errorlevel ~= 0 then
    error("** Error!!: Failed to copy source files to " .. tmpdir)
  else
    os_message("Copying scontents.dtx and scontents.ins to " .. tmpdir)
  end

  -- Unpack source files
  os_message("Unpacking source files in " .. tmpdir)
  local file = jobname("scontents.ins")
  errorlevel = run(tmpdir, "luatex -interaction=batchmode " .. file .. ".ins > " .. os_null)
  if errorlevel ~= 0 then
    local f = io.open(tmpdir .. "/" .. file .. ".log", "r")
    if f then
      print(f:read("*all"))
      f:close()
    end
    cp(file .. ".log", tmpdir, maindir)
    cp(file .. ".ins", tmpdir, maindir)
    error("** Error!!: Unpacking failed with luatex")
  else
    os_message("Successfully unpacked " .. file .. ".ins")
    rm(tmpdir, file .. ".log")
  end
  return 0
end

-- Names (without extension) of the .tex files in srcdir. Only plain file
-- names are accepted because they end up in shell commands.
local function list_samples(srcdir, wanted_only)
  if not direxists(srcdir) then
    error("** Error!!: Directory " .. srcdir .. " not found")
  end
  local samples = {}
  for file in lfs.dir(srcdir) do
    local name = file:match("^([%w%-_%.]+)%.tex$")
    if name then
      table.insert(samples, name)
    elseif file:match("%.tex$") then
      print("** Warning: skipping " .. file .. " (unsafe file name)")
    end
  end
  table.sort(samples)
  if #samples == 0 then
    error("** Error!!: No .tex files found in " .. srcdir)
  end
  -- Keeps only the names given on the command line (l3build example name ...);
  -- with no names all the files are kept. A name can be written with or
  -- without the .tex extension.
  local wanted = options["names"]
  if not wanted or #wanted == 0 then
    return samples
  end
  local exists = {}
  for _, name in ipairs(samples) do exists[name] = true end
  local selected = {}
  for _, arg_name in ipairs(wanted) do
    local name = (arg_name:gsub("%.tex$", ""))
    if not exists[name] then
      error("** Error!!: " .. name .. ".tex not found in " .. srcdir)
    end
    table.insert(selected, name)
  end
  return selected
end

-- On errors the temporary directory is kept, so the logs can be inspected
local function fail(msg)
  print("** Temporary directory kept for inspection: " .. tmpdir)
  error(msg)
end

-- Helper to detect whether an executable is in the PATH (Windows and Linux)
local function has_cmd(cmd)
  local is_windows = package.config:sub(1, 1) == "\\"
  local null_dev = os_null or (is_windows and "NUL" or "/dev/null")
  local check = is_windows and ("where " .. cmd .. " > " .. null_dev .. " 2>&1")
                           or ("command -v " .. cmd .. " > " .. null_dev .. " 2>&1")
  local res = os.execute(check)
  return (res == true or res == 0)
end

local function show_log(dir, name)
  local f = io.open(dir .. "/" .. name .. ".log", "r")
  if f then
    print(f:read("*all"))
    f:close()
  end
end

-- PDF validators (the ones that are installed)
local run_rnv, run_verapdf

local function announce_validators()
  run_rnv = has_cmd("rnv-wrapp") and has_cmd("show-pdf-tags")
  run_verapdf = has_cmd("verapdf")
  if run_rnv and run_verapdf then
    os_message("Validators detected: show-pdf-tags, rnv-wrapp & veraPDF")
  elseif run_rnv then
    os_message("Validators detected: show-pdf-tags & rnv-wrapp")
  elseif run_verapdf then
    os_message("Validator detected: veraPDF")
  end
end

local function validate_pdf(dir, pdf_file)
  if run_rnv then
    local cmd_rnv = "show-pdf-tags --xml " .. pdf_file .. " | rnv-wrapp"
    if run(dir, cmd_rnv .. " > " .. os_null) ~= 0 then
      print("\n[RNC Validation Error Output]:")
      run(dir, cmd_rnv)
      fail("** Error!!: Tag structure validation (rnv-wrapp) failed for " .. pdf_file)
    end
  end
  if run_verapdf then
    local cmd_vera = "verapdf --flavour ua2 --format text " .. pdf_file
    if run(dir, cmd_vera .. " > " .. os_null) ~= 0 then
      print("\n[PDF/UA-2 Validation Error Output]:")
      run(dir, cmd_vera)
      fail("** Error!!: veraPDF (PDF/UA-2) validation failed for " .. pdf_file)
    end
  end
  if run_rnv or run_verapdf then
    print("PASS")
  end
end

-- Run each command of the list in the temporary directory, the file name
-- is appended to each command; on error the log of the file is shown,
-- unless ignore is true (the file is expected to raise errors)
local function run_commands(sample, cmds, logname, ignore)
  for _, cmd in ipairs(cmds) do
    os_message("Running: " .. cmd .. " " .. sample)
    if run(tmpdir, cmd .. " " .. sample .. " > " .. os_null) ~= 0 and not ignore then
      show_log(tmpdir, logname or sample)
      fail("** Error!!: " .. cmd .. " failed for " .. sample)
    end
  end
end

-- The files of sources/samples that need more than one run: the key
-- remember of scontents-exa-12 uses the stored contents before they are
-- stored, they are read from the .sct file written by the first run
local example_runs = {
  ["scontents-exa-12"] = 2,
}

-- Custom target: l3build example
-- Compiles with lualatex-dev the files in sources/samples, once or as many
-- times as example_runs says; the PDFs are left there
target_list.example = {
  desc = "Compile the files in /samples (one run, two for scontents-exa-12)",
  help = "Accepts file names, with or without .tex: l3build example scontents-exa-2",
  func = function()
    local srcdir = sourcefiledir .. "/samples"
    local samples = list_samples(srcdir)
    make_tmp_dir()
    if cp("*.tex", srcdir, tmpdir) ~= 0 then
      fail("** Error!!: Failed to copy example files from " .. srcdir .. " to " .. tmpdir)
    end
    os_message("Copied example files from " .. srcdir .. " to " .. tmpdir)
    for _, sample in ipairs(samples) do
      local cmds = {}
      for _ = 1, example_runs[sample] or 1 do
        table.insert(cmds, "lualatex-dev -interaction=nonstopmode")
      end
      run_commands(sample .. ".tex", cmds, sample)
      if cp(sample .. ".pdf", tmpdir, srcdir) ~= 0 then
        fail("** Error!!: Failed to copy " .. sample .. ".pdf to " .. srcdir)
      end
      os_message("OK: " .. sample .. ".tex, copied " .. sample .. ".pdf to " .. srcdir)
    end
    os_message("All " .. #samples .. " example files compiled")
    cleandir(tmpdir)
    lfs.rmdir(tmpdir)
    os_message("Removed temporary directory " .. tmpdir)
    return 0
  end,
}

-- The files of sources/test-pkg are compiled according to their name:
--   test-format.plain.tex   : pdftex (plain TeX)
--   test-format.latex.tex   : latex-dev > dvips > ps2pdf
--   test-format.context.tex : context --luatex
--   test-tagged-pdf.tex     : lualatex-dev (two runs) and validated
--   test-pkg-current.tex    : pdflatex-dev, its errors are not checked
-- The other files in sources/test-pkg are not compiled.
local testse_files = {
  ["test-format.plain"]   = { cmds = { "pdftex -interaction=nonstopmode" } },
  ["test-format.latex"]   = { cmds = { "latex-dev -interaction=nonstopmode" },
                              post = { "dvips -q", "ps2pdf" } },
  ["test-format.context"] = { cmds = { "context --luatex --nonstopmode" } },
  ["test-tagged-pdf"]     = { cmds = { "lualatex-dev -interaction=nonstopmode",
                                       "lualatex-dev -interaction=nonstopmode" },
                              validate = true },
  ["test-pkg-current"]    = { cmds = { "pdflatex-dev -interaction=nonstopmode" },
                              ignore = true },
}

-- Custom target: l3build testSE
-- Compiles the files in sources/test-pkg with their format and validates the
-- tagged one; the PDFs are left there
target_list.testSE = {
  desc = "Compile and validate the files in /test-pkg (all formats)",
  help = "Accepts file names, with or without .tex: l3build testSE test-tagged-pdf",
  func = function()
    local srcdir = sourcefiledir .. "/test-pkg"
    local samples = {}
    for _, name in ipairs(list_samples(srcdir)) do
      if testse_files[name] then
        table.insert(samples, name)
      elseif options["names"] and #options["names"] > 0 then
        error("** Error!!: " .. name .. ".tex is not compiled by testSE")
      end
    end
    make_tmp_dir()
    if cp("*.*", srcdir, tmpdir) ~= 0 then
      fail("** Error!!: Failed to copy test files from " .. srcdir .. " to " .. tmpdir)
    end
    os_message("Copied test files from " .. srcdir .. " to " .. tmpdir)
    announce_validators()
    for _, sample in ipairs(samples) do
      local spec = testse_files[sample]
      run_commands(sample .. ".tex", spec.cmds, sample, spec.ignore)
      if spec.post then
        run_commands(sample .. ".dvi", { spec.post[1] }, sample)
        run_commands(sample .. ".ps", { spec.post[2] }, sample)
      end
      if spec.validate then
        validate_pdf(tmpdir, sample .. ".pdf")
      end
      if cp(sample .. ".pdf", tmpdir, srcdir) ~= 0 then
        fail("** Error!!: Failed to copy " .. sample .. ".pdf to " .. srcdir)
      end
      os_message("OK: " .. sample .. ".tex, copied " .. sample .. ".pdf to " .. srcdir)
    end
    os_message("All " .. #samples .. " test files compiled")
    cleandir(tmpdir)
    lfs.rmdir(tmpdir)
    os_message("Removed temporary directory " .. tmpdir)
    return 0
  end,
}

-- The PDFs attached to the manual are the ones that 'l3build example' leaves
-- in sources/samples, and 'l3build testSE' leaves its PDFs in
-- sources/test-pkg. Before packaging, check that all of them exist and are
-- not older than their .tex (target ctan and release only; doc copies what
-- is there without checking).
local function check_example_pdfs()
  local stale = {}
  local function check(dir, names)
    for _, sample in ipairs(names) do
      local tex = lfs.attributes(dir .. "/" .. sample .. ".tex", "modification")
      local pdf = sample .. ".pdf"
      local mod = lfs.attributes(dir .. "/" .. pdf, "modification")
      if not mod then
        table.insert(stale, dir .. "/" .. pdf .. " (missing)")
      elseif mod < tex then
        table.insert(stale, dir .. "/" .. pdf .. " (older than " .. sample .. ".tex)")
      end
    end
  end
  check(sourcefiledir .. "/samples", list_samples(sourcefiledir .. "/samples"))
  local tests = {}
  for name in pairs(testse_files) do table.insert(tests, name) end
  table.sort(tests)
  check(sourcefiledir .. "/test-pkg", tests)
  if #stale > 0 then
    error("** Error!!: PDFs of the examples out of date, run 'l3build example' and 'l3build testSE' first:\n   "
      .. table.concat(stale, "\n   "))
  end
  os_message("Checking PDFs of sources/test-pkg and sources/samples")
end

if options["target"] == "ctan" then
  check_example_pdfs()
end

-- Clean repo with Git
-- 'git clean -X' removes only the files ignored by .gitignore (build/, logs,
-- ...), so it needs no confirmation. Untracked files that are not ignored
-- (new files not yet added) are never removed: they are only listed.
-- With --dry-run it only lists.
if options["target"] == "clean" then
  local function git_out(cmd)
    local f = io.popen(cmd .. " 2>&1", "r")
    if not f then return nil end
    local out = f:read("*a") or ""
    f:close()
    return out
  end

  local inside = git_out("git rev-parse --is-inside-work-tree")
  if not inside or not inside:match("^true") then
    os_message("Not a Git work tree: skipping git clean")
  else
    local preview = git_out("git ls-files --others --ignored --exclude-standard --directory")
    if not preview or preview:match("^%s*$") then
      os_message("Nothing to clean with Git")
    else
      print("** Ignored files and directories removed by git clean:")
      io.write(preview)
      if options["dry-run"] then
        os_message("Dry run: nothing removed")
      else
        os_message("Cleaning ignored repository files with Git")
        local res = os.execute("git clean -Xdfq")
        if res ~= 0 and res ~= true then
          error("** Error!!: git clean failed")
        end
      end
    end
    local kept = git_out("git ls-files --others --exclude-standard --directory")
    if kept and not kept:match("^%s*$") then
      print("** Untracked files NOT removed (add them or delete them by hand):")
      io.write(kept)
    end
  end
  -- No os.exit() here so that l3build goes on cleaning the build/ directory
end

-- Capture shell output safely (e.g. for Git queries)
local function os_capture(cmd, raw)
  local f = io.popen(cmd, "r")
  if not f then return "" end
  local s = f:read("*a") or ""
  f:close()
  if raw then return s end
  s = string.gsub(s, "^%s+", "")
  s = string.gsub(s, "%s+$", "")
  s = string.gsub(s, "[\n\r]+", " ")
  return s
end

-- Run another l3build target quietly; its failure stops the release
local function run_l3build(tgt, extra)
  os_message("Running 'l3build " .. tgt .. "'" .. (extra or ""))
  local res = os.execute("l3build " .. tgt .. " > " .. os_null)
  if res ~= 0 and res ~= true then
    error("** Error!!: 'l3build " .. tgt .. "' failed (run it alone to see why); nothing was tagged or pushed")
  end
end

-- Run a git command; its failure stops the release with the given message
local function run_git(cmd, msg)
  local res = os.execute(cmd)
  if res ~= 0 and res ~= true then
    error(msg)
  end
end

-- Target "release": performs pre-release checks for Git and CTAN
local function release_target()
  -- 1. Verify working branch is 'master'
  local gitbranch = os_capture("git symbolic-ref --short HEAD")
  if gitbranch == "master" then
    os_message("Checking git branch 'master'")
  else
    error("** Error!!: You must be on the 'master' branch (currently on '" .. gitbranch .. "')")
  end

  -- 2. Verify clean working directory (before generating any build files)
  local gitstatus = os_capture("git status --porcelain")
  if gitstatus == "" then
    os_message("Checking working directory status")
  else
    error("** Error!!: Uncommitted changes detected. Please commit all changes before release.")
  end

  -- 3. Verify local commits are pushed
  local gitpush = os_capture("git log --branches --not --remotes")
  if gitpush == "" then
    os_message("Checking pending commits")
  else
    error("** Error!!: There are unpushed local commits. Run 'git push' first.")
  end

  -- 4. Audit version/date consistency across all files
  if not check_all_tags() then
    error("** Error!!: Tag verification failed. Update build.lua or run 'l3build tag'")
  end

  -- 5. Test source extraction via luatex
  local file = jobname(sourcefiledir .. "/scontents.ins")
  local errorlevel = run(sourcefiledir, "luatex --interaction=batchmode " .. file .. ".ins > " .. os_null)
  if errorlevel ~= 0 then
    error("** Error!!: Failed to process " .. file .. ".ins with luatex")
  else
    os_message("Unpacking " .. file .. ".ins with luatex")
  end

  -- 6. Build CTAN package archive if absent
  if fileexists(ctanzip .. ".zip") then
    os_message("Checking CTAN package " .. ctanzip .. ".zip")
  else
    -- The PDFs attached to the manual are regenerated first: the ctan
    -- target refuses to run if they are missing or older than their .tex
    run_l3build("example", " (PDFs of sources/samples)")
    run_l3build("testSE", " (PDFs of sources/test-pkg)")
    run_l3build("ctan", " (" .. ctanzip .. ".zip)")
  end

  -- 7. Perform CTAN upload dry run. With --debug l3build posts the form to
  -- httpbin.org and always exits with status 1, so the check looks at the
  -- echoed form (package and version) instead of the exit status.
  os_message("Running dry-run upload check")
  local dryrun = os_capture("l3build upload -F ctan.ann --debug 2>&1", true)
  local okpkg = string.find(dryrun, '"pkg": "' .. ctanpkg .. '"', 1, true)
  local okver = string.find(dryrun, '"version": "' .. uploadconfig.version .. '"', 1, true)
  if not (okpkg and okver) then
    error("** Error!!: dry-run upload check failed; nothing was tagged or pushed")
  end

  -- 8. Commit what the steps above regenerated (the PDFs versioned in git),
  -- so that the tag points to the commit that matches the zip. The working
  -- directory was clean in step 2: only regenerated files can have changed.
  local regenerated = os_capture("git status --porcelain --untracked-files=no")
  if regenerated == "" then
    os_message("No regenerated files to commit")
  else
    local commit_msg = "Release v" .. pkgversion .. " [" .. pkgdate .. "]"
    run_git("git add -u", "** Error!!: 'git add -u' failed; nothing was tagged or pushed")
    run_git('git commit --quiet -m "' .. commit_msg .. '"', "** Error!!: 'git commit' failed; nothing was tagged or pushed")
    os_message("Committing regenerated files: " .. commit_msg)
    run_git("git push --quiet", "** Error!!: 'git push' failed. The commit exists locally; push it manually.")
    os_message("Pushing the commit to remote")
  end

  -- 9. Tag commit in Git (only after everything above succeeded)
  local tag_version = "v" .. pkgversion
  local tagongit = os_capture('git for-each-ref refs/tags --sort=-taggerdate --format="%(refname:short)" --count=1')
  os_message("Checking latest Git tag (latest: " .. (tagongit ~= "" and tagongit or "none") .. ")")

  local tag_cmd = string.format('git tag -a %s -m "Release %s %s"', tag_version, tag_version, pkgdate)
  run_git(tag_cmd, "** Error!!: Could not create Git tag " .. tag_version .. ". Verify if it already exists.")
  os_message("Creating Git tag " .. tag_version)

  os_message("Pushing Git tags to remote")
  run_git("git push --tags --quiet", "** Error!!: 'git push --tags' failed. The tag " .. tag_version .. " exists locally; push it manually.")

  print("-----------------------------------------------------------------")
  print("** Pre-release checks completed successfully!")
  print("** Review '" .. ctanzip .. ".curlopt' and verify 'ctan.ann'")
  print("** To publish to CTAN, run manually: l3build upload")
  print("-----------------------------------------------------------------")
  return 0
end

target_list.release = {
  desc = "Checks before a public release (git and ctan), then tags and pushes",
  help = "Runs the checks, creates the git tag and pushes it; then run l3build upload by hand.",
  func = release_target,
}
