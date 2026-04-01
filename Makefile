.PHONY: all examples update-readme tests pdfs docs serve deploy clean help

EXAMPLES := $(shell find examples -maxdepth 2 -name main.go \
               | xargs -I{} dirname {} | sort)

TESTS := $(shell find tests -maxdepth 2 -name main.go \
            | xargs -I{} dirname {} | sort)


# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------

help:
	@echo "Available targets:"
	@echo "  help      Show this message"
	@echo "  all       Build all examples and tests to _build / (default)"
	@echo "  examples       Same as target "all"<Down>Build all examples to _build/"
	@echo "  update-readme  Regenerate examples/README.md tables from meta.yaml files"
	@echo "  run-NAME       Build and run a single example (e.g. make run-parity_decision)"
	@echo "  tests     Build test binaries"
	@echo "  pdfs      Generate PDF docs via pandoc + xelatex"
	@echo "  docs      Build Zensical HTML site to site/"
	@echo "  serve     Live-reload docs preview at http://127.0.0.1:8000"
	@echo "  deploy    Generate PDFs and build docs (GitHub Actions pushes to Pages)"
	@echo "  clean     Remove _build/ and site/"



all: examples tests

# ---------------------------------------------------------------------------
# Examples
# ---------------------------------------------------------------------------

# Build all examples; binaries go to _build/
examples:
	@mkdir -p _build
	@for dir in $(EXAMPLES); do \
	  name=$$(basename $$dir); \
	  echo "Building $$name..."; \
	  (cd $$dir && CGO_ENABLED=0 go build -o "$(CURDIR)/_build/$$name" .); \
	done

# Regenerate the examples/README.md tables from per-example meta.yaml files.
update-readme:
	@cd examples && go run ./cmd/gen-readme/

# Build and run a single example: make run-hello_world
run-%:
	@(cd examples/$* && CGO_ENABLED=0 go run .)

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

# Build all tests; binaries go to _build/
tests:
	@mkdir -p _build
	@for dir in $(TESTS); do \
	  name=$$(basename $$dir); \
	  echo "Building $$name..."; \
	  (cd $$dir && CGO_ENABLED=0 go build -o "$(CURDIR)/_build/$$name" .); \
	done

# ---------------------------------------------------------------------------
# Documentation
# ---------------------------------------------------------------------------

# Generate PDF versions of the documentation.
# Requires: pandoc, xelatex  (sudo apt install pandoc texlive-xetex)
pdfs:
	bash docs/make_pdfs.sh

# Build the Zensical HTML site locally (output → site/).
docs:
	zensical build --clean

# Live-reload preview at http://127.0.0.1:8000
serve:
	zensical serve

# Generate PDFs and build docs locally.
# GitHub Actions (.github/workflows/docs.yml) handles the push to GitHub Pages.
deploy: pdfs docs

# ---------------------------------------------------------------------------
# Clean
# ---------------------------------------------------------------------------

clean:
	rm -rf _build/ site/

