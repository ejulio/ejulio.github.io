cd source

git add --all
git push origin source

hexo generate --deploy

cd ../master
git add --all
git push origin master

cd ../