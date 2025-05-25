# frozen_string_literal: true

module Snappier
  module Who
    def self.current=(value)
      Thread.current[:snappier_who_current] = value
    end

    def self.current
      Thread.current[:snappier_who_current]
    end
  end
end
