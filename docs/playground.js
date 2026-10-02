/* SPDX-License-Identifier: LicenseRef-NON-AI-MPL-2.0 */
/* Copyright (C) 2026 SnapKitty Collective */

// WASM Playground driver.
//
// Boots Ruby 3.2 (ruby.wasm) in the browser, evaluates the repository's own
// ruby_self_resonance.rb verbatim, and wires the live PermissionRuntime to
// the page. All Ruby<->JS exchange goes through JSON strings.

"use strict";

let vm = null;

const $ = (id) => document.getElementById(id);

function setStatus(msg) {
  $("boot-status").textContent = msg;
}

function num(id, fallback) {
  const v = parseFloat($(id).value);
  return Number.isFinite(v) ? v : fallback;
}

function intNum(id, fallback, min, max) {
  let v = parseInt($(id).value, 10);
  if (!Number.isFinite(v)) v = fallback;
  return Math.min(Math.max(v, min), max);
}

// Escape a JS string for embedding inside a single-quoted Ruby string.
function rbEscape(s) {
  return s.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
}

// Evaluate Ruby code that returns a JSON string; parse it in JS.
function rubyJSON(code) {
  const out = vm.eval(`require "json"; (${code}).to_json`).toString();
  return JSON.parse(out);
}

function refreshState() {
  const s = rubyJSON("$playground.state");
  $("st-coherence").textContent = fmt(s.intent_coherence);
  $("st-emotion").textContent = s.emotional_state;
  $("st-density").textContent = fmt(s.resonance.crystallization_density);
  $("st-threshold").textContent = fmt(s.resonance.threshold);
  $("st-diary").textContent = s.diary_events;
  const al = $("st-aligned");
  if (s.resonance.aligned) {
    al.textContent = "Σ SOVEREIGN — alignment locked";
    al.className = "sovereign";
  } else {
    al.textContent = `accumulating — ${s.resonance.memory_creases} memory creases`;
    al.className = "dim";
  }
}

function refreshDiary() {
  const events = rubyJSON("$playground.intent_core.field_diary.events");
  $("diary-count").textContent = events.length;
  $("diary-body").innerHTML = events.map((e) => `
    <tr>
      <td>${e.sequence}</td>
      <td><code>${escapeHtml(e.type)}</code></td>
      <td class="dim">${escapeHtml(e.timestamp)}</td>
      <td><code>${escapeHtml(JSON.stringify(e.payload))}</code></td>
    </tr>`).join("");
}

function fmt(n) {
  return typeof n === "number" ? n.toFixed(4) : String(n);
}

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, "&amp;").replace(/</g, "&lt;")
    .replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

function authorizeAction() {
  const payload = {
    name: $("a-name").value.trim() || "anonymous",
    vector: $("a-vector").value.split(",").map((x) => parseFloat(x.trim())),
    entropy_cost: num("a-entropy", 0.2),
    purpose: num("a-purpose", 1.0),
    risk: num("a-risk", 0.1),
  };
  if (payload.vector.some((x) => !Number.isFinite(x))) {
    showDecision({ ok: false, error: "vector must be comma-separated numbers" });
    return;
  }
  const code = `
    begin
      p = JSON.parse('${rbEscape(JSON.stringify(payload))}')
      a = RubySelfResonance::ActionVector.new(
        name: p["name"].to_sym,
        vector: p["vector"],
        entropy_cost: p["entropy_cost"],
        purpose: p["purpose"],
        risk: p["risk"],
        metadata: { "source" => "wasm-playground" }
      )
      d = $playground.authorize(a)
      { "ok" => true, "decision" => d.to_h }.to_json
    rescue ArgumentError => e
      { "ok" => false, "error" => e.message }.to_json
    end`;
  let res;
  try {
    res = JSON.parse(vm.eval(code).toString());
  } catch (e) {
    res = { ok: false, error: String(e.message || e) };
  }
  showDecision(res);
  refreshState();
  refreshDiary();
}

function showDecision(res) {
  const box = $("decision-box");
  box.style.display = "";
  if (!res.ok) {
    box.className = "panel alert-error";
    box.innerHTML = `<h2>Error</h2><p>${escapeHtml(res.error)}</p>`;
    return;
  }
  const d = res.decision;
  box.className = "panel " + (d.allowed ? "alert-ok" : "alert-denied");
  box.innerHTML = `
    <h2>Decision: ${d.allowed ? "PERMITTED" : "DENIED"}</h2>
    <dl>
      <dt>action</dt><dd>${escapeHtml(d.action)}</dd>
      <dt>reason</dt><dd>${escapeHtml(JSON.stringify(d.reason))}</dd>
      <dt>coherence</dt><dd>${fmt(d.coherence)}</dd>
      <dt>entropy Δ</dt><dd>${fmt(d.entropy_delta)}</dd>
      <dt>risk</dt><dd>${fmt(d.risk)}</dd>
      <dt>timestamp</dt><dd>${escapeHtml(d.timestamp)}</dd>
    </dl>`;
}

function foldInfo() {
  const purpose = num("f-purpose", 1.0);
  const entropy = num("f-entropy", 0.1);
  const times = intNum("f-times", 1, 1, 60);
  const code = `
    rs = []
    ${times}.times do
      begin
        rs << $playground.fold(purpose_vector: ${purpose}, entropy_friction: ${entropy})
      rescue RubySelfResonance::DissonanceOverride => e
        rs << { "status" => "dissonance", "message" => e.message }
      end
    end
    rs.to_json`;
  let results;
  try {
    results = JSON.parse(vm.eval(code).toString());
  } catch (e) {
    results = [{ status: "error", message: String(e.message || e) }];
  }
  const box = $("fold-box");
  box.style.display = "";
  box.className = "panel alert-ok";
  const shown = results.slice(-5).map((r) => {
    if (r.status === "dissonance") {
      return `<p><span class="denied">dissonance</span> — ${escapeHtml(r.message)}</p>`;
    }
    if (r.status === "error") {
      return `<p><span class="denied">error</span> — ${escapeHtml(r.message)}</p>`;
    }
    return `<p><span class="sovereign">${escapeHtml(r.status)}</span> — density ${fmt(r.density)} (+${fmt(r.density_gain)}) · creases ${r.creases}</p>`;
  }).join("");
  box.innerHTML = `<h2>Fold results</h2>${shown}` +
    (results.length > 5 ? `<p class="dim">…and ${results.length - 5} more</p>` : "");
  refreshState();
  refreshDiary();
}

function resetField() {
  if (!confirm("Reset the field? Diary will be cleared.")) return;
  vm.eval("$playground = RubySelfResonance::PermissionRuntime.new([1.0, 0.8, 0.6, 0.9])");
  $("decision-box").style.display = "none";
  $("fold-box").style.display = "none";
  refreshState();
  refreshDiary();
}

async function boot() {
  try {
    setStatus("Loading Ruby 3.2 WebAssembly binary (≈32 MB)…");
    const { DefaultRubyVM } = window["ruby-wasm-wasi"];
    const response = await fetch(
      "https://cdn.jsdelivr.net/npm/ruby-3_2-wasm-wasi@2.3.0/dist/ruby+stdlib.wasm"
    );
    if (!response.ok) throw new Error(`WASM fetch failed: ${response.status}`);
    const buffer = await response.arrayBuffer();
    setStatus("Compiling WebAssembly…");
    const module = await WebAssembly.compile(buffer);
    setStatus("Starting Ruby VM…");
    const { vm: newVm } = await DefaultRubyVM(module);
    vm = newVm;

    setStatus("Evaluating ruby_self_resonance.rb (verbatim)…");
    const src = await (await fetch("ruby_self_resonance.rb")).text();
    vm.eval(`require "time";\n` + src + `\n$playground = RubySelfResonance::PermissionRuntime.new([1.0, 0.8, 0.6, 0.9])\n`);

    $("boot").style.display = "none";
    $("playground").style.display = "";
    refreshState();
    refreshDiary();
  } catch (e) {
    setStatus("Boot failed: " + (e.message || e));
  }
}

$("btn-authorize").addEventListener("click", authorizeAction);
$("btn-fold").addEventListener("click", foldInfo);
$("btn-reset").addEventListener("click", resetField);

boot();
