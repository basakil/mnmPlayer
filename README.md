# mnmPlayer
A simple and native Mac (OS X) media player, with a playlist window/table, aimed to have minimal resource usage...
* There extists a working product (application) but the project is incomplete yet...

## Completed/Planned properties of the product:

1. Native media APIs
    * Uses the new -HW accelerated- AVKit/AVFoundation APIs.
2. Native UI
    * All Cocoa.
3. Playlist management
    * Drag & drop or cut/copy/paste playlist management
    * Directory crawling, inspection and selective insertion for directory/mixed drops
    * .m3u save/load/drop
    * web url drop (radio, audio, video, ...)
3. Minimal CPU usage when active, -almost- none when idle.
    * Less than 2% when playing audio @ a mid-2009 macbook pro, -almost- none when idle.
4. Minimal memory usage.
    * Less than 20MB real memory usage when playing audio, for now...
5. Minimal -distributed- application size
    * Less than 10MB for now, will be significantly less when Apple embeds Swift runtime into MacOS.

## License
Is not decided yet, please ignore any copyright statements for now. 

## Help Wanted!:

### Swift / Mac Developers are needed
    * for -general- development process
### Graphics Designers are needed
    * for application / button icons (svg,png) 
