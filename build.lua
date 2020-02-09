-- Build script for scontents
-- l3build tag
-- l3build doc
-- l3build ctan
-- l3build upload
-- l3build clean

module     = "scontents"
pkgdate    = "2020-02-09"
pkgmajor   = "1"
pkgmenor   = "9"
pkgmicro   = "c"

-- We assign the package version <number.number(number|leter)?>
pkgversion = string.format("%i.%s%s", pkgmajor, pkgmenor,pkgmicro)

-- Local instalation
excludefiles = { "scontents/scontents.sty","scontents/scontents-code.tex" }
sourcefiles  = { "sources/scontents.dtx","sources/scontents.ins","sources/scontents.sty","sources/scontents-code.tex"}
installfiles = { "scontents.sty","scontents-code.tex","scontents.tex","t-scontents.mkiv"}
tdslocations={
"tex/generic/scontents/scontents.tex",
"tex/generic/scontents/scontents-code.tex",
"tex/latex/scontents/scontents.sty",
"tex/context/third/scontents/t-scontents.mkiv",
"doc/latex/scontents/README.md",
"doc/latex/scontents/scontents.pdf",
"source/latex/scontents/scontents.dtx",
"source/latex/scontents/scontents.ins"
}

-- Documentation
docfiles     = {"sources/scontents.pdf"}
textfiles    = {"sources/README.md"}
typesetexe   = "lualatex"
typesetfiles = { "scontents.dtx" }
typesetruns  = 3

-- Update tag in pkg files
tagfiles   = {"sources/README.md","sources/scontents.ins","sources/scontents.dtx", "README.md"}

function update_tag (file,content,tagname,tagdate)
 tagdate = string.gsub (pkgdate,"-", "-")
 if string.match (file, "scontents.ins" ) then
  content = string.gsub (content,
                         "date=%d%d%d%d%-%d%d%-%d%d",
                         "date="..tagdate.."")
  content = string.gsub (content,
                         "version=%d%.%d%w?",
                         "version=".. pkgversion ..""  )
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
 elseif string.match (file, "README.md") then
  content = string.gsub (content,
                         "Version: %d%.%d%w?",
                         "Version: "..pkgversion.."" )
  content = string.gsub (content,
                         "Date: %d%d%d%d%-%d%d%-%d%d",
                         "Date: ".. tagdate.."" )
  content = string.gsub (content,
                         "scontents/v%d%.%d",
                         "scontents/v".. pkgmajor..'.'..pkgmenor.."")
  return content
 end
end

-- Write announcement text
function announcement ()
local f = io.open("announcement.txt", "w")
f:write("Changes in the version " .. pkgversion .. " " .. pkgdate ..":\n")
f:close()
end

-- Store last tag register on git
local handle   = io.popen('git for-each-ref refs/tags --sort=-taggerdate --format="%(refname:short)" --count=1')
local tagongit = string.gsub(handle:read("*a"), '%s+', '')
handle:close()

-- Test files before tag in git (and ctan upload)
function tag_hook(tagname)
  print('*****************************************************************')
  print('****** Extract files from scontents.ins, v'..pkgversion..' '..pkgdate..' *******')
  run("sources/", "pdftex -interaction=batchmode scontents.ins")
  print('*****************************************************************')
  print('******** Compiling tests for scontents v'..pkgversion..' '..pkgdate..' *********')
  cp("*.tex", "sources/", "sources/test-pkg")
  cp("*.sty", "sources/", "sources/test-pkg")
  cp("*.mkiv", "sources/", "sources/test-pkg")
  print('*********** Running pdflatex on test-pkg-current.tex ************')
  print('*****************************************************************')
  run("sources/test-pkg/", "pdflatex -interaction=nonstopmode test-pkg-current.tex")
  print('*****************************************************************')
  print('************ Running pdftex on test-format.plain.tex ************')
  print('*****************************************************************')
  run("sources/test-pkg/", "pdftex test-format.plain.tex")
  print('*****************************************************************')
  print('*****  Running latex>dvips>ps2pdf on test-format.latex.tex ******')
  print('*****************************************************************')
  run("sources/test-pkg/", "latex test-format.latex.tex")
  run("sources/test-pkg/", "dvips test-format.latex.dvi")
  run("sources/test-pkg/", "ps2pdf test-format.latex.ps")
  print('*****************************************************************')
  print('********** All tests have been successfully completed ***********')
  print('** Running lualatex on scontents.dtx to extract example files **')
  print('*****************************************************************')
  run("sources/", "lualatex --draftmode --interaction=batchmode scontents.dtx")
  print('*****************************************************************')
  print('****** Compiling the example files, using v'..pkgversion..' '..pkgdate..' ******')
  print('******* Running pdflatex on scexamp1.ltx using arara tool *******')
  run("sources/", "arara scexamp1.ltx")
  print('*****************************************************************')
  print('******* Running pdflatex on scexamp2.ltx using arara tool *******')
  run("sources/", "arara scexamp2.ltx")
  print('*****************************************************************')
  print('******* Running pdflatex on scexamp3.ltx using arara tool *******')
  run("sources/", "arara scexamp3.ltx")
  print('*****************************************************************')
  print('******* Running pdflatex on scexamp4.ltx using arara tool *******')
  run("sources/", "arara scexamp4.ltx")
  print('*****************************************************************')
  print('******* Running pdflatex on scexamp5.ltx using arara tool *******')
  run("sources/", "arara scexamp5.ltx")
  print('*****************************************************************')
  print('******* Running pdflatex on scexamp6.ltx using arara tool *******')
  run("sources/", "arara scexamp6.ltx")
  print('*****************************************************************')
  print('******* Running pdflatex on scexamp7.ltx using arara tool *******')
  print('Customization of verbatimsc using the fancyvrb and tcolorbox package')
  run("sources/", "arara scexamp7.ltx")
  print('*****************************************************************')
  print('******* Running pdflatex on scexamp8.ltx using arara tool *******')
  print('Customization of verbatimsc using the listings package')
  run("sources/", "arara scexamp8.ltx")
  print('*****************************************************************')
  print('******* Running xelatex on scexamp9.ltx using arara tool ********')
  print('Customization of verbatimsc using the minted package')
  run("sources/", "arara scexamp9.ltx")
  print('********** All sample files were successfully compiled **********')
  print('*****************************************************************')
  print('*************** Configuration for Github and CTAN ***************')
  os.execute("git clean -xdfq")
  print('** The last tag marked for scontens in github is: '..tagongit..' **')
  print('**** Check if there are modifications in the generated files ****')
  os.execute("git status -s")
  print('* If it shows files that start with M you need to make a commit *')
  print('**** If everything is OK, you just need to execute manually *****')
  --print("git commit -a -m 'Release v"..pkgversion.."'")
  print("git tag -a v"..pkgversion.." -m 'Release v"..pkgversion.."'")
  print("git push --tags")
  print('*** Edit announcement.txt and add the changes for this version **')
  announcement ()
  print('**** Then run l3build ctan, l3build upload and l3build clean ****')
  print('*****************************************************************')
end

-- ctan setup
packtdszip = false
ctanpkg    = "scontents"
ctanzip    = ctanpkg.."-"..pkgversion

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
  update       = true,
  announcement_file = "announcement.txt"
}

-- Cleanup .zip and .curlopt files
cleanfiles = {"scontents-"..pkgversion..".curlopt", "scontents-"..pkgversion..".zip"}
