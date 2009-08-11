require 'codenote/models'
module CodeNote
  class Application < Sinatra::Default

    set :root, CodeNote.root
    set :app_file, __FILE__
    set :views, CodeNote.root_path_to('views')

    def presentation
      @presentaion ||= Presentation.current
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
      @slide = presentation.slide(slide_number)#, :presenter => presenter?)
      @next_slide = presentation.slide_after(slide_number)
      @previous_slide = presentation.slide_before(slide_number)
      haml :slide
    end



  end
end

