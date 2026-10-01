{ pkgs, isync-oauth2 }:

pkgs.writeShellApplication {
  name = "mbsync-safe";

  runtimeInputs = with pkgs; [
    coreutils
    gnugrep
    util-linux
    oauth2ms
  ];

  text = ''
    set -euo pipefail

    # Use exactly the same mbsync build as programs.mbsync.package.
    # This wrapper provides SASL_PATH with XOAUTH2 support.
    MBSYNC="${isync-oauth2}/bin/mbsync"

    # Refuse a sync if it would mark for deletion or expunge more than
    # this many messages on the IMAP (Far) side.
    MAX_FAR_DELETE=50

    STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/mbsync-safe"
    LOG="$STATE_DIR/mbsync.log"

    mkdir -p "$STATE_DIR"

    # Prevent overlapping invocations. mu4e runs this periodically,
    # so a new invocation may otherwise start before the previous one
    # has finished.
    LOCK="''${XDG_RUNTIME_DIR:-/tmp}/mbsync-safe-$UID.lock"
    exec 9>"$LOCK"

    if ! flock -n 9; then
      # Another mbsync-safe invocation is already running.
      # This is expected and is not considered an error.
      exit 0
    fi

    timestamp() {
      date --iso-8601=seconds
    }

    save_diagnostic_log() {
      local prefix="$1"
      local content="$2"
      local ts
      local path

      ts="$(date +'%Y-%m-%dT%H-%M-%S%z')"
      path="$STATE_DIR/$prefix-$ts.log"

      printf '%s\n' "$content" > "$path"
      printf '%s\n' "$path"
    }

    #
    # 1. Dry run
    #

    set +e
    dry_run="$("$MBSYNC" -y -V -a 2>&1)"
    dry_status=$?
    set -e

    if (( dry_status != 0 )); then
      error_log="$(save_diagnostic_log "dry-run-error" "$dry_run")"

      printf '%s DRY-RUN ERROR exit=%d log=%s\n' \
        "$(timestamp)" \
        "$dry_status" \
        "$error_log" >> "$LOG"

      printf 'mbsync-safe: dry-run failed; see %s\n' \
        "$error_log" >&2

      exit "$dry_status"
    fi

    summary="$(
      printf '%s\n' "$dry_run" \
        | grep '^Channels:' \
        | tail -n 1 \
        || true
    )"

    if [[ -z "$summary" ]]; then
      error_log="$(save_diagnostic_log "unparseable" "$dry_run")"

      printf '%s PARSE ERROR log=%s\n' \
        "$(timestamp)" \
        "$error_log" >> "$LOG"

      printf 'mbsync-safe: no summary found; refusing to sync; see %s\n' \
        "$error_log" >&2

      exit 1
    fi

    printf '%s DRY  %s\n' \
      "$(timestamp)" \
      "$summary" >> "$LOG"

    #
    # Expected summary format:
    #
    # Channels: 1 Boxes: 6 Far: +0 *0 #0 -24 Near: +2 *0 #0 -0
    #
    # Far:
    #   +  copied/created
    #   *  flags changed
    #   #  marked deleted/trashed
    #   -  expunged
    #

    regex='Far:[[:space:]]+\+([0-9]+)[[:space:]]+\*([0-9]+)[[:space:]]+#([0-9]+)[[:space:]]+-([0-9]+)'

    if [[ "$summary" =~ $regex ]]; then
      far_trashed="''${BASH_REMATCH[3]}"
      far_expunged="''${BASH_REMATCH[4]}"
    else
      error_log="$(save_diagnostic_log "unparseable" "$dry_run")"

      printf '%s PARSE ERROR summary=%s log=%s\n' \
        "$(timestamp)" \
        "$summary" \
        "$error_log" >> "$LOG"

      printf 'mbsync-safe: cannot parse Far changes; refusing to sync; see %s\n' \
        "$error_log" >&2

      exit 1
    fi

    #
    # 2. Safety check
    #

    if (( far_trashed > MAX_FAR_DELETE ||
          far_expunged > MAX_FAR_DELETE )); then

      blocked_log="$(save_diagnostic_log "blocked" "$dry_run")"

      printf '%s BLOCKED Far#=%d Far-=%d limit=%d log=%s\n' \
        "$(timestamp)" \
        "$far_trashed" \
        "$far_expunged" \
        "$MAX_FAR_DELETE" \
        "$blocked_log" >> "$LOG"

      printf \
        'mbsync-safe: BLOCKED suspicious sync: Far #=%d -=%d (limit=%d)\n' \
        "$far_trashed" \
        "$far_expunged" \
        "$MAX_FAR_DELETE" >&2

      printf 'Full dry-run saved to: %s\n' \
        "$blocked_log" >&2

      exit 1
    fi

    #
    # 3. Real sync
    #

    set +e
    real_run="$("$MBSYNC" -V -a 2>&1)"
    real_status=$?
    set -e

    real_summary="$(
      printf '%s\n' "$real_run" \
        | grep '^Channels:' \
        | tail -n 1 \
        || true
    )"

    if (( real_status != 0 )); then
      error_log="$(save_diagnostic_log "sync-error" "$real_run")"

      printf '%s SYNC ERROR exit=%d log=%s\n' \
        "$(timestamp)" \
        "$real_status" \
        "$error_log" >> "$LOG"

      printf 'mbsync-safe: real sync failed; see %s\n' \
        "$error_log" >&2

      exit "$real_status"
    fi

    if [[ -n "$real_summary" ]]; then
      printf '%s REAL %s\n' \
        "$(timestamp)" \
        "$real_summary" >> "$LOG"
    else
      # Successful sync but unexpected output format. Preserve the output
      # so that this can be investigated without treating the completed
      # sync as a failure.
      diagnostic_log="$(save_diagnostic_log "sync-no-summary" "$real_run")"

      printf '%s REAL completed, no summary, log=%s\n' \
        "$(timestamp)" \
        "$diagnostic_log" >> "$LOG"
    fi
  '';
}
