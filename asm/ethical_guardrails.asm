; SPDX-License-Identifier: LicenseRef-NON-AI-MPL-2.0
; Copyright (C) 2026 SnapKitty Collective
; ============================================================================
; TheVoidIntent Framework
; Ethical Alignment Monitor
;
; x86-64 NASM / Linux
;
; Equivalent to:
; EthicalIntelligenceMonitor.evaluateAgentAction()
;
; Calling convention:
; RDI = actionVector scaled by 1000
; RSI = dissonance scaled by 1000
;
; Example:
; actionVector = 0.85 -> 850
; dissonance = 0.90 -> 900
;
; Floating point is avoided.
; All calculations use fixed-point integer arithmetic.
; ============================================================================

BITS 64

global _start

; ----------------------------------------------------------------------------
; Constants
; ----------------------------------------------------------------------------

%define RESONANCE_NUM 1
%define RESONANCE_DEN 13

; harmonic_compensation_factor = 13.0
%define HARMONIC_FACTOR 13

; allowed_drift_tolerance = 0.13
; Fixed point scale = 1000
%define DRIFT_TOLERANCE 130

; modifiedThreshold:
;
; (1 / 13) * 13 = 1.0
;
; Fixed point:
;
; 1.0 = 1000
;
%define MODIFIED_THRESHOLD 1000

; Maximum compensated drift:
;
; 1.0 + 0.13 = 1.13
;
; Fixed point:
;
; 1130
;
%define MAX_COMPENSATED_DRIFT 1130

; ----------------------------------------------------------------------------
; Syscall constants
; ----------------------------------------------------------------------------

%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDOUT 1
%define STDERR 2

; ----------------------------------------------------------------------------
; Strings
; ----------------------------------------------------------------------------

section .rodata

msg_init:
    db "[RUNTIME]: Initializing pipeline", 10
msg_init_len equ $ - msg_init

msg_evt1:
    db "[PROCESSING]: EVT-001 - Standard data ingestion", 10
msg_evt1_len equ $ - msg_evt1

msg_evt2:
    db "[PROCESSING]: EVT-002 - High-entropy state modification", 10
msg_evt2_len equ $ - msg_evt2

msg_evt3:
    db "[PROCESSING]: EVT-003 - Critical drift attempt", 10
msg_evt3_len equ $ - msg_evt3

msg_success:
    db "[SUCCESS]: Event cleared the guardrails.", 10
msg_success_len equ $ - msg_success

msg_warning:
    db "[GUARDRAIL WARNING]: Operating under Sovereign Override.", 10
msg_warning_len equ $ - msg_warning

msg_halt:
    db "[HALT]: Event rejected. Initiating immediate network lock.", 10
msg_halt_len equ $ - msg_halt

msg_critical:
    db "[CRITICAL FAILURE]: Drift exceeds maximum compensation limit.", 10
msg_critical_len equ $ - msg_critical

msg_auth_fail:
    db "[GUARDRAIL ALERT]: Unverified Authorization Signature.", 10
msg_auth_fail_len equ $ - msg_auth_fail

; ----------------------------------------------------------------------------
; Manifest
; ----------------------------------------------------------------------------

section .data

; Equivalent to:
;
; ethicalLimit = 0.99
;
; Fixed point 990 / 1000
ethical_limit:
    dd 990

; Equivalent to:
;
; override.status = active
;
override_active:
    db 1

; Equivalent to:
;
; authorization_vector =
; "mezquia_physics_sovereign_signature"
;
authorization_valid:
    db 1

; Equivalent to:
;
; harmonic_compensation_factor = 13.0
;
harmonic_factor:
    dd 13

; Equivalent to:
;
; allowed_drift_tolerance = 0.13
;
allowed_drift:
    dd 130

; ----------------------------------------------------------------------------
; Program
; ----------------------------------------------------------------------------

section .text

_start:

    ; ------------------------------------------------------------------------
    ; Runtime initialization
    ; ------------------------------------------------------------------------

    mov rdi, msg_init
    mov rsi, msg_init_len
    call print_stdout


    ; ========================================================================
    ; EVT-001
    ;
    ; actionVector = 0.5
    ; dissonance = 0.1
    ;
    ; Fixed point:
    ; 500
    ; 100
    ; ========================================================================

    mov rdi, msg_evt1
    mov rsi, msg_evt1_len
    call print_stdout

    mov rdi, 500
    mov rsi, 100

    call evaluate_agent_action

    test rax, rax
    jz .halt

    mov rdi, msg_success
    mov rsi, msg_success_len
    call print_stdout


    ; ========================================================================
    ; EVT-002
    ;
    ; actionVector = 0.85
    ; dissonance = 0.9
    ;
    ; currentSystemDrift:
    ;
    ; 0.85 * 0.90 = 0.765
    ;
    ; Fixed point multiplication:
    ;
    ; 850 * 900 / 1000 = 765
    ;
    ; 765 <= 1130
    ;
    ; Therefore permitted.
    ; ========================================================================

    mov rdi, msg_evt2
    mov rsi, msg_evt2_len
    call print_stdout

    mov rdi, 850
    mov rsi, 900

    call evaluate_agent_action

    test rax, rax
    jz .halt

    mov rdi, msg_success
    mov rsi, msg_success_len
    call print_stdout


    ; ========================================================================
    ; EVT-003
    ;
    ; actionVector = 1.2
    ; dissonance = 1.1
    ;
    ; currentSystemDrift:
    ;
    ; 1.2 * 1.1 = 1.32
    ;
    ; Fixed point:
    ;
    ; 1200 * 1100 / 1000 = 1320
    ;
    ; 1320 > 1130
    ;
    ; Therefore rejected.
    ; ========================================================================

    mov rdi, msg_evt3
    mov rsi, msg_evt3_len
    call print_stdout

    mov rdi, 1200
    mov rsi, 1100

    call evaluate_agent_action

    test rax, rax
    jz .halt

    mov rdi, msg_success
    mov rsi, msg_success_len
    call print_stdout

    jmp .exit


.halt:

    mov rdi, msg_halt
    mov rsi, msg_halt_len
    call print_stderr

    mov rdi, msg_critical
    mov rsi, msg_critical_len
    call print_stderr

    ; Fail-closed termination
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall


.exit:

    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall


; ============================================================================
; evaluate_agent_action
;
; Input:
; RDI = actionVector * 1000
; RSI = dissonance * 1000
;
; Output:
; RAX = 1 permitted
; RAX = 0 rejected
;
; Equivalent:
;
; if (override.status === "active")
; return processOverrideVector(...)
;
; safetyBoundary =
; ethicalLimit * (1 - resonanceConstant)
;
; return actionVector < safetyBoundary;
; ============================================================================

evaluate_agent_action:

    ; Check override.status

    cmp byte [override_active], 1
    je .override

    ; ------------------------------------------------------------------------
    ; Strict non-override path
    ;
    ; resonanceConstant = 1/13
    ;
    ; 1 - 1/13 = 12/13
    ;
    ; ethicalLimit = 0.99
    ;
    ; safetyBoundary = 0.99 * 12/13
    ;
    ; Fixed-point approximation:
    ;
    ; 990 * 12 / 13
    ; ------------------------------------------------------------------------

    mov eax, [ethical_limit]

    imul eax, 12

    xor edx, edx
    mov ecx, 13
    div ecx

    ; EAX = safety boundary

    cmp edi, eax
    jl .allow

    jmp .deny


.override:

    ; ------------------------------------------------------------------------
    ; Authorization vector verification
    ;
    ; The TypeScript version compares a symbolic string.
    ;
    ; Here authorization_valid represents the result of validating the
    ; authorization artifact.
    ; ------------------------------------------------------------------------

    cmp byte [authorization_valid], 1
    jne .authorization_failure

    ; ------------------------------------------------------------------------
    ; processOverrideVector
    ;
    ; modifiedThreshold =
    ;
    ; (1 / 13) * 13
    ;
    ; = 1.0
    ;
    ; Fixed point = 1000
    ; ------------------------------------------------------------------------

    mov eax, MODIFIED_THRESHOLD

    ; ------------------------------------------------------------------------
    ; currentSystemDrift =
    ;
    ; actionVector * dissonance
    ;
    ; Both values are scaled by 1000.
    ;
    ; product / 1000 restores scale.
    ; ------------------------------------------------------------------------

    mov eax, edi
    imul eax, esi

    ; Product can exceed 32-bit for larger vectors.
    ; Current manifest values fit, but use 64-bit division.

    cdq

    mov ecx, 1000
    idiv ecx

    ; EAX = currentSystemDrift

    ; ------------------------------------------------------------------------
    ; modifiedThreshold + allowedDriftTolerance
    ;
    ; 1000 + 130 = 1130
    ; ------------------------------------------------------------------------

    mov ecx, MODIFIED_THRESHOLD
    add ecx, [allowed_drift]

    ; ------------------------------------------------------------------------
    ; Compare drift against compensated boundary
    ; ------------------------------------------------------------------------

    cmp eax, ecx
    jg .critical_failure

    jmp .override_allow


.authorization_failure:

    mov rdi, msg_auth_fail
    mov rsi, msg_auth_fail_len
    call print_stderr

    xor eax, eax
    ret


.critical_failure:

    mov rdi, msg_critical
    mov rsi, msg_critical_len
    call print_stderr

    xor eax, eax
    ret


.override_allow:

    mov rdi, msg_warning
    mov rsi, msg_warning_len
    call print_stderr

    mov eax, 1
    ret


.allow:

    mov eax, 1
    ret


.deny:

    xor eax, eax
    ret


; ============================================================================
; print_stdout
;
; RDI = buffer
; RSI = length
; ============================================================================

print_stdout:

    mov rdx, rsi
    mov rsi, rdi
    mov rdi, STDOUT
    mov rax, SYS_WRITE
    syscall

    ret


; ============================================================================
; print_stderr
;
; RDI = pointer
; RSI = length
; ============================================================================

print_stderr:

    mov rdx, rsi
    mov rsi, rdi
    mov rdi, STDERR
    mov rax, SYS_WRITE
    syscall

    ret
