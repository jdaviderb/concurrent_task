# frozen_string_literal: true

module ConcurrentTask
  class Scope < ::Concurrent::Atom
    alias update swap
  end
end
