require 'spec_helper'

describe "Static pages" do

  describe "Home page" do
    before { visit '/static_pages/home' }
    
    it "should have the content 'Memcached SaaS'" do
      page.should have_selector('h1', text: 'Get your Memcached')      
      page.should have_selector('title', text: 'Memcached Server')      
    end
  end

  describe "About page" do
    before { visit '/static_pages/about' }
    
    it "should have the content 'Memcached SaaS'" do
      page.should have_selector('h1', text: 'About this project')
      page.should have_selector('title', text: 'About this project')      
    end
  end

end
