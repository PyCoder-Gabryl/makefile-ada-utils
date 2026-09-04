# ============================================================================
# PROJECT:         Makefile System
# AUTHOR:          PyCoder Gabryl
# GITHUB:          https://github.com/PyCoder-Gabryl
# EMAIL:           pycoder.gabryl@gmail.com
# LICENSE:         Apache 2.0
# ----------------------------------------------------------------------------
# DESCRIPTION:     Moduł codziennego przepływu pracy z systemem Git (Git Workflow).
#                  Zarządza bezpieczną synchronizacją między maszynami (rebase),
#                  tworzeniem gałęzi roboczych, awaryjnym wypychaniem kodu
#                  oraz wizualizacją stanu repozytorium i historii commitów.
# ----------------------------------------------------------------------------
# PATH:            make-tools/modules/05-git.mk
# CREATED:         2026-09-04
# ============================================================================

## help-git: Spis poleceń modułu codziennej pracy z Git
help-git:
	@echo "$(C_BLUE)--- GRUPA: CODZIENNY PRZEPŁYW PRACY Z GIT ---$(C_RESET)"
	@echo "  make git-getsync          - Bezpieczna synchronizacja z GitHubem (pull --rebase)"
	@echo "  make git-branch [NAME=x]  - Utworzenie nowej gałęzi (pyta o nazwę, jeśli brak)"
	@echo "  make git-push-inprogress  - Wypchnięcie stanu roboczego bez testów (--no-verify)"
	@echo "  make git-status (gs)      - Przejrzysty stan repozytorium z kolorową legendą"
	@echo "  make git-log (gl)         - Kompaktowe drzewo ostatnich commitów w ASCII"
	@echo "  make git-workhelp         - Obszerny, edukacyjny przewodnik po Git i GitHubie"

## git-workhelp: Obszerny, kolorowy przewodnik edukacyjny po systemie Git w projekcie
git-workhelp:
	@echo "$(C_BLUE)======================================================================$(C_RESET)"
	@echo "$(C_BLUE)          PRZEWODNIK EDUKACYJNY: GIT I GITHUB W PROJEKCIE             $(C_RESET)"
	@echo "$(C_BLUE)======================================================================$(C_RESET)"
	@echo "$(C_GREEN)1. SYNCHRONIZACJA MIĘDZY MASZYNAMI (Komputer A <-> Komputer B):$(C_RESET)"
	@echo "   Gdy siadasz do drugiego komputera, ZANIM zaczniesz pisać kod:"
	@echo "   $(C_CYAN)make git-getsync$(C_RESET)"
	@echo "   Pobiera najnowsze commity i układa Twoją historię w idealną linię (rebase)."
	@echo ""
	@echo "$(C_GREEN)2. BEZPIECZNE ROZSZERZANIE KODU (Złota zasada gałęzi):$(C_RESET)"
	@echo "   Kod na gałęzi 'main' ZAWSZE musi działać. Gdy zaczynasz nowy element:"
	@echo "   $(C_CYAN)make git-branch$(C_RESET)  (lub np. make git-branch NAME=feature/menu)"
	@echo "   Przenosisz się do bezpiecznej piaskownicy. Jeśli eksperyment się nie uda,"
	@echo "   'main' pozostaje nienaruszony."
	@echo ""
	@echo "$(C_GREEN)3. TRANSFER KODU W TOKU PRAC (Work In Progress):$(C_RESET)"
	@echo "   Musisz pilnie wyjść, kod nie przechodzi testów, ale chcesz dokończyć na drugim Macu:"
	@echo "   Zrób commit w edytorze (Cmd+K), a następnie w terminalu wpisz:"
	@echo "   $(C_CYAN)make git-push-inprogress$(C_RESET)"
	@echo "   Wysyła kod na GitHuba, omijając lokalne testy i hooki (flaga --no-verify)."
	@echo ""
	@echo "$(C_GREEN)4. KONTROLA STANU I HISTORII:$(C_RESET)"
	@echo "   $(C_CYAN)make git-status (gs)$(C_RESET) - pokazuje co zmieniłeś, z kolorową legendą."
	@echo "   $(C_CYAN)make git-log (gl)$(C_RESET)    - rysuje kolorowe drzewko ostatnich 15 commitów."
	@echo "======================================================================"

## git-getsync: Bezpieczne pobranie najnowszego kodu z GitHuba (pull --rebase)
git-getsync:
	@CURR_BRANCH=$$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main"); \
	echo "$(C_BLUE)==> Pobieranie zmian z GitHuba dla gałęzi $${CURR_BRANCH} (rebase)...$(C_RESET)"; \
	git pull --rebase origin "$${CURR_BRANCH}" || { \
		echo "$(C_RED)Błąd: Wystąpił konflikt scalania podczas rebase.$(C_RESET)"; \
		echo "Rozwiąż konflikty w edytorze lub cofnij operację: git rebase --abort"; exit 1; \
	}; \
	echo "$(C_GREEN)==> Repozytorium jest zsynchronizowane i aktualne.$(C_RESET)"

## git-branch: Tworzy nową gałąź roboczą i od razu się na nią przełącza
git-branch:
	@B="$(NAME)"; \
	if [ -z "$$B" ]; then \
		echo "$(C_YELLOW)--- TWORZENIE NOWEJ GAŁĘZI ROBOCZEJ (BRANCH) ---$(C_RESET)"; \
		echo "Gałąź pozwala pisać nowy kod bez ryzyka zepsucia działającej wersji 'main'."; \
		printf "Podaj nazwę nowej gałęzi (np. feature/menu, fix/parser): "; \
		read -r B || B=""; \
	fi; \
	B=$$(printf '%s' "$$B" | tr ' ' '-' | sed 's/[^a-zA-Z0-9_\/\.-]//g'); \
	if [ -z "$$B" ]; then \
		echo "$(C_RED)Błąd: Nie podano nazwy gałęzi. Anulowano.$(C_RESET)"; exit 1; \
	fi; \
	echo "$(C_BLUE)==> Tworzenie i przełączanie na gałąź '$$B'...$(C_RESET)"; \
	git checkout -b "$$B" || git switch -c "$$B" || exit 1; \
	echo "$(C_GREEN)==> Jesteś teraz na bezpiecznej gałęzi roboczej '$$B'.$(C_RESET)"; \
	echo "    Możesz swobodnie modyfikować kod. Gdy skończysz, wrócisz na 'main'."

## git-push-inprogress: Wypycha kod na GitHub z pominięciem testów i hooków (--no-verify)
git-push-inprogress:
	@CURR_BRANCH=$$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main"); \
	echo "$(C_YELLOW)==> Wypychanie stanu roboczego (gałąź: $${CURR_BRANCH}) z --no-verify...$(C_RESET)"; \
	git push --no-verify -u origin "$${CURR_BRANCH}" || { \
		echo "$(C_RED)Błąd: Wypychanie nie powiodło się.$(C_RESET)"; exit 1; \
	}; \
	echo "$(C_GREEN)==> Kod roboczy został przesłany na GitHub. Możesz pobrać go na drugim komputerze.$(C_RESET)"

## git-status: Kompaktowy status repozytorium z objaśnieniem oznaczeń
git-status gs:
	@echo "$(C_BLUE)=== STAN REPOZYTORIUM GIT ===$(C_RESET)"
	@git status -s || exit 1
	@echo ""
	@echo "  \033[90mLegenda oznaczeń statusu:\033[0m"
	@echo "  \033[90m• ?? - plik nowy, nieśledzony w repozytorium\033[0m"
	@echo "  \033[90m•  M - plik zmodyfikowany lokalnie (nie w poczekalni)\033[0m"
	@echo "  \033[90m• M  - plik zmodyfikowany i przygotowany do commitu (staged)\033[0m"
	@echo "  \033[90m•  D - plik usunięty lokalnie\033[0m"
	@echo "  \033[90m----------------------------------------------------------------\033[0m"

## git-log: Przejrzyste, kolorowe drzewo ostatnich 15 commitów w terminalu
git-log gl:
	@echo "$(C_BLUE)=== DRZEWO OSTATNICH COMMITÓW (ASCII GRAPH) ===$(C_RESET)"
	@git log --graph --pretty=format:'%C(yellow)%h%Creset -%C(red)%d%Creset %s %C(green) \
		(%cr) %C(bold blue)<%an>%Creset' \
		--abbrev-commit -n 15 || exit 1
	@echo ""

.PHONY: help-git git-workhelp git-getsync git-branch git-push-inprogress \
        git-status gs git-log gl
