# GEMINI.md - goxpyriment Paper Refinement

This document outlines the specific goals and stylistic mandates for the `goxpyriment` paper, targeted for submission to the journal **Behavior Research Methods (BRM)**.

## Core Objectives
- **Target Audience:** Experimental psychologists and neuroscientists who prioritize timing reliability, ease of deployment, and a low barrier to entry.
- **Tone:** Professional, seasoned experimental psychologist. Authoritative but accessible.
- **Key Value Propositions:**
  1. **Zero-Dependency Deployment:** Single compiled binaries (no Python/Conda environment hell).
  2. **Native High-Precision Timing:** Direct SDL3 access providing sub-millisecond precision without external C++ engines (like Psychtoolbox).
  3. **AI-Friendly API:** A linear, strictly typed design optimized for "vibe-coding" and LLM-assisted experiment generation.

## Structural Mandates
- **Front-Load Merits:** Move the "Why Go?" (Core Advantages) and "Timing Architecture" sections early in the paper to immediately address the readership's primary concerns.
- **Narrative Over Lists:** Avoid long, dry bulleted lists of API methods or tests. Convert these into flowing technical prose that explains *why* a feature matters to a researcher.
- **Deployment Simplicity:** Keep OS-specific security warnings (Gatekeeper/SmartScreen) concise. The paper should focus on the *methodology* of deployment, not act as a technical troubleshooting guide.
- **Streamlined API Section:** Replace exhaustive package/method descriptions with a narrative walkthrough of the experiment lifecycle, safety mechanisms (panic/recover for `ESC`), and data logging.

## Editorial Style
- Prioritize "timing accuracy" and "simplicity of the framework."
- Use "Comparison with Existing Tools" (Table 1) as a cornerstone for situating the framework within the current ecosystem (PsychoPy, Expyriment, MATLAB/PTB, jsPsych).
- Maintain a focus on reproducibility and the reduction of "operational overhead" in the lab.
