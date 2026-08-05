#!/usr/bin/env bash

set -e
mkdir -p "$HOME/.cache/zsh"
stow -v */
