#!/usr/bin/env zsh

# aliases.zsh
# for all active aliases, run `alias`

# Atom
# https://github.com/jeefberkey/dotfiles/blob/2ded1c3/.zshrc#L48-L61
alias atom-beta='atom-nightly'
alias apm-beta='apm-nightly'
alias atom='atom-nightly'
alias apm='apm-nightly'

# dotfiles
# https://stackoverflow.com/q/4210042#comment38334264_4210072
mu() {
  cd "${DOTFILES:=${HOME}/Dropbox/dotfiles}" &&
    (command -v cleanup >/dev/null 2>&1 && cleanup) &&
    mackup backup --force --root &&
    git fetch --all &&
    git submodule update --init --recursive &&
    git status
}
mux() {
  cd "${DOTFILES:=${HOME}/Dropbox/dotfiles}" &&
    (command -v cleanup >/dev/null 2>&1 && cleanup) &&
    mackup backup --force --root --verbose &&
    git fetch --all --verbose &&
    git submodule update --init --recursive --remote &&
    git submodule sync --recursive &&
    git status
}

# Git
git_add_patch() {
  git add --patch --verbose -- "$@"
  git status
}
alias gap='git_add_patch'
alias gc='git commit --verbose --gpg-sign; git status'
alias gca='git commit --amend --verbose --gpg-sign; git status'
alias gcl='git clone --verbose --progress --recursive --recurse-submodules'
alias gcm='git commit --verbose --gpg-sign --message'
alias gco='git checkout --progress'

# `git checkout` the default branch
git_checkout_default() {
  git checkout --progress "$(git_default_branch)"
}
alias gcom='git_checkout_default'

git_diff_default() {
  git diff "$(git_default_branch)"
}
alias gdm='git_diff_default'

alias gsd='gds'

alias gfgs='git fetch --all --verbose && git status'
git_garbage_collection() {
  (command -v cleanup >/dev/null 2>&1 && cleanup)
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git fetch --prune --prune-tags --verbose
    git prune --verbose --progress --expire now
    git prune-packed
    git gc --aggressive --prune=now
    git maintenance start
    git status
  else
    return 1
  fi
}
alias ggc='git_garbage_collection'
alias git_garbage_collect='ggc'

# https://github.com/jwiegley/git-scripts/blob/3c301e7/git-find-children
alias git_find_parents='git rev-list'
alias gfp='git_find_parents'
alias gfc='gfp'

# initial commit
# https://stackoverflow.com/q/1006775#comment23686803_1007545
alias gic='git rev-list --topo-order --parents HEAD | grep -E "^[a-f0-9]{40}$"'
alias gcic='git rev-parse --is-inside-work-tree >/dev/null 2>&1 || git init && git commit --allow-empty --verbose --message $(printf \x27\xe2\x9c\xa8 initial commit\x27) && git add . && git commit --verbose --message $(printf \x27\xe2\x9c\xa8 initial commit\x27)'
alias ginit='git init && git status'

# git log
# https://github.com/gggritso/gggritso.com/blob/a07b620/_posts/2015-08-23-human-git-aliases.md#readme
alias glog='git log --graph --branches --remotes --tags --format=format:"%Cgreen%h %Creset• %<(75,trunc)%s (%cN, %cr) %Cred%d" --date-order'

# return the name of the repository’s default branch
# ohmyzsh/ohmyzsh@c99f3c5/plugins/git/git.plugin.zsh#L28-L35
# place the function inside `{()}` to prevent the leaking of variable data
# https://stackoverflow.com/a/37675401
git_default_branch() {
  (
    # check if there’s a `remote` with a default branch and
    # if so, then use that name for `default_branch`
    # https://stackoverflow.com/a/44750379
    if git symbolic-ref refs/remotes/origin/HEAD >/dev/null 2>&1; then
      default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

    # check for `main`, which, if it exists, is most likely to be default
    elif [ -n "$(git branch --list main)" ]; then
      default_branch=main

    # check for a branch called `master`
    elif [ -n "$(git branch --list master)" ]; then
      default_branch=master
    else
      printf 'unable to detect a \x60main\x60, \x60master\x60, or default '
      printf 'branch in this repository\n'
      return 1
    fi
    printf %s "${default_branch}"
  )
}
alias gdb='git_default_branch'

# https://news.ycombinator.com/item?id=5512864
alias gm='GIT_MERGE_VERBOSITY=4 git merge --overwrite-ignore --progress --rerere-autoupdate --strategy-option patience'
alias gmc='GIT_MERGE_VERBOSITY=4 git merge --continue'

# git merge main
gmm() {
  # set Git merge verbosity environment variable
  # 4 “shows all paths as they are processed” but
  # 5 is “show detailed debugging information”
  # https://github.com/progit/progit2/commit/aea93a7
  GIT_MERGE_VERBOSITY=4 git merge --verbose --progress --rerere-autoupdate --strategy-option patience "$(git_default_branch)"
}

alias gmv='git mv --verbose'

# git pull after @ohmyzsh `gupav` ohmyzsh/ohmyzsh@3d2542f
alias gpl='git pull --all --rebase --autostash --ff-only --verbose && git status'

# git push after @ohmyzsh `gpsup` ohmyzsh/ohmyzsh@ae21102
alias gps='git push --verbose --set-upstream origin "$(git_current_branch)" && git status'

alias grmr='git rm -r'
alias grm='grmr'

git_restore() {
  for file in "${@}"; do
    git checkout --progress -- "${file}"
  done && git status
}
alias grs='git_restore'

# git submodule rm
git_submodule_rm() {
  # https://github.com/romkatv/dotfiles-public/commit/07c9b29

  # usage: $0 submodule-to-remove
  if [ $# -eq 1 ] &&
    # continue only if `submodule-to-remove` is an existing file or directory
    [ -e "$1" ] &&
    # continue only if called from the top of a Git repository
    [ "$(git rev-parse --show-toplevel)" = "$(pwd -P)" ]; then
        command git submodule deinit --force -- "$1"
        command rm -r -f -- "$(git rev-parse --git-dir)"/modules/"$1"
        command git rm --force -- "$1"
  else
    command -v git rev-parse --git-dir >/dev/null 2>&1 || (
      printf ''
      return 2
    )
    command cd -- "$(git rev-parse --git-dir)" || (
      printf ''
      return 3
    )
    printf 'usage: \xe2\x80\x98%s <path-of-submodule-to-remove>\xe2\x80\x99\n' "$0"
    return 1
  fi
}
alias git-submodule-rm='git_submodule_rm'
alias git-rm-submodule='git-submodule-rm'
alias gsr='git_submodule_rm'

git_submodule_update() {
  git submodule update --init --recursive --remote -- "$@" &&
    git submodule sync --recursive -- "$@" &&
    git status
}
alias gsu='git_submodule_update'
alias gtake='git checkout -b'
alias gti='git'

gu() {
  (
    (command -v cleanup >/dev/null 2>&1 && cleanup)

    # run only from within a git repository
    # https://stackoverflow.com/a/53809163
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      git fetch --all --verbose

      # `git submodule update` with `--remote` appears to slow Git to a crawl
      # https://docs.google.com/spreadsheets/d/14W8w71DK0YpsePbgtDkyFFpFY1NVrCmVMaw06QY64eU
      if [ "$1" = --remote ] || [ "$1" = -r ]; then
        remote="--remote"
      fi
      git submodule update --init --recursive ${remote}
      git submodule sync --recursive --
      git status
    fi
  )
}

# https://github.com/tarunsk/dotfiles/blob/5b31fd6/.always_forget.txt#L1957
gvc() {
  # if there is an argument (commit hash), use it
  # otherwise check `HEAD`
  git verify-commit "${1:-HEAD}"
}

# shell
cd_pwd_P() {
  cd_from=$(pwd)
  cd_to=$(pwd -P)
  if [ "${cd_from}" != "${cd_to}" ]; then
    printf 'moving from \xe2\x80\x98%s\xe2\x80\x99\n' "${cd_from}" &&
      sleep 0.2
    cd "${cd_to}" || (
      printf 'unable to perform this operation\n' && return 1
    )
    printf '       into \xe2\x80\x98%s\xe2\x80\x99\n' "${cd_to}" &&
      sleep 0.2
  else
    printf 'already in unaliased directory '
    printf '\xe2\x80\x98%s\xe2\x80\x99\n' "${cd_from}"
  fi
  unset cd_from cd_to
}
alias cdp='cd_pwd_P'

clang_format() {
  # https://github.com/Originate/guide/blob/880952d/ios/files/clang-format.sh
  (
    program=clang-format

    # if no argument is provided, then set `IndentWidth` to 2
    # https://stackoverflow.com/a/2013573
    IndentWidth=${1:-2}

    # if no second argument is provided, then set `ColumnLimit` to 79
    # https://stackoverflow.com/a/48016407
    ColumnLimit=${2:-79}

    printf '\n%s\n\n' "$("${program}" --version)"
    sleep 1

    printf 'applying %s to all applicable files in %s...\n' "${program}" "${PWD##*/}"
    sleep 1

    printf 'setting \x60IndentWidth\x60 to %d\n' "${IndentWidth}"
    sleep 1

    printf 'setting \x60ColumnLimit\x60 to %d\n\n\n' "${ColumnLimit}"
    sleep 1

    find -- * -type f \
      \( \
      -iname '*.adb' -or \
      -iname '*.ads' -or \
      -iname '*.asm' -or \
      -iname '*.ast' -or \
      -iname '*.c' -or \
      -iname '*.c++' -or \
      -iname '*.c++m' -or \
      -iname '*.cc' -or \
      -iname '*.ccm' -or \
      -iname '*.cl' -or \
      -iname '*.cp' -or \
      -iname '*.cpp' -or \
      -iname '*.cppm' -or \
      -iname '*.cs' -or \
      -iname '*.cu' -or \
      -iname '*.cuh' -or \
      -iname '*.cui' -or \
      -iname '*.cxx' -or \
      -iname '*.cxxm' -or \
      -iname '*.f' -or \
      -iname '*.f90' -or \
      -iname '*.f95' -or \
      -iname '*.for' -or \
      -iname '*.fpp' -or \
      -iname '*.h' -or \
      -iname '*.h++' -or \
      -iname '*.hh' -or \
      -iname '*.hip' -or \
      -iname '*.hp' -or \
      -iname '*.hpp' -or \
      -iname '*.hxx' -or \
      -iname '*.i' -or \
      -iname '*.ifs' -or \
      -iname '*.ii' -or \
      -iname '*.iim' -or \
      -iname '*.inc' -or \
      -iname '*.inl' -or \
      -iname '*.java' -or \
      -iname '*.js' -or \
      -iname '*.ll' -or \
      -iname '*.m' -or \
      -iname '*.mi' -or \
      -iname '*.mii' -or \
      -iname '*.mm' -or \
      -iname '*.pcm' -or \
      -iname '*.proto' -or \
      -iname '*.protodevel' -or \
      -iname '*.rs' -or \
      -iname '*.tcc' -or \
      -iname '*.td' -or \
      -iname '*.theletters' -or \
      -iname '*.tlh' -or \
      -iname '*.tli' -or \
      -iname '*.tpp' -or \
      -iname '*.ts' -or \
      -iname '*.txx' \
      \) -and \
      \( \
      -not -path '*.git/*' -and \
      -not -path '*node_modules/*' \
      \) \
      -exec "${program}" -i --style "{IndentWidth: ${IndentWidth}, ColumnLimit: ${ColumnLimit}}" --verbose --fcolor-diagnostics --print-options {} \+
    printf '\n\n\xe2\x9c\x85 done\x21\n\n'
  )
}

# http://mywiki.wooledge.org/BashPitfalls?rev=524#Filenames_with_leading_dashes
alias cp='cp -r'
cy() {
  (
    if [ -r "$1" ]; then
      # if within git repo, then auto-overwrite
      if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        interactive="-i"
      fi
      if [ -z "$2" ]; then
        # if there is no second argument,
        # then copy to the current directory
        # -r to copy recursively
        # -L to follow symbolic links
        eval cp -r -L "${interactive} -- $1 ${PWD}"
      else
        eval cp -r -L "${interactive} -- $1 $2"
      fi
    elif [ -e "$1" ]; then
      printf '\x60%s\x60 is not readable and cannot be copied\n' "$1"
      return 1
    else
      printf '\x60%s\x60 does not exist and cannot be copied\n' "$1"
      return 2
    fi
  )
}

cleanup() {
  (
    # if `cleanup -v` or `cleanup --verbose`,
    # then use `-print` during `-delete`
    if [ "$1" = -v ] || [ "$1" = --verbose ]; then
      verbose=-print
    fi

    # delete thumbnail cache files
    find -- * -type f \( \
      -name '.DS_Store' -or \
      -name 'Desktop.ini' -or \
      -name 'desktop.ini' -or \
      -name 'Thumbs.db' -or \
      -name 'thumbs.db' \
      \) \
      ${verbose} -delete

    # delete empty, zero-length files
    # except those within `.git/` directories
    # or with specific names and are writable
    # https://stackoverflow.com/a/64863398
    find -- * -type f -writable -size 0 \( \
      -not -path '*.git/*' -and \
      -not -path '*/test*' -and \
      -not -name "$(printf 'Icon\x0d\x0a')" -and \
      -not -name '*LOCK' -and \
      -not -name '*empty*' -and \
      -not -name '*hushlogin' -and \
      -not -name '*ignore' -and \
      -not -name '*journal' -and \
      -not -name '*lock' -and \
      -not -name '*lockfile' -and \
      -not -name '.dirstamp' -and \
      -not -name '.gitkeep' -and \
      -not -name '.gitmodules' -and \
      -not -name '.keep' -and \
      -not -name '.sudo_as_admin_successful' -and \
      -not -name '.watchmanconfig' -and \
      -not -name '__init__.py' -and \
      -not -name 'favicon.*' \
      \) \
      ${verbose} -delete

    # delete empty directories recursively
    # but skip Git-specific and `/.well-known/` directories
    # https://stackoverflow.com/q/4210042#comment38334264_4210072
    find -- * -type d -empty \( \
      -not -path '*.git/*' -and \
      -not -name '.well-known' \
      \) \
      ${verbose} -delete
  )
}

define() {
  sh -c 'IFS=$(printf " \t\n/"); IFS=${IFS%/}'
  for query in "${@:-$0}"; do
    printf '\n'

    # hash
    command -v hash >/dev/null 2>&1 &&
      printf 'hash return value:\n%d\n———\n' "$(
        hash "${query}" >/dev/null 2>&1
        printf %s $?
      )"

    # type (System V)
    command -v type >/dev/null 2>&1 &&
      printf 'type:\n%s\n———\n' "$(type "${query}")"

    # whence (KornShell)
    command -v whence >/dev/null 2>&1 &&
      printf 'whence:\n%s\n———\n' "$(whence "${query}")"

    # where
    command -v where >/dev/null 2>&1 &&
      printf 'where:\n%s\n———\n' "$(where "${query}")"

    # whereis
    command -v whereis >/dev/null 2>&1 &&
      printf 'whereis:\n%s\n———\n' "$(whereis "${query}")"

    # locate
    command -v locate >/dev/null 2>&1 &&
      printf 'locate:\n%s\n———\n' "$(locate "${query}")"

    # command -V
    printf 'command -V:\n%s\n———\n' "$(command -V "${query}")"

    # command -v (POSIX)
    printf 'command -v:\n%s\n———\n' "$(command -v "${query}")"

    # which (C shell)
    command -v which >/dev/null 2>&1 &&
      printf 'which -a:\n%s\n' "$(which -a "${query}")"

  done
}

# find duplicate files
# https://linuxjournal.com/content/boost-productivity-bash-tips-and-tricks
fdf() {
  find -- * -not -empty -type f \( -not -path '*.git/*' -and -not -path '*node_modules*' \) -printf '%s\n' | sort --reverse --numeric-sort | uniq -d | xargs -I{} -n1 find -type f -size {}c -print0 | xargs -0 sha256sum | sort | uniq -w32 --all-repeated=separate
}

# find by name
fname() {
  find -- * -iname "*${*}*"
}
alias findname='fname'

identify() {
  sh -c 'IFS=$(printf " \t\n/"); IFS=${IFS%/}; printf %s "${IFS}" | xxd'

  # uname
  command -v uname >/dev/null 2>&1 && uname -a

  # sw_vers
  # https://apple.stackexchange.com/a/368244
  command -v sw_vers >/dev/null 2>&1 && sw_vers

  # lsb_release
  # https://linuxize.com/post/how-to-check-your-debian-version
  command -v lsb_release >/dev/null 2>&1 && lsb_release --all

  # hostnamectl
  # https://linuxize.com/post/how-to-check-your-debian-version
  command -v hostnamectl >/dev/null 2>&1 && hostnamectl

  # /etc/os-release
  # https://linuxize.com/post/how-to-check-your-debian-version
  [ -r /etc/os-release ] && cat -v /etc/os-release

  # /proc/version
  # https://superuser.com/a/773608
  [ -r /proc/version ] && cat -v /proc/version

  # /etc/issue
  # https://linuxize.com/post/how-to-check-your-debian-version
  [ -r /etc/issue ] && cat -v /etc/issue
}
alias l='ls -AFgho1 --time-style=+%4Y-%m-%d\ %l:%M:%S\ %P'

# https://unix.stackexchange.com/a/30950
alias mv='mv -v -i'

# paste faster
# https://git.io/pasteinit-pastefinish
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}
pastefinish() {
  zle -N self-insert "${OLD_SELF_INSERT}"
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

same_file() {
  # POSIX-compliant conditional expression `-ef`
  # to find if two files refer to the device and inode numbers
  # usage: same_file file1 file2
  # return 0 if they match
  # https://superuser.com/a/196655
  [ "$(stat -L -c %d:%i "$1")" = "$(stat -L -c %d:%i "$2")" ] && return 0 || return 1
}

# https://github.com/mcornella/dotfiles/commit/ff4e527
question_mark() {
  printf '%s\n' "$?"
}
alias '?'='question_mark'

# sudo, even for aliases, but not functions
# https://github.com/mathiasbynens/dotfiles/commit/bb8de8b
alias sudo='sudo '

# take
# https://github.com/ohmyzsh/ohmyzsh/commit/7cba6bb
take() {
  mkdir -p -v -- "$@" &&
    printf 'cd: changed directory to \xe2\x80\x98%s\xe2\x80\x99\n' "${@:$#}" &&
    cd -- "${@:$#}" || return 1
}

# Unix epoch seconds
# https://stackoverflow.com/a/12312982
# date -j +%s # for milliseconds
alias unixtime='date +%s'

# update
update() {
  (
    update=1
    clear && clear

    printf '                 .___       __\n __ ________   __\x7c _\x2f____ _\x2f  \x7c_  ____\n\x7c  \x7c  \x5c____ \x5c \x2f __ \x7c\x5c__  \x5c\x5c   __\x5c\x2f __ \x5c\n\x7c  \x7c  \x2f  \x7c_\x3e \x3e \x2f_\x2f \x7c \x2f __ \x5c\x7c  \x7c \x5c  ___\x2f\n\x7c____\x2f\x7c   __\x2f\x5c____ \x7c\x28____  \x2f__\x7c  \x5c___  \x3e\n      \x7c__\x7c        \x5c\x2f     \x5c\x2f          \x5c\x2f\n a Lucas Larson production\n\n'

    sleep 1.0

    printf '\n\xf0\x9f\x93\xa1 verifying network connectivity'
    sleep 0.5
    for ((i = 0; i < 2 ** 15; i++)); do
      if (((i / 3) % 2 == 0)); then
        printf '.'
      else
        printf '\b'
      fi
    done
    (
      ping -q -i1 -c1 one.one.one.one >/dev/null 2>&1 && ping -q -i1 -c1 8.8.8.8 >/dev/null 2>&1
    ) || (
      printf 'No internet connection was detected.\nAborting update.\n' && return "${update}"
    )

    ### Homebrew
    printf '\xf0\x9f\x8d\xba checking for Homebrew installation...\n'
    if command -v brew >/dev/null 2>&1; then
      printf '\xf0\x9f\x8d\xba checking for Homebrew updates...\n'
      brew update
      brew upgrade
      brew upgrade --cask
    else
      printf 'No Homebrew installation detected...\n'
    fi # brew

    ### Alpine Linux package keeper
    printf 'checking for Alpine Package Keeper installation...\n'
    if command -v apk >/dev/null 2>&1; then
      printf '\xf0\x9f\x8f\x94 apk update...\n'
      apk update --progress --verbose --verbose

      printf '\n\xf0\x9f\x8f\x94 apk upgrade...\n'
      apk upgrade --update-cache --progress --verbose --verbose

      printf '\n\xf0\x9f\x8f\x94 apk fix...\n'
      apk fix --progress --verbose --verbose

      printf '\n\xf0\x9f\x8f\x94 apk verify...\n'
      apk verify --progress --verbose --verbose
      printf '\xf0\x9f\x8f\x94 apk verify complete...\n\n'
    else
      printf 'no Alpine Package Keeper installation detected...\n'
    fi # apk

    ### Xcode
    printf 'checking for Xcode installation...\n'
    if command -v xcrun >/dev/null 2>&1; then
      printf 'removing unavailable device simulators...\n'
      xcrun simctl delete unavailable
    else
      printf 'no Xcode installation detected...\n'
    fi # xcrun

    ### Atom
    printf 'checking for Atom installation...\n'
    if command -v apm >/dev/null 2>&1; then
      printf 'updating Atom packages...\n'
      apm upgrade --no-confirm
    else
      printf 'no Atom installation detected...\n'
    fi # apm

    ### Rust
    printf 'checking for Rust installation...\n'
    if command -v rustup >/dev/null 2>&1; then
      rustup update
    else
      printf 'no Rust installation detected...\n'
    fi # rustup

    ### Node
    if command -v npm >/dev/null 2>&1; then
      printf 'checking this device is can update Node quickly...\n'
      if [ $((COLUMNS * LINES)) -ge $((80 * 24)) ]; then
        npm install npm --global
        npm update --global --verbose
      else
        printf 'skipping Node update...\n\n' && sleep 1
        printf 'to update Node later, run:\n\n'
        printf '    npm install npm --global && \x5c'
        printf '    npm update --global --verbose\x60\n\n\n'
        sleep 3
      fi # columns

    fi # npm

    ### RubyGems
    if command -v gem >/dev/null 2>&1; then
      gem update --system
      gem update
    fi # gem

    ### rbenv
    if command -v rbenv >/dev/null 2>&1; then
      rbenv rehash
    fi # rbenv

    ### Python
    if command -v python >/dev/null 2>&1; then
      printf '\n\xf0\x9f\x90\x8d verifying Python\xe2\x80\x99s packager is up to date...\n'
      python -m pip install --upgrade pip

      ### pip
      printf 'verifying pip installation...\n'
      if command -v pip >/dev/null 2>&1; then
        printf '\n\xf0\x9f\x90\x8d updating outdated Python packages...\n'
        for package in $(pip list --outdated --format freeze); do
          pip install --upgrade --verbose --verbose --verbose "${package%%=*}"
        done
      fi # pip

      ### pyenv
      printf 'checking for pyenv installation...\n'
      if command -v pyenv >/dev/null 2>&1; then
        printf 'rehashing pyenv shims...\n'
        pyenv rehash
      else
        printf 'no pyenv installation detected...\n'
      fi # pyenv

    fi # python

    ### Oh My Zsh
    if command -v omz >/dev/null 2>&1; then

      # because otherwise omz will force this to exit
      omz update >/dev/null 2>&1 &
    fi # omz

    ### ~/.shrc
    # shellcheck source=/dev/null
    if [ -r "${HOME}"/."${SHELL##*[-/]}"rc ]; then
      . "${HOME}"/."${SHELL##*[-/]}"rc
    fi # ~/.shrc

    ### rehash
    if command -v rehash >/dev/null 2>&1; then
      rehash
    fi # rehash
    unset update

    printf '\n\n\xe2%s\x9c\x85 done\x21\n\n' "${update}"
    exec -l ${SHELL##*[-/]}
  )
}

alias all='which -a'

# https://stackoverflow.com/a/1371283
# https://github.com/mathiasbynens/dotfiles/commit/cb8843b
# http://zsh.sf.net/Doc/Release/Shell-Grammar.html#index-exec
alias ','='. "${HOME}"/."${SHELL##*[-/]}"rc && exec -l ${SHELL##*[-/]}'
alias aliases='${EDITOR:=vi} "${ZSH_CUSTOM:=${DOTFILES}/custom}"/aliases."${SHELL##*[-/]}"; . "${HOME}"/."${SHELL##*[-/]}"rc && exec -l ${SHELL##*[-/]}'
alias ohmyzsh='cd -- "${ZSH:=${HOME}/.oh-my-${SHELL##*[-/]}}" && git status'
alias zshconfig='${EDITOR:=vi} "${HOME}"/."${SHELL##*[-/]}"rc; . "${HOME}"/."${SHELL##*[-/]}"rc && exec -l ${SHELL##*[-/]}'
alias zshenv='${EDITOR:=vi} "${HOME}"/."${SHELL##*[-/]}"env; . "${HOME}"/."${SHELL##*[-/]}"rc && exec -l ${SHELL##*[-/]}'
alias zshrc='${EDITOR:=vi} "${HOME}"/."${SHELL##*[-/]}"rc; . "${HOME}"/."${SHELL##*[-/]}"rc && exec -l ${SHELL##*[-/]}'
