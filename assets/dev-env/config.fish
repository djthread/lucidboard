alias imp "iex -S mix phx.server"
alias im "iex -S mix"
alias mdg "mix deps.get"
alias mdu "mix deps.update --all"
alias mer "mix ecto.reset"

function setup
    mix deps.get; and \
    cd assets; npm install; and cd ..; \
    mix ecto.setup; and \
    echo "You may now start the dev server with `imp`."
end
