require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')
require 'codenote/models'

describe Slide do
  it "should not be viewable by default" do
    Slide.new.should_not be_viewable_by_audience
  end

  describe '#viewable_by_audience!' do
    it "should make it viewable_by_audience and persist the change" do
      slide = Slide.create(:image => 'foo.png')

      slide.viewable_by_audience!
      slide.reload

      slide.should be_viewable_by_audience

    end
  end
end
