class Presentation < ActiveRecord::Base
  has_many :slides, :order => 'number'


  def self.current=(presentation)
    if self.current && self.current.id != presentation.id
      self.current.update_attribute(:current, false)
    end

    presentation.current = true
    presentation.save!
  end

  def self.current
    self.find(:first, :include => [:slides])
  end

  def full_title
    @full_title ||= "#{title} - #{presenter}"
  end

  def add_slide(slide_image)
    slides << (slide =Slide.new(:image => slide_image))
    slide
  end

  def reset!
    slides.update_all({:viewable_by_audience => false})
  end

  def slide(number, options)
    return if (number-1) < 0
    if slide = slides[number-1]
      slide.viewable_by_audience! if options[:presenter]
    end
    slide
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

end

