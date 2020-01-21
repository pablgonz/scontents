-- Build script for scontents
-- l3build tag
-- l3build ctan
-- l3build clean

pkgversion   = "1.9"
pkgdate      = "2020-01-21"

module       = "scontents"
ctanpkg      = "scontents"
ctanzip      = ctanpkg.."-"..pkgversion

tagfiles     = {"sources/README.md","sources/scontents.ins","sources/scontents.dtx", "README.md"}

function update_tag (file,content,tagname,tagdate)
 tagdate = string.gsub (pkgdate,"-", "-")
 if string.match (file, "scontents.ins" ) then
  content = string.gsub (content,
                         "date=%d%d%d%d%-%d%d%-%d%d",
                         "date="..tagdate.."")
  content = string.gsub (content,
                         "version=%d%.%d",
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
                         "Version: %d%.%d",
                         "Version: "..pkgversion.."" )
   content = string.gsub (content,
                         "Date: %d%d%d%d%-%d%d%-%d%d",
                         "Date: ".. tagdate.."" )
   content = string.gsub (content,
                         "scontents/v%d%.%d",
                         "scontents/v"..pkgversion.."" )
 return content
  end
 return content
 end


-- Store last package tag on git
local handle = io.popen("git describe --tags --abbrev=0")
local oldtag = handle:read("*a")
handle:close()

-- Test files before tag in git and ctan upload
function tag_hook(tagname)
    print('** Extract files from <scontents.ins>, current v'..pkgversion..' **')
    run("sources/", "pdftex --interaction=batchmode scontents.ins")
    print('** Running lualatex to extract example files **')
    run("sources/", "lualatex --draftmode --interaction=batchmode scontents.dtx")
    print('** Running pdflatex on <scexamp1.ltx> using arara tool **')
    run("sources/", "arara scexamp1.ltx")
    print('** Running pdflatex on <scexamp2.ltx> using arara tool **')
    run("sources/", "arara scexamp2.ltx")
    print('** Running pdflatex on <scexamp3.ltx> using arara tool **')
    run("sources/", "arara scexamp3.ltx")
    print('** Running pdflatex on <scexamp4.ltx> using arara tool **')
    run("sources/", "arara scexamp4.ltx")
    print('** Running pdflatex on <scexamp5.ltx> using arara tool **')
    run("sources/", "arara scexamp5.ltx")
    print('** Running pdflatex on <scexamp6.ltx> using arara tool **')
    run("sources/", "arara scexamp6.ltx")
    print('** Running pdflatex on <scexamp7.ltx> using arara tool **')
    print('Customization of verbatimsc using the fancyvrb and tcolorbox package')
    run("sources/", "arara scexamp7.ltx")
    print('Customization of verbatimsc using the listings package')
    print('** Running pdflatex on <scexamp8.ltx> using arara tool **')
    run("sources/", "arara scexamp8.ltx")
    print('Customization of verbatimsc using the minted package')
    print('** Running xelatex on <scexamp9.ltx> using arara tool **')
    run("sources/", "arara scexamp9.ltx")
    print('** All sample files were successfully compiled **')
    print('** Copy package files from sources/ to sources/test-pkg/ **')
    cp("*.tex", "sources/", "sources/test-pkg")
    cp("*.sty", "sources/", "sources/test-pkg")
    cp("*.mkiv", "sources/", "sources/test-pkg")
    print('****** Running tests for the package ******')
    print('** Running pdflatex on <test-pkg-current> **')
    run("sources/test-pkg/", "pdflatex test-pkg-current.tex")
    print('** Running pdftex on <test-format.plain> **')
    run("sources/test-pkg/", "pdftex test-format.plain.tex")
    print('** Running latex on <test-format.latex> **')
    run("sources/test-pkg/", "latex test-format.latex.tex")
    run("sources/test-pkg/", "dvips test-format.latex.dvi")
    run("sources/test-pkg/", "ps2pdf test-format.latex.ps")
    print('** All tests have been successfully completed **')
    print('****** Configuration for Github and CTAN ******')
    print('** Running local repository cleanup **')
    os.execute("git clean -xdfq")
    print('** We check if there are modifications in the generated files to make a commit **')
    os.execute("git status")
    print('** The last tag marked for scontens is: '..oldtag..' **')
    print('** If everything is OK, you just need to execute manually **')
    print("git commit -a -m 'Release v"..pkgversion.."'")
    print("git tag -a v"..pkgversion.." -m 'Release v"..pkgversion.."'")
    print("git push --tags")
    print("Now you just need to run l3build ctan and upload it")
end

-- ctan setup
docfiles = {"sources/scontents.pdf","sources/scontents.dtx","sources/scontents.ins"}
textfiles= {"sources/README.md"}

-- Compile documentation with lualatex
typesetexe = "lualatex"
packtdszip   = false

excludefiles = { "scontents/scontents.sty","scontents/scontents-code.tex" }
sourcefiles  = { "sources/scontents.dtx","sources/scontents.sty","sources/scontents-code.tex" }
typesetfiles = { "scontents.dtx" }

typesetruns = 3
