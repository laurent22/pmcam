#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_DIR="$SCRIPT_DIR/images"

CAPTURE_INTERVAL="1" # in seconds
FFMPEG=ffmpeg
command -v $FFMPEG >/dev/null 2>&1 || { FFMPEG=avconv ; }
DIFF_RESULT_FILE=$OUTPUT_DIR/diff_results.txt

fn_cleanup() {
	rm -f diff.png $DIFF_RESULT_FILE
}

fn_terminate_script() {
	fn_cleanup
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
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		$FFMPEG -loglevel fatal -f video4linux2 -i /dev/video0 -r 1 -t 0.0001 $FILENAME
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		# Mac OSX
		$FFMPEG -loglevel fatal -f avfoundation -i "" -r 1 -t 0.0001 $FILENAME
	fi
	
	if [[ "$PREVIOUS_FILENAME" != "" ]]; then
		# For some reason, `compare` outputs the result to stderr so
		# it's not possibly to directly get the result. It needs to be
		# redirected to a temp file first.
		compare -fuzz 20% -metric ae $PREVIOUS_FILENAME $FILENAME diff.png 2> $DIFF_RESULT_FILE
		DIFF="$(cat $DIFF_RESULT_FILE)"
		fn_cleanup
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