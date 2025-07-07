# Directories to exclude from processing (space-separated)
EXCLUDE_DIRS := .git

# Convert to find-compatible format
FIND_EXCLUDE := $(foreach dir,$(EXCLUDE_DIRS),-path "./$(dir)" -prune -o)

.PHONY: format all check-deps show clean help

default: help

# Check if tools are installed and give installation instructions
check-deps:
	@echo "Checking dependencies..."
	@if ! which perltidy >/dev/null 2>&1; then \
		echo "❌ perltidy not found"; \
		echo "   Install with: brew install perltidy  OR cpm install -g Perl::Tidy"; \
	else \
		echo "✅ perltidy found"; \
	fi
	@if ! which Rscript >/dev/null 2>&1; then \
		echo "❌ Rscript not found"; \
		echo "   Install R from: https://r-project.org  OR  brew install r"; \
	else \
		echo "✅ Rscript found"; \
	fi
	@if ! which prettier >/dev/null 2>&1; then \
		echo "❌ prettier not found"; \
		echo "   Install with: npm install -g prettier  OR  brew install prettier"; \
	else \
		echo "✅ prettier found"; \
	fi
	@if ! which shfmt >/dev/null 2>&1; then \
		echo "❌ shfmt not found"; \
		echo "   Install with: brew install shfmt  OR  go install mvdan.cc/sh/v3/cmd/shfmt@latest"; \
	else \
		echo "✅ shfmt found"; \
	fi
	@echo ""
	@echo "Please manually check R::styler is installed."
	@echo "  To install: Rscript src/install_r_packages.R styler"
	@echo ""

format:
	@echo "Formatting files..."
	@if which perltidy >/dev/null 2>&1; then \
		find . $(FIND_EXCLUDE) \( -name "*.pl" -o -name "*.pm" -o -name "*.t" \) -print0 | xargs -0 perltidy --pro=.perltidyrc -b; \
	else \
		echo "⚠️  Skipping Perl files (perltidy not installed - run 'make check-deps')"; \
	fi
	@if which Rscript >/dev/null 2>&1; then \
		if Rscript -e "if (!requireNamespace('styler', quietly=TRUE)) quit(status=1)" 2>/dev/null; then \
			find . $(FIND_EXCLUDE) -name "*.R" -print0 | xargs -0 -I {} Rscript -e "styler::style_file('{}')"; \
		else \
			echo "⚠️  Skipping R files (styler package not installed)"; \
		fi; \
	else \
		echo "⚠️  Skipping R files (Rscript not installed - run 'make check-deps')"; \
	fi
	@if which prettier >/dev/null 2>&1; then \
		find . $(FIND_EXCLUDE) \( -name "*.md" -o -name "*.markdown" \) -print0 | xargs -0 prettier --write; \
	else \
		echo "⚠️  Skipping markdown files (prettier not installed - run 'make check-deps')"; \
	fi
	@if which shfmt >/dev/null 2>&1; then \
		find . $(FIND_EXCLUDE) \( -name "*.sh" -o -name "*.bash" \) -print0 | xargs -0 shfmt -w -i 2 -ci -sr; \
	else \
		echo "⚠️  Skipping shell files (shfmt not installed - run 'make check-deps')"; \
	fi

show:
	@echo "Files that would be processed:"
	@echo "Excluded directories: $(EXCLUDE_DIRS)"
	@echo ""
	@echo "Perl files:"
	@find . $(FIND_EXCLUDE) \( -name "*.pl" -o -name "*.pm" -o -name "*.t" \) -print | head -5
	@echo "R files:"
	@find . $(FIND_EXCLUDE) -name "*.R" -print | head -5
	@echo "Markdown files:"
	@find . $(FIND_EXCLUDE) \( -name "*.md" -o -name "*.markdown" \) -print | head -5
	@echo "Shell files:"
	@find . $(FIND_EXCLUDE) \( -name "*.sh" -o -name "*.bash" \) -print | head -5

clean:
	@find . $(FIND_EXCLUDE) -name "*.bak" -print0 | xargs -0 rm -f

help:
	@echo "Available targets:"
	@echo "  check-deps      Check if required tools are installed"
	@echo "  format          Format all code files"
	@echo "  show            Show files that would be processed"
	@echo "  clean           Remove backup files"
	@echo "  all             Run format"
	@echo "  help            Show this help"
	@echo ""
	@echo "Excluded directories: $(EXCLUDE_DIRS)"