--[[
   Configuration script for l3build from the scontents package
   At the moment the possible options that can be passed on to
   l3build are:
   * tag        : Update the version and date
   * doc        : Generate the documentation
   * unpack     : Unpacks the source files
   * install    : Install the package locally, you can use
                  it in conjunction with [--full] [--dry-run]
   * uninstall  : Uninstall the package locally
   * clean      : Clean the directory tree and some files
   * ctan       : Generate the compressed package (.zip)
   * upload     : Upload the package to ctan, you must add
                  -F ctan.ann in conjunction with [--debug]
   * testpkg    : Compile the tests included in the test-pkg/
   * examples   : Compile the example files included in the .dtx
   * release    : It performs the checks before generating a public
                  release (on git and ctan).
--]]

--[[
    General package identification
--]]
module     = "scontents"
ctanpkg    = "scontents"
pkgdate    = "2020-02-11"
pkgmajor   = "1"
pkgmenor   = "9"
pkgmicro   = "d"
pkgversion = string.format("%i.%s%s",pkgmajor,pkgmenor,pkgmicro)

--[[
    Location of the package's source files
--]]
sourcefiledir = "./sources"

--[[
    List of files to which the version and date will be updated
--]]
tagfiles = { "sources/scontents.ins","sources/scontents.dtx", "sources/CTANREADME.md","README.md","ctan.ann" }

function update_tag (file,content,tagname,tagdate)
 tagdate = string.gsub (pkgdate,"-", "-")
 if string.match (file, "scontents.ins" ) then
  content = string.gsub (content,
                         "date=%d%d%d%d%-%d%d%-%d%d",
                         "date="..tagdate.."")
  content = string.gsub (content,
                         "version=%d%.%d%w?",
                         "version=".. pkgversion .."")
 end
 if string.match (file, "scontents.dtx") then
  content = string.gsub (content,
                         "\\ScontentsFileDate{(.-)}",
                         "\\ScontentsFileDate{"..tagdate.."}")
  content = string.gsub (content,
                         "\\ScontentsCoreFileDate{(.-)}",
                         "\\ScontentsCoreFileDate{"..tagdate.."}")
  content = string.gsub (content,
                         "\\ScontentsFileVersion{(.-)}",
                         "\\ScontentsFileVersion{"..pkgversion.."}")
 end
 if string.match (file, "CTANREADME.md") then
  content = string.gsub (content,
                         "Version: %d%.%d%w?",
                         "Version: "..pkgversion.."")
  content = string.gsub (content,
                         "Date: %d%d%d%d%-%d%d%-%d%d",
                         "Date: ".. tagdate.."")
 end
 if string.match (file, "README.md") then
  content = string.gsub (content,
                         "scontents/v%d%.%d",
                         "scontents/v".. pkgmajor..'.'..pkgmenor.."")
 end
 if string.match (file, "ctan.ann") then
  content = string.gsub (content,
                         "v%d%.%d%w? %d%d%d%d%-%d%d%-%d%d",
                         "v"..pkgversion..' '..tagdate.."")
 end
 return content
end

--[[
    Configuration of files for local installation,
    documentation and package distribution in zip.
--]]

textfiles    = {"sources/CTANREADME.md"}
ctanreadme   = "CTANREADME.md"
ctanzip      = ctanpkg.."-"..pkgversion
packtdszip   = false
installfiles = {"**/*.sty", "**/*.tex", "**/*.mkiv" }
sourcefiles  = {"**/*.dtx", "**/*.ins"}
unpackexe    = "luatex"
unpackopts   = "--interaction=batchmode"
unpackfiles  = { "scontents.ins" }
typesetexe   = "lualatex"
typesetopts  = "--interaction=batchmode"
typesetfiles = { "scontents.dtx" }
typesetruns  = 3
cleanfiles   = { ctanzip..".curlopt", ctanzip..".zip" }
tdslocations = {
"tex/generic/scontents/scontents.tex",
"tex/generic/scontents/scontents-code.tex",
"tex/latex/scontents/scontents.sty",
"tex/context/third/scontents/t-scontents.mkiv",
"doc/latex/scontents/scontents.pdf",
"source/latex/scontents/scontents.dtx",
"source/latex/scontents/scontents.ins"
}

--[[
    Configuration for package distribution in ctan
--]]
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
  update       = true
}

--[[
    We added a new target "testpkg" to run the tests
    files in test-pkg/.
--]]
if options["target"] == "testpkg" then
  print('*****************************************************************')
  print('****** Extract files from scontents.ins, v'..pkgversion..' '..pkgdate..' *******')
  run("sources/", "pdftex -interaction=batchmode scontents.ins")
  print('******** Compiling tests for scontents v'..pkgversion..' '..pkgdate..' *********')
  cp("*.tex", "sources/", "sources/test-pkg")
  cp("*.sty", "sources/", "sources/test-pkg")
  cp("*.mkiv","sources/", "sources/test-pkg")
  print('*********** Running pdflatex on test-pkg-current.tex ************')
  run("sources/test-pkg/", "pdflatex -interaction=nonstopmode test-pkg-current.tex")
  print('************ Running pdftex on test-format.plain.tex ************')
  run("sources/test-pkg/", "pdftex test-format.plain.tex")
  print('*****  Running latex>dvips>ps2pdf on test-format.latex.tex ******')
  run("sources/test-pkg/", "latex test-format.latex.tex")
  run("sources/test-pkg/", "dvips test-format.latex.dvi")
  run("sources/test-pkg/", "ps2pdf test-format.latex.ps")
  print('********** All tests have been successfully completed ***********')
  os.exit()
end

--[[
    We added a new target "examples" to run the examples
    files in scontents.dtx.
--]]
if options["target"] == "examples" then
  print('*****************************************************************')
  print('****** Extract files from scontents.ins, v'..pkgversion..' '..pkgdate..' *******')
  run("sources/", "pdftex -interaction=batchmode scontents.ins")
  print('** Running lualatex on scontents.dtx to extract example files **')
  run("sources/", "lualatex --draftmode --interaction=batchmode scontents.dtx")
  print('****** Compiling the example files, using v'..pkgversion..' '..pkgdate..' ******')
  print('******* Running pdflatex on scexamp1.ltx using arara tool *******')
  run("sources/", "arara scexamp1.ltx")
  print('******* Running pdflatex on scexamp2.ltx using arara tool *******')
  run("sources/", "arara scexamp2.ltx")
  print('******* Running pdflatex on scexamp3.ltx using arara tool *******')
  run("sources/", "arara scexamp3.ltx")
  print('******* Running pdflatex on scexamp4.ltx using arara tool *******')
  run("sources/", "arara scexamp4.ltx")
  print('******* Running pdflatex on scexamp5.ltx using arara tool *******')
  run("sources/", "arara scexamp5.ltx")
  print('******* Running pdflatex on scexamp6.ltx using arara tool *******')
  run("sources/", "arara scexamp6.ltx")
  print('******* Running pdflatex on scexamp7.ltx using arara tool *******')
  print('Customization of verbatimsc using the fancyvrb and tcolorbox package')
  run("sources/", "arara scexamp7.ltx")
  print('******* Running pdflatex on scexamp8.ltx using arara tool *******')
  print('Customization of verbatimsc using the listings package')
  run("sources/", "arara scexamp8.ltx")
  print('******* Running xelatex on scexamp9.ltx using arara tool ********')
  print('Customization of verbatimsc using the minted package')
  --run("sources/", "xelatex --shell-escape -8bit scexamp9.ltx")
  print('********** All sample files were successfully compiled **********')
  os.exit()
end

--[[
    We added a new target "release" to do the final checks for git and
    ctan, the file ctan.ann no follow up in git.
    git update-index --assume-unchanged ctan.ann
--]]

current_tags = nil
do
  local f = assert(io.open("sources/scontents.dtx", "r"))
  current_tags = f:read("*all")
  f:close()
end
current_pkgv = string.match(current_tags,"\\ScontentsFileVersion{(.-)}")
current_date = string.match(current_tags,"\\ScontentsFileDate{(.-)}")

status_bool = false
if options["target"] == "release" then
  print('*************** Configuration for Github and CTAN ***************')
  os.execute("git clean -xdfq")
  local handle    = io.popen('git status --porcelain --untracked-files=no')
  local gitstatus = string.gsub(handle:read("*a"),'%s*$','')
  handle:close()
  local handle    = io.popen('git log --branches --not --remotes')
  local gitpush   = string.gsub(handle:read("*a"),'%s*$','')
  handle:close()
  local handle    = io.popen('git for-each-ref refs/tags --sort=-taggerdate --format="%(refname:short)" --count=1')
  local tagongit  = string.gsub(handle:read("*a"),'%s*$','')
  handle:close()
  if status_bool then
    return true
  end
  if gitstatus=="" then
    if gitpush=="" then
      print('** Checking for pending commits')
    else
      print('** There are pending commits, running git push')
      os.execute("git push")
      print('** You must run l3build release again')
      os.exit()
    end
    print('** The last tag marked for ' ..module.. ' in github is: '..tagongit)
    print('** The new tag marked for ' ..module.. ' in github will be: v'..pkgversion)
    print('** Current version (defined in the scontents.dtx file): '..current_pkgv)
    print('** Current date (defined in the scontents.dtx file): '..current_date)
    if pkgversion==current_pkgv and pkgdate==current_date then
      print('** The version number and date are consistent with build.lua')
    else
      print('** The version number or date are inconsistent with build.lua')
      print('** You must run: l3build tag')
      os.exit()
    end
    print('** Everything is correct, we record changes in git by running')
    print("git tag -a v"..pkgversion.." -m 'Release v"..pkgversion.." "..pkgdate.."' && git push --tags")
    os.execute("git tag -a v"..pkgversion.." -m 'Release v"..pkgversion.." "..pkgdate.."' && git push --tags")
    print('** We created the compressed package to send to ctan')
    os.execute("l3build ctan && l3build upload -F ctan.ann --debug")
    print('** We must add the changes for this version in ctan.ann file')
    print('** And finally (if everything is ok) execute manually (without --debug):')
    print('l3build upload -F ctan.ann')
    print('*****************************************************************')
    status_bool = true
    os.exit()
    return status_bool
  else
    print(gitstatus)
    print('** Aborting, git status is not clean, need to make a commit')
    status_bool = false
    os.exit()
    return status_bool
  end
end
