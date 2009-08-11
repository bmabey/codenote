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
    end

    def presentation
      Presentation.new(
        :title => @title,
        :presenter => @presenter,
        :slides => slides
      )
    end

    def slides
      lines.map { |source| Slide.new(:source => source, :classes => @classes.shift) }
    end

    private

    def lines
      @lines ||= @presentation_content.split(/^!SLIDE$\n/).reject { |line| line.empty? }
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
