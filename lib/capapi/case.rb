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

    def self.transform_values(values)
      values[:reporter] = {id: Util.extract_id(values[:reporter_url]),
                           url: values.delete(:reporter_url),
                           full_name: values.delete(:reporter)}

      values[:volume] = {barcode: Util.extract_id(values[:volume_url]),
                         url: values.delete(:volume_url),
                         volume_number: values.delete(:volume_number)}

      values
    end
  end
end
