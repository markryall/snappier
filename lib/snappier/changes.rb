# frozen_string_literal: true

module Snappier
  module Changes
    def self.between(previous_state, current_state)
      {}.tap { |changes| append_changes(changes, previous_state, current_state) }
    end

    def self.append_changes(changes, previous_state, current_state, path = [])
      previous_state ||= {}
      current_state ||= {}
      keys = Set.new(previous_state.keys + current_state.keys)

      keys.each do |key|
        previous_value = previous_state[key]
        current_value = current_state[key]

        if previous_value.is_a?(Array) || current_value.is_a?(Array)
          append_changes_for_collections(changes, previous_value, current_value, path + [key])
          next
        end

        if previous_value.is_a?(Hash) || current_value.is_a?(Hash)
          previous_id = (previous_value || {}).delete("id")
          current_id = (current_value || {}).delete("id")

          if previous_id || current_id
            if previous_id == current_id
              append_changes(changes, previous_value, current_value, path + [key, previous_id])
            else
              append_changes(changes, previous_value, {}, path + [key, previous_id])
              append_changes(changes, {}, current_value, path + [key, current_id])
            end
          else
            append_changes(changes, previous_value, current_value, path + [key])
          end

          next
        end

        next if previous_value == current_value

        changes[path + [key]] = [previous_value, current_value]
      end
    end

    def self.append_changes_for_collections(changes, previous_collection, current_collection, path)
      ids = ids_for_collections(previous_collection, current_collection)

      if ids.empty?
        changes[path] = [previous_collection, current_collection] unless previous_collection == current_collection
        return
      end

      ids.each do |id|
        previous_value = (previous_collection || []).find { |r| r["id"] == id } || {}
        current_value = (current_collection || []).find { |r| r["id"] == id } || {}
        previous_value&.delete("id")
        current_value&.delete("id")

        append_changes(changes, previous_value, current_value, path + [id])
      end
    end

    def self.ids_for_collections(*collections)
      Set.new.tap do |ids|
        collections.each do |collection|
          (collection || []).each { |e| ids << e["id"] if e["id"] }
        end
      end
    end
  end
end
