
if [ -z "$VAULT_READ_PATHS" ]
then
  >&2 echo "[.profile] skipping Vault because VAULT_READ_PATHS is empty"
  return
fi

# Fail immediately on non-zero exit code.
set -e

>&2 echo "[.profile] fetching secrets from Vault: $VAULT_READ_PATHS"

# This uses the cached gems in `vendor/` (update with `bundle pack`)
bundle install --quiet

PATH_TO_SELF="$( pwd -P )"

# This command uses the `|| exit $?` trick to fail on Ruby exceptions with bash 4
EXPORTABLE_ENV=$(ruby -E utf-8:utf-8 \
  -r "$PATH_TO_SELF/main.rb" \
  -e "STDOUT << VaultToEnv.run('$VAULT_READ_PATHS')") || exit $?

while read -r line
do
  if [[ $line =~ ^\s*# ]]
  then
    >&2 echo "[vault-to-env.rb] $line"
  else
    declare -x "$line"
  fi
done <<< "$EXPORTABLE_ENV"

# Revert to continue after non-zero exit code.
set +e
