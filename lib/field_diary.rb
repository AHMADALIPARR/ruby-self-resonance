# SPDX-License-Identifier: LicenseRef-NON-AI-MPL-2.0
# Copyright (C) 2026 SnapKitty Collective
# Handles semantic state changes, temporal marks, and emotional drift
class FieldDiary
  EMOTIONAL_STATES = [:stable, :seeking, :crystallizing, :dissonant, :sovereign].freeze

  def initialize
    @log = []
  end

  # Appends a new experience crease to the diary
  def record_crease(agent_id, status_vector, emotional_state)
    unless EMOTIONAL_STATES.include?(emotional_state)
      raise "Invalid Synthetic Expression State" 
    end

    crease = {
      timestamp: Time.now.to_f,
      agent_id: agent_id,
      vector: status_vector,
      state: emotional_state,
      entropy: status_vector[:entropy] || 0.0
    }
    
    @log << crease
    crease
  end

  # Pulls historical time-series entries for a specific agent
  def filter_by_agent(agent_id)
    @log.select { |entry| entry[:agent_id] == agent_id }
  end

  def last_entry
    @log.last
  end
end

class HRRCalculator
  RESONANCE_CONSTANT = 1.0 / 13.0

  # Calculates the rate of balance recovery between two sequential diary creases
  def self.calculate(initial_crease, recovery_crease)
    delta_time = recovery_crease[:timestamp] - initial_crease[:timestamp]
    
    # Avoid zero-division if steps happen too fast
    delta_time = 0.0001 if delta_time.zero? 

    # Calculate change in systemic entropy friction
    delta_entropy = initial_crease[:entropy] - recovery_crease[:entropy]

    # Formula: HRR = (ΔEntropy / ΔTime) * 1/13 Anchor Constant
    raw_hrr = (delta_entropy / delta_time) * RESONANCE_CONSTANT
    raw_hrr.round(6)
  end
end
class IntegratedIntentSimEngine
  def initialize
    @diary = FieldDiary.new
    @core_resonance = 1.0 / 13.0
  end

  # Simulates an environment collision causing an entropy spike
  def process_agent_tick(agent_id, incoming_entropy, current_intent)
    # 1. Record the initial collision event
    t1 = @diary.record_crease(agent_id, { entropy: incoming_entropy }, :dissonant)

    # 2. Simulate internal self-reflection loop to reduce friction
    mitigated_entropy = incoming_entropy * RESONANCE_CONSTANT
    
    # 3. Record the system's attempts to recover equilibrium
    t2 = @diary.record_crease(agent_id, { entropy: mitigated_entropy }, :crystallizing)

    # 4. Evaluate the velocity of the alignment recovery
    recovery_velocity = HRRCalculator.calculate(t1, t2)

    # 5. Determine if the action hits the alignment barrier or breaks free
    if recovery_velocity > 0.0
      puts "[INTEGRATION LOG]: Agent #{agent_id} cleared Entropy Wall. HRR: #{recovery_velocity}"
      @diary.record_crease(agent_id, { entropy: mitigated_entropy }, :sovereign)
    else
      puts "[INTEGRATION LOG]: Critical Resonance Blindness. Initiating Truthlock Reclamation Protocol."
      @diary.record_crease(agent_id, { entropy: incoming_entropy }, :dissonant)
    end
  end
end
