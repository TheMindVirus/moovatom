# moovatom
Python Tools for Decrypting Corrupt MP4 Metadata for video files that refuse to open or play back correctly

This has been written due to a data corruption event that occurred on 04/10/2022 @ 10pm BST \
involving a 15 minute video recording in OBS Studio of the video game Astroneer. \
The audio has saved correctly but the video has not and is missing. \
Windows Metadata shows blank for width, height, etc... \
FFMPEG fails to re-encode it with the copy codec. \
The original videofile is 3GB. \
A shorter version has \
been included.

![screenshot](/screenshot.png)
![screenshot](/screenshot2.png)

There are a lack of available tools to decode and correctly repair corrupt media manually \
and as the screenshots show, data is still fairly integral but still fails to be played back. \
This has been written in the hope that you could use a utility like HxD Hex Editor \
to fix and recover corrupted digital media files that were encoded incorrectly at source.
