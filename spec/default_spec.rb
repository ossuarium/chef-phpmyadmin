require 'spec_helper'

describe 'phpmyadmin::default' do

  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
end
