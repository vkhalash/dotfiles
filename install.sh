#!/usr/bin/env bash

set -e
mkdir -p "$HOME/.cache/zsh"
mkdir -p "$HOME/.config/Code/User"
stow -v */
