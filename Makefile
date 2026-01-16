.PHONY: help install

help:
	@echo "Available commands:"
	@echo "  make install  - Install dependencies"
	@echo "  make help     - Show this help"

install:
	@echo "Running install..."
	@./scripts/install.sh
