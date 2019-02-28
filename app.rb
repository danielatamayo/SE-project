require "sinatra"
require_relative "authentication.rb"
require "data_mapper"
require 'aws-sdk'
require 'aws-sdk-resources'
require "dotenv"
Dotenv.load

#the following urls are included in authentication.rb
# GET /login
# GET /logout
# GET /sign_up

# authenticate! will make sure that the user is signed in, if they are not they will be redirected to the login page
# if the user is signed in, current_user will refer to the signed in user object.
# if they are not signed in, current_user will be nil



if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
end

class Item
    include DataMapper::Resource
    property :id, Serial
    property :name, String
    property :body, Text
    property :image, String
    property :price, Float
    property :created_at, DateTime
    property :user_id, Integer

    def user
    	return User.first(id: user_id)
    end

end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
Item.auto_upgrade!

get "/" do
	@items = Item.all
	erb :index
end


get "/dashboard" do
	@items = Item.all
	authenticate!
	erb :dashboard


end

get "/new" do
	authenticate!
	erb :new
end

post "/sell" do
	n = params["name"]
	b = params["body"]
	f = params["price"]
	i = params["image"]

	p = Item.new
	p.name = n
	p.body = b
	p.price = f
	p.image = i
	p.user_id = current_user.id
	#p.created_at = Time.now.to_s

	p.user_id = current_user.id

	p.save
	#return "created new item"
	authenticate!

	redirect '/'
end

get"/upload" do
	erb :upload_pic
end

post "/aws" do
S3_ACCESS_ID = "AKIAINAQHE3XTJOMZD6Q"
S3_SECRET_KEY = "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"
S3_BUCKET = "softwareengineeringprojectbucket"
 s3 = AWS::S3.new(
 :access_key_id => ENV['S3_ACCESS_ID'],
 :secret_access_key => ENV['S3_SECRET_KEY']
 )
BUCKET = s3.buckets[ENV['S3_BUCKET']]
end

#get "/buy" do
#	"Item bought. Thank you for using EzMarket"
#end