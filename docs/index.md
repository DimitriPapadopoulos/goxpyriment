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

OD> 💡 **TIP:* _AI assisted coding_ After cloning the repository, launch an AI coding agent inside the `goxpyriment` folder and ask it to add a new experiment to the `examples` folder — the agent reads the existing examples for context. Describe the experiment (stimuli, design, etc.) in plain language. Save your prompt in a `description.md` file alongside the code.

> ⚠️ **Beta:** This software is in beta-testing. It is usable for real lab experiments, but users should carefully validate timing behaviour, e.g. with a [bbtk](https://chrplr.github.io/bbtkv3/).

---

## Documentation

It is recommended to start by skimming over [goxpyriment-paper.pdf](https://github.com/chrplr/goxpyriment/blob/main/paper/goxpyriment_paper.pdf) which describes the goals and features of the framework. 

Then, to go further:

| Document | | PDF |
|---|---|---|
| [Installation](Installation.md) | Install Go and build the examples | [↓](Installation.pdf) |
| [Getting Started](GettingStarted.md) | Tutorials | [↓](GettingStarted.pdf) |
| [Gallery of Examples](GalleryOfExamples.md) | Ready-to-run experiments and demos | |
| [User Manual](UserManual.md) | Core concepts explained in depth | [↓](UserManual.pdf) |
| [Migration Guide](MigrationGuide.md) | Coming from Expyriment, PsychoPy, or Psychtoolbox? | [↓](MigrationGuide.pdf) |
| [API Reference](API.md) | Complete function and type reference | [↓](API.pdf) |

---

## Quick Start

* Download and install Go from <https://go.dev> (See [Installing-a-development-environment.md](Installing-a-development-environment.md) if you are new to this).

* Clone goxpriment and check that you can compile the examples, by executing the following commands in a Terminal (`Git Bash` for Windows):


        git clone https://github.com/chrplr/goxpyriment.git
        cd goxpyriment
        make examples


* Create a `hello` folder somewhere on your computer, and create  `main.go` inside it, containing the following code:

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

* Initialize dependencies in the `hello` folder:

    ```bash
    go mod init hello
    go mod tidy
    ```

* Run your program


    ```bash
    go run .
    ```

---

## Ready-to-run experiments

Pre-built binaries (ready-to run apps) of many experiment are available for Windows, macOS, and Linux on the
[Releases page](https://github.com/chrplr/goxpyriment/releases).

---

## Background

Goxpyriment relies on [libsdl](http://libsdl.org) via the [go-sdl3](https://github.com/Zyko0/go-sdl3) bindings.

It was inspired by [expyriment.org](https://github.com/expyriment/expyriment), a lightweight Python library for cognitive and neuroscientific experiments (Krause & Lindemann, 2014. *Behavior Research Methods*, 46(2), 416–428. <https://doi.org/10.3758/s13428-013-0390-6>). The API should feel familiar to expyriment users.

---

## License & citation

GNU GPL v3 — see [LICENSE](https://github.com/chrplr/goxpyriment/blob/main/LICENSE.txt).

Please cite as:
> Christophe Pallier (2026) chrplr/goxpyriment. Zenodo. https://doi.org/10.5281/zenodo.19200598


[Christophe Pallier](http://github.com/chrplr), 2026.
