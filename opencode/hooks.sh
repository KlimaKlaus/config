#!/bin/bash
# OpenCode → cmux notification bridge

case "$1" in
  agent-complete)
    cmux notify \
      --title "OpenCode" \
      --subtitle "Task complete" \
      --body "$2"
    ;;
  agent-error)
    cmux notify \
      --title "OpenCode" \
      --subtitle "Error" \
      --body "$2"
    ;;
esac
