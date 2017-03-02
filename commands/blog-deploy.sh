#!bin/bash

cd source

git add --all
git commit -m "$1"
git push origin source

hugo

cp CNAME ../master
cp .nojekyll ../master
mv ./public/* ../master
rm -rf ./public

cd ../master
git add --all
git commit -m "$1"
git push origin master

cd ../