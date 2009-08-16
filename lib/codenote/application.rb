require 'codenote/models'
module CodeNote
  class Application < Sinatra::Default

    enable :sessions
    set :root, CodeNote.root
    set :app_file, __FILE__
    set :views, CodeNote.root_path_to('views')

    def presentation
      @presentaion ||= Presentation.current
    end

    def presenter?
      session[:presenter] == true
    end

    get '/' do
      if presentation
        redirect "/slides/#{presentation.latest_slide.number}"
      else
        "No presentation has been loaded!"
      end
    end

    get %r{/slides/(\d+)} do
      slide_number = params[:captures].first.to_i
      @slide = presentation.slide(slide_number, :presenter => presenter?)
      @next_slide = presentation.slide_after(slide_number)
      @previous_slide = presentation.slide_before(slide_number)
      haml :slide
    end

    get '/secret_login' do
      haml :login, :layout => :admin
    end

    post '/secret_login' do
      if params['password'] == 'presentation_zen09'
        session[:presenter] = true
        redirect '/'
      else
        haml :login,:layout => :admin
      end
    end

    get '/reset' do
      if presenter?
        presentation.reset!
      end
      redirect "/slides/1"
    end

    get '/logout' do
      session[:presenter] = false
      redirect '/'
    end

  end
end

