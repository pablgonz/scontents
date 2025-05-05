--[[
   Configuration script for l3build from the scontents package
   At the moment the possible options that can be passed on to
   l3build are:
   * tag        : Update the version and date
   * doc        : Generate the documentation [-q]
   * unpack     : Unpacks the source files [-q]
   * install    : Install the package locally, you can use
                  it in conjunction with [--full] [--dry-run]
   * uninstall  : Uninstall the package locally
   * clean      : Clean the directory tree and repo
   * ctan       : Generate the compressed package (.zip)
   * upload     : Upload the package to ctan, you must add
                  -F ctan.ann in conjunction with [--debug]
   * testpkg    : Compile the tests included in the test-pkg/
   * tagged     : Check version and date in files
   * examples   : Compile the example files included in .dtx file
   * release    : It performs the checks before generating a public
                  release (on git and ctan).
--]]

-- General package identification
module     = "scontents"
pkgversion = "2.4"
pkgdate    = "2025-05-05"

-- Configuration of files for build and installation
maindir       = "."
sourcefiledir = "./sources"
textfiledir   = "./sources"
--textfiles     = {textfiledir.."/CTANREADME.md"}
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

-- Unpacking files from .ins file
unpackfiles = { "scontents.ins" }
unpackopts  = "--interaction=batchmode"
unpackexe   = "luatex"

-- Generating documentation
typesetfiles  = {"scontents.dtx"}

-- Update package date and version
tagfiles = {"sources/scontents.ins", "sources/scontents.dtx", "sources/CTANREADME.md", "ctan.ann"}
local mydate = os.date("!%Y-%m-%d")

function update_tag(file,content,tagname,tagdate)
  if not tagname and tagdate == mydate or "" then
    tagname = pkgversion
    tagdate = pkgdate
    print("** "..file.." have been tagged with the version and date of build.lua")
  else
    local v_maj, v_min = string.match(tagname, "^v?(%d+)(%S*)$")
    if v_maj == "" or not v_min then
      print("Error!!: Invalid tag '"..tagname.."', none of the files have been tagged")
      os.exit(0)
    else
      tagname = string.format("%i%s", v_maj, v_min)
      tagdate = mydate
    end
    print("** "..file.." have been tagged with the version "..tagname.." and date "..mydate)
  end

  if string.match(file, "scontents.ins") then
    content = string.gsub(content,
                          "date=%d%d%d%d%-%d%d%-%d%d",
                          "date="..tagdate)
    content = string.gsub(content,
                          "version=%d%.%d%w?",
                          "version="..tagname)
  end
  if string.match(file, "scontents.dtx") then
    content = string.gsub(content,
                          "\\ScontentsFileDate{(.-)}",
                          "\\ScontentsFileDate{"..tagdate.."}")
    content = string.gsub(content,
                          "\\ScontentsCoreFileDate{(.-)}",
                          "\\ScontentsCoreFileDate{"..tagdate.."}")
    content = string.gsub(content,
                          "\\ScontentsFileVersion{(.-)}",
                          "\\ScontentsFileVersion{"..tagname.."}")
  end
  if string.match(file, "CTANREADME.md") then
    content = string.gsub(content,
                          "Release v%d+.%d+%a* \\%[%d%d%d%d%-%d%d%-%d%d\\%]",
                          "Release v"..tagname.." \\["..tagdate.."\\]")
  end
  if string.match(file,"ctan.ann") then
    content = string.gsub(content,
                         "v%d%.%d%w? %d%d%d%d%-%d%d%-%d%d",
                         "v"..tagname..' '..tagdate)
  end
  return content
end

-- Configuration for ctan
ctanreadme = "CTANREADME.md"
ctanpkg    = "scontents"
ctanzip    = ctanpkg.."-"..pkgversion
packtdszip = false

-- Clean files
cleanfiles = {module..".pdf", ctanzip..".curlopt", ctanzip..".zip"}

--  Configuration for package distribution in ctan
uploadconfig = {
  author       = "Pablo González L",
  uploader     = "Pablo González L",
  email        = "pablgonz@yahoo.com",
  pkg          = ctanpkg,
  version      = pkgversion,
  license      = "lppl1.3c",
  summary      = "Stores LaTeX contents in memory or files",
  description  =[[This package stores valid LaTeX code in memory (sequences) using the l3seq module of expl3. The stored content (including verbatim) can be used as many times as desired in the document, additionally can be written to external files if desired.]],
  topic        = { "File management", "Experimental LaTeX3" },
  ctanPath     = "/macros/latex/contrib/" .. ctanpkg,
  repository   = "https://github.com/pablgonz/" .. module,
  bugtracker   = "https://github.com/pablgonz/" .. module .. "/issues",
  support      = "https://github.com/pablgonz/" .. module .. "/issues",
  note         = [[Uploaded automatically by l3build...]],
  announcement_file="ctan.ann",
  update       = true
}

-- Line length in 80 characters
local function os_message(text)
  local mymax = 77 - string.len(text) - string.len("done")
  local msg = text.." "..string.rep(".", mymax).." done"
  return print(msg)
end

-- Typesetting scontents documentation step by step :)
function docinit_hook()
  errorlevel = (cp("*.tex", unpackdir, typesetdir) + cp("*.sty", unpackdir, typesetdir))
  if errorlevel ~= 0 then
    error("** Error!!: Can't copy .tex and .sty files from "..unpackdir.." to "..typesetdir)
    return errorlevel
  end
  return 0
end

function typeset(file)
  local file = jobname(sourcefiledir.."/scontents.dtx")
  print("** Running: lualatex -draftmode -interaction=batchmode "..file..".dtx")
  errorlevel = runcmd("lualatex -draftmode -interaction=batchmode "..file..".dtx >"..os_null, typesetdir, {"TEXINPUTS","LUAINPUTS"})
  if errorlevel ~= 0 then
    local f = assert(io.open(typesetdir.."/scontents.log", "r"))
    err_log_file = f:read("*all")
    print(err_log_file)
    cp(file..".log", typesetdir, maindir)
    cp(file..".dtx", typesetdir, maindir)
    error("** Error!!: lualatex -draftmode -interaction=batchmode "..file..".dtx")
    return errorlevel
  end
  print("** Running: lualatex -draftmode -interaction=batchmode "..file..".dtx")
  errorlevel = runcmd("lualatex -draftmode -interaction=batchmode "..file..".dtx >"..os_null, typesetdir, {"TEXINPUTS","LUAINPUTS"})
  if errorlevel ~= 0 then
    error("** Error!!: lualatex -draftmode -interaction=batchmode "..file..".dtx")
    return errorlevel
  end
  print("** Running: lualatex -interaction=batchmode "..file..".dtx")
  errorlevel = runcmd("lualatex -interaction=batchmode "..file..".dtx >"..os_null, typesetdir, {"TEXINPUTS","LUAINPUTS"})
  if errorlevel ~= 0 then
    error("** Error!!: lualatex -interaction=batchmode "..file..".dtx")
    return errorlevel
  end
  return 0
end

-- Create check_marked_tags() function
local function check_marked_tags()
  local f = assert(io.open("sources/scontents.dtx", "r"))
  marked_tags = f:read("*all")
  f:close()
  local m_pkgd = string.match(marked_tags, "\\ScontentsFileDate{(.-)}")
  local m_pkgv = string.match(marked_tags, "\\ScontentsFileVersion{(.-)}")
  if pkgversion == m_pkgv and pkgdate == m_pkgd then
    os_message("Checking version and date in scontents.dtx")
  else
    print("** Warning: scontents.dtx is marked with version "..m_pkgv.." and date "..m_pkgd)
    print("** Warning: build.lua is marked with version "..pkgversion.." and date "..pkgdate)
    print("** Check version and date in build.lua then run l3build tag")
  end
end

-- Create check_readme_tags() function
local function check_readme_tags()
  local pkgversion = "v"..pkgversion

  local f = assert(io.open("sources/CTANREADME.md", "r"))
  readme_tags = f:read("*all")
  f:close()
  local m_readmev, m_readmed = string.match(readme_tags, "Release (v%d+.%d+%a*) \\%[(%d%d%d%d%-%d%d%-%d%d)\\%]")

  if pkgversion == m_readmev and pkgdate == m_readmed then
    os_message("Checking version and date in README.md")
  else
    print("** Warning: README.md is marked with version "..m_readmev.." and date "..m_readmed)
    print("** Warning: build.lua is marked with version "..pkgversion.." and date "..pkgdate)
    print("** Check version and date in build.lua then run l3build tag")
  end
end

-- Config tag_hook
function tag_hook(tagname)
  check_marked_tags()
  check_readme_tags()
end

-- Add "tagged" target to l3build CLI
if options["target"] == "tagged" then
  check_marked_tags()
  check_readme_tags()
  os.exit(0)
end

-- Create make_tmp_dir() function
local function make_tmp_dir()
  -- Check version and date
  check_marked_tags()
  check_readme_tags()
  -- Fix basename(path) in windows
  local function basename(path)
    return path:match("^.*[\\/]([^/\\]*)$")
  end
  local tmpname = os.tmpname()
  tmpdir = basename(tmpname)
  -- Create a tmp dir
  errorlevel = mkdir(tmpdir)
  if errorlevel ~= 0 then
    error("** Error!!: The ./"..tmpdir.." directory could not be created")
    return errorlevel
  else
    os_message("Creating the temporary directory ./"..tmpdir)
  end
  -- Copy files
  errorlevel = (cp("*.dtx", sourcefiledir, tmpdir) + cp("*.ins", sourcefiledir, tmpdir))
  if errorlevel ~= 0 then
    error("** Error!!: Can't copy .dtx and .ins files from "..sourcefiledir.." to ./"..tmpdir)
    return errorlevel
  else
    os_message("Copying scontents.dtx and scontents.ins from "..sourcefiledir.." to ./"..tmpdir)
  end
  -- Unpack files
  print("Unpacks the source files into ./"..tmpdir)
  local file = jobname(tmpdir.."/scontents.ins")
  errorlevel = run(tmpdir, "luatex -interaction=batchmode "..file..".ins > "..os_null)
  if errorlevel ~= 0 then
    local f = assert(io.open(tmpdir.."/"..file..".log", "r"))
    err_log_file = f:read("*all")
    print(err_log_file)
    cp(file..".log", tmpdir, maindir)
    cp(file..".ins", tmpdir, maindir)
    error("** Error!!: luatex -interaction=batchmode "..file..".ins")
    return errorlevel
  else
    os_message("** Running: luatex -interaction=batchmode "..file..".ins")
    rm(tmpdir, file..".log")
  end
  return 0
end

-- We added a new target "testpkg" to run the tests files in test-pkg/
if options["target"] == "testpkg" then
  -- Create a tmp dir and unpack files
  make_tmp_dir()
  -- Copy test files
  errorlevel = cp("*.*", "sources/test-pkg", tmpdir)
  if errorlevel ~= 0 then
    error("** Error!!: Can't copy files from sources/test-pkg to ./"..tmpdir)
    return errorlevel
  else
    os_message("** Copying files from sources/test-pkg to ./"..tmpdir)
  end
  -- First, no check error level :(
  local file = jobname(tmpdir.."/test-pkg-current.tex")
  print("Running first test on the file: "..file..".tex using [pdflatex]")
  os_message("** Running: pdflatex -interaction=batchmode "..file..".tex")
  errorlevel = run(tmpdir, "pdflatex -no-file-line-error -interaction=nonstopmode "..file..".tex")
  -- Second
  local file = jobname(tmpdir.."/test-format.plain.tex")
  print("Running second test on the file: "..file..".tex using [pdftex]")
  errorlevel = run(tmpdir, "pdftex "..file..".tex > "..os_null)
  if errorlevel ~= 0 then
    local f = assert(io.open(tmpdir.."/"..file..".log", "r"))
    err_log_file = f:read("*all")
    print(err_log_file)
    cp(file..".log", tmpdir, maindir)
    error("** Error!!: pdftex "..file..".tex")
    return errorlevel
  else
    os_message("** Running: pdftex "..file..".tex")
  end
  --Third
  local file = jobname(tmpdir.."/test-format.latex.tex")
  print("Running third test on the file: "..file..".tex using [latex>dvips>ps2pdf]")
  errorlevel = run(tmpdir, "latex "..file..".tex > "..os_null)
  if errorlevel ~= 0 then
    local f = assert(io.open(tmpdir.."/"..file..".log", "r"))
    err_log_file = f:read("*all")
    print(err_log_file)
    cp(file..".log", tmpdir, maindir)
    error("** Error!!: latex "..file..".tex")
    return errorlevel
  else
    os_message("** Running: latex "..file..".tex")
  end
  errorlevel = run(tmpdir, "dvips -q "..file..".dvi > "..os_null)
  if errorlevel ~= 0 then
    local f = assert(io.open(tmpdir.."/"..file..".log", "r"))
    err_log_file = f:read("*all")
    print(err_log_file)
    cp(file..".log", tmpdir, maindir)
    error("** Error!!: dvips "..file..".dvi")
    return errorlevel
  else
    os_message("** Running: dvips "..file..".dvi")
  end
  errorlevel = run(tmpdir, "ps2pdf "..file..".ps > "..os_null)
  if errorlevel ~= 0 then
    local f = assert(io.open(tmpdir.."/"..file..".log", "r"))
    err_log_file = f:read("*all")
    print(err_log_file)
    cp(file..".log", tmpdir, maindir)
    error("** Error!!: ps2pdf "..file..".ps")
    return errorlevel
  else
    os_message("** Running: ps2pdf "..file..".ps")
  end
  -- Fourth
  local file = jobname(tmpdir.."/test-format.context.tex")
  print("Running fourth test on the file: "..file..".tex using [context]")
  errorlevel = run(tmpdir, "context --luatex "..file..".tex > "..os_null)
  if errorlevel ~= 0 then
    local f = assert(io.open(tmpdir.."/"..file..".log", "r"))
    err_log_file = f:read("*all")
    print(err_log_file)
    cp(file..".log", tmpdir, maindir)
    error("** Error!!: context --luatex "..file..".tex")
    return errorlevel
  else
    os_message("** Running: context --luatex "..file..".tex")
  end
  -- Fifth (Tagged PDF)
  local file = jobname(tmpdir.."/test-tagged-pdf.tex")
  print("Running fifth test on the file: "..file..".tex using [lualatex]")
  errorlevel = run(tmpdir, "lualatex "..file..".tex")
  if errorlevel ~= 0 then
    local f = assert(io.open(tmpdir.."/"..file..".log", "r"))
    err_log_file = f:read("*all")
    print(err_log_file)
    cp(file..".log", tmpdir, maindir)
    error("** Error!!: lualatex "..file..".tex")
    return errorlevel
  else
    os_message("** Running: lualatex "..file..".tex")
  end
  -- Copy generated .pdf files to maindir
  errorlevel = cp("*.pdf", tmpdir, maindir)
  if errorlevel ~= 0 then
    error("** Error!!: Can't copy generated pdf files to ./"..maindir)
    return errorlevel
  else
    os_message("Copy generated .pdf files to ./"..maindir)
  end
   -- If are OK then remove ./temp dir
  cleandir(tmpdir)
  lfs.rmdir(tmpdir)
  os_message("Remove temporary directory ./"..tmpdir)
  os.exit(0)
end

-- We added a new target "examples" to run the examples files for scontents
if options["target"] == "examples" then
  -- Create a tmp dir and unpack files
  make_tmp_dir()
  local file = jobname(tmpdir.."/scontents.dtx")
  -- Unpack sample files
  print("Unpack samples into ./"..tmpdir.." from file "..file..".dtx")
  errorlevel = run(tmpdir, "lualatex -draftmode -interaction=batchmode "..file..".dtx > "..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: lualatex -draftmode -interaction=batchmode "..file..".dtx")
    return errorlevel
  else
    os_message("** Running: lualatex -draftmode -interaction=batchmode "..file..".dtx")
  end
  -- List of sample files
  samples = {
    "scexamp1",
    "scexamp2",
    "scexamp3",
    "scexamp4",
    "scexamp5",
    "scexamp6",
    "scexamp7",
    "scexamp8",
    "scexamp9",
    "scexamp10",
    "scexamp11",
  }
  -- Compiling sample files
  print("Compiling sample files in ./"..tmpdir.." using [arara]")
  for i, samples in ipairs(samples) do
    errorlevel = run(tmpdir, "arara "..samples..".ltx > "..os_null)
    if errorlevel ~= 0 then
      local f = assert(io.open(tmpdir.."/"..samples..".log", "r"))
      err_log_file = f:read("*all")
      print(err_log_file)
      cp(samples..".ltx", tmpdir, maindir)
      cp(samples..".log", tmpdir, maindir)
      error("** Error!!: arara "..samples..".ltx")
      return errorlevel
    else
      os_message("** Running: arara "..samples..".ltx")
    end
  end
  -- Copy generated .pdf files to maindir
  errorlevel = cp("scexamp*.pdf", tmpdir, maindir)
  if errorlevel ~= 0 then
    error("** Error!!: Can't copy generated pdf files to ./"..maindir)
    return errorlevel
  else
    os_message("Copy generated .pdf files to ./"..maindir)
  end
  -- If are OK then remove ./temp dir
  cleandir(tmpdir)
  lfs.rmdir(tmpdir)
  os_message("Remove temporary directory ./"..tmpdir)
  os.exit(0)
end

-- Clean repo
if options["target"] == "clean" then
  print("Clean files in repo")
  os.execute("git clean -xdfq")
  os_message("** Running: git clean -xdfq")
end

-- Capture os cmd for git
local function os_capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

-- We added a new target "release" to do the final checks for git and ctan
if options["target"] == "release" then
  -- os.execute("git clean -xdfq")
  local gitbranch = os_capture("git symbolic-ref --short HEAD")
  local gitstatus = os_capture("git status --porcelain")
  local tagongit  = os_capture('git for-each-ref refs/tags --sort=-taggerdate --format="%(refname:short)" --count=1')
  local gitpush   = os_capture("git log --branches --not --remotes")

  if gitbranch == "master" then
    os_message("** Checking git branch '"..gitbranch.."': OK")
  else
    error("** Error!!: You must be on the 'master' branch")
  end
  local file = jobname(sourcefiledir.."/scontents.ins")
  errorlevel = run(sourcefiledir, "luatex --interaction=batchmode "..file..".ins > "..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: luatex -interaction=batchmode "..file..".ins")
    return errorlevel
  else
    os_message("** Running: luatex -interaction=batchmode "..file..".ins")
  end
  if gitstatus == "" then
    os_message("** Checking status of the files: OK")
  else
    error("** Error!!: Files have been edited, please commit all changes")
  end
  if gitpush == "" then
    os_message("** Checking pending commits: OK")
  else
    error("** Error!!: There are pending commits, please run git push")
  end
  check_marked_tags()
  local pkgversion = "v"..pkgversion
  os_message("** Checking last tag marked in GitHub "..tagongit..": OK")
  errorlevel = os.execute("git tag -a "..pkgversion.." -m 'Release "..pkgversion.." "..pkgdate.."'")
  if errorlevel ~= 0 then
    error("** Error!!: run git tag -d "..pkgversion.." && git push --delete origin "..pkgversion)
    return errorlevel
  else
    os_message("** Running: git tag -a "..pkgversion.." -m 'Release "..pkgversion.." "..pkgdate.."'")
  end
  os_message("** Running: git push --tags --quiet")
  os.execute("git push --tags --quiet")
  if fileexists(ctanzip..".zip") then
    os_message("** Checking "..ctanzip..".zip file to send to CTAN: OK")
  else
    os_message("** Creating "..ctanzip..".zip file to send to CTAN")
    os.execute("l3build ctan > "..os_null)
  end
  os_message("** Running: l3build upload -F ctan.ann --debug")
  os.execute("l3build upload -F ctan.ann --debug >"..os_null)
  print("** Now check "..ctanzip..".curlopt file and add changes to ctan.ann")
  print("** If everything is OK run (manually): l3build upload")
  os.exit(0)
end
