module CodeNote
  class Presentation < ActiveRecord::Base
    has_many :slides, :order => 'number'


    def self.current=(presentation)
      if self.current && self.current.id != presentation.id
        update_all('current = 0', :current => true)
      end

      presentation.make_first_slide_viewable
      presentation.current = true
      presentation.save!
    end

    def self.current
      self.find(:first, :include => [:slides], :conditions => {:current => true})
    end

    def make_first_slide_viewable
      slides.first.viewable_by_audience! if slides.first
    end

    def reset!
      slides.update_all({:viewable_by_audience => false})
    end

    def slide(number, options = {})
      return if (number-1) < 0
      return unless slide = slides[number-1]
      if options[:presenter]
        slide.viewable_by_audience!
        slide
      else
        slide.viewable_by_audience? ? slide : no_peeking_slide
      end
    end

    def slide_after(number)
      number + 1 unless number == slides.size
    end

    def slide_before(number)
      number - 1 unless (number > slides.size) || number == 1
    end

    def latest_slide
      slides.find(:first, :conditions => {:viewable_by_audience => true}, :order => 'number DESC') || slides.first
    end

    private

    def next_slide_image
      slides.size + 1
    end

    def no_peeking_slide
      Slide.new(:source => "# No Peeking!", :classes => "no_peeking")
    end

  end
end
