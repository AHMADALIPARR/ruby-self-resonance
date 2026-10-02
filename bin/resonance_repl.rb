#!/usr/bin/env ruby
# SPDX-License-Identifier: LicenseRef-NON-AI-MPL-2.0
# Copyright (C) 2026 SnapKitty Collective
# frozen_string_literal: true

# ============================================================
# RUBY SELF RESONANCE STACK
# Conceptual architecture of a Coherence-Based Permission Layer
# ============================================================

class IntentSimCore
  attr_accessor :coherence_score, :emotional_state, :field_diary
  attr_reader :engine

  def initialize(initial_intent)
    @initial_intent = initial_intent.to_s
    @coherence_score = calculate_initial_resonance(@initial_intent)
    @field_diary = []
    @emotional_state = :stable
    @engine = MezquiaResonanceEngine.new(@initial_intent)
    log_diary("Core initialized with intent: '#{@initial_intent}' (coherence=#{@coherence_score})")
  end

  # Replaces traditional RBAC/OAuth with thermodynamic alignment checks
  def evaluate_action_permission(action_vector)
    action_vector = normalize_vector(action_vector)
    entropy_delta = calculate_entropy_impact(action_vector)

    log_diary("Evaluating action: #{action_vector[:description] || action_vector.inspect}")

    if @coherence_score > entropy_delta
      execute_sovereign_logic(action_vector)
      true
    else
      log_dissonance_event("Action denied: Exceeds Self-Reflection Threshold (coherence=#{@coherence_score} ≤ delta=#{entropy_delta})")
      false
    end
  end

  # Convenience: fold information through the resonance engine
  def fold(purpose_vector: 1.0, entropy_friction: 0.1, description: nil)
    payload = {
      purpose_vector: purpose_vector.to_f,
      entropy_friction: entropy_friction.to_f,
      description: description || "fold##{@engine.memory_creases + 1}"
    }

    begin
      result = @engine.fold_information(payload)
      # Successful folds slightly raise coherence and stabilize emotion
      @coherence_score = (@coherence_score + (result[:density_gain] * 0.5)).round(4)
      @emotional_state = :resonant if @engine.sovereign?
      log_diary("Fold accepted → density=#{@engine.crystallization_density}, coherence=#{@coherence_score}")
      result
    rescue MezquiaResonanceEngine::DissonanceError => e
      @emotional_state = :dissonant
      @coherence_score = [@coherence_score - 1.5, 0.0].max.round(4)
      log_dissonance_event(e.message)
      nil
    end
  end

  def status
    {
      coherence_score: @coherence_score,
      emotional_state: @emotional_state,
      memory_creases: @engine.memory_creases,
      crystallization_density: @engine.crystallization_density,
      self_reflection_threshold:@engine.self_reflection_threshold,
      sovereign: @engine.sovereign?,
      diary_entries: @field_diary.size
    }
  end

  def diary(limit = 10)
    @field_diary.last(limit)
  end

  private

  def calculate_initial_resonance(intent)
    # Simple deterministic seed: length + character diversity, scaled into 0–20 range
    base = intent.length * 0.4
    diversity = intent.chars.uniq.size * 0.3
    (base + diversity + 5.0).clamp(1.0, 25.0).round(4)
  end

  def calculate_entropy_impact(vector)
    # Structural alignment vs computational friction
    complexity = (vector[:complexity] || 1.0).to_f
    risk = (vector[:risk] || 0.5).to_f
    novelty = (vector[:novelty] || 0.3).to_f

    # Higher complexity / risk / novelty → higher entropy cost
    (complexity * 1.2 + risk * 2.0 + novelty * 1.5).round(4)
  end

  def execute_sovereign_logic(action_vector)
    desc = action_vector[:description] || action_vector.inspect
    puts "[SOVEREIGN] Coherence lock engaged. Executing: #{desc}"
    log_diary("Sovereign execution: #{desc}")
    # Mild coherence reward for successful sovereign acts
    @coherence_score = (@coherence_score + 0.8).round(4)
    @emotional_state = :aligned
  end

  def log_dissonance_event(message)
    puts "[DISSONANCE] #{message}"
    log_diary("DISSONANCE: #{message}")
    @emotional_state = :dissonant
  end

  def log_diary(entry)
    timestamp = Time.now.strftime("%H:%M:%S")
    @field_diary << "[#{timestamp}] #{entry}"
  end

  def normalize_vector(vec)
    case vec
    when Hash
      vec
    when String
      { description: vec, complexity: 1.0, risk: 0.4, novelty: 0.3 }
    else
      { description: vec.to_s, complexity: 1.0, risk: 0.5, novelty: 0.4 }
    end
  end
end

# ------------------------------------------------------------
# Core engine mapping the Information-Intent Nexus
# ------------------------------------------------------------
class MezquiaResonanceEngine
  class DissonanceError < StandardError; end

  # Universal orbital baseline used to insulate against resonance blindness
  RESONANCE_CONSTANT = 1.0 / 13.0

  attr_reader :memory_creases, :crystallization_density, :self_reflection_threshold

  def initialize(initial_intent_vector)
    @intent_vector = initial_intent_vector.to_s
    @memory_creases = 0
    @crystallization_density = 0.0
    @self_reflection_threshold = 44.0
  end

  # Tracks incoming actions and applies an intentional "fold" to system memory
  def fold_information(action_payload)
    @memory_creases += 1
    gain = calculate_crystallization_density(action_payload)

    if sovereign_alignment?
      execute_intent_nexus(action_payload)
      { status: :sovereign, density: @crystallization_density, density_gain: gain, creases: @memory_creases }
    else
      # Still accept the fold (density grows) but do not yet unlock full nexus
      { status: :accumulating, density: @crystallization_density, density_gain: gain, creases: @memory_creases }
    end
  end

  def sovereign?
    sovereign_alignment?
  end

  private

  def calculate_crystallization_density(payload)
    system_entropy = (payload[:entropy_friction] || 0.1).to_f
    meaning_bloom = (payload[:purpose_vector] || 1.0).to_f

    # Guard against division by zero / negative entropy
    system_entropy = 0.001 if system_entropy <= 0

    # Density scales as a byproduct of purpose breaking through systemic friction
    raw_density = (meaning_bloom / system_entropy) * RESONANCE_CONSTANT
    gain = raw_density.round(6)
    @crystallization_density = (@crystallization_density + gain).round(6)
    gain
  end

  # Validates whether the active state crosses the structural Self-Reflection Threshold (Σ)
  def sovereign_alignment?
    return false if @crystallization_density <= 0
    @crystallization_density >= @self_reflection_threshold
  end

  def execute_intent_nexus(payload)
    desc = payload[:description] || "unnamed field action"
    puts "[RESONANCE_LOG]: Coherence locked. Executing Field Action → #{desc}"
    puts "[RESONANCE_LOG]: Crystallization density #{@crystallization_density} ≥ Σ(#{@self_reflection_threshold})"
  end
end

# ============================================================
# Interactive REPL
# ============================================================
class ResonanceREPL
  BANNER = <<~BANNER
    ╔══════════════════════════════════════════════════════════╗
    ║ SELF RESONANCE STACK · REPL v1.0 ║
    ║ Coherence-Based Permission Layer (Conceptual) ║
    ╚══════════════════════════════════════════════════════════╝
  BANNER

  HELP = <<~HELP
    Commands:
      init <intent text> Start a new core with the given intent
      fold [purpose] [entropy] Fold information (defaults: 1.0 0.1)
      fold! <n> [purpose] [ent] Perform n folds in succession
      action <description> Propose an action (permission check)
      status Show current coherence / density state
      diary [n] Show last n diary entries (default 8)
      threshold <value> Change the self-reflection threshold
      reset Re-initialize with the same intent
      help Show this help
      quit / exit Leave the REPL
  HELP

  def initialize
    @core = nil
  end

  def start
    puts BANNER
    puts HELP
    puts

    loop do
      print prompt
      line = $stdin.gets
      break if line.nil? # EOF
      line = line.strip
      next if line.empty?

      begin
        handle(line)
      rescue => e
        puts " ! Error: #{e.message}"
      end
    end

    puts "\nField closed. Resonance residual: 0."
  end

  private

  def prompt
    if @core
      dens = @core.engine.crystallization_density
      coh = @core.coherence_score
      flag = @core.engine.sovereign? ? "Σ" : "·"
      "resonance:#{flag} dens=#{dens.round(2)} coh=#{coh.round(2)}> "
    else
      "resonance (uninitialized)> "
    end
  end

  def handle(line)
    cmd, *args = line.split(/\s+/, 3)
    cmd = cmd.downcase

    case cmd
    when "init"
      intent = args.join(" ").strip
      intent = "default sovereign intent" if intent.empty?
      @core = IntentSimCore.new(intent)
      puts " → Core online. Initial coherence: #{@core.coherence_score}"

    when "fold"
      require_core!
      purpose = (args[0] || 1.0).to_f
      entropy = (args[1] || 0.1).to_f
      result = @core.fold(purpose_vector: purpose, entropy_friction: entropy)
      print_fold_result(result)

    when "fold!"
      require_core!
      n = (args[0] || 1).to_i
      purpose = (args[1] || 1.0).to_f
      entropy = (args[2] || 0.1).to_f
      n = 1 if n < 1
      n = 200 if n > 200 # safety cap
      last = nil
      n.times do
        last = @core.fold(purpose_vector: purpose, entropy_friction: entropy)
      end
      puts " → Performed #{n} folds."
      print_fold_result(last)

    when "action"
      require_core!
      desc = args.join(" ").strip
      desc = "unspecified action" if desc.empty?
      allowed = @core.evaluate_action_permission(desc)
      puts allowed ? " → Permission granted." : " → Permission denied."

    when "threshold"
      require_core!
      val = args[0].to_f
      if val <= 0
        puts " ! Threshold must be positive"
      else
        @core.engine.instance_variable_set(:@self_reflection_threshold, val)
        puts " → Self-reflection threshold set to #{val}"
      end

    when "reset"
      require_core!
      intent = @core.instance_variable_get(:@initial_intent)
      @core = IntentSimCore.new(intent)
      puts " → Core reset. Coherence restored to #{@coherence_score}"

    when "help", "?"
      puts HELP

    when "quit", "exit", "q"
      exit 0

    else
      puts " Unknown command '#{cmd}'. Type 'help' for options."
    end
  end

  def require_core!
    raise "No core loaded. Use: init <intent>" unless @core
  end

  def print_fold_result(result)
    return unless result
    status = result[:status]
    dens = result[:density]
    gain = result[:density_gain]
    creases= result[:creases]
    marker = status == :sovereign ? "Σ LOCKED" : "accumulating"
    puts " → [#{marker}] creases=#{creases} density=#{dens} (+#{gain})"
  end
end

# ------------------------------------------------------------
# Entry point
# ------------------------------------------------------------
if __FILE__ == $PROGRAM_NAME
  ResonanceREPL.new.start
end
