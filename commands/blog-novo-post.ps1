param([string]$nome)
$notepadpp = "${env:ProgramFiles(x86)}/MarkdownPad 2/MarkdownPad2.exe"

cd source

hexo new post $nome

$arquivo = (gci source/_posts | sort LastWriteTime | select -last 1).Name
$arquivo = "source/_posts/$arquivo"
&$notepadpp $arquivo

hexo server