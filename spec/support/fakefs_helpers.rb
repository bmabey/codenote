module FakeFSHelpers
  def use_fakefs
    before(:each) do
      FakeFS.activate!
    end

    after(:each) do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
    end
  end
end
