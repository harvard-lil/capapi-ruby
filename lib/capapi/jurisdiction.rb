# frozen_string_literal: true

module Capapi
  class Jurisdiction < APIResource
    extend Capapi::APIOperations::List
    OBJECT_NAME = "jurisdiction".freeze

    def cases(params = {}, opts = {})
      opts = @opts.merge(Util.normalize_opts(opts))
      Case.list(params.merge(jurisdiction: slug), opts)
    end
  end
end
