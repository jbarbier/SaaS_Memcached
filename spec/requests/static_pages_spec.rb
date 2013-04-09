require 'spec_helper'

describe "Static pages" do

  subject { page }

  describe "Home page" do
    before { visit root_path }

    it "should have the content 'Memcached SaaS'" do
      should have_selector('h1', text: 'Get your Memcached')
      should have_selector('title', text: full_title('Memcached Server'))      
    end
  end

  describe "About page" do
    before { visit about_path }
    
    it "should have the content 'About this project'" do
      should have_selector('h1', text: 'About this project')
      should have_selector('title', text: full_title('About this project'))      
    end
  end

end
