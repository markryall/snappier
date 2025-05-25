# frozen_string_literal: true

require_relative "file_persistence"

module Snappier
  module Registry
    def self.reset
      @for_class_name = {}
      @persistence = nil
    end

    def self.all
      @for_class_name
    end

    def self.register_persistence(instance)
      @persistence = instance
    end

    def self.persistence
      @persistence || FilePersistence.new
    end

    def self.register(map)
      @for_class_name ||= {}
      map.each_key do |key|
        @for_class_name[key] = map[key]
      end
    end

    def self.for_entity(entity)
      @for_class_name ||= {}
      class_name = @for_class_name[entity.class.name]
      return unless class_name

      class_name.split("::").reduce(Object) { |acc, elem| acc.const_get(elem) }
    end
  end
end
