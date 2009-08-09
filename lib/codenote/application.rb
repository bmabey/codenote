module CodeNote
  class Application < Sinatra::Default
    get '/' do
      haml "%h2= 'Write some real code now.'"
    end
  end
end

