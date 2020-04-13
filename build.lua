-- Build script for tkz-doc

module = "tkz-doc"
tkzdocv = "1.43c"
tkzdocd = "2020/04/10"
tkzexamplev = "v1.43c"
tkzexampled = "2020/04/10"

-- Setting variables for .zip file (CTAN)
textfiles  = {"README.md"}
ctanreadme = "README.md"
ctanpkg    = module
ctanzip    = ctanpkg.."-"..tkzdocv
print(ctanzip..".zip")
packtdszip = false
flatten    = false
cleanfiles = {ctanzip..".zip", ctanzip..".curlopt"}

-- Setting variables for package files
sourcefiledir = "latex"
textfiledir   = "doc"
sourcefiles  = {"tkz-doc.cfg", "tkz-doc.cls", "couverture.tex", "tkzexample.sty"}
installfiles = sourcefiles

-- Setting file locations for local instalation (TDS)
tdslocations = {
  "doc/latex/tkz-doc/README",
  "tex/latex/tkz-doc/tkz-doc.cfg",
  "tex/latex/tkz-doc/tkz-doc.cls",
  "tex/latex/tkz-doc/couverture.tex",
  "tex/latex/tkz-doc/tkzexample.sty",
}

-- Update package date and version
tagfiles = {"tkz-doc.cfg", "tkz-doc.cls", "couverture.tex", "tkzexample.sty", "README.md"}

function update_tag(file, content, tagname, tagdate)
  if string.match(file, "%.cfg$") then
    content = string.gsub(content,
                          "\\fileversion{.-}",
                          "\\fileversion{"..tkzdocv.."}")
    content = string.gsub(content,
                          "\\filedate{.-}",
                          "\\filedate{"..tkzdocd.."}")
    content = string.gsub(content,
                          "\\typeout{%d%d%d%d%/%d%d%/%d%d %d+.%d+%a* %s*(.-)}",
                          "\\typeout{"..tkzdocd.." "..tkzdocv.." %1}")
  end
  if string.match(file, "%.tex$") then
    content = string.gsub(content,
                          "\\fileversion{.-}",
                          "\\fileversion{"..tkzdocv.."}")
    content = string.gsub(content,
                          "\\filedate{.-}",
                          "\\filedate{"..tkzdocd.."}")
    content = string.gsub(content,
                          "\\typeout{%d%d%d%d%/%d%d%/%d%d %d+.%d+%a* %s*(.-)}",
                          "\\typeout{"..tkzdocd.." "..tkzdocv.." %1}")
  end
  if string.match(file, "%.cls$") then
    content = string.gsub(content,
                          "\\newcommand%*{\\PackageVersion}{.-}",
                          "\\newcommand*{\\PackageVersion}{"..tkzdocv.."}")
    content = string.gsub(content,
                          "\\newcommand*{\\filedate}{.-}",
                          "\\newcommand*{\\filedate}{"..tkzdocd.."}")
  end
  if string.match(file, "%.sty$") then
    content = string.gsub(content,
                          "\\ProvidesPackage{(.-)}%[%d%d%d%d%/%d%d%/%d%d v?%d+.%d*%s?%a* %s*(.-)%]",
                          "\\ProvidesPackage{%1}["..tkzexampled.." "..tkzexamplev.." %2]")
  end
  if string.match(file, "README.md$") then
    content = string.gsub(content,
                          "Release %d+.%d+%a* %d%d%d%d%/%d%d%/%d%d",
                          "Release "..tkzdocv.." "..tkzdocd)
  end
  return content
end

-- Load personal data
local ok, mydata = pcall(require, "Alaindata.lua")
if not ok then
  mydata = {email="XXX", uploader="YYY"}
end

-- CTAN upload config
uploadconfig = {
  author      = "Alain Matthes",
  uploader    = mydata.uploader,
  email       = mydata.email,
  pkg         = ctanpkg,
  version     = tkzdocv,
  license     = "lppl1.3c",
  summary     = "Documentation macros for the TKZ series of packages",
  description = [[This bundle offers a documentation class (tkz-doc) and a package (tkzexample).\n These files are used in the documentation of the author’s packages tkz-base, tkz-euclide, tkz-fct, tkz-linknodes, and tkz-tab.]],
  topic       = { "Class", "Documentation support" },
  ctanPath    = "/macros/latex/contrib/" .. ctanpkg,
  repository  = "https://github.com/tkz-sty/" .. ctanpkg,
  bugtracker  = "https://github.com/tkz-sty/" .. ctanpkg .. "/issues",
  support     = "https://github.com/tkz-sty/" .. ctanpkg .. "/issues",
  announcement_file="ctan.ann",
  note_file   = "ctan.note",
  update      = true,
}

-- Print lines in 80 characters
local function os_message(text)
  local mymax = 77 - string.len(text) - string.len("done")
  local msg = text.." "..string.rep(".", mymax).." done"
  return print(msg)
end

-- Create check_marked_tags() function
local function check_marked_tags()
  local f = assert(io.open("latex/tkz-doc.cls", "r"))
  marked_tags = f:read("*all")
  f:close()
  local m_pkgd = string.match(marked_tags, "\\newcommand%*{\\filedate}{(.-)}")
  local m_pkgv = string.match(marked_tags, "\\newcommand%*{\\PackageVersion}{(.-)}")
  if tkzdocv == m_pkgv and tkzdocd == m_pkgd then
    os_message("** Checking version and date: OK")
  else
    print("** Warning: tkz-doc.cls is marked with version "..m_pkgv.." and date "..m_pkgd)
    print("** Warning: build.lua is marked with version "..tkzdocv.." and date "..tkzdocd)
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
  os.exit()
end

-- GitHub release version
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
  if gitbranch == "master" then
    os_message("** Checking git branch '"..gitbranch.."': OK")
  else
    error("** Error!!: You must be on the 'master' branch")
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

  local pkgversion = "v"..tkzdocv
  local pkgdate = tkzdocd
  os_message("** Checking last tag marked in GitHub "..tagongit..": OK")
  errorlevel = os.execute("git tag -a "..pkgversion.." -m 'Release "..pkgversion.." "..pkgdate.."'")
  if errorlevel ~= 0 then
    error("** Error!!: tag "..tagongit.." already exists, run git tag -d "..pkgversion.." && git push --delete origin "..pkgversion)
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
