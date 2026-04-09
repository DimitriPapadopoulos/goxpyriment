* improve the movie player for gv format: the gv file should be read progressively from the disk in a goroutine, if possible (but beware lz4 compression).  
* during video playback (gv or mpeg-1), we would like to sent triggers on a triggerbox device at very specific frames. 
* maybe movies playing should be considered as a kind of stream (see stimuli/streams.go). It would be great if they can return input events. Yet, I think we may want the retain the possibility to pause movies, rewind them, ... This is not what stresm do. To be discussed.
* add support for some eyetrackers, e.g., eyelink 1000

