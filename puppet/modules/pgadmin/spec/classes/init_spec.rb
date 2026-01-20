# frozen_string_literal: true

require 'spec_helper'

describe 'pgadmin' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'service { "docker": }' }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('pgadmin') }
        it { is_expected.to contain_file('/var/lib/pgadmin').with(
          'ensure' => 'directory',
          'owner'  => '5050',
        )}
        it { is_expected.to contain_docker__run('pgadmin') }
      end

      context 'with custom port' do
        let(:params) { { port: 9090 } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_docker__run('pgadmin').with(
          'ports' => ['9090:80'],
        )}
      end

      context 'with server connections' do
        let(:params) do
          {
            server_connections: {
              'production' => {
                'host'     => 'db.example.com',
                'username' => 'dbadmin',
              }
            }
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/var/lib/pgadmin/servers.json') }
      end
    end
  end
end
