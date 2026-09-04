#!/bin/sh
#  =============================================================================
#  Hook post-commit: automatyczne wersjonowanie po każdym commicie
#  (instaluje: make git-init; szablon: make-templ/post-commit.githook.tpl)
#  -----------------------------------------------------------------------------
#  Działanie:
#    1. Commit z prefiksem "bump:" w temacie -> nic nie robi (to commit hooka,
#       więc pętla jest wygaszana).
#    2. Brak commitizen (cz) w PATH -> tylko komunikat informacyjny;
#       ręczna ścieżka wersjonowania: make bump LEVEL=patch|minor|major
#    3. Jest cz -> cz bump --yes --files-only (podbija VERSION, alire.toml.tpl,
#       .cz.toml.tpl wg .cz.toml.tpl), potem dokleja sufiks +git.<hash> do VERSION
#       i commituje to jako "bump: version -> X.Y.Z".
#  =============================================================================
LAST_MSG=$(git log -1 --pretty=%B)

case "$LAST_MSG" in
    bump:*|*bump:*)
        exit 0
        ;;
esac

if ! command -v cz >/dev/null 2>&1; then
    echo "[post-commit] commitizen (cz) niezainstalowany - pomijam auto-bump wersji."
    echo "[post-commit] reczna sciezka: make bump LEVEL=patch|minor|major"
    exit 0
fi

#  Automatyczne podbicie wersji przez Commitizen
cz bump --yes --files-only 2>/dev/null || true

#  Pobranie nowej wersji bazowej i hasha
GIT_HASH=$(git rev-parse --short HEAD)
BASE_VER=$(cut -d"+" -f1 < VERSION 2>/dev/null)

if [ -n "$BASE_VER" ]; then
    echo "$BASE_VER+git.$GIT_HASH" > VERSION
    #  Dodajemy pliki osobno: git add przerywa calosc (exit 128), gdy ktoregos
    #  z plikow brak (np. alire.toml.tpl przed pierwszym alr init).
    git add VERSION 2>/dev/null
    if [ -f alire.toml ]; then git add alire.toml 2>/dev/null; fi
    if [ -f .cz.toml ]; then git add .cz.toml 2>/dev/null; fi
    git commit -m "bump: version -> $BASE_VER" 2>/dev/null || true
fi
