# Include the gem
require 'gattica'

class Post < ActiveRecord::Base
  attr_accessible :text, :title

  ##==================================================
  ## GATTICA
  ## https://github.com/chrisle/gattica
  ## http://www.seerinteractive.com/blog/google-analytics-data-export-api-with-rubygattica/
  ##==================================================
  p "---------------------------------"
  p "GATTICA"

  ## Login
  ga = Gattica.new({ 
      :email => 'miriya.test@gmail.com', 
      :password => 'miriyatest'
  })
    
  mytoken = ga.token
  ## above line for session, like this 
  # ga = Gattica.new({ :token => my_token })

  
  ## Get a list of accounts
  accounts = ga.accounts
  
  ## Show the data
  # puts data.inspect
  
  ## Show information about accounts
  p "---------------------------------"
  p "Available profiles: " + accounts.count.to_s
  accounts.each do |account|
    p "   --> " + account.title
    p "   last updated: " + account.updated.inspect
    p "   web property: " + account.web_property_id
    p "     profile id: " + account.profile_id.inspect
    p "          goals: " + account.goals.count.inspect
  end
  ga.profile_id = 66404880 
  
  ## Get the number of visitors by month from Jan 1st to April 1st.
  data_visitors = ga.get({ 
      :start_date   => '2012-10-01',
      :end_date     => '2012-12-31',
      :dimensions   => ['month', 'year'],
      :metrics      => ['visitors']
  })
  
  data_avgTimeOnSite = ga.get({ 
      :start_date   => '2012-10-01',
      :end_date     => '2012-12-31',
      :dimensions   => ['month', 'year'],
      :metrics      => ['avgTimeOnSite']
  })
  
  data_pageviews = ga.get({ 
      :start_date   => '2012-10-01',
      :end_date     => '2012-12-31',
      :dimensions   => ['month', 'year'],
      :metrics      => ['pageviews']
  })
  
  p "---------------------------------"
  p data_visitors.to_h['points'].to_json
  p "---------------------------------"
  p data_avgTimeOnSite.to_h['points'].to_json
  p "---------------------------------"
  p data_pageviews.to_h['points'].to_json
  p "---------------------------------"
  
  
  
  ##==================================================
  ## ANALYTICAL
  ## https://github.com/jkrall/analytical
  ##==================================================
  p "---------------------------------"
  p "ANALYTICAL" 
  
  
end