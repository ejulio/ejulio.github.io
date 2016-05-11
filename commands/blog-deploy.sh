#!bin/bash

cd source

git add --all
git commit -m "$0"
git push origin source

hexo generate --deploy

cp CNAME ../master
cp .nojekyll ../master

cd ../master
git add --all
git commit -m "$0"
git push origin master

cd ../