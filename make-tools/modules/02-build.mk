# ============================================================================
# PROJECT:         Makefile System
# AUTHOR:          PyCoder Gabryl
# GITHUB:          https://github.com/PyCoder-Gabryl
# EMAIL:           pycoder.gabryl@gmail.com
# LICENSE:         Apache 2.0
# ----------------------------------------------------------------------------
# DESCRIPTION:     Moduł budowania, uruchamiania i wielopoziomowego sprzątania.
#                  Zarządza kompilacją deweloperską (-O0) i produkcyjną (-O2),
#                  uruchamianiem binarek oraz sprzątaniem artefaktów i logów.
# ----------------------------------------------------------------------------
# PATH:            make-tools/modules/02-build.mk
# CREATED:         2026-09-04
# ============================================================================

## help-build: Pomoc dla sekcji budowania i sprzątania
help-build:
	@echo "$(C_BLUE)--- GRUPA: BUDOWANIE I CZYSZCZENIE ---$(C_RESET)"
	@echo "  make build         - Kompilacja deweloperska (debug, asercje, symbole -O0)"
	@echo "  make build-release - Kompilacja produkcyjna (optymalizacja -O2, inlining)"
	@echo "  make run           - Uruchomienie programu przez środowisko Alire"
	@echo "  make run-bin       - Bezpośrednie uruchomienie pliku wykonywalnego z bin/"
	@echo "  make clean         - Usunięcie katalogów kompilacji, raportów i śladów"
	@echo "  make clean-logs    - Usunięcie katalogu logs/ i plików *.log"
	@echo "  make clean-dump    - Usunięcie katalogu zrzutów dump-txt/"
	@echo "  make clean-all     - Gruntowne czyszczenie deweloperskie (clean + zrzuty + config/)"
	@echo "  $(C_GREEN)make rebuild$(C_RESET)       - Pełna rekompilacja (clean -> build)"

## rebuild: Czysta kompilacja (clean -> build)
rebuild:
	$(call print_banner,make rebuild)
	@$(MAKE) --no-print-directory clean
	@$(MAKE) --no-print-directory build

## build: Budowanie projektu w trybie deweloperskim (debug)
build:
	@echo "$(C_BLUE)==> Kompilacja deweloperska projektu $(PROJECT_NAME) (debug)...$(C_RESET)"
	@echo "    Konfiguracja : symbole debuggera (-g), asercje włączone (-gnata), brak optymalizacji (-O0)"
	@echo "    Cel binarny  : bin/$(EXE_NAME)"
	@alr build -- -j0
	@echo "$(C_GREEN)==> Kompilacja deweloperska zakończona pomyślnie.$(C_RESET)"

## build-release: Budowanie produkcyjne z pełną optymalizacją (-O2)
build-release build-prod:
	@echo "$(C_BLUE)==> Kompilacja produkcyjna projektu $(PROJECT_NAME) (release)...$(C_RESET)"
	@echo "    Konfiguracja : zrównoważona optymalizacja (-O2), inlining funkcji (-gnatn)"
	@echo "    Cel binarny  : bin/$(EXE_NAME)"
	@alr build --release -- -j0
	@echo "$(C_GREEN)==> Kompilacja produkcyjna zakończona sukcesem.$(C_RESET)"

## run: Uruchamianie programu przez Alire
run:
	@echo "$(C_BLUE)==> Uruchamianie $(PROJECT_NAME) przez środowisko Alire...$(C_RESET)"
	@alr run

## run-bin: Uruchomienie zbudowanej binarki bezpośrednio z bin/
run-bin:
	@echo "$(C_BLUE)==> Bezpośrednie uruchamianie binarki: ./bin/$(EXE_NAME)...$(C_RESET)"
	@./bin/$(EXE_NAME)

## clean: Usuwanie plików binarnych, obiektowych i artefaktów kompilacji
clean:
	@echo "$(C_YELLOW)==> Czyszczenie projektu i artefaktów kompilacji...$(C_RESET)"
	@echo "    Usuwanie katalogów obiektowych i binarnych (obj/, bin/, tests/obj/, tests/bin/)..."
	@echo "    Usuwanie śladów wykonania i raportów pokrycia ($(COV_REPORT)/, $(COV_RTS_DIR)/, *.trace)..."
	@find . ~/.local/share/alire/builds -type f \
		\( -name "*.stdout" -o -name "*.stderr" -o -name "*.cswi" -o -name "*.lexch" \) \
		-delete 2>/dev/null || true
	@$(RM) obj bin tests/obj tests/bin $(COV_REPORT) $(COV_RTS_DIR) gnatcov_rts.gpr
	@$(RM) *.trace *.srctrace *.map bielik_metrics.txt src/*.npp src/**/*.npp
	@alr clean 2>&1 | grep -v "could not be removed" || true
	@echo "$(C_GREEN)==> Projekt został wyczyszczony.$(C_RESET)"

## clean-logs: Usuwa pliki dziennika zdarzeń i katalog logs/
clean-logs:
	@echo "$(C_YELLOW)==> Usuwanie plików dziennika (logs/)...$(C_RESET)"
	@$(RM) logs *.log *.stdout *.stderr
	@echo "$(C_GREEN)==> Pliki dziennika zostały usunięte.$(C_RESET)"

## clean-dump: Alias do czyszczenia katalogu zrzutów kontekstu
clean-dump: dump-clean

## clean-all: Gruntowne czyszczenie projektu z zachowaniem ekosystemu alire/
clean-all:
	$(call print_banner,make clean-all)
	@echo "$(C_YELLOW)==> Gruntowne czyszczenie środowiska deweloperskiego...$(C_RESET)"
	@$(MAKE) --no-print-directory clean
	@$(MAKE) --no-print-directory clean-logs
	@$(MAKE) --no-print-directory clean-dump
	@echo "    Usuwanie wygenerowanego folderu config/ (Alire) oraz zasobów share/..."
	@$(RM) config share dist bielik_install_manifest.xml
	@echo "$(C_GREEN)==> Wszystkie generowane zasoby projektu zostały usunięte.$(C_RESET)"

.PHONY: help-build rebuild build build-release build-prod run run-bin \
        clean clean-logs clean-dump clean-all
