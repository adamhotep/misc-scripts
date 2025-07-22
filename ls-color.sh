#!/bin/sh
# This is a 100% POSIX wrapper for `ls` that supports `--color=WHEN`
# and the BSD environment variable color cues ($CLICOLOR and $CLICOLOR_FORCE).
# `CLICOLOR="" ls`      has no colors (unless CLICOLOR_FORCE is non-empty)
# `unset CLICOLOR; ls`  is the same as `ls --color=auto`
# `NOCOLOR=1 ls`        overrides all color requests, like `ls --color=never`
#
# ls-color 0.1.20250720.0 copyright 2025+ by Adam Katz, Apache License 2.0

ls() {
  local class= col=1 color= force_F=1 non_arg= opt pid=$$ skip=init sopt
  if [ -n "$CLICOLOR_FORCE" ] || [ -n "${CLICOLOR-1}" -a -t 1 ]; then
    color=1
  fi

  # loop through options for --color, -l vs -C/-x, and -F vs -p vs neither {{{
  for opt in "$@"; do
    if [ "$skip" = init ]; then # first iteration: clear $@ so we can rebuild it
      skip=
      set --
    fi
    if [ "$skip" = 1 ]; then
      skip=
    elif [ "$opt" != "${opt#-}" ]; then
      case "$non_arg$opt" in
        ( -- )	non_arg=1 ;;
        ( --colo[ur]* )
          case ${opt#*[ou]r} in
            ( =n* )		color= ;;	# --color=never
            ( =auto | =*tty )	[ -t 1 ] && color=1 ;;
            ( '' | =[afy]* )	color=1 ;;	# --color or --color=always
          esac
          continue	# skip: POSIX `ls` doesn't support --color
          ;;
        ( --* )	: "long option $opt" ;;
        ( -* )
          sopt="${opt%%[ITw]*}"  # Assume -I/-T/-w require arguments (as w/ GNU)
          if   [ -z "${opt#*[ITw]}" ]; then skip=1; fi	# opt arg is next
          if   [ -z "${sopt##-*l*[Cx]*}" ]; then col=1 force_F=1
          elif [ -z "${sopt##-*l*}"      ]; then col=  force_F=
          elif [ -z "${sopt##-*[Cx]*}"   ]; then col=1 force_F=1; fi
          if   [ -z "${sopt##-*F*}" ]; then class=F force_F=
          elif [ -z "${sopt##-*p*}" ]; then class=p; fi
          ;;
      esac
    elif [ -n "$non_arg" -o -e "$opt" ] && [ "$force_F" = 1 ]; then
      force_F=2 	# keep $force_F set but don't let it trigger here again
      set -- "$@" -F
    fi

    set -- "$@" "$opt"

  done	# done parsing options }}}

  if [ -n "$NO_COLOR" ] || [ -z "$color" ]; then	# no colors = no wrapper
    CLICOLOR_FORCE= CLICOLOR= command ls "$@"
    return $?
  fi

  # col needs -F for color cues. w/out path args, we haven't added it yet
  if [ "$force_F" = 1 ]; then
    set -- "$@" -F
  fi

  {
    command ls -C "$@"
    echo "$pid $?" |awk '{ print "\0\0\0", $1, "exit", $2 }' # ls exit code
  } |awk -v col="$col" -v class="$class" -v force_F="$force_F" -v pid="$pid" '

    BEGIN {
      e = "\033[";     c = e "40;33;1m";  d = e "1;34m";  l = e "1;36m"
      p = e "40;33m";  s = e "1;35m";     x = e "1;32m";  z = e "m"
    }

    NF == 4 && $1 $2 == "\0\0\0" pid && $3 == "exit" { exit $4 } # ls exit code

    #  columnar view {{{
    col {
      # This has some known limitations:
      # * It assumes paths do not contain two consecutive spaces
      # * It cannot handle paths containing line breaks (eww! do not do that!)
      # * It can miscolor regular files whose names end in any of  * | = @
      #   and such files lose that trailing character unless this runs with -F
      last = 0	# this loop runs only once per line when matching /$/
      while (match($0, /[ 	][ 	]+|$/) && RLENGTH || !last++) {
        file = substr($0, 1, RSTART - 1)
        gap = substr($0, RSTART, RLENGTH)
        $0 = substr($0, RSTART + RLENGTH)
        type = substr(file, length(file))
        file = substr(file, 1, length(file) - 1)	# assume there is a type
        color = off = ""
        if      (type == "/") { color = d; off = z }
        else if (force_F || class == "F") {
          if      (type == "*") { color = x; off = z }
          else if (type == "|") { color = p; off = z }
          else if (type == "=") { color = s; off = z }
          else if (type == "@") { color = l; off = z }
          }
        if (color && (class == "" || class == "p" && type != "/")) {
          type = gap ? " " : ""
        }
        printf "%s%s%s%s%s", color, file, off, type, gap
      }
    }	# end columnar view }}}

    # long listing view {{{
    ! col && NF > 2 && !file_pos {	# determine where the path starts
      # A very simple matcher for `m DD HH:MM ` or `m DD  YYYY `
      # where `m` is the last character of the abbreviated month (`date +%b`)
      # (My complete matcher: https://stackoverflow.com/a/79702508/519360)
      match($0, /[^0-9] [ 0-3][0-9] ( (19|20)[0-9]|[0-2][0-9]:[0-5])[0-9] /)
      if (RSTART > 9) file_pos = RSTART + RLENGTH - 1
      else {
        # matcher failed. use a space-ignorant matcher (earliest match is best)
        pos = match($0, / [^ ]+( -> .+)?$/) + 1
        if (!alt_file_pos || pos < alt_file_pos) alt_file_pos = pos
      }
    }

    ! col && NF > 2 {

      pos = file_pos ? file_pos : alt_file_pos
      file = substr($0, pos)

      if (/^[^ ]+x/) {
        if (/\/$/) exe = d	# ls -p or -F has told us this is a directory
        else exe = x
      } else exe = ""

      color = exe
      extra = ""
      link = 0

      if   (/^[bc]/) { color = c }
      else if (/^d/) { color = d }
      else if (/^l/) { link = 1; sub(/ -> /, z "&" exe, file); color = l }
      else if (/^p/) { color = p }
      else if (/^s/) { color = s }

      if (color) {
        if      ((color == d || link) && sub(/\/$/, "", file)) extra = "/"
        else if ((color == x || link) && sub(/\*$/, "", file)) extra = "*"
        else if ((color == p || link) && sub(/\|$/, "", file)) extra = "|"
        else if ((color == s || link) && sub(/=$/,  "", file)) extra = "="
        $0 = substr($0, 1, pos - 1) color file z extra
      }
    }	# end long listing view }}}

    { print }
  '
}

ls "$@"
