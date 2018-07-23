# frozen_string_literal: true

module Capapi
  class Court < APIResource
    extend Capapi::APIOperations::List
    OBJECT_NAME = "court".freeze

    def cases(params = {}, opts = {})
      opts = @opts.merge(Util.normalize_opts(opts))
      Case.list(params.merge(court: slug), opts)
    end
  end
end
