require 'spec_helper'

describe Puppet::Type.type(:fme_repository) do
  before :each do
    Fme::Helper.stubs(:get_url).returns('www.example.com')
  end
  describe 'when validating attributes' do
    [:name, :provider].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end
    [:ensure, :description].each do |prop|
      it "should have a #{prop} property" do
        expect(described_class.attrtype(prop)).to eq(:property)
      end
    end
  end

  describe 'namevar validation' do
    it 'should have :name as its namevar' do
      expect(described_class.key_attributes).to eq([:name])
    end
  end

  describe 'when validating attribute values' do
    describe 'ensure' do
      [:present, :absent].each do |value|
        it "should support #{value} as a value to ensure" do
          expect { described_class.new(:name => 'example_user', :ensure => value) }.to_not raise_error
        end
      end
      it 'should not support other values' do
        expect { described_class.new(:name => 'example_user', :ensure => 'foo') }.to raise_error(Puppet::Error, %r{Invalid value})
      end
    end
  end

  describe 'autorequiring' do
    before :each do
      @settings_file = Puppet::Type.type(:file).new(:name => '/etc/fme_api_settings.yaml', :ensure => :file)
      @catalog = Puppet::Resource::Catalog.new
      @catalog.add_resource @settings_file
    end

    it 'should autorequire the settings file' do
      @resource = described_class.new(:ensure => :present, :name => 'repo1')
      @catalog.add_resource @resource
      req = @resource.autorequire
      expect(req.size).to eq(1)
      expect(req[0].target).to eq(@resource)
      expect(req[0].source).to eq(@settings_file)
    end
  end
end
