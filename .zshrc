export ZSH="$HOME/.oh-my-zsh"

plugins=(git alias-tips z)

source $ZSH/oh-my-zsh.sh source ~/.zsh/alias-tips/alias-tips.plugin.zsh

alias lg="lazygit"
alias gup="git pull --rebase"
alias agent="ollama launch claude --model qwen2.5-coder"
alias brew-uuc="brew update && brew upgrade && brew cleanup"
alias yt-dlp="~/Desktop/code/yt-dlp/yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata --no-abort-on-error -o './playlist/%(playlist_index)s - %(title)s.%(ext)s'"
alias repolicense="~/Desktop/code/repolicense-cli/zig-out/bin/repolicense"
alias hermes-subprocess="ps aux | grep hermes | grep -v grep"
alias ssh-termux='ssh "${TERMUX_USER}@${TERMUX_IP}" -p "${TERMUX_PORT}"'
alias ssh-klaus='ssh "${KLAUS_USER}@${KLAUS_IP}"'
alias ssh-klaus-dashboard='ssh -N -L 18789:"${KLAUS_DASHBOARD_PORT}" "${KLAUS_USER}"@"${KLAUS_IP}"'
alias ssh-ecoray-data='ssh "${ECORAY_DATA_USER}@${ECORAY_DATA_IP}"'

eval "$(starship init zsh)"
export PATH=/usr/local/anaconda3/bin:$PATH
export PATH=/Users/lucasfreytorreshanson/.cargo/bin:$PATH
export PATH="~/.dotnet/tools:$PATH"
export PATH="/Users/lucasfreytorreshanson/.bun/bin:$PATH"

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "~/.sdkman/bin/sdkman-init.sh" ]] && source "~/.sdkman/bin/sdkman-init.sh"export PATH="/opt/homebrew/opt/gradle@7/bin:$PATH"

# bun completions
[ -s "/Users/lucasfreytorreshanson/.bun/_bun" ] && source "/Users/lucasfreytorreshanson/.bun/_bun"

# Mole shell completion
if output="$(mole completion zsh 2>/dev/null)"; then eval "$output"; fi

#compdef opencode
###-begin-opencode-completions-###
_opencode_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" opencode --get-yargs-completions "${words[@]}"))
  IFS=$si
  if [[ ${#reply} -gt 0 ]]; then
    _describe 'values' reply
  else
    _default
  fi
}
if [[ "'${zsh_eval_context[-1]}" == "loadautofunc" ]]; then
  _opencode_yargs_completions "$@"
else
  compdef _opencode_yargs_completions opencode
fi
###-end-opencode-completions-###

# Time format for the `time` command
TIMEFMT=$'\n================\nCPU\t%P\nuser\t%*U\nsystem\t%*S\ntotal\t%*E'

. "$HOME/.local/bin/env"

# zsh secrets
if [ -f ~/.zsh/.zshrc_secrets ]; then
  source ~/.zsh/.zshrc_secrets
fi

# Enforce Multica Docker Sandbox defaults natively
export MULTICA_AGENT_RUNTIME_PROVIDER="docker"
export MULTICA_AGENT_DEFAULT_IMAGE="ghcr.io/multica-ai/multica-agent-env:latest"
