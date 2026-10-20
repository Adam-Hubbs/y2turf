#!/bin/sh
# Re-run whenever src/rust/Cargo.toml or Cargo.lock changes.
set -e
cd "$(dirname "$0")/../src/rust"
rm -rf vendor vendor.tar.xz
cargo vendor --locked vendor > /dev/null
tar --sort=name --mtime='1970-01-01' --owner=0 --group=0 --numeric-owner -cJf vendor.tar.xz vendor 2>/dev/null \
  || tar -cJf vendor.tar.xz vendor
rm -rf vendor
ls -lh vendor.tar.xz
