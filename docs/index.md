# goxpyriment

`goxpyriment` is a high-level Go framework for building behavioral and psychological experiments with precise, VSYNC-locked stimulus timing.

* [GitHub repository](https://github.com/chrplr/goxpyriment)
* [Google group](https://groups.google.com/a/pallier.org/g/goxpyriment) — Forum
* Report bugs at <https://github.com/chrplr/goxpyriment/issues>

If you are looking for a simpler, *no-code experiment generator*, check out [Gostim2](https://chrplr.github.io/gostim2/).

---

## Why goxpyriment?

1. **Zero-dependency deployment.** A finished experiment compiles to a single binary — an `.exe` on Windows, an AppImage on Linux, a `.app` on macOS. No Python, no conda, no DLL hell on lab computers.
2. **Timing precision.** The stimulus loop runs VSYNC-locked with GC pauses disabled, giving sub-millisecond frame jitter on typical hardware.
3. **AI-friendly API.** The linear, consistent API is well suited to "vibe-coding" — describe your paradigm in plain language to Claude, Gemini, or ChatGPT and the generated code is usually 90 % ready to run immediately.

> 💡 **Vibe-coding tip:** After installation, launch an AI coding agent inside the `goxpyriment` folder and ask it to add a new experiment to the `examples` folder — the agent reads the existing examples for context. Describe the experiment (stimuli, design, etc.) in plain language. Save your prompt in a `description.md` file alongside the code.

> ⚠️ **Beta:** This software is in beta-testing. It is usable for real lab experiments, but users should carefully validate timing behaviour, e.g. with a [bbtk](https://chrplr.github.io/bbtkv3/).

---

## Documentation

| Document | | PDF |
|---|---|---|
| [Installation](Installation.md) | Install Go and build the examples | [↓](Installation.pdf) |
| [Getting Started](GettingStarted.md) | Tutorial for psychologists | [↓](GettingStarted.pdf) |
| [Gallery of Examples](GalleryOfExamples.md) | Ready-to-run experiments and demos | |
| [User Manual](UserManual.md) | Core concepts explained in depth | [↓](UserManual.pdf) |
| [Migration Guide](MigrationGuide.md) | Coming from Expyriment, PsychoPy, or Psychtoolbox? | [↓](MigrationGuide.pdf) |
| [API Reference](API.md) | Complete function and type reference | [↓](API.pdf) |

---

## Quick Start

```go
package main

import (
    "github.com/chrplr/goxpyriment/control"
    "github.com/chrplr/goxpyriment/stimuli"
)

func main() {
    exp := control.NewExperimentFromFlags("Hello World", control.Black, control.White, 32)
    defer exp.End()

    hello := stimuli.NewTextBox("Hello, World!", 600, control.FPoint{}, control.White)

    exp.Run(func() error {
        exp.Show(hello)
        exp.Keyboard.Wait()
        return control.EndLoop
    })
}
```

Save this as `hello/main.go`, then in the `hello` folder run once:

```bash
go mod init hello
go mod tidy
```

Then:

```bash
go run . -w        # windowed mode
go run . -w -s 1   # windowed, subject ID = 1
```

---

## Installation

Download and install Go from <https://go.dev>, then:

```bash
git clone https://github.com/chrplr/goxpyriment.git
cd goxpyriment
make examples   # compiles all examples into _build/
```

You can also run examples directly from source:

```bash
go run examples/Stroop_task/main.go -w -s 1
```

---

## Ready-to-run demos

Pre-built binaries for Windows, macOS, and Linux are available on the
[Releases page](https://github.com/chrplr/goxpyriment/releases).

---

## Background

Goxpyriment relies on [libsdl](http://libsdl.org) via the [go-sdl3](https://github.com/Zyko0/go-sdl3) bindings.

It was inspired by [expyriment.org](https://github.com/expyriment/expyriment), a lightweight Python library for cognitive and neuroscientific experiments (Krause & Lindemann, 2014. *Behavior Research Methods*, 46(2), 416–428. <https://doi.org/10.3758/s13428-013-0390-6>). The API should feel familiar to expyriment users.

---

## License & citation

GNU GPL v3 — see [LICENSE](https://github.com/chrplr/goxpyriment/blob/main/LICENSE.txt).

Please cite as:
> Christophe Pallier (2026) chrplr/goxpyriment: Goxpyriment vX.Y.Z. Zenodo. https://doi.org/10.5281/zenodo.19200598
> *(update the version number)*

Christophe Pallier, 2026.
