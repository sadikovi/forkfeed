#!/bin/bash

bin="`dirname "$0"`"
ROOT_DIR="`cd "$bin/../"; pwd`"

# check if user has sass and coffee
WHICH_SASS=$(which sass)
if [ -z "$WHICH_SASS" ]; then
    echo "[ERROR] Cannot compile .scss scripts. Run 'gem install sass' to install"
    exit 1
fi

WHICH_COFFEE=$(which coffee)
if [ -z "$WHICH_COFFEE" ]; then
    echo "[ERROR] Cannot compile .coffee scripts. Run 'npm install coffee-script' to install"
    exit 1
fi

WHICH_UGLIFYJS=$(which uglifyjs)
if [ -z "$WHICH_UGLIFYJS" ]; then
    echo "[ERROR] Cannot minify js files using uglifyjs. Run 'npm install uglifyjs' to install"
    exit 1
fi

SCSS_DIR="$ROOT_DIR/service/scss"
CSS_DIR="$ROOT_DIR/service/css"
COFFEE_DIR="$ROOT_DIR/service/coffee"
JS_DIR="$ROOT_DIR/temp/service/js"
MINJS_DIR="$ROOT_DIR/service/js"

# compile scss -> css and minify css
echo "[INFO] .scss >>> .css"
sass "$SCSS_DIR/internal.scss" "$CSS_DIR/forkfeed.min.css" --style compressed --sourcemap=none

# compile coffee -> js
echo "[INFO] .coffee >>> .js"
coffee --no-header --compile --output "$JS_DIR" "$COFFEE_DIR"

# compress scripts in specific order, because of the dependencies
echo "[INFO] compress scripts folder >> forkfeed.min.js"
uglifyjs \
    $JS_DIR/utilities/util.js \
    $JS_DIR/utilities/loader.js \
    $JS_DIR/utilities/mapper.js \
    $JS_DIR/utilities/fasteditor.js \
    $JS_DIR/api.js \
    $JS_DIR/index.js \
    -o "$MINJS_DIR/forkfeed.min.js" -c -m
