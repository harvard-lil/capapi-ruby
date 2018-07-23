# frozen_string_literal: true

module Capapi
  class Reporter < APIResource
    extend Capapi::APIOperations::List
    OBJECT_NAME = "reporter".freeze

    def cases(params = {}, opts = {})
      opts = @opts.merge(Util.normalize_opts(opts))
      Case.list(params.merge(reporter: id), opts)
    end
  end
end
