# goxpyriment


`goxpyriment` is a high-level Go framework for building behavioral and psychological experiments with precise stimulus timing.


* Full documentation: <https://chrplr.github.io/goxpyriment>
* Gallery of Examples: [source code](./examples/)
* [Google group](https://groups.google.com/a/pallier.org/g/goxpyriment) — Forum
* Report bugs at <https://github.com/chrplr/goxpyriment/issues>

If you are looking for a simpler, *no-code experiment generator*, check out [Gostim2](https://chrplr.github.io/gostim2/).

> [WARNING!] This software is in beta-testing. 

---

## Why goxpyriment?

1. **Zero-dependency deployment.** A finished experiment compiles to a single binary — an `.exe` on Windows, an AppImage on Linux, a `.app` on macOS. No Python, no conda, no DLL hell on lab computers.
2. **Timing precision.** The stimulus loop runs VSYNC-locked with GC pauses disabled, giving sub-millisecond frame jitter on typical hardware.
3. **AI-friendly API.** The linear, consistent API is well suited to "vibe-coding" — describe your paradigm in plain language to Claude, Gemini, or ChatGPT and the generated code is usually 90 % ready to run immediately.

> 💡 **TIP:** _AI assisted coding_ After cloning the repository, launch an AI coding agent inside the `goxpyriment` folder and ask it to add a new experiment to the `examples` folder — the agent reads the existing examples for context. Describe the experiment (stimuli, design, etc.) in plain language. Save your prompt in a `description.md` file alongside the code.

> ⚠️ **Beta:** This software is in beta-testing. Although it is usable for real lab experiments, users should (as always) carefully test their program's behaviour, e.g. with a [bbtk](https://chrplr.github.io/bbtkv3/).

---

## Documentation

| Document | | PDF |
|---|---|---|
| [Installation](docs/Installation.md) | Install Go and build the examples | [↓](docs/Installation.pdf) |
| [Getting Started](docs/GettingStarted.md) | Tutorial for psychologists | [↓](docs/GettingStarted.pdf) |
| [Gallery of Examples](docs/GalleryOfExamples.md) | Ready-to-run experiments and demos | |
| [User Manual](docs/UserManual.md) | Core concepts explained in depth | [↓](docs/UserManual.pdf) |
| [Migration Guide](docs/MigrationGuide.md) | Coming from Expyriment, PsychoPy, or Psychtoolbox? | [↓](docs/MigrationGuide.pdf) |
| [API Reference](docs/API.md) | Complete function and type reference | [↓](docs/API.pdf) |


---

Inspired by [expyriment.org](https://github.com/expyriment/expyriment). Built on [libsdl](http://libsdl.org) via [go-sdl3](https://github.com/Zyko0/go-sdl3). Licensed under the GNU GPL v3.

Please cite this repository as:
> Christophe Pallier (2026) Goxpyriment vX.Y.Z. Zenodo. https://doi.org/10.5281/zenodo.19200598


[Christophe Pallier](https://github.com/chrplr)
---

![](assets/icon_512.png)
