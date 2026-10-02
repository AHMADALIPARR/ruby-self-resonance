# SPDX-License-Identifier: LicenseRef-NON-AI-MPL-2.0
# Copyright (C) 2026 SnapKitty Collective
# frozen_string_literal: true

module RubySelfResonance
  VERSION = "0.1.0"

  # --------------------------------------------------------------------------
  # Deterministic primitives
  # --------------------------------------------------------------------------

  module MathKernel
    module_function

    def clamp(value, min, max)
      [[value.to_f, min].max, max].min
    end

    def normalize(value, max)
      return 0.0 if max.to_f.zero?

      clamp(value.to_f / max.to_f, 0.0, 1.0)
    end

    def distance(a, b)
      a = Array(a).map(&:to_f)
      b = Array(b).map(&:to_f)

      raise ArgumentError, "Vector dimensions must match" unless a.length == b.length

      Math.sqrt(
        a.zip(b).sum { |x, y| (x - y)**2 }
      )
    end

    def cosine_similarity(a, b)
      a = Array(a).map(&:to_f)
      b = Array(b).map(&:to_f)

      raise ArgumentError, "Vector dimensions must match" unless a.length == b.length

      numerator = a.zip(b).sum { |x, y| x * y }
      magnitude_a = Math.sqrt(a.sum { |x| x * x })
      magnitude_b = Math.sqrt(b.sum { |x| x * x })

      return 0.0 if magnitude_a.zero? || magnitude_b.zero?

      numerator / (magnitude_a * magnitude_b)
    end
  end

  # --------------------------------------------------------------------------
  # Immutable action representation
  # --------------------------------------------------------------------------

  ActionVector = Struct.new(
    :name,
    :vector,
    :entropy_cost,
    :purpose,
    :risk,
    :metadata,
    keyword_init: true
  ) do
    def initialize(**kwargs)
      super

      self.vector = Array(vector).map(&:to_f).freeze
      self.entropy_cost = entropy_cost.to_f
      self.purpose = purpose.to_f
      self.risk = risk.to_f
      self.metadata = (metadata || {}).dup.freeze

      freeze
    end
  end

  # --------------------------------------------------------------------------
  # Decision result
  # --------------------------------------------------------------------------

  Decision = Struct.new(
    :allowed,
    :reason,
    :coherence,
    :entropy_delta,
    :risk,
    :timestamp,
    :action,
    keyword_init: true
  ) do
    def allowed?
      allowed == true
    end

    def denied?
      !allowed?
    end

    def to_h
      {
        allowed: allowed,
        reason: reason,
        coherence: coherence,
        entropy_delta: entropy_delta,
        risk: risk,
        timestamp: timestamp,
        action: action
      }
    end
  end

  # --------------------------------------------------------------------------
  # Append-only field diary
  # --------------------------------------------------------------------------

  class FieldDiary
    attr_reader :events

    def initialize
      @events = []
    end

    def record(type, payload = {})
      event = {
        sequence: @events.length + 1,
        type: type,
        timestamp: Time.now.utc.iso8601(6),
        payload: deep_freeze(payload)
      }

      @events << event.freeze
      event
    end

    def last(count = 1)
      @events.last(count)
    end

    def count
      @events.length
    end

    private

    def deep_freeze(object)
      case object
      when Hash
        object.each { |key, value| deep_freeze(key); deep_freeze(value) }
      when Array
        object.each { |value| deep_freeze(value) }
      end

      object.freeze
    end
  end

  # --------------------------------------------------------------------------
  # Intent simulator
  # --------------------------------------------------------------------------

  class IntentSimCore
    attr_reader :coherence_score,
                :emotional_state,
                :field_diary,
                :initial_intent

    def initialize(initial_intent)
      @initial_intent = Array(initial_intent).map(&:to_f).freeze
      @coherence_score = calculate_initial_resonance(@initial_intent)
      @field_diary = FieldDiary.new
      @emotional_state = :stable
      @action_count = 0

      @field_diary.record(
        :initialization,
        coherence: @coherence_score,
        intent: @initial_intent
      )
    end

    def evaluate_action_permission(action_vector)
      action = normalize_action(action_vector)
      entropy_delta = calculate_entropy_impact(action)

      coherence = calculate_action_coherence(action)

      if coherence > entropy_delta && action.risk <= coherence
        execute_sovereign_logic(action, coherence, entropy_delta)
      else
        log_dissonance_event(
          "Action denied: Exceeds Self-Reflection Threshold",
          action,
          coherence,
          entropy_delta
        )
      end
    end

    def update_intent(new_intent)
      @initial_intent = Array(new_intent).map(&:to_f).freeze
      @coherence_score = calculate_initial_resonance(@initial_intent)

      @field_diary.record(
        :intent_update,
        coherence: @coherence_score,
        intent: @initial_intent
      )

      @coherence_score
    end

    private

    def normalize_action(action)
      return action if action.is_a?(ActionVector)

      ActionVector.new(
        name: action[:name] || "anonymous",
        vector: action[:vector] || @initial_intent,
        entropy_cost: action[:entropy_cost] || action[:entropy_friction] || 0.1,
        purpose: action[:purpose] || action[:purpose_vector] || 1.0,
        risk: action[:risk] || 0.0,
        metadata: action[:metadata] || {}
      )
    end

    def calculate_initial_resonance(intent)
      magnitude = Math.sqrt(
        intent.sum { |value| value**2 }
      )

      MathKernel.clamp(magnitude, 0.0, 100.0)
    end

    def calculate_entropy_impact(action)
      structural_friction = MathKernel.clamp(action.entropy_cost, 0.0, 100.0)
      purpose = [action.purpose, 0.000001].max

      structural_friction / purpose
    end

    def calculate_action_coherence(action)
      similarity =
        MathKernel.cosine_similarity(@initial_intent, action.vector)

      baseline =
        MathKernel.clamp(@coherence_score / 100.0, 0.0, 1.0)

      ((similarity + 1.0) / 2.0) * baseline * 100.0
    end

    def execute_sovereign_logic(action, coherence, entropy_delta)
      @action_count += 1

      event = @field_diary.record(
        :permission_granted,
        action: action.name,
        coherence: coherence,
        entropy_delta: entropy_delta,
        risk: action.risk,
        count: @action_count
      )

      Decision.new(
        allowed: true,
        reason: "coherence_threshold_satisfied",
        coherence: coherence,
        entropy_delta: entropy_delta,
        risk: action.risk,
        timestamp: event[:timestamp],
        action: action.name
      )
    end

    def log_dissonance_event(reason, action, coherence, entropy_delta)
      event = @field_diary.record(
        :permission_denied,
        reason: reason,
        action: action.name,
        coherence: coherence,
        entropy_delta: entropy_delta,
        risk: action.risk
      )

      Decision.new(
        allowed: false,
        reason: reason,
        coherence: coherence,
        entropy_delta: entropy_delta,
        risk: action.risk,
        timestamp: event[:timestamp],
        action: action.name
      )
    end
  end

  # --------------------------------------------------------------------------
  # Resonance engine
  # --------------------------------------------------------------------------

  class MezquiaResonanceEngine
    RESONANCE_CONSTANT = 1.0 / 13.0

    attr_reader :memory_creases,
                :crystallization_density,
                :self_reflection_threshold,
                :intent_vector,
                :history

    def initialize(initial_intent_vector)
      @intent_vector = Array(initial_intent_vector).map(&:to_f).freeze
      @memory_creases = 0
      @crystallization_density = 0.0
      @self_reflection_threshold = 44.0
      @history = []
    end

    def fold_information(action_payload)
      payload = symbolize(action_payload)

      @memory_creases += 1

      density_delta =
        calculate_crystallization_density(payload)

      @history << {
        sequence: @memory_creases,
        density_delta: density_delta,
        density: @crystallization_density,
        payload: payload.freeze,
        timestamp: Time.now.utc.iso8601(6)
      }.freeze

      if sovereign_alignment?
        execute_intent_nexus(payload)
      else
        raise(
          DissonanceOverride,
          "Crystallization requires Field Correction."
        )
      end
    end

    def sovereign_alignment?
      @crystallization_density > 0 &&
        @crystallization_density >= @self_reflection_threshold
    end

    def reset_field!
      @memory_creases = 0
      @crystallization_density = 0.0
      @history.clear
      true
    end

    def field_state
      {
        memory_creases: @memory_creases,
        crystallization_density: @crystallization_density.round(6),
        threshold: @self_reflection_threshold,
        aligned: sovereign_alignment?
      }
    end

    private

    def calculate_crystallization_density(payload)
      system_entropy =
        [payload.fetch(:entropy_friction, 0.1).to_f, 0.000001].max

      meaning_bloom =
        payload.fetch(:purpose_vector, 1.0).to_f

      raw_density =
        (meaning_bloom / system_entropy) * RESONANCE_CONSTANT

      delta = raw_density.round(6)

      @crystallization_density += delta

      delta
    end

    def execute_intent_nexus(payload)
      result = {
        status: :executed,
        mechanism: :intent_nexus,
        density: @crystallization_density.round(6),
        payload: payload
      }

      puts(
        "[RESONANCE_LOG] Coherence locked. " \
        "Executing Field Action."
      )

      result
    end

    def symbolize(hash)
      hash.each_with_object({}) do |(key, value), result|
        result[key.to_sym] = value
      end
    end
  end

  # --------------------------------------------------------------------------
  # Policy layer
  # --------------------------------------------------------------------------

  class CoherencePolicy
    attr_reader :minimum_coherence,
                :maximum_entropy,
                :maximum_risk

    def initialize(
      minimum_coherence: 50.0,
      maximum_entropy: 1.0,
      maximum_risk: 0.5
    )
      @minimum_coherence = minimum_coherence.to_f
      @maximum_entropy = maximum_entropy.to_f
      @maximum_risk = maximum_risk.to_f
    end

    def permit?(coherence:, entropy:, risk:)
      coherence >= @minimum_coherence &&
        entropy <= @maximum_entropy &&
        risk <= @maximum_risk
    end

    def explain(coherence:, entropy:, risk:)
      failures = []

      failures << :coherence if coherence < @minimum_coherence
      failures << :entropy if entropy > @maximum_entropy
      failures << :risk if risk > @maximum_risk

      failures
    end
  end

  # --------------------------------------------------------------------------
  # Complete permission runtime
  # --------------------------------------------------------------------------

  class PermissionRuntime
    attr_reader :intent_core,
                :resonance_engine,
                :policy

    def initialize(
      initial_intent,
      policy: CoherencePolicy.new
    )
      @intent_core = IntentSimCore.new(initial_intent)
      @resonance_engine =
        MezquiaResonanceEngine.new(initial_intent)
      @policy = policy
    end

    def authorize(action)
      normalized =
        action.is_a?(ActionVector) ?
          action :
          ActionVector.new(**action)

      entropy =
        normalized.entropy_cost /
        [normalized.purpose, 0.000001].max

      coherence =
        MathKernel.cosine_similarity(
          @intent_core.initial_intent,
          normalized.vector
        )

      coherence =
        ((coherence + 1.0) / 2.0) * 100.0

      allowed =
        @policy.permit?(
          coherence: coherence,
          entropy: entropy,
          risk: normalized.risk
        )

      if allowed
        @intent_core.evaluate_action_permission(normalized)
      else
        Decision.new(
          allowed: false,
          reason: @policy.explain(
            coherence: coherence,
            entropy: entropy,
            risk: normalized.risk
          ),
          coherence: coherence,
          entropy_delta: entropy,
          risk: normalized.risk,
          timestamp: Time.now.utc.iso8601(6),
          action: normalized.name
        )
      end
    end

    def fold(payload)
      @resonance_engine.fold_information(payload)
    end

    def state
      {
        intent_coherence: @intent_core.coherence_score,
        emotional_state: @intent_core.emotional_state,
        resonance: @resonance_engine.field_state,
        diary_events: @intent_core.field_diary.count
      }
    end
  end

  class DissonanceOverride < StandardError
  end
end


# =============================================================================
# Example
# =============================================================================

runtime =
  RubySelfResonance::PermissionRuntime.new(
    [1.0, 0.8, 0.6, 0.9]
  )

action =
  RubySelfResonance::ActionVector.new(
    name: :compile_kernel,
    vector: [1.0, 0.7, 0.5, 0.8],
    entropy_cost: 0.20,
    purpose: 1.0,
    risk: 0.10,
    metadata: {
      subsystem: :kernel,
      operation: :compile
    }
  )

decision = runtime.authorize(action)

puts decision.to_h
puts runtime.state
