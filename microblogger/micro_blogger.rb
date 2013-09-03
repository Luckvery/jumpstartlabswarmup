require 'jumpstart_auth'
require 'bitly'
require 'klout'

#  I kept getting "certificate verify failed (Twitter::Error::ClientError)"
#  Every time I tried to call my tweet method. Found a solution on SO. 
#  The following disables the SSL security but it allows you to process
#  with troubleshooting. The underlying issue is an outdated SSL.
#  http://bit.ly/15tfOdX
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing"
    @client = JumpstartAuth.twitter

    Bitly.use_api_version_3

    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
 
  end

  def shorten(original_url)
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    return bitly.shorten(original_url).short_url
  end

  def screen_names_following_auth_user
    @client.followers.collect{|f| f.screen_name}
  end

  def friends_of_auth_user
    @client.friends.sort_by {|friend| friend.screen_name.downcase}
  end

  def friends_of_auth_user_by_screen_name_and_klout
    names = friends_of_auth_user.collect{ |f| f.screen_name}  
    names_and_klout = Hash[names.collect { |name| [name, klout(name)] }]
    names_and_klout.sort_by {|k,v| v.to_f }.reverse
  end

  def klout(screen_name)
    begin
      identity = Klout::Identity.find_by_screen_name(screen_name)
      user = Klout::User.new(identity.id)
      user.score.score.round(2)
    rescue
      "not found"
    end
  end

  def klout_score_of_friends_desc
    friends = friends_of_auth_user_by_screen_name_and_klout
    friends.each do |name, klout|
      puts "#{name}'s klout score is #{klout}" 
    end
  end

  def everyones_last_tweet
    friends = friends_of_auth_user

    friends.each do |friend|

      # find each friend's last message
      last_tweet = friend.status.text

      # find time of last tweet
      timestamp = friend.status.created_at.strftime("%A, %b, %d")

      # print each friend's screen_name and time stamp
      puts "*** #{friend.screen_name} said at #{timestamp} ***"

      # print each friend's last message
      puts "#{last_tweet}"
      puts ""  # Just print a blank line to separate people

    end
  end


  def spam_my_followers(message)
    screen_names = screen_names_following_auth_user
    screen_names.each do |screen_name|
       @client.direct_message_create(screen_name, message)
    end
  end

  def isFollower?(target)
   screen_names = people_following_auth_user 
   screen_names.include?(target)
  end

  def dm(target, message)
    if isFollower?(target) 
     puts "Trying to send #{target} a direct message:"
      @client.direct_message_create(target, message)
    else
      puts "You may only direct message users who are following you"
    end
  end 


  def tweet(message)
   if message.length > 140
    puts "messages may not be more than 140 charachters!!!"
   else
    @client.update(message)
   end
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    input = ""
    while input != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]

      case command 
        when "q"     then puts "Peace out good bye!!!"
        when "t"     then tweet(parts[1..-1].join(" "))
        when "dm"    then dm(parts[1], parts[2..-1].join(" "))
        when "spam"  then spam_my_friends(parts[1..-1].join(" "))
        when "elt"   then everyones_last_tweet()
        when "s"     then shorten(parts[1..-1].join(" "))
        when "klout" then klout_score_of_friends_desc() 
        when "turl"  then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
        else
          puts "Sorry, I have no idea how to process #{command}"
      end
    end
  end
end

blogger = MicroBlogger.new
blogger.run

