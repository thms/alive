class Utilities

  def self.deep_clone(object)
    Marshal.load(Marshal.dump(object))
  end
end
