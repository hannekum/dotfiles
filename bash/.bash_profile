# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Add `~/bin` to the `$PATH`
PATH="$HOME/bin:$PATH"
#PATH=${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
OS="$(uname -s)"
EDITOR=nvim
VISUAL="$EDITOR"

HOMEBREW_GITHUB_API_TOKEN=5c6ec70d8c8fac798c9787c8fa6bdf144631ab2e

export PATH
export OS
export EDITOR VISUAL
export HOMEBREW_GITHUB_API_TOKEN

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
#for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
#	[ -r "$file" ] && [ -f "$file" ] && . "$file";
#done;
#unset file;

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null
done
unset option

# Tab completion
[ -f $(command -v brew) ] && brew_prefix="$(brew --prefix)"
[ -f ${brew_prefix}/etc/bash_completion ] && . ${brew_prefix}/etc/bash_completion

# Enable tab completion for `g` by marking it as an alias for `git`
[ -f ${brew_prefix}/etc/bash_completion.d/git-completion.bash ] && type -t _git >/dev/null &&
  complete -o default -o nospace -F _git g
unset brew_prefix

# Git prompt
[ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ] && {
  GIT_PROMPT_THEME=Default; . "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"; }

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" \
  -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;

#printvar() { (( $# )) && for i in "$@"; do declare -p "$i" >&2; done }

#__dirs="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
#__self="$__dirs/$(basename -- "${BASH_SOURCE[0]}")"
#__file="$(basename "$__self")"
#__name="$(basename "$__self" "${__file#${__file%.*}}")"

#__realdirs="$(readlink -f "$__dirs")"
#__realself="$(readlink -f "$__self")"
#__realfile="$(basename "$__realself")"
#__realname="$(basename "$__realself" "${__realfile#${__realfile%.*}}")"

# First entry is default and used when dotfiles path cannot be found
# (i.e. ${dotfile_dirs[0]})
# Set default dotfiles path first as search loop destroys array
#
dotfile_dirs=("$HOME/.config/dotfiles" "$HOME/.dotfiles" "$HOME/dotfiles")
DOTFILES_DIR="$dotfile_dirs"
until [ -d "$dotfile_dirs" ] || (( ! ${#dotfile_dirs[@]} )); do
  dotfile_dirs=("${dotfile_dirs[@]:1}")
done
[ "$dotfile_dirs" ] && DOTFILES_DIR="$dotfile_dirs"
[ ! -d "$DOTFILES_DIR" ] && err DOTFILES_DIR
unset dotfile_dirs

# Finally we can source the dotfiles (order matters)
#
dotdirs=(exports function function_* path env aliases completion grep prompt nvm rvm custom)
for file in "${dotdirs[@]/#/${DOTFILES_DIR}\/system\/}"; do
  [ -f "$file" ] && . "$file"
  [ -f "${file}.${OS,,}" ] && . "${file}.${OS,,}"
done
unset dotdirs file

# Hook for extra/custom stuff
EXTRA_DIR="$HOME/.extra"
if [ -d "$EXTRA_DIR" ]; then
  for EXTRAFILE in "$EXTRA_DIR"/runcom/*.sh; do
    [ -f "$EXTRAFILE" ] && . "$EXTRAFILE"
  done
fi

# Set LSCOLORS
#eval "$(dircolors "$DOTFILES_DIR"/system/.dir_colors)"

# Export
export DOTFILES_DIR EXTRA_DIR
