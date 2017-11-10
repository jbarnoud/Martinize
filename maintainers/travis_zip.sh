#!/bin/bash

set -e
PROGRAM=martinize

if [[ "${TRAVIS_PULL_REQUEST}" != false ]]
then
    echo "Do not deploy on pull requests"
    exit 0
fi

if [[ "${TRAVIS_BRANCH}" != "master" ]]
then
    echo " Do not deploy other branches than master"
    exit 0
fi


test -n "${GH_TOKEN}" || die "GH_TOKEN must be defined"
test -n "${GIT_CI_USER}" || die "GIT_CI_USER must be defined"
test -n "${GIT_CI_EMAIL}" || die "GIT_CI_EMAIL must be defined"

cd maintainers
./zippackage.sh
mv $PROGRAM ${PROGRAM}.zip


git init
git config user.name "${GIT_CI_USER}"
git config user.email "${GIT_CI_EMAIL}"
git remote add origin "https://${GH_TOKEN}@github.com/Tsjerk/Insane.git"
git fetch origin package
git checkout package

if [[ ! -z ${TRAVIS_TAG} ]]
then
    cp ${PROGRAM}.zip ${PROGRAM}
    git add insane
fi

mv ${PROGRAM}.zip ${PROGRAM}-dev
git add ${PROGRAM}-dev

git commit -m "Add package for commit ${TRAVIS_COMMIT}"
git push --force origin package
