#!/bin/sh
# ==============================================================================
# Git Hook: pre-push
# Weryfikuje jakość kodu przed wysłaniem na serwer zdalny (GitHub).
# ==============================================================================

remote="$1"
url="$2"

# Git przekazuje na standardowe wejście informacje o wypychanych referencjach:
# <lokalna_ref> <lokalny_sha> <zdalna_ref> <zdalny_sha>
while read -r local_ref local_oid remote_ref remote_oid; do
	# Wycięcie nazwy gałęzi docelowej (np. refs/heads/main -> main)
	target_branch=$(echo "$remote_ref" | sed 's@^refs/heads/@@')

	if [ "$target_branch" = "main" ] || [ "$target_branch" = "master" ]; then
		echo "==> [pre-push hook] Wykryto wypychanie na gałąź główną ($target_branch)."
		echo "==> [pre-push hook] Uruchamianie weryfikacji (make check && make test-all)..."

		# Sprawdzenie diagnostyki środowiska, składni i formatowania
		if ! make BANNER_SHOWN=1 check; then
			echo "==> [pre-push hook] BŁĄD: 'make check' nie powiodło się! Push zablokowany."
			echo "    Popraw błędy semantyczne lub sformatuj kod (make format)."
			exit 1
		fi

		# Sprawdzenie testów jednostkowych AUnit oraz analizy SPARK L1
		if ! make BANNER_SHOWN=1 test-all; then
			echo "==> [pre-push hook] BŁĄD: 'make test-all' nie powiodło się! Push zablokowany."
			echo "    Upewnij się, że testy AUnit i dowody SPARK przechodzą pomyślnie."
			exit 1
		fi

		echo "==> [pre-push hook] Weryfikacja jakości zakończona sukcesem. Push dozwolony."
	else
		echo "==> [pre-push hook] Gałąź robocza ($target_branch) - pomijam rygorystyczne testy."
	fi
done

exit 0
