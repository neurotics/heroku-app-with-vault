require 'open3'
require './main.rb'

RSpec.describe '.profile' do
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

    it 'exports secrets to the env' do
      # command ends in `env` to make assertions of exported vars via stdout
      stdout, stderr, status = Open3.capture3(%Q(bash -c "cd .. && VAULT_READ_PATHS='test_path_1, test_path_2' source .profile && env"))
      expect(status.exitstatus).to eq(0)
      expect(stderr).to include('connected to Vault')
      expect(stdout).to include('test_path_1=\'{"value":"I\\\'m one"}\'')
      expect(stdout).to include('test_path_2=\'{"value":"I\\\'m two"}\'')
    end

    it 'exits failure when a key does not exist' do
      stdout, stderr, status = Open3.capture3(%Q(bash -c "cd .. && VAULT_READ_PATHS='test_path_xxxxx' source .profile"))
      expect(status.exitstatus).to eq(1)
      expect(stderr).to include("Vault key 'test_path_xxxxx' does not exist")
    end
  end

  it 'exits quietly without VAULT_READ_PATHS' do
    # switch to project root / home and then exec the top-level stub
    stdout, stderr, status = Open3.capture3(%Q(bash -c "cd .. && source .profile"))
    expect(status.exitstatus).to eq(0)
    expect(stderr).to include('skipping Vault because VAULT_READ_PATHS is empty')
  end

end
