param([string]$mensagem)
cd source

git add --all
git commit -m "$mensagem"
git push origin source

hexo generate --deploy

copy CNAME ../master
copy .nojekyll ../master

cd ../master
git add --all
git commit -m "$mensagem"
git push origin master

cd ../