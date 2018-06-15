require 'rubygems'
require 'bundler/setup'
# Gems
require 'vault'

class VaultToEnv
  # Optional whitespace, a comma, and then more optional whitespace
  COMMA_SEPARATION_MATCHER = /[\s]*,[\s]*/

  # Fetch keys from Vault, returning env var assignments as a multi-line string.
  #
  # Vault is configured automatically (in the vault-ruby gem) via env variables: 
  #   VAULT_ADDR, VAULT_TOKEN, etc…
  # See the gem's usage docs, https://github.com/hashicorp/vault-ruby#usage
  #
  # @param keys (String) a comma-&-space separated list of keys to fetch
  #
  def self.run(keys)
    mounts = Vault.sys.mounts

    output = []
    # Lines that start with `#` are comments, not actual exports.
    output << "# connected to Vault, mounts #{mounts.keys}"

    secrets_mount = ENV['VAULT_SECRETS_MOUNT']
    raise "Vault mount must be specified. Please set VAULT_SECRETS_MOUNT." unless secrets_mount

    keys.split(COMMA_SEPARATION_MATCHER).each do |key|
      secret = Vault.with_retries(Vault::HTTPConnectionError) do
        Vault.logical.read("#{secrets_mount}/#{key}")
      end
      if secret
        output << %Q(#{key}='#{JSON.generate(secret.data).gsub("'", '\\\\\'')}')
      else
        raise "Vault key '#{key}' does not exist"
      end
    end

    output * "\n"
  end
end
