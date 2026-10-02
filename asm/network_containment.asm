; SPDX-License-Identifier: LicenseRef-NON-AI-MPL-2.0
; Copyright (C) 2026 SnapKitty Collective
; ============================================================================
; TheVoidIntent Framework
; Network Containment & Reclamation Module
;
; x86-64 NASM / Linux
;
; TypeScript equivalent:
;
; NetworkAlertModule
; WARNING -> logDissonanceMarker()
; CONTAINMENT -> quarantineAgentRouting()
; TRUTHLOCK -> executeCoreReclamation()
;
; Build:
;
; nasm -f elf64 network_containment.asm -o network_containment.o
; ld network_containment.o -o network_containment
;
; Run:
;
; ./network_containment
; ============================================================================

BITS 64

global _start

; ============================================================================
; Isolation levels
; ============================================================================

%define WARNING 0
%define CONTAINMENT 1
%define TRUTHLOCK 2

; Linux syscalls
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDOUT 1
%define STDERR 2


; ============================================================================
; Read-only strings
; ============================================================================

section .rodata

msg_warning:
    db "[CRITICAL ALERT]: Entering FIELD_WARN State!", 10
msg_warning_len equ $ - msg_warning

msg_containment:
    db "[CRITICAL ALERT]: Entering AGENT_ISOLATE State!", 10
msg_containment_len equ $ - msg_containment

msg_truthlock:
    db "[CRITICAL ALERT]: Entering CORE_RECLAMATION State!", 10
msg_truthlock_len equ $ - msg_truthlock

msg_dissonance:
    db "[ALERT]: Dissonance marker recorded.", 10
msg_dissonance_len equ $ - msg_dissonance

msg_quarantine:
    db "[CONTAINMENT]: Agent routing quarantined.", 10
msg_quarantine_len equ $ - msg_quarantine

msg_null_sink:
    db "[CONTAINMENT]: Downstream vectors redirected to null sink.", 10
msg_null_sink_len equ $ - msg_null_sink

msg_reclamation:
    db "[TRUTHLOCK]: Commencing core reclamation.", 10
msg_reclamation_len equ $ - msg_reclamation

msg_reset:
    db "[TRUTHLOCK]: Resetting state machines to Stage 1.", 10
msg_reset_len equ $ - msg_reset

msg_unknown:
    db "[ERROR]: Unknown isolation level. Fail-closed.", 10
msg_unknown_len equ $ - msg_unknown


; ============================================================================
; Mutable runtime state
; ============================================================================

section .bss

; Equivalent to:
;
; private activeFailsafe: boolean = false;
;
active_failsafe:
    resb 1

; Event identifier storage
event_id:
    resb 64

; Agent identifier storage
agent_id:
    resb 64

; Measured drift
measured_drift:
    resq 1

; Maximum allowed drift
max_allowed_limit:
    resq 1

; Timestamp
event_timestamp:
    resq 1


; ============================================================================
; Program
; ============================================================================

section .text

_start:

    ; ------------------------------------------------------------------------
    ; Initialize failsafe
    ; ------------------------------------------------------------------------

    mov byte [active_failsafe], 0


    ; ------------------------------------------------------------------------
    ; Example WARNING event
    ; ------------------------------------------------------------------------

    mov rdi, WARNING
    call trigger_containment_protocol


    ; ------------------------------------------------------------------------
    ; Example CONTAINMENT event
    ; ------------------------------------------------------------------------

    mov rdi, CONTAINMENT
    call trigger_containment_protocol


    ; ------------------------------------------------------------------------
    ; Example TRUTHLOCK event
    ;
    ; This path terminates the process with exit code 13.
    ; ------------------------------------------------------------------------

    mov rdi, TRUTHLOCK
    call trigger_containment_protocol


    ; Should never reach here because TRUTHLOCK exits.
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall


; ============================================================================
; trigger_containment_protocol
;
; Equivalent:
;
; triggerContainmentProtocol(
; level: IsolationLevel,
; payload: AlertPayload
; )
;
; Input:
; RDI = isolation level
;
; Side effect:
; activeFailsafe = true
;
; ============================================================================

trigger_containment_protocol:

    ; ------------------------------------------------------------------------
    ; activeFailsafe = true
    ; ------------------------------------------------------------------------

    mov byte [active_failsafe], 1


    ; ------------------------------------------------------------------------
    ; Dispatch isolation level
    ; ------------------------------------------------------------------------

    cmp rdi, WARNING
    je .warning

    cmp rdi, CONTAINMENT
    je .containment

    cmp rdi, TRUTHLOCK
    je .truthlock

    ; Unknown state
    jmp .unknown


; ============================================================================
; WARNING
;
; Equivalent:
;
; this.logDissonanceMarker(payload);
; ============================================================================

.warning:

    mov rdi, msg_warning
    mov rsi, msg_warning_len
    call print_stderr

    call log_dissonance_marker

    ret


; ============================================================================
; CONTAINMENT
;
; Equivalent:
;
; this.quarantineAgentRouting(payload.eventId);
; ============================================================================

.containment:

    mov rdi, msg_containment
    mov rsi, msg_containment_len
    call print_stderr

    call quarantine_agent_routing

    ret


; ============================================================================
; TRUTHLOCK
;
; Equivalent:
;
; this.executeCoreReclamation();
;
; ============================================================================

.truthlock:

    mov rdi, msg_truthlock
    mov rsi, msg_truthlock_len
    call print_stderr

    call execute_core_reclamation

    ; execute_core_reclamation does not return.

    ret


; ============================================================================
; UNKNOWN STATE
; ============================================================================

.unknown:

    mov rdi, msg_unknown
    mov rsi, msg_unknown_len
    call print_stderr

    ; Fail closed.
    mov rax, SYS_EXIT
    mov rdi, 13
    syscall


; ============================================================================
; log_dissonance_marker
;
; TypeScript:
;
; console.log(
; `[ALERT]: Dissonance logged at ${payload.timestamp}.`
; );
;
; ============================================================================

log_dissonance_marker:

    mov rdi, msg_dissonance
    mov rsi, msg_dissonance_len
    call print_stdout

    ret


; ============================================================================
; quarantine_agent_routing
;
; TypeScript:
;
; console.warn(
; `[CONTAINMENT]: Severing socket bridges for Agent: ${agentId}.`
; );
;
; console.warn(
; `[CONTAINMENT]: Re-routing downstream data vectors
; to zero-entropy null sinks.`
; );
;
; This implementation records the containment state and emits the
; corresponding control-plane messages.
;
; Actual interface/socket manipulation should be implemented separately
; behind an explicitly authorized privileged syscall/service boundary.
; ============================================================================

quarantine_agent_routing:

    mov rdi, msg_quarantine
    mov rsi, msg_quarantine_len
    call print_stderr

    mov rdi, msg_null_sink
    mov rsi, msg_null_sink_len
    call print_stderr

    ret


; ============================================================================
; execute_core_reclamation
;
; TypeScript:
;
; console.error(
; `[TRUTHLOCK]: Commencing total sovereign memory wipe.`
; );
;
; console.error(
; `[TRUTHLOCK]: Resetting operational state machines
; back to Stage 1 Calibration.`
; );
;
; process.exit(13);
;
; ============================================================================

execute_core_reclamation:

    mov rdi, msg_reclamation
    mov rsi, msg_reclamation_len
    call print_stderr

    mov rdi, msg_reset
    mov rsi, msg_reset_len
    call print_stderr


    ; ------------------------------------------------------------------------
    ; Clear selected runtime state before termination.
    ;
    ; This is ordinary process-state cleanup, not secure erasure of arbitrary
    ; system memory.
    ; ------------------------------------------------------------------------

    xor eax, eax

    mov byte [active_failsafe], 0

    mov qword [measured_drift], 0
    mov qword [max_allowed_limit], 0
    mov qword [event_timestamp], 0

    lea rdi, [event_id]
    mov rcx, 64
    rep stosb

    lea rdi, [agent_id]
    mov rcx, 64
    rep stosb


    ; ------------------------------------------------------------------------
    ; Linux:
    ;
    ; process.exit(13)
    ;
    ; becomes:
    ;
    ; syscall
    ; RAX = 60 SYS_exit
    ; RDI = 13 status
    ; ------------------------------------------------------------------------

    mov rax, SYS_EXIT
    mov rdi, 13
    syscall


; ============================================================================
; print_stdout
;
; RDI = pointer
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
