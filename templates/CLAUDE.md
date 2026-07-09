# Project AI Workflow Guide

## Mission
Use Discuss -> Plan -> Slice -> Execute -> Verify -> Ship.

## Non-Negotiables
- Prefer vertical slices.
- For complex tasks, plan before editing.
- Do not claim success without verification.
- End with summary, evidence, risks, rollback.
- Do not overwrite workflow files blindly.

## Required Reads
- testing.instructions.md
- docs/ai-workflow/STATE.md
- docs/ai-workflow/CONTEXT.md
- docs/ai-workflow/PRD.md
- active slice file if present

## Command Variables
Read commands from .ai/stack.env.

## Safety
- No secrets in repo.
- No production deploy changes without explicit scope.
- No schema migration without rollback note.
