#!/usr/bin/zsh
function command_not_found_handler() {
  [ -z $1 ] && return 1

  if ! [ -x "$(command -v pacman)" ] && ! [ -x "$(command -v pkgfile)" ]; then
    echo '`pkgfile` is not installed, which is required for Arch repo checking. Alternatively, you can edit this script and use `pacman -Fq` instead, although it is a lot slower.' ; return 1
  fi
  if ! [[ -f /usr/lib/command-not-found ]]; then
    echo 'command-not-found not installed'
  fi

  debianPkgs="$(/usr/lib/command-not-found $1 2>&1)"
  if ! [[ $debianPkgs =~ 'from deb' ]]; then
    debianPkgs="$(echo $debianPkgs | tail -n '+2' | sed -e 's/^/  /')"
  fi

  archPkgs="$(pkgfile -b $1)"
  if ! [[ -z $archPkgs ]]; then
    archPkgs="$(echo $archPkgs | sed -e 's/^/  sudo pacman -S /')"
  fi

  if [ -z $archPkgs ] && [ -z $debianPkgs ]; then
    echo "$1: command not found"
  else
    if [[ $debianPkgs =~ 'from deb' ]]; then
      echo $debianPkgs
    else
      echo "Command '$1' not found, but can be installed with:"
      echo $archPkgs
      echo $debianPkgs
    fi
  fi
  return 127
}
