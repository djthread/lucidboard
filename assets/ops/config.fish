# This first condition ensures the echo doesn't happen twice.
# I have no idea why this file is being executed twice!!
if [ ! "$HEX_UNSAFE_HTTPS" -a "$QL_MODE" -eq "1" ]
    echo "Disabling SSL authentication in Hex for operation on the QL network."
    set -x HEX_UNSAFE_HTTPS 1
end

alias imp "iex -S mix phx.server"
alias im "iex -S mix"
alias mdg "mix deps.get"
alias mdu "mix deps.update --all"
alias mt "mix test"
alias mtw "mix test.watch"
alias ml "mix lint"
alias mer "mix ecto.reset"

function setup
    /setup_security.sh
    mix deps.get; and \
    cd assets; npm install; and cd ..; \
    mix ecto.setup; and \
    echo "You may now start the dev server with `imp`."
end

alias gff "git pull --rebase origin $argv"
alias ga "git add $argv"
alias gp "git push $argv"
alias gl "git log $argv"
alias gs "git status --ignore-submodules $argv"
alias gsu "git submodule $argv"
alias gsu-init-recursive-update "gsu update --init --recursive"
alias gd "git diff $argv"
alias gm "git commit -m $argv"
alias gb "git branch $argv"
alias gbr "git branch -r $argv"
alias gc "git checkout $argv"
alias gre "git rebase $argv"
alias gf "git fetch -p $argv"
alias grm "git rm $argv"
alias gmv "git mv $argv"
alias grv "git remote -v $argv"
alias gca "git commit --amend"
