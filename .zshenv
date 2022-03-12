#!/usr/bin/env zsh

## Dotfiles and templates
command mkdir -p "${HOME-}"'/Dropbox/dotfiles' &&
  export DOTFILES="${DOTFILES:="${HOME-}"/Dropbox/dotfiles}" &&
  command mkdir -p "${TEMPLATE:="${DOTFILES-}"/../Template}" &&
  export TEMPLATE="${TEMPLATE:="${DOTFILES-}"/../Template}" &&
  command mkdir -p "${DEFAULT:="${TEMPLATE-}"/../Default}" &&
  export DEFAULT="${DEFAULT:="${TEMPLATE-}"/../Default}"

# XDG
# https://specifications.freedesktop.org/basedir-spec/0.7/ar01s03.html
export XDG_DATA_HOME="${XDG_DATA_HOME:=${HOME-}/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=${HOME-}/.config}"

export XDG_STATE_HOME="${XDG_STATE_HOME:=${HOME-}/.local/state}"

# `XDG_DATA_DIRS` does have trailing slashes
# https://web.archive.org/web/0id_/lists.freedesktop.org/archives/xdg/2019-June/014157.html
export XDG_DATA_DIRS="${XDG_DATA_DIRS:=/usr/local/share/:/usr/share/}"

export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:=/etc/xdg}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:=${HOME-}/.cache}"

# Locale
export LC_ALL="${LC_ALL:=en_US.UTF-8}"
export TZ="${TZ:=America/New_York}"

## private
test -r "${HOME-}"'/.env' &&
. "${HOME-}"'/.env'
