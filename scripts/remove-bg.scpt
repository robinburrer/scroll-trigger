on run argv
    set inputPath to item 1 of argv
    set outputPath to item 2 of argv

    set inputFile to POSIX file inputPath
    set outputFile to POSIX file outputPath

    tell application "Pixelmator Pro"
        open inputFile
        delay 1

        if (count of documents) = 0 then
            return -- document failed to open, skip
        end if

        tell the front document
            remove background
            delay 1
            export to outputFile as PNG
            delay 1
            close saving no -- this closes the document
        end tell
    end tell
end run