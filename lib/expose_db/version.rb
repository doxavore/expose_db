module ExposeDB
  MAJOR   = 0
  MINOR   = 2
  TINY    = 0

  VERSION = [MAJOR, MINOR, TINY].join('.')

  def self.version
    VERSION
  end
end
