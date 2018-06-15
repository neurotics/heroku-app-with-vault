# encoding: utf-8
require './main.rb'

RSpec.describe VaultToEnv do

  describe '.run' do
    SECRETS_MOUNT = ENV['VAULT_SECRETS_MOUNT']

    describe 'with existing secrets' do
      before do
        @secrets = {
          'test_path_1' => 'I\'m one',
          'test_path_2' => 'I\'m two'
        }
        @secrets.each_pair do |name, val|
          Vault.logical.write("#{SECRETS_MOUNT}/#{name}", value: val)
        end
      end
      after do
        @secrets.each_pair do |name, val|
          Vault.logical.delete("#{SECRETS_MOUNT}/#{name}")
        end
      end

      it "fetches & outputs env var assignments" do
        keys_to_fetch = @secrets.keys * ', '
        result = VaultToEnv.run(keys_to_fetch)
        expect(result).to include('test_path_1=\'{"value":"I\\\'m one"}\'')
        expect(result).to include('test_path_2=\'{"value":"I\\\'m two"}\'')
      end

      it "raises exception when key does not exist" do
        expect { VaultToEnv.run('i-do-not-exist') }.to(
          raise_error(RuntimeError, "Vault key 'i-do-not-exist' does not exist"))
      end
    end

    describe 'without mount' do
      before do
        @original_mount = ENV['VAULT_SECRETS_MOUNT']
        ENV.delete 'VAULT_SECRETS_MOUNT'
      end
      after do
        ENV['VAULT_SECRETS_MOUNT'] = @original_mount
      end

      it "raises exception" do
        expect { VaultToEnv.run('test_path_1') }.to(
          raise_error(RuntimeError, /^Vault mount must be specified/))
      end

    end
  end
end
