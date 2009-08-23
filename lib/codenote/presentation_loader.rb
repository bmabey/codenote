require 'codenote/models'
module CodeNote
  class PresentationLoader
    def self.setup(presentation_content)
      Presentation.current = PresentationLoader.new(presentation_content).presentation
    end

    def initialize(presentation_content)
      @presentation_content = presentation_content
      extract_classes
      @title = extract('TITLE')
      @presenter = extract('PRESENTER')
      ensure_first_slide_is_marked

    end

    def presentation
      Presentation.new(
        :title => @title,
        :presenter => @presenter,
        :slides => slides
      )
    end

    def slides
      [].tap do |slides|
        @presentation_content.each_line do |line|
          if line =~ /^!SLIDE$/
            slides << Slide.new(:classes => @classes.shift, :source => "")
          else
            slides.last.source << line
          end
        end
      end
    end

    private

    def ensure_first_slide_is_marked
      unless @presentation_content.match(/(.*)$/)[1] == "!SLIDE"
        @presentation_content = "!SLIDE\n" + @presentation_content
      end
    end

    def extract(keyword)
      @presentation_content.sub!(/^!#{keyword}\s+(.*)$\n/,'') ? $1 : ''
    end

    def extract_classes
      @classes = []
      @presentation_content.gsub!(/^!SLIDE[^\w]([a-z\s]*)$/) do |_|
        @classes << $1
        "!SLIDE"
      end
      @classes
    end

  end

end
