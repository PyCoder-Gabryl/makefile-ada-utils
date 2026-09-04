#!/bin/sh
#  =============================================================================
#  Hook commit-msg: walidacja formatu commita (instaluje: make git-init)
#  Konwencja: "prefiks: opis po polsku" - szczegoly w CONTRIBUTING.md
#  =============================================================================
MSG_FILE="$1"
FIRST_LINE=$(head -n 1 "$MSG_FILE")

case "$FIRST_LINE" in
    add:*|fix:*|docs:*|test:*|refactor:*|style:*|perf:*|build:*|ci:*|chore:*|revert:*|release:*|bump:*|Merge*)
        exit 0
        ;;
esac

echo ""
echo "BLEDNY FORMAT COMMITA: $FIRST_LINE"
echo "Oczekiwano: prefiks: opis po polsku"
echo "Dozwolone prefiksy: add fix docs test refactor style perf build ci chore revert release"
echo "Szczegoly konwencji: CONTRIBUTING.md"
exit 1
