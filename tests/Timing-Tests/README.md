# Timing-Tests — quick reference

A hardware timing verification suite for goxpyriment experiments.
Run these tests **before** collecting data to characterise your system's
display and audio timing and to verify that stimulus presentation is
behaving as intended.

For full background, equipment setup, interpretation guidance, and worked
examples see **[docs/TimingTests.md](../../docs/TimingTests.md)**.

---

## Recommended workflow

```
1. check    — verify display flash + audio output
2. display  — measure true refresh rate and frame stability
3. latency  — measure audio pipeline latency
4. stream   — verify RSVP / sequential-stimulus timing
5. vrr      — Variable Refresh Rate sweep: 1–N ms in 1 ms steps
6. trigger  — characterise DLP-IO8-G (if available)
7. frames   — validate visual onset with photodiode
8. flash    — verify single-frame capability with photodiode
9. tones    — measure audio onset jitter (long stream)
10. av      — measure audio–visual synchrony
11. rt      — measure reaction-time timestamp precision
```

Steps 1–5 require no external hardware (step 5 benefits from a VRR monitor).
Steps 6–10 require a DLP-IO8-G and/or oscilloscope + photodiode (see docs).
Step 11 requires a keyboard or USB response box.

---

## Running

```bash
# from the repo root (go.work resolves both modules):
go run tests/Timing-Tests/main.go -test <name> [flags]

# examples
go run tests/Timing-Tests/main.go -test check  -w
go run tests/Timing-Tests/main.go -test display -duration-s 30 -w
go run tests/Timing-Tests/main.go -test latency -w
go run tests/Timing-Tests/main.go -test stream  -cycles 120 -frames-per-phase 3 -isi-frames 3 -w
go run tests/Timing-Tests/main.go -test vrr     -vrr-max-ms 50 -cycles 5 -w
go run tests/Timing-Tests/main.go -test trigger -period-ms 100 -duty 50 -duration-s 30
go run tests/Timing-Tests/main.go -test frames  -frames-per-phase 2 -cycles 120
go run tests/Timing-Tests/main.go -test flash   -isi-frames 60 -cycles 60
go run tests/Timing-Tests/main.go -test tones   -cycles 300 -freq-hz 1000 -tone-ms 50 -iti-ms 450 -w
go run tests/Timing-Tests/main.go -test av      -soa-ms 0 -cycles 30 -w
go run tests/Timing-Tests/main.go -test rt      -cycles 60 -w
```

Add `-w` for a 1024×768 window instead of fullscreen.
Remove `-w` for fullscreen on the primary display.
Use `-d N` to select a specific monitor (0-indexed; -1 = primary).

Legacy names (`jitter`, `drain`, `square`, `sound`, `audio`) still work as aliases.

---

## Equipment summary

| Test | Display | Photodiode | Oscilloscope | DLP-IO8-G | Keyboard |
|------|:-------:|:----------:|:------------:|:---------:|:--------:|
| `check`   | ✓ | — | — | — | — |
| `display` | ✓ | — | — | — | — |
| `latency` | ✓ | — | — | — | — |
| `stream`  | ✓ | optional | optional | optional | — |
| `vrr`     | ✓ | optional | optional | optional | — |
| `trigger` | ✓ | — | recommended | **required** | — |
| `frames`  | ✓ | **required** | recommended | optional | — |
| `flash`   | ✓ | **required** | recommended | optional | — |
| `tones`   | ✓ | — | recommended | optional | — |
| `av`      | ✓ | **required** | **required** | optional | — |
| `rt`      | ✓ | optional | optional | optional | **required** |

---

## Flags reference

### Common flags

| Flag | Default | Description |
|------|---------|-------------|
| `-test` | *(required)* | Sub-test name |
| `-w` | false | Windowed mode (1024×768) instead of fullscreen |
| `-d N` | -1 | Monitor index (-1 = primary) |
| `-port` | auto | Serial port for DLP-IO8-G |
| `-trigger-pin` | 1 | DLP-IO8-G output pin (1–8) |
| `-trigger-ms` | 5 | Trigger pulse duration (ms) |
| `-cycles` | 60 | Number of elements / flashes / trials |
| `-hz` | 60.0 | Expected refresh rate (Hz); run `display` first to measure the true value |
| `-warmup` | 10 | Elements excluded from statistics at start |
| `-audio-frames` | SDL default | Hardware audio buffer size in sample frames (e.g. 256, 512, 2048) |

### Per-test flags

| Flag | Applies to | Default | Description |
|------|-----------|---------|-------------|
| `-level-a` | display, frames, flash, stream | 0 | Dark luminance 0–255 |
| `-level-b` | display, frames, flash, stream | 255 | Bright luminance 0–255 |
| `-frames-per-phase` | frames, stream | 2 | Bright frames per element |
| `-isi-frames` | flash, stream | 60 | Dark frames per ISI |
| `-duration-s` | display, trigger | 10 | Measurement duration (s) |
| `-period-ms` | trigger | 100 | Square-wave period (ms) |
| `-duty` | trigger | 50 | Duty cycle (%) |
| `-soa-ms` | av | 0 | Audio-before-visual SOA (ms); negative = audio first |
| `-iti-ms` | av, tones, rt | 1000 | Inter-trial interval (ms) |
| `-freq-hz` | av, tones, latency | 1000 | Tone frequency (Hz) |
| `-tone-ms` | av, tones | 50 | Tone duration (ms) |
| `-drain-reps` | latency | 10 | Repetitions per tone duration |
| `-vrr-max-ms` | vrr | 50 | Maximum sweep duration (ms); test runs 1 ms → this value in 1 ms steps |

---

## Output files

Each run writes a `.csv` file to `~/goxpy_data/` with `#`-prefixed metadata headers:

```python
import pandas as pd
df = pd.read_csv("~/goxpy_data/Timing-Tests_000_*.csv", comment="#")
```

---

## Hardware notes

**Photodiode** — tape it to the screen corner where the bright stimulus appears
and connect its output to oscilloscope channel 1.

**DLP-IO8-G** — connects via USB (appears as `/dev/ttyUSBx` on Linux).
The user must be in the `dialout` group: `sudo usermod -aG dialout $USER`.
To reduce USB latency to ~1 ms (recommended):
```bash
echo 1 | sudo tee /sys/bus/usb-serial/devices/ttyUSB0/latency_timer
```

**Audio line-out** — for the `av` test, patch the headphone or line-out jack
directly into oscilloscope channel 2 to measure actual acoustic onset timing.
