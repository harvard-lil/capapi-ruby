# frozen_string_literal: true

module Capapi
  class Case < APIResource
    extend Capapi::APIOperations::List
    OBJECT_NAME = "case".freeze

    def retrieve_casebody(body_format = nil)
      @retrieve_params["full_case"] = true
      @retrieve_params["body_format"] = body_format if body_format
      refresh
      casebody
    end

    # This gets overwritten once casebody is loaded
    def casebody
      retrieve_casebody
    end

    def casebody_loaded?
      @values[:casebody] != nil
    end

    private

    def transform_values(values)
      values[:reporter][:id] = Util.extract_id(values[:reporter][:url])
      values[:volume][:barcode] = Util.extract_id(values[:volume][:url])
      values
    end
  end
end
