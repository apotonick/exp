module Disposable
  module Read
    module_function

    # Compute a nested hash from a nested twin, only considering readable properties along with their private name.
    def to_h(twin)
      ary = twin.class.definitions.collect do |dfn|
        next if dfn[:readable] == false

        value = twin.send(dfn[:name]) # TODO: use #[] interface.

        value = Disposable::Twin::PropertyProcessor.(dfn, value) { |twin| to_h(twin) } if dfn[:nested]

        [dfn[:private_name], value]
      end.compact

      Hash[ary]
    end

    def from_h(twin_class, hash)
      ary = twin_class.definitions.collect do |dfn|
        next if dfn[:readable] == false # FIXME: is that really what we want?

        value = hash[ dfn[:private_name] ]
        value ||= dfn[:default] # FIXME: what if we want nil? Also, optional? Do we need it>

        value = Disposable::Twin::PropertyProcessor.(dfn, value) { |twin| from_h(dfn[:nested], twin) } if dfn[:nested]

        [dfn[:private_name], value]
      end.compact

puts "yo"
pp ary

      twin_class.new(Hash[ary])
    end
  end
end
