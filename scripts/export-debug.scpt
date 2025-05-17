on run argv
    set inputPath to item 1 of argv
    set outputPath to item 2 of argv

    tell application "Pixelmator Pro"
        open POSIX file inputPath
        delay 1 -- wait for file to open (increase to 2 if needed)

        if (count of documents) = 0 then
            display dialog "Failed to open image: " & inputPath
            return
        end if

        tell the front document
            remove background
            delay 1 -- optional, in case removal takes time
            export to file outputPath as PNG
            close saving no
        end tell
    end tell
end run