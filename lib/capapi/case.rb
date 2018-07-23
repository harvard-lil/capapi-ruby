# frozen_string_literal: true

module Capapi
  class Case < APIResource
    extend Capapi::APIOperations::List
    OBJECT_NAME = "case".freeze

    def reporter(opts = {})
      opts = @opts.merge(Util.normalize_opts(opts))
      Reporter.retrieve(Util.extract_id(reporter_url), opts)
    end

    def volume(opts = {})
      opts = @opts.merge(Util.normalize_opts(opts))
      Volume.retrieve(Util.extract_id(volume_url), opts)
    end

    private

    def self.transform_values(values)
      values[:reporter_full_name] = values.delete(:reporter)
      values
    end
  end
end
