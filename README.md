# pmcam - poor man's video capture with motion detection in Bash

This simple Bash script can be used to capture images from a webcam, and will provide motion detection support. There's Yawcam on Windows which is good, but I couldn't find anything free on OS X. So I put together this quick and dirty solution, which does the job surprisingly well.

Frames are captured at regular intervals using `ffmpeg`. Then ImageMagick's `compare` tool is used to check if this frame is similar to the previous one. If the frames are different enough, they are kept, otherwise they are deleted. This provide very simple motion detection and avoids filling up the hard drive with duplicate frames.

## Installation

### OS X

	brew install ffmpeg
	brew install imagemagick
	curl -O https://raw.github.com/laurent22/pmcam/master/pmcam.sh

### Linux

	apt-get install ffmpeg
	apt-get install imagemagick
	curl -O https://raw.github.com/laurent22/pmcam/master/pmcam.sh

I could not test on Linux (feedback would be welcome) but according to the [ffmpeg documentation](https://trac.ffmpeg.org/wiki/Capture/Webcam) the ffmpeg command might need to be changed as follow:

- Set `-f v4l2`
- Set `-i /dev/video0`

### Windows

* Install [Cygwin](https://www.cygwin.com/) or [MinGW](http://www.mingw.org/)
* Install [ffmpeg](http://ffmpeg.zeranoe.com/builds/)
* Install [ImageMagick](http://www.imagemagick.org/script/binary-releases.php)

## Usage

	./pmcam.sh

The script will use the default webcam to capture frames. To capture using a different camera, the ffmpeg command `-i` parameter can be changed - see the [ffmpeg documentation](https://trac.ffmpeg.org/wiki/Capture/Webcam) for more information.

A frame will then be saved approximately every 1 second to the "images" folder next to the Bash script. Both delay and target folder can be changed in the script.

To stop the script, type Ctrl + C.

## TODO

* Check if the script is working on Linux. If necessary, provide alternative ffmpeg command depending on the OS - https://trac.ffmpeg.org/wiki/Capture/Webcam
* Command line argument to change frame directory.
* Command line argument to change interval between frame captures.

## License

MIT