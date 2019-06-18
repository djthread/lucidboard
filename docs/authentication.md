# Authentication

Lucidboard has a modular authentication scheme. By default, Github.com logins
are enabled and you must add secrets, found in your Github.com account, to
the configuration.

## Github.com Strategy

In order to set up Github.com authentication in Lucidboard, you'll need to
create a new set of OAuth credentials and add them to your configuration.
For your dev environment, make sure you've done an initial start-up since
this will generate the initial `config/dev.secret.exs` file with the database
connection info.

* Navigate to Github.com. Click your avatar in the top right corner and choose
  "Settings".
* In the left sidebar, navigate to "Developer settings".
* In the left sidebar, navigate to "OAuth Apps".
* In the top-right, click the "New OAuth App" button.
* Fill out the form
  * Choose an application name. A good one might be `lucidboard-dev`.
  * Homepage url should be the root of your instance -- perhaps
    `http://localhost:8800/`.
  * Application description can be filled if you want.
  * Authorization callback URL should start with your homepage url and end with
    `/auth/github/callback`, so you might use
    `http://localhost:8800/auth/github/callback`.

When you press the "Register application" button, you'll find the generated
"Client ID" and "Client Secret". Open your `config/dev.secret.exs` and add
the following configuration, replacing the ellipses with your secrets:

    config :ueberauth, Ueberauth.Strategy.Github.OAuth,
      client_id: "...",
      client_secret: "..."

Now, if you start up your dev environment, Github.com logins should work!