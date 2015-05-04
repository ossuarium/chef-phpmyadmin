require 'spec_helper'

describe "phpmyadmin::default" do
  describe command('ls -al /') do
    its(:stdout) { should match(/bin/) }
  end
end
