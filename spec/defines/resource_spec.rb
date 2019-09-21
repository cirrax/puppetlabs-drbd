require 'spec_helper'

describe 'drbd::resource', type: :define do
  let(:title) { 'mock_drbd_resource' }
  let(:default_facts) do
    { concat_basedir: '/dne' }
  end
  let(:default_params) do
    {
      disk: '/dev/mock_disk',
      initial_setup: true,
      host1: 'mock_primary',
      host2: 'mock_secondary',
      ip1: '10.16.0.1',
      ip2: '10.16.0.2',
      ha_primary: false
    }
  end

  context 'DRBD metadisk' do
    describe 'defaults to internalr' do
      let(:params) do
        default_params
      end

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').with_content(%r{^\s*flexible-meta-disk internal;$})
      }
    end
    describe 'set external metadisk' do
      let(:params) do
        {
          metadisk: '/dev/vg00/drbd-meta[0]'
        }.merge(default_params)
      end

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').with_content(%r{^\s*flexible-meta-disk \/dev\/vg00\/drbd-meta\[0\];$})
      }
    end
  end

  context 'initialization of DRBD metadata' do
    describe 'with initialize::false' do
      let :params do
        {
          initialize: false
        }.merge(default_params)
      end

      it { is_expected.not_to contain_exec('initialize DRBD metadata for mock_drbd_resource') }
    end
    describe 'with initialize::true' do
      let :params do
        {
          initialize: true
        }.merge(default_params)
      end

      it { is_expected.to contain_exec('initialize DRBD metadata for mock_drbd_resource') }
    end
  end

  context 'handlers_parameters' do
    describe 'with no handlers' do
      let(:params) do
        default_params
      end

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').without_content(%r{^\s*handlers \{$})
      }
    end
    describe 'with a set value' do
      let :params do
        {
          'handlers_parameters' =>
            {
              'split-brain' => '"/usr/lib/drbd/notify-split-brain.sh"'
            }
        }.merge(default_params)
      end

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').with_content(%r{^\s*handlers \{\n\s*split-brain "\/usr\/lib\/drbd\/notify-split-brain.sh";$})
      }
    end
  end

  context 'startup_parameters' do
    describe 'with no startup' do
      let(:params) do
        default_params
      end

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').without_content(%r{^\s*startup \{$})
      }
    end
    describe 'with a set value' do
      let :params do
        {
          'startup_parameters' =>
            {
              'wfc-timeout' => 0
            }
        }.merge(default_params)
      end

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').with_content(%r{^\s*startup \{\n\s*wfc-timeout 0;$})
      }
    end
  end
  context 'syncer config: verify_alg and rate' do
    describe 'with default values' do
      let(:params) do
        default_params
      end

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').with_content(%r{^\s*syncer \{\n\s*verify-alg crc32c;$})
      }
      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').without_content(%r{^\s*rate.*;$})
      }
    end
    describe 'with rate of 1M' do
      let :params do
        {
          rate: '1M'
        }.merge(default_params)
      end

      it {
        is_expected.to contain_concat__fragment('mock_drbd_resource drbd header').with_content(%r{^\s*syncer \{\n.*\s*rate 1M;$})
      }
    end
  end
end
# it { pp catalogue.resources }
