# frozen_string_literal: true

module Capapi
  class Case < APIResource
    extend Capapi::APIOperations::List
    OBJECT_NAME = "case".freeze

    def casebody
      @retrieve_params["full_case"] = true
      refresh
      casebody
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
