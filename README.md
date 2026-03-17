# misc-scripts
Miscellaneous scripts, mostly for the GNU/Linux command line.

## abridge
Show a brief sampling of given file(s) content.

## alert
Pop up an alert on your desktop (wraps `zenity` or `gxmessage`).

## anagrams
Find words composed of given letters, without extra repetition. Useful for word games like Scrabble.

## apt
Wrapper for `apt` that adds more features to the command, including the ability to upgrade to root (using `sudo`) when needed.

## apt-popcon
Find [Debian Popularity Contest](https://popcon.debian.org/) data for packages matching a given query.

## arms
Print the first and last lines of files (like `head` and `tail`), truncating them to the current terminal's width.

## avg
Calculate the average of a series of input numbers. Supports arithmetic mean, median, standard deviation, max, min, and sum. Numbers can be from a given field with a custom delimiter.

## beep, vbeep
Alert by beeping or flashing the screen. If there is another `beep`, it is invoked when making audio beeps.

## cal
A smarter `cal` wrapper that can handle English month names, a 9mo view, and nearest month. Try `cal -9`.

## columns
Equalize output of column widths. Similar to `column -t` but color-safe and tab-aware. Right-aligns columns.

## countdown
Like `sleep`, but counts down visually when interactive and unpiped.

## diffc
Colored diff, uses `git diff --patience` if available.

## gray
Color standard output gray so standard error is nice and visible.

## grepe
A smarter multi-pattern `grep` wrapper.

## hd
Enhanced hex dump wrapper with colors and wide options.

## ls.swp
Show notes on vim swap files.

## lsps
List entire ownership hierarchy of given process(es) from top to bottom.

## namegen
Generate a block of randomly-generated names, excluding dictionary matches. Good for creating pronounceable number-free usernames.

## pdfmerge
A drop-in replacement for the old `psmerge` program with better support for PDF. Supports PDF, PS, and TIFF.

## radix
Convert numbers from one radix (arithmetic base) to another or generate a code from a truncated MD5 checksum.

## sgr
Demonstration of various [Select Graphic Rendition](https://en.wikipedia.org/wiki/ANSI_Select_Graphic_Rendition) parameters (ANSI SGR colors+).

## sortn
Title-aware `sort` wrapper that displays title line(s) before sorted content.

## timecalc
Convert time between colon-delimited units and numbers of seconds.

## trunc
Truncate input to current terminal width (or specify a different width).

## utf2ascii
Convert look-alike characters into ASCII.

## vimdiff / gvimdiff
Wrapper for vimdiff that supports automatically comparing to git, SyncThing, snapshots, or else backup names.

## waitx
Wait until all given PIDs complete.

## waketime
Show uptime statistics like `uptime`, but ignore time spent suspended/hibernated when calculating uptime ("waketime").

## window-trans
Set a window's transparency (a wrapper for `transset` with a better `--toggle`).

## xdate
A wrapper for `date` that supports dates like YYYYMMDD_HHMMSS and xlsDDDDD[.DDD] (Excel's "days since 1899-12-31").

## zawk
Like `zcat` + `awk`, supporting bz2, gz, xz, & more, with proper FILENAME and FNR.

## A note on versions
This project uses a modified [Semantic Versioning 2.0.0](https://semver.org/) system of `MAJOR.MINOR.PATCH.BUILD` where:

1. MAJOR increments mean a major overhaul or dependencies/assumptions/API breaks
2. MINOR increments mean new backwards-compatible features were added
3. PATCH is the YYYYMMDD. Unchanged MAJOR.MINOR means bugfixes or minor tweaks
4. BUILD is an extension of PATCH to prevent collisions and/or for trivial fixes

As with SemVer, a MAJOR version of 0 means it's new and not yet deemed stable. It's probably still mostly stable (it wouldn't be published otherwise). Incrementing to version 1 means it has been promoted. The other MAJOR version criteria may or may not be met.

