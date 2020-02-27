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
   * clean      : Clean the directory tree and some files
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
pkgversion = "1.9e"
pkgdate    = "2020-02-27"

-- Configuration of files for build and installation
maindir       = "."
sourcefiledir = "./sources"
textfiledir   = "./sources"
textfiles     = {textfiledir.."/CTANREADME.md"}
sourcefiles   = {"**/*.dtx", "**/*.ins"}
installfiles  = {"**/*.sty", "**/*.tex", "**/*.mkiv"}
tdslocations  = {
  "tex/generic/scontents/scontents.tex",
  "tex/generic/scontents/scontents-code.tex",
  "tex/latex/scontents/scontents.sty",
  "tex/context/third/scontents/t-scontents.mkiv",
  "doc/latex/scontents/scontents.pdf",
  "source/latex/scontents/scontents.dtx",
  "source/latex/scontents/scontents.ins"
}

-- Unpacking files from .ins file
unpackfiles = { "scontents.ins" }
unpackopts  = "--interaction=batchmode"
unpackexe   = "luatex"

-- Generating documentation
typesetfiles  = {"scontents.dtx"}
typesetexe    = "lualatex"
typesetopts   = "--interaction=batchmode"
typesetruns   = 3
makeindexopts = "-q"

-- Update package date and version
tagfiles = {"sources/scontents.ins", "sources/scontents.dtx", "sources/CTANREADME.md", "ctan.ann"}
local mydate = os.date("!%Y-%m-%d")

function update_tag(file,content,tagname,tagdate)
  if not tagname and tagdate == mydate then
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
                          "Version: %d%.%d%w?",
                          "Version: "..tagname)
    content = string.gsub(content,
                          "Date: %d%d%d%d%-%d%d%-%d%d",
                          "Date: ".. tagdate)
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
  author       = "Pablo González Luengo",
  uploader     = "Pablo González Luengo",
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

-- Compiling documentation step by step :)
--[[
function docinit_hook()
  errorlevel = cp("*.sty", unpackdir, typesetdir)
  errorlevel = cp("*.tex", unpackdir, typesetdir)
  if errorlevel ~= 0 then
    error("** Error!!: Can't copy all files from "..unpackdir.." to "..typesetdir)
    return errorlevel
  else
    print("** Copying all files from "..unpackdir.." to "..typesetdir)
  end
  return 0
end

function typeset(file)
  local file = jobname(sourcefiledir.."/scontents.dtx")
  errorlevel = run(typesetdir, "lualatex --interaction=batchmode "..file..".dtx >"..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: lualatex --interaction=batchmode "..file..".dtx")
    return errorlevel
  else
    os_message("** Running: lualatex --interaction=batchmode "..file..".dtx: OK")
  end
  local file = jobname(unpackdir.."/userdoc.ind")
  --errorlevel = run(typesetdir, "makeindex -s gind.ist -o "..file..".ind "..file..".idx")
  errorlevel = makeindex(file, typesetdir, ".idx", ".ind", ".ilg", indexstyle)
  if errorlevel ~= 0 then
    error("** Error!!: makeindex -s gind.ist -o "..file..".ind "..file..".idx")
    return errorlevel
  else
    os_message("** Running: makeindex -s gind.ist -o "..file..".ind "..file..".idx: OK")
  end
  local file = jobname(sourcefiledir.."/scontents.dtx")
  --errorlevel = run(typesetdir, "makeindex -q -s gind.ist -o "..file..".ind "..file..".idx")
  errorlevel = makeindex(file, typesetdir, ".idx", ".ind", ".ilg", indexstyle)
  if errorlevel ~= 0 then
    error("** Error!!: makeindex -s gind.ist -o "..file..".ind "..file..".idx")
    return errorlevel
  else
    os_message("** Running: makeindex -s gind.ist -o "..file..".ind "..file..".idx: OK")
  end
  errorlevel = run(typesetdir, "lualatex --interaction=batchmode "..file..".dtx >"..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: lualatex --interaction=batchmode "..file..".dtx")
    return errorlevel
  else
    os_message("** Running: lualatex --interaction=batchmode "..file..".dtx: OK")
  end
  errorlevel = run(typesetdir, "lualatex --interaction=batchmode "..file..".dtx >"..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: lualatex --interaction=batchmode "..file..".dtx")
    return errorlevel
  else
    os_message("** Running: lualatex --interaction=batchmode "..file..".dtx: OK")
  end
  return 0
end
--]]
-- Create check_marked_tags() function
local function check_marked_tags()
  local f = assert(io.open("sources/scontents.dtx", "r"))
  marked_tags = f:read("*all")
  f:close()
  local m_pkgd = string.match(marked_tags, "\\ScontentsFileDate{(.-)}")
  local m_pkgv = string.match(marked_tags, "\\ScontentsFileVersion{(.-)}")
  if pkgversion == m_pkgv and pkgdate == m_pkgd then
    os_message("** Checking version and date: OK")
  else
    print("** Warning: scontents.dtx is marked with version "..m_pkgv.." and date "..m_pkgd)
    print("** Warning: build.lua is marked with version "..pkgversion.." and date "..pkgdate)
    print("** Check version and date in build.lua then run l3build tag")
  end
end

-- Config tag_hook
function tag_hook(tagname)
  check_marked_tags()
end

-- Add "tagged" target to l3build CLI
if options["target"] == "tagged" then
  check_marked_tags()
  os.exit(0)
end

-- We added a new target "testpkg" to run the tests files in test-pkg/
if options["target"] == "testpkg" then
  local file = jobname(sourcefiledir.."/scontents.ins")
  errorlevel = run(sourcefiledir, "pdftex -interaction=batchmode "..file..".ins > "..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: pdftex -interaction=batchmode "..file..".ins")
    return errorlevel
  else
    os_message("** Running: pdftex -interaction=batchmode "..file..".ins")
  end
  errorlevel = cp("*.*", sourcefiledir, "sources/test-pkg")
  if errorlevel ~= 0 then
    error("** Error!!: Can't copy files from "..sourcefiledir.." to ./sources/test-pkg")
    return errorlevel
  else
    os_message("** Copying files from "..sourcefiledir.." to to sources/test-pkg: OK")
  end
  os_message("** Running: pdflatex -interaction=batchmode "..file..".tex")
  local file = jobname("sources/test-pkg/test-pkg-current.tex")
  run("./sources/test-pkg", "pdflatex -no-file-line-error -interaction=nonstopmode "..file..".tex")
  local file = jobname("sources/test-pkg/test-format.plain.tex")
  errorlevel = run("./sources/test-pkg", "pdftex "..file..".tex > "..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: pdftex "..file..".tex")
    return errorlevel
  else
    os_message("** Running: pdftex "..file..".tex")
  end
  local file = jobname("./sources/test-pkg/test-format.latex.tex")
  errorlevel = run("sources/test-pkg", "latex "..file..".tex > "..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: latex "..file..".tex")
    return errorlevel
  else
    os_message("** Running: latex "..file..".tex")
  end
  errorlevel = run("sources/test-pkg", "dvips -q "..file..".dvi > "..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: dvips "..file..".dvi")
    return errorlevel
  else
    os_message("** Running: dvips "..file..".dvi")
  end
  errorlevel = run("sources/test-pkg", "ps2pdf "..file..".ps > "..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: ps2pdf "..file..".ps")
    return errorlevel
  else
    os_message("** Running: ps2pdf "..file..".ps")
  end
  os.exit(0)
end

-- We added a new target "examples" to run the examples files for scontents
samples = {
  "scexamp1.ltx",
  "scexamp2.ltx",
  "scexamp3.ltx",
  "scexamp4.ltx",
  "scexamp5.ltx",
  "scexamp6.ltx",
  "scexamp7.ltx",
  "scexamp8.ltx",
  "scexamp9.ltx"
}

if options["target"] == "examples" then
  local file = jobname(sourcefiledir.."/scontents.ins")
  errorlevel = run(sourcefiledir, "luatex --interaction=batchmode "..file..".ins > "..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: luatex -interaction=batchmode "..file..".ins")
    return errorlevel
  else
    os_message("** Running: luatex -interaction=batchmode "..file..".ins")
  end
  errorlevel = run(sourcefiledir, "lualatex --draftmode --interaction=batchmode "..file..".dtx > "..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: lualatex -interaction=batchmode "..file..".dtx")
    return errorlevel
  else
    os_message("** Running: lualatex -interaction=batchmode "..file..".dtx")
  end
  for i, samples in ipairs(samples) do
    errorlevel = run("sources/", "arara "..samples.." > "..os_null)
    if errorlevel ~= 0 then
      error("** Error!!: arara "..samples)
      return errorlevel
    else
      os_message("** Running: arara "..samples)
    end
  end
  os.exit(0)
end


-- We added a new target "release" to do the final checks for git and ctan
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

local gitbranch = os_capture("git symbolic-ref --short HEAD")
local gitstatus = os_capture("git status --porcelain")
local tagongit  = os_capture('git for-each-ref refs/tags --sort=-taggerdate --format="%(refname:short)" --count=1')
local gitpush   = os_capture("git log --branches --not --remotes")

if options["target"] == "release" then
  -- os.execute("git clean -xdfq")
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
  print("** If everything is OK run (manually): l3build upload -F ctan.ann")
  os.exit(0)
end
