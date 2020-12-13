#!/usr/bin/env bash
# exit on error
set -o errexit

_build/prod/rel/butler/bin/butler eval "Butler.Release.migrate"
_build/prod/rel/butler/bin/butler start