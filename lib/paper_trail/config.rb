require 'singleton'

module PaperTrail
  class Config
    include Singleton
    attr_accessor :enabled, :serializer

    def initialize
      # Indicates whether PaperTrail is on or off.
      @enabled = true
      @serializer = PaperTrail::Serializers::Yaml
    end
  end
end
