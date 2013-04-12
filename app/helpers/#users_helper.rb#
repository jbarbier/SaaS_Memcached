require 'net/http'
require 'rubygems'
require 'json'

module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.email, class: "gravatar")
  end

  def my_public_ip
    @@ip ||= Net::HTTP.get_response(URI.parse("http://ifconfig.me/ip")).body.chomp
  end

end
