# `.profile` file for Heroku apps
# to fetch secrets from Hashicorp Vault
# and load them into environment variables.
#
# https://devcenter.heroku.com/articles/dynos#the-profile-file
#

cd vault_to_env/ && source export.sh && cd ..
