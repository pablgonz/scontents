-- Build script for scontents
-- l3build tag
-- l3build doc
-- l3build install [--full]
-- l3build ctan
-- l3build upload [--debug]
-- l3build clean

-- General package identification
module     = "scontents"
ctanpkg    = "scontents"
pkgdate    = "2020-02-11"
pkgmajor   = "1"
pkgmenor   = "9"
pkgmicro   = "d"
pkgversion = string.format("%i.%s%s",pkgmajor,pkgmenor,pkgmicro)

-- Location of the package's source files
sourcefiledir = "./sources"

-- List of files to which the version and date will be updated
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
  return content
 elseif string.match (file, "scontents.dtx") then
  content = string.gsub (content,
                         "\\ScontentsFileDate{(.-)}",
                         "\\ScontentsFileDate{"..tagdate.."}")
  content = string.gsub (content,
                         "\\ScontentsCoreFileDate{(.-)}",
                         "\\ScontentsCoreFileDate{"..tagdate.."}")
  content = string.gsub (content,
                         "\\ScontentsFileVersion{(.-)}",
                         "\\ScontentsFileVersion{"..pkgversion.."}")
  return content
 elseif string.match (file, "CTANREADME.md") then
  content = string.gsub (content,
                         "Version: %d%.%d%w?",
                         "Version: "..pkgversion.."")
  content = string.gsub (content,
                         "Date: %d%d%d%d%-%d%d%-%d%d",
                         "Date: ".. tagdate.."")
  return content
 elseif string.match (file, "README.md") then
  content = string.gsub (content,
                         "scontents/v%d%.%d",
                         "scontents/v".. pkgmajor..'.'..pkgmenor.."")
  return content
 elseif string.match (file, "ctan.ann") then
  content = string.gsub (content,
                         "v%d%.%d%w? %d%d%d%d%-%d%d%-%d%d",
                         "v"..pkgversion..' '..tagdate.."")
  return content
 end
 return content
 end

--[[
    Configuration of files for local installation,
    documentation and package distribution in zip.
--]]

textfiles    = {"sources/CTANREADME.md"}
ctanreadme   = "CTANREADME.md"
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
tdslocations = {
"tex/generic/scontents/scontents.tex",
"tex/generic/scontents/scontents-code.tex",
"tex/latex/scontents/scontents.sty",
"tex/context/third/scontents/t-scontents.mkiv",
"doc/latex/scontents/scontents.pdf",
"source/latex/scontents/scontents.dtx",
"source/latex/scontents/scontents.ins"
}

--  Configuration for package distribution in ctan
uploadconfig = {
  author       = "Pablo González Luengo",
  uploader     = "Pablo González Luengo",
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

-- Store last tag register on git in tagongit
local handle   = io.popen('git for-each-ref refs/tags --sort=-taggerdate --format="%(refname:short)" --count=1')
local tagongit = string.gsub(handle:read("*a"), '%s+', '')
handle:close()


function interact_git ()
  print('*************** Configuration for Github and CTAN ***************')
  os.execute("git clean -xdfq")
  print('*** We must add the changes for this version in ctan.ann file ***')
  print('**** Check if there are modifications in the generated files ****')
  os.execute("git status -s")
  print('* If it shows files that start with M you need to make a commit *')
  print('**** The last tag marked for ' ..module.. ' in github is: '..tagongit..'  ****')
  --print('**** If everything is OK, you just need to execute manually *****')
  --print("git commit -a -m 'Release v"..pkgversion.."'")
  print("git tag -a v"..pkgversion.." -m 'Release v"..pkgversion.."'")
  print("git push --tags")
  print('**** Then run l3build ctan, l3build upload and l3build clean ****')
  print('*****************************************************************')
end


--[[
    We added a new target "testpkg" to run the tests files in test-pkg/.
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
  interact_git ()
  os.exit()
end

--[[
    We added a new target "examples" to run the examples files in scontenst.dtx.
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
