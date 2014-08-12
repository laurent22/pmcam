#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_DIR="$SCRIPT_DIR/images"
CAPTURE_INTERVAL="1" # in seconds

fn_terminate_script() {
	echo "SIGINT caught."
	exit 0
}
trap 'fn_terminate_script' SIGINT

mkdir -p $OUTPUT_DIR
PREVIOUS_FILENAME=""
while true ; do
	FILENAME="$OUTPUT_DIR/$(date +"%Y%m%dT%H%M%S").jpg"
	echo "-----------------------------------------"
	echo "Capturing $FILENAME"
	ffmpeg -loglevel fatal -f avfoundation -i "" -r 1 -t 0.0001 $FILENAME
	
	if [[ "$PREVIOUS_FILENAME" != "" ]]; then
		# For some reason, `compare` outputs the result to stderr so
		# it's not possibly to directly get the result. It needs to be
		# redirected to a temp file first.
		OUT_FILE=$(mktemp -t diff)
		compare -fuzz 20% -metric ae $PREVIOUS_FILENAME $FILENAME diff.png 2> $OUT_FILE
		DIFF="$(cat $OUT_FILE)"
		rm -f diff.png $OUT_FILE
		if [ "$DIFF" -lt 20 ]; then
			echo "Same as previous image: delete (Diff = $DIFF)"
			rm -f $FILENAME
		else
			echo "Different image: keep (Diff = $DIFF)"
			PREVIOUS_FILENAME="$FILENAME"
		fi
	else
		PREVIOUS_FILENAME="$FILENAME"
	fi
	
	sleep $CAPTURE_INTERVAL
done