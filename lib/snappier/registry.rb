# frozen_string_literal: true

module Snappier
  module Registry
    def self.reset
      @for_class_name = {}
    end

    def self.all
      @for_class_name
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
