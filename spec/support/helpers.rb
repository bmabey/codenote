module SpecHelpers
  def given_presentation_content(content)
    @presentation_content = content.gsub(/^\s*\|/, '')
  end

  attr_reader :presentation_content
end
