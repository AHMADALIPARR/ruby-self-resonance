# SPDX-License-Identifier: LicenseRef-NON-AI-MPL-2.0
# Copyright (C) 2026 SnapKitty Collective
# frozen_string_literal: true

# Resonance Dashboard — Sinatra front end for the Ruby Self-Resonance Stack.
#
# Wires the verbatim RubySelfResonance::PermissionRuntime (../ruby_self_resonance.rb)
# to a web dashboard: live coherence / resonance state, action authorization,
# information folding, and the append-only field diary.
#
# The supplied module calls Time#iso8601, which lives in Ruby's `time`
# stdlib — required here (our file, not theirs) so their code stays verbatim.

require "time"
require "sinatra/base"
require_relative "../ruby_self_resonance"

class ResonanceDashboard < Sinatra::Base
  set :views, File.expand_path("views", __dir__)
  set :public_folder, File.expand_path("public", __dir__)

  DEFAULT_INTENT = [1.0, 0.8, 0.6, 0.9].freeze

  configure do
    set :runtime, RubySelfResonance::PermissionRuntime.new(DEFAULT_INTENT)
  end

  helpers do
    def runtime
      settings.runtime
    end

    def fmt(n)
      n.is_a?(Float) ? format("%.4f", n) : n.to_s
    end
  end

  get "/" do
    @state = runtime.state
    @policy = runtime.policy
    erb :index
  end

  post "/authorize" do
    vector = params[:vector].to_s.split(",").map { |v| Float(v.strip) }
    action = RubySelfResonance::ActionVector.new(
      name: (params[:name].to_s.strip.empty? ? "anonymous" : params[:name].strip).to_sym,
      vector: vector,
      entropy_cost: params[:entropy_cost].to_f,
      purpose: params[:purpose].to_f,
      risk: params[:risk].to_f,
      metadata: { source: "dashboard" }
    )
    begin
      @decision = runtime.authorize(action)
      @error = nil
    rescue ArgumentError => e
      @decision = nil
      @error = "Dimension mismatch: #{e.message} (intent is #{DEFAULT_INTENT.length}-dimensional)"
    end
    @state = runtime.state
    @policy = runtime.policy
    erb :index
  end

  post "/fold" do
    times = params[:times].to_i
    times = 1 if times < 1
    times = 200 if times > 200
    @fold_results = []
    times.times do
      begin
        @fold_results << runtime.fold(
          purpose_vector: params[:purpose_vector].to_f,
          entropy_friction: params[:entropy_friction].to_f
        )
      rescue RubySelfResonance::DissonanceOverride => e
        @fold_results << { status: :dissonance, message: e.message }
      end
    end
    @state = runtime.state
    @policy = runtime.policy
    erb :index
  end

  get "/diary" do
    @events = runtime.intent_core.field_diary.events
    erb :diary
  end

  post "/reset" do
    settings.runtime = RubySelfResonance::PermissionRuntime.new(DEFAULT_INTENT)
    redirect "/"
  end
end
