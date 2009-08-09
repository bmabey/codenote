Given %r{^a file named "([^"]+)" with:$} do |file_name, content|
  create_file(file_name, content)
end

When %r{^I run "codenote(?: ([^"]+)|)"$} do |args|
  codenote args
end

When %r{^I run "codenote_load ([^"]+)"$} do |args|
  codenote_load args
end


#Then /^the (.*) should match (.*)$/ do |stream, string_or_regex|
  #written(stream).should smart_match(string_or_regex)
#end

#Then /^the (.*) should not match (.*)$/ do |stream, string_or_regex|
  #written(stream).should_not smart_match(string_or_regex)
#end

#Then /^the exit code should be (\d+)$/ do |exit_code|
  #if last_exit_code != exit_code.to_i
    #raise "Did not exit with #{exit_code}, but with #{last_exit_code}. Standard error:\n#{last_stderr}"
  #end
#end
