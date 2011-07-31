require ''

module Ruil

  module Skin

    @@skins = {
      :desktop => [],
      :mobile  => []
    }

    def self.call(body)
      body
    end

  end

end
