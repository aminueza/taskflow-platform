# frozen_string_literal: true

require 'spec_helper'

describe 'bastion_users' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('bastion_users') }
        it { is_expected.to contain_group('admin-users').with_ensure('present') }
        it { is_expected.to contain_file('/etc/sudoers.d/admin-users').with(
          'ensure' => 'file',
          'mode'   => '0440',
        )}
      end

      context 'with users defined' do
        let(:params) do
          {
            users: {
              'testuser' => {
                'ensure'   => 'present',
                'uid'      => 2001,
                'ssh_keys' => ['ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...'],
                'groups'   => ['admin-users'],
              }
            }
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_bastion_users__user('testuser') }
      end

      context 'with manage_sudo disabled' do
        let(:params) { { manage_sudo: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_file('/etc/sudoers.d/admin-users') }
      end
    end
  end
end
