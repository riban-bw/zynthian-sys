#!/bin/bash


# Check if the number of arguments is not equal to 1
if [ "$#" -ne 1 ]; then
    echo Error: Expects name of point release as command line argument, e.g. oram-2024.1.0
    exit 1
fi

TAG=$1

for REPO in zynthian-sys zynthian-ui zynthian-webconf zynthian-data zyncoder
do
  git -C /zynthian/$REPO checkout oram
  git -C /zynthian/$REPO pull
  git -C /zynthian/$REPO tag -f $TAG
  git -C /zynthian/$REPO tag -f oram-2409
  git -C /zynthian/$REPO push --tags --force
done
