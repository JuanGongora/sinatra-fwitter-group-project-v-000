require 'pry'

class TweetController < ApplicationController

  get '/tweets' do
    if logged_in?
      @user = User.find_by_id(session[:user_id])
      @tweets = Tweet.all
      erb :'tweets/tweets'
    else
      redirect to '/login'
    end
  end

  get '/tweets/new' do
    if logged_in?
      erb :'tweets/new'
    else
      redirect to '/login'
    end
  end

  get '/tweets/:id' do
    if logged_in?
      @tweet = Tweet.find_by_id(params[:id])
      erb :'/tweets/show'
    else
      redirect to '/login'
    end
  end

  get '/tweets/:id/edit' do
    @tweet = Tweet.find_by_id(params[:id])
    if logged_in?
      if current_user.username == twitter_user(@tweet)
        erb :'/tweets/edit'
      else
        flash[:message] = "You are not logged in as that user"
        redirect to '/tweets'
      end
    else
      redirect to '/login'
    end
  end

  post '/tweets' do
    @tweet = current_user.tweets.new(content: params[:content], time: Time.new.strftime("%Y-%m-%d %H:%M:%S"))

    if @tweet.valid? # http://guides.rubyonrails.org/active_record_validations.html
      @tweet.save
      redirect to '/tweets'
    else
      redirect to '/tweets/new'
    end
  end

  patch '/tweets/:id' do
    @tweet = Tweet.find_by_id(params[:id])
    #present? is an RoR method
    if params[:content].present? && current_user.username == twitter_user(@tweet)
      #I'm asking it for params instead of instance since it's a new value, not from called data of already stored @twitter
      @tweet.update(content: params[:content], time: "Updated on #{Time.new.strftime("%Y-%m-%d %H:%M:%S")}")

      flash[:message] = "Tweet has been updated"
      erb :'tweets/show'

    else
      redirect to "/tweets/#{params[:id]}/edit"
    end
  end

  delete '/tweets/:id/delete' do
    if logged_in?
      @tweet = Tweet.find_by_id(params[:id])

      if current_user == @tweet.user
        @tweet.destroy
        flash[:message] = "Tweet has been deleted"
      else
        flash[:message] = "You are not logged in as that user"
        redirect to '/tweets'
      end
    end

    redirect to '/login'
  end
end