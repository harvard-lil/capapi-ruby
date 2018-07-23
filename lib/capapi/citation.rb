# frozen_string_literal: true

module Capapi
  class Citation < APIResource
    extend Capapi::APIOperations::List
    OBJECT_NAME = "citation".freeze

    def cases(params = {}, opts = {})
      opts = @opts.merge(Util.normalize_opts(opts))
      Case.list(params.merge(cite: normalized_cite), opts)
    end
  end
end
