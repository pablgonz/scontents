-- Build script for scontents
-- l3build tag
-- l3build ctan
-- l3build clean

module     = "scontents"
pkgmajor   = "1"
pkgmenor   = "9"
pkgmicro   = "b"

-- We assign the package version <number.number(number|leter)?>
pkgversion = string.format("%i.%s%s", pkgmajor, pkgmenor,pkgmicro)

-- Package date
pkgdate    = "2020-02-08" -- Use os.date("!%Y-%m-%d") in future

-- ctan setup
ctanpkg    = "scontents"
ctanzip    = ctanpkg.."-"..pkgversion

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

-- Store last package tag on git
local handle   = io.popen('git for-each-ref refs/tags --sort=-taggerdate --format="%(refname:short)" --count=1')
local tagongit = string.gsub(handle:read("*a"), '%s+', '')
handle:close()

-- Test files before tag in git and ctan upload
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
  print('****** Now you just need to run l3build ctan and upload it ******')
  print('*****************************************************************')
end

packtdszip   = false
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
