require './degree.rb'
require './TestFile'
require 'net/https'
require 'json'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


class Fetchdata
include ConnectionFind
#~ def initialize
 #~ @@data=[]
#~ end
$error=false
def getresponse(url)
   url = URI.parse(url)
   begin
   response = Net::HTTP.start(url.host, use_ssl: true) do |http|
     http.get url.request_uri, 'User-Agent' => 'MyLib v1.2'
   end
	case response
	when Net::HTTPRedirection
	when Net::HTTPSuccess
		 repo_info = JSON.parse response.body
	else
		  response.error!  
	  end
    rescue
          $error=true
	  p "Problem in response from the URL #{url}"
          return
    end
end
  

def verify_actors_directly_connected(response1,response2)
 
   movies1,movies2=[],[]
   response1["movies"].select{|x|movies1<<x["url"]}
   response2["movies"].select{|x|movies2<<x["url"]}   
   if (movies1 & movies2).empty?
	   return false
	   else
	   return true
   end

end

def connect_people(response,actor_2)	
	@arr=[]
	name=response["name"]
	movies=response["movies"]
	movies=movies[1..2]
	movies.each do |movie|
		response=getresponse(convert_to_url(movie["name"]))
		actors=response["cast"]
		actors=actors[1..2]
	        actors.each do |actor|
			connection(name,actor["name"]) #connect actor with current actor
			@arr<<actor["name"]
			if actor["name"]==actor_2
				@arr=[] 				
				return @arr								
                        end                       			
	      end
	    
    end
    return @arr
end

def convert_to_url(actor)
 name=actor.downcase.gsub(" ","-")
 url="https://data.moviebuff.com/"+name
 return url
 end


def manipulate_datas(actor_1,actor_2)
response1=getresponse(convert_to_url(actor_1))
response2=getresponse(convert_to_url(actor_2))
if !$error
	is_directly=verify_actors_directly_connected(response1,response2)
	if is_directly
		puts "directly connected"
	else  
		#actor1,actor2
		#get movies of actor1 and then get actors of each movie
		actors=connect_people(response1,actor_2)#list of actors from the movies of actor1  				
		actors && actors.each do |actor|
			response=getresponse(convert_to_url(actor))# repeat the process by getting actors from previoursly obtained actors
			repeat_actors=connect_people(response,actor_2)		
			break if repeat_actors.empty?
				repeat_actors && repeat_actors.each do  |repeat_actor|
					repeat_response=getresponse(convert_to_url(actor))	 			
				end		  
		end		
	end	
end	

end

fetch_data=Fetchdata.new()
fetch_data.manipulate_datas('Amitabh Bachchan','Sharmila Shetty')
p "Degree of seperation"
p fetch_data.connected?('Amitabh Bachchan','Sharmila Shetty')


#FOR EXAMPLE WITH STATIC DATA
#connection_find =Fetchdata.new()
#connection_find.connection('Amitabh Bachchan', 'Leonardo DiCaprio')
#connection_find.connection('Leonardo DiCaprio', 'Martin Scorsese')
#connection_find.connection('Martin Scorsese', 'Robert De Niro')  
#p connection_find.connected?('Amitabh Bachchan', 'Robert De Niro')

end