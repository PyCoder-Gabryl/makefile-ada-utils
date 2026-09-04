# ============================================================================
# PROJECT:         Makefile System
# AUTHOR:          PyCoder Gabryl
# GITHUB:          https://github.com/PyCoder-Gabryl
# EMAIL:           pycoder.gabryl@gmail.com
# LICENSE:         Apache 2.0
# ----------------------------------------------------------------------------
# DESCRIPTION:     Moduł narzędzi diagnostycznych i administracyjnych.
#                  Obsługuje weryfikację środowiska (doctor), kontrolę
#                  semantyki (gnatc), formatowanie stylu kodu (gnatpp),
#                  zbieranie metryk złożoności (gnatmetric), podbijanie wersji
#                  oraz modularny system zrzutów kontekstu (dump-txt/).
# ----------------------------------------------------------------------------
# PATH:            make-tools/modules/04-utils.mk
# CREATED:         2026-09-04
# ============================================================================

DUMP_DIR := dump-txt

## help-utils: Pomoc dla sekcji narzędzi diagnostycznych i administracyjnych
help-utils:
	@echo "$(C_BLUE)--- GRUPA: NARZĘDZIA I DIAGNOSTYKA ---$(C_RESET)"
	@echo "  make doctor          - Diagnostyka środowiska (wykrywa narzędzia systemowe i Alire)"
	@echo "  make syntax          - Szybkie sprawdzenie poprawności semantycznej (gnatc)"
	@echo "  make format          - Automatyczne formatowanie stylu kodu (gnatpp)"
	@echo "  make metrics (mt)    - Analiza metryk kodu i złożoności McCabe'a (gnatmetric)"
	@echo "  make bump LEVEL=x    - Podbicie wersji projektu (patch/minor/major)"
	@echo "  make help-dump       - Wyświetla pomoc dedykowaną dla zrzutów kontekstu (dump-txt/)"
	@echo "  $(C_GREEN)make check$(C_RESET)           - Szybki przegląd jakości kodu (doctor -> syntax -> format)"

## help-dump: Pomoc dla modułowego systemu zrzutów kontekstu do folderu dump-txt/
help-dump:
	@echo "$(C_BLUE)--- POMOC: SYSTEM ZRZUTÓW KONTEKSTU ($(DUMP_DIR)/) ---$(C_RESET)"
	@echo "  make dump-tree       - Zrzut drzewa istotnych plików projektu (bez artefaktów)"
	@echo "  make dump-tree-dir   - Zrzut wyłącznie samej struktury katalogów projektu"
	@echo "  make dump-project    - Zrzut metadanych projektu (alire, gpr, version, roadmap, lic)"
	@echo "  make dump-editor     - Zrzut plików konfiguracyjnych edytora i formatowania"
	@echo "  make dump-src        - Zrzut wyłącznie kodu źródłowego aplikacji (src/)"
	@echo "  make dump-data       - Zrzut konfiguracji, schematów i zasobów (data/)"
	@echo "  make dump-src-data   - Zrzut łączony kodu aplikacji (src/) oraz danych (data/)"
	@echo "  make dump-tests      - Zrzut uprzęży i przypadków testowych (tests/)"
	@echo "  make dump-makefile   - Zrzut głównego Makefile oraz modułów make-tools/"
	@echo "                         (Alias: make dump-make)"
	@echo "  make dump-clean      - Czyszczenie wygenerowanych zrzutów z katalogu $(DUMP_DIR)/"
	@echo "                         (Alias: make clean-dump)"
	@echo "  $(C_GREEN)make dump-full$(C_RESET)       - Agregat: tworzy pełny zrzut do $(DUMP_DIR)/00-full.txt"
	@echo "                         (Alias: make dump-all)"

## check: Szybki przegląd (doctor -> syntax -> format)
check:
	$(call print_banner,make check)
	@$(MAKE) --no-print-directory doctor
	@$(MAKE) --no-print-directory syntax
	@$(MAKE) --no-print-directory format

## doctor: Diagnostyka środowiska: narzędzia OK/BRAK + wykryte ścieżki
doctor:
	$(call print_banner,make doctor)
	@echo "$(C_BLUE)==> Diagnostyka środowiska deweloperskiego Ada / Alire...$(C_RESET)"
	@MISS=0; \
	for t in alr git gh zip; do \
		if command -v $$t >/dev/null 2>&1; then \
			printf "  $(C_GREEN)[OK]  $(C_RESET) %-10s %s\n" "$$t" "$$(command -v $$t)"; \
		else \
			printf "  $(C_RED)[BRAK]$(C_RESET) %s\n" "$$t"; MISS=$$((MISS + 1)); \
		fi; \
	done; \
	for t in gprbuild gnatprove gnatcov; do \
		if alr exec -- command -v $$t >/dev/null 2>&1; then \
			printf "  $(C_GREEN)[OK]  $(C_RESET) %-10s %s\n" "$$t" "$$(alr exec -- command -v $$t)"; \
		else \
			printf "  $(C_RED)[BRAK]$(C_RESET) %s (w środowisku Alire)\n" "$$t"; \
			MISS=$$((MISS + 1)); \
		fi; \
	done; \
	echo "  ----------------------------------------------------------------"; \
	printf "  Plik projektu  : %s\n" "$(GPR_FILE)"; \
	printf "  Nazwa projektu : %s\n" "$(PROJECT_NAME)"; \
	printf "  Aktualna wersja: %s\n" "$(VERSION)"; \
	if [ $$MISS -gt 0 ]; then \
		echo "$(C_YELLOW)==> Liczba brakujących narzędzi: $$MISS$(C_RESET)"; \
	else \
		echo "$(C_GREEN)==> Wszystkie wymagane narzędzia są obecne i skonfigurowane.$(C_RESET)"; \
	fi

## syntax: Szybkie sprawdzenie poprawności semantyki (gnatc)
syntax:
	@echo "$(C_BLUE)==> Sprawdzanie poprawności semantycznej i składniowej (gnatc)...$(C_RESET)"
	@echo "    Weryfikacja reguł języka Ada 2022 bez generowania kodu maszynowego"
	@alr exec gprbuild -- -c -gnatc -P $(GPR_FILE)
	@echo "$(C_GREEN)==> Semantyka i składnia w jednostkach projektu są poprawne.$(C_RESET)"

## format: Automatyczne formatowanie kodu źródłowego (gnatpp)
format:
	@echo "$(C_BLUE)==> Automatyczne formatowanie kodu źródłowego (gnatpp)...$(C_RESET)"
	@echo "    Egzekwowanie reguł stylu (standard 3 spacji, dwukropki, UTF-8)"
	@alr exec gnatpp -- -P $(GPR_FILE) -rf -W8
	@$(RM) src/*.npp src/**/*.npp
	@echo "$(C_GREEN)==> Formatowanie kodu źródłowego zakończone pomyślnie.$(C_RESET)"

## metrics: Analizuje złożoność cyklomatyczną i kontrakty
metrics mt:
	@echo "$(C_BLUE)==> Analiza metryk inżynieryjnych kodu (gnatmetric)...$(C_RESET)"
	@echo "    Pomiar złożoności cyklomatycznej McCabe'a, linii kodu i kontraktów SPARK"
	@alr exec gnatmetric -- -P $(GPR_FILE)
	@echo "$(C_GREEN)==> Raport metryk wygenerowany do pliku bielik_metrics.txt.$(C_RESET)"

## bump: Podbija wersję (VERSION + alire.toml) o LEVEL
bump:
	@case "$(LEVEL)" in patch|minor|major) : ;; *) \
		echo "$(C_RED)Błąd: Użycie: make bump LEVEL=patch|minor|major$(C_RESET)"; exit 1 ;; esac; \
	V=$$(cut -d"+" -f1 < VERSION 2>/dev/null || echo "0.1.0"); \
	MAJ=$$(echo "$$V" | cut -d. -f1); MIN=$$(echo "$$V" | cut -d. -f2); PAT=$$(echo "$$V" | cut -d. -f3); \
	case "$(LEVEL)" in \
		patch) PAT=$$((PAT + 1)) ;; \
		minor) MIN=$$((MIN + 1)); PAT=0 ;; \
		major) MAJ=$$((MAJ + 1)); MIN=0; PAT=0 ;; \
	esac; \
	NV="$$MAJ.$$MIN.$$PAT"; echo "$$NV" > VERSION; \
	if [ -f alire.toml ]; then \
		sed -i.bak -e 's/^version = .*/version = "'$$NV'"/' alire.toml && \
		rm -f alire.toml.bak; \
	fi; \
	echo "$(C_GREEN)==> Podbito numer wersji: $$V -> $$NV$(C_RESET)"

#  =============================================================================
#  MODULARNY SYSTEM ZRZUTÓW KONTEKSTU (dump-txt/)
#  =============================================================================

## dump-clean: Usuwa wygenerowane pliki zrzutów z katalogu dump-txt/
dump-clean:
	@echo "$(C_YELLOW)==> Czyszczenie katalogu zrzutów $(DUMP_DIR)...$(C_RESET)"
	@$(RM) $(DUMP_DIR) context.txt
	@echo "$(C_GREEN)==> Katalog $(DUMP_DIR) został usunięty.$(C_RESET)"

## dump-tree: Zrzut drzewa istotnych plików projektu (bez artefaktów i bibliotek)
dump-tree:
	@mkdir -p $(DUMP_DIR)
	@echo "$(C_BLUE)==> Generowanie drzewa plików do $(DUMP_DIR)/tree.txt...$(C_RESET)"
	@printf "=== DRZEWO PLIKÓW PROJEKTU %s (%s) ===\n\n" "$(PROJECT_NAME)" "$$(date)" \
		> $(DUMP_DIR)/tree.txt
	@find . -not -path '*/.*' \
		-not -path './obj*' \
		-not -path './bin*' \
		-not -path './alire*' \
		-not -path './gnatcov_rts*' \
		-not -path './coverage_report*' \
		-not -path './$(DUMP_DIR)*' \
		-not -name '*.iml' \
		-not -name '*.trace' \
		-not -name '*.map' \
		| sort >> $(DUMP_DIR)/tree.txt
	@echo "$(C_GREEN)==> Zapisano drzewo plików: $(DUMP_DIR)/tree.txt$(C_RESET)"

## dump-tree-dir: Zrzut wyłącznie samej struktury katalogów projektu
dump-tree-dir:
	@mkdir -p $(DUMP_DIR)
	@echo "$(C_BLUE)==> Generowanie struktury katalogów do $(DUMP_DIR)/tree-dir.txt...$(C_RESET)"
	@printf "=== STRUKTURA KATALOGÓW %s (%s) ===\n\n" "$(PROJECT_NAME)" "$$(date)" \
		> $(DUMP_DIR)/tree-dir.txt
	@find . -type d \
		-not -path '*/.*' \
		-not -path './obj*' \
		-not -path './bin*' \
		-not -path './alire*' \
		-not -path './gnatcov_rts*' \
		-not -path './coverage_report*' \
		-not -path './$(DUMP_DIR)*' \
		| sort >> $(DUMP_DIR)/tree-dir.txt
	@echo "$(C_GREEN)==> Zapisano strukturę katalogów: $(DUMP_DIR)/tree-dir.txt$(C_RESET)"

## dump-project: Zrzut metadanych projektu (alire, gpr, version, roadmap, lic)
dump-project:
	@mkdir -p $(DUMP_DIR)
	@echo "$(C_BLUE)==> Generowanie zrzutu metadanych do $(DUMP_DIR)/project.txt...$(C_RESET)"
	@printf "=== METADANE PROJEKTU %s (%s) ===\n" "$(PROJECT_NAME)" "$$(date)" \
		> $(DUMP_DIR)/project.txt
	@for f in VERSION alire.toml $(GPR_FILE) ROADMAP.md README.md LICENSE commit.md; do \
		if [ -f "$$f" ]; then \
			printf "\n--- PLIK: %s ---\n" "$$f" >> $(DUMP_DIR)/project.txt; \
			cat "$$f" >> $(DUMP_DIR)/project.txt; \
		fi; \
	done
	@echo "$(C_GREEN)==> Zapisano metadane projektu: $(DUMP_DIR)/project.txt$(C_RESET)"

## dump-editor: Zrzut plików konfiguracyjnych edytora i formatowania
dump-editor:
	@mkdir -p $(DUMP_DIR)
	@echo "$(C_BLUE)==> Generowanie zrzutu edytora do $(DUMP_DIR)/editor.txt...$(C_RESET)"
	@printf "=== KONFIGURACJA EDYTORA I NARZĘDZI (%s) ===\n" "$$(date)" \
		> $(DUMP_DIR)/editor.txt
	@for f in .editorconfig .clang-format .cz.toml .gitignore; do \
		if [ -f "$$f" ]; then \
			printf "\n--- PLIK: %s ---\n" "$$f" >> $(DUMP_DIR)/editor.txt; \
			cat "$$f" >> $(DUMP_DIR)/editor.txt; \
		fi; \
	done
	@echo "$(C_GREEN)==> Zapisano konfigurację edytora: $(DUMP_DIR)/editor.txt$(C_RESET)"

## dump-src: Zrzut wyłącznie kodu źródłowego aplikacji (src/)
dump-src:
	@mkdir -p $(DUMP_DIR)
	@echo "$(C_BLUE)==> Generowanie zrzutu kodu do $(DUMP_DIR)/src.txt...$(C_RESET)"
	@printf "=== KOD ŹRÓDŁOWY APLIKACJI %s (%s) ===\n" "$(PROJECT_NAME)" "$$(date)" \
		> $(DUMP_DIR)/src.txt
	@find src -type f \( -name "*.ads" -o -name "*.adb" \) | sort | while read -r f; do \
		printf "\n--- PLIK: %s ---\n" "$$f" >> $(DUMP_DIR)/src.txt; \
		cat "$$f" >> $(DUMP_DIR)/src.txt; \
	done
	@echo "$(C_GREEN)==> Zapisano kod źródłowy: $(DUMP_DIR)/src.txt$(C_RESET)"

## dump-data: Zrzut konfiguracji, schematów i zasobów (data/)
dump-data:
	@mkdir -p $(DUMP_DIR)
	@echo "$(C_BLUE)==> Generowanie zrzutu danych do $(DUMP_DIR)/data.txt...$(C_RESET)"
	@printf "=== ZASOBY I KONFIGURACJA %s (%s) ===\n" "$(PROJECT_NAME)" "$$(date)" \
		> $(DUMP_DIR)/data.txt
	@find data -type f \( -name "*.toml" -o -name "*.adc" -o -name "*.json" \
		-o -name "*.txt" \) | sort | while read -r f; do \
		printf "\n--- PLIK: %s ---\n" "$$f" >> $(DUMP_DIR)/data.txt; \
		cat "$$f" >> $(DUMP_DIR)/data.txt; \
	done
	@echo "$(C_GREEN)==> Zapisano zasoby i konfigurację: $(DUMP_DIR)/data.txt$(C_RESET)"

## dump-src-data: Zrzut łączony kodu aplikacji (src/) oraz danych (data/)
dump-src-data: dump-src dump-data
	@mkdir -p $(DUMP_DIR)
	@echo "$(C_BLUE)==> Łączenie kodu i danych do $(DUMP_DIR)/src-data.txt...$(C_RESET)"
	@cat $(DUMP_DIR)/src.txt $(DUMP_DIR)/data.txt > $(DUMP_DIR)/src-data.txt
	@echo "$(C_GREEN)==> Zapisano połączony pakiet: $(DUMP_DIR)/src-data.txt$(C_RESET)"

## dump-tests: Zrzut uprzęży i przypadków testowych (tests/)
dump-tests:
	@mkdir -p $(DUMP_DIR)
	@echo "$(C_BLUE)==> Generowanie zrzutu testów do $(DUMP_DIR)/tests.txt...$(C_RESET)"
	@printf "=== PAKIET TESTÓW JEDNOSTKOWYCH (%s) ===\n" "$$(date)" \
		> $(DUMP_DIR)/tests.txt
	@find tests -type f \( -name "*.gpr" -o -name "*.ads" -o -name "*.adb" \) \
		| sort | while read -r f; do \
		printf "\n--- PLIK: %s ---\n" "$$f" >> $(DUMP_DIR)/tests.txt; \
		cat "$$f" >> $(DUMP_DIR)/tests.txt; \
	done
	@echo "$(C_GREEN)==> Zapisano uprząż testową: $(DUMP_DIR)/tests.txt$(C_RESET)"

## dump-makefile: Zrzut głównego Makefile oraz modułów make-tools/
dump-makefile dump-make:
	@mkdir -p $(DUMP_DIR)
	@echo "$(C_BLUE)==> Generowanie zrzutu automatyzacji do $(DUMP_DIR)/makefile.txt...$(C_RESET)"
	@printf "=== SYSTEM AUTOMATYZACJI MAKEFILE (%s) ===\n" "$$(date)" \
		> $(DUMP_DIR)/makefile.txt
	@if [ -f Makefile ]; then \
		printf "\n--- PLIK: Makefile ---\n" >> $(DUMP_DIR)/makefile.txt; \
		cat Makefile >> $(DUMP_DIR)/makefile.txt; \
	fi
	@find make-tools/modules -name "*.mk" | sort | while read -r f; do \
		printf "\n--- PLIK: %s ---\n" "$$f" >> $(DUMP_DIR)/makefile.txt; \
		cat "$$f" >> $(DUMP_DIR)/makefile.txt; \
	done
	@echo "$(C_GREEN)==> Zapisano system automatyzacji: $(DUMP_DIR)/makefile.txt$(C_RESET)"

## dump-full: Agregat: generuje wszystkie zrzuty wyłącznie do dump-txt/00-full.txt
dump-full dump-all:
	$(call print_banner,make dump-full)
	@echo "$(C_YELLOW)==> Czyszczenie katalogu zrzutów $(DUMP_DIR)...$(C_RESET)"
	@$(RM) $(DUMP_DIR)
	@mkdir -p $(DUMP_DIR)
	@echo "$(C_BLUE)==> Generowanie pełnego audytu do $(DUMP_DIR)/00-full.txt...$(C_RESET)"
	@$(MAKE) --no-print-directory dump-tree
	@$(MAKE) --no-print-directory dump-tree-dir
	@$(MAKE) --no-print-directory dump-project
	@$(MAKE) --no-print-directory dump-editor
	@$(MAKE) --no-print-directory dump-src
	@$(MAKE) --no-print-directory dump-data
	@$(MAKE) --no-print-directory dump-tests
	@$(MAKE) --no-print-directory dump-makefile
	@cat $(DUMP_DIR)/tree.txt \
		$(DUMP_DIR)/tree-dir.txt \
		$(DUMP_DIR)/project.txt \
		$(DUMP_DIR)/editor.txt \
		$(DUMP_DIR)/src.txt \
		$(DUMP_DIR)/data.txt \
		$(DUMP_DIR)/tests.txt \
		$(DUMP_DIR)/makefile.txt > $(DUMP_DIR)/00-full.txt
	@echo "$(C_GREEN)======================================================================$(C_RESET)"
	@echo "$(C_GREEN)==> Kompletny zrzut projektu gotowy: $(DUMP_DIR)/00-full.txt$(C_RESET)"
	@echo "$(C_GREEN)======================================================================$(C_RESET)"

.PHONY: help-utils help-dump check doctor syntax format metrics mt bump \
        dump-clean dump-tree dump-tree-dir dump-project dump-editor dump-src \
        dump-data dump-src-data dump-tests dump-makefile dump-make dump-full \
        dump-all
