#!/bin/bash

cd "$HOME"

set -x

REPO_GIT=https://github.com/JetBrains/intellij-community.git
PREP_COMMAND="./getPlugins.sh"
BUILD_COMMAND="./installers.cmd -Dintellij.build.target.os=current"
BUILD_ENV_PATH=".m2 .jdks .java .android"

REPO_NAME=`echo ${REPO_GIT} | sed 's/.*\/\(.*\)\.git/\1/'`

rm -rf .m2 .jdks .java .android .cache/JetBrains/RemoteDev-IU/

echo "Get Repo"

if [ -e $HOME/$REPO_NAME ]; then
    echo "$REPO_NAME exists, pull"
    cd $HOME/$REPO_NAME && git pull
else
    echo "$REPO_NAME does not exist, clone"
    cd $HOME && git clone $REPO_GIT
    cd $HOME/$REPO_NAME && $PREP_COMMAND
fi


echo "Get IDE for pre-indexing"

IDE_URL=https://download.jetbrains.com/idea/ideaIU-2022.3.2.tar.gz
IDE_FILE_NAME=ideaIU-2022.3.2.tar.gz
IDE_CODE=IU
IDE_NAME=ideaIU
IDE_BASE_PATH=/tmp/IDE/

if [ -e $IDE_BASE_PATH/$IDE_NAME ]; then
    echo "exists"
else
    echo "does not exist"
    mkdir -p $IDE_BASE_PATH/$IDE_NAME
    cd $IDE_BASE_PATH && curl -L -O -C - $IDE_URL
    cd $IDE_BASE_PATH && tar -xzf $IDE_FILE_NAME -C $IDE_NAME --strip-components=1
fi

IDE_HEADLESS=$IDE_BASE_PATH/$IDE_NAME/bin/remote-dev-server.sh

echo "Run pre-indexing"

$IDE_HEADLESS warm-up $HOME/$REPO_NAME

CODE_INDEX_NAME=`echo ${HOME} | sed 's/\//_/g'`_$REPO_NAME
CODE_INDEX_PATH=.cache/JetBrains/RemoteDev-$IDE_CODE/$CODE_INDEX_NAME

echo "Run build"

cd $HOME/$REPO_NAME && $BUILD_COMMAND

echo "Pack the results"
cd $HOME

rm -f code-index.tar.gz code.tar.gz build-env.tar.gz

tar -czf code-index.tar.gz -H posix $CODE_INDEX_PATH

tar -czf code.tar.gz -H posix $REPO_NAME

tar -czf build-env.tar.gz -H posix $BUILD_ENV_PATH

mkdir -p archive

mv code-index.tar.gz code.tar.gz build-env.tar.gz archive/

cs ar create -f -C archive $REPO_NAME
