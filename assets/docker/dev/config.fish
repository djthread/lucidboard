if [ "$QL_MODE" -a "$QL_MODE" -eq "1" ]
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
    mix deps.get; and \
    cd assets; npm install; and cd ..; \
    mix ecto.setup; and \
    echo "You may now start the dev server with `imp`."
end
