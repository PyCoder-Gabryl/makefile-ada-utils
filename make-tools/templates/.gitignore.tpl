# ==============================================================================
# PROJECT:          Makefile Ada Utils
# AUTHOR:           PyCoder Gabryl
# EMAIL:            pycoder.gabryl@gmail.com
# GITHUB:           https://github.com/PyCoder-Gabryl/
# LICENSE:          Apache License 2.0
# ------------------------------------------------------------------------------
# DESCRIPTION:      Uniwersalny plik .gitignore dla projektów Ada 2022 / SPARK
#                   narzędzi Alire, GPRbuild, GNATcov, systemów operacyjnych
#                   (macOS, Linux, Windows) oraz edytorów (JetBrains, VS Code).
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ARTEFAKTY KOMPILATORA GNAT I KOD MASZYNOWY
# ------------------------------------------------------------------------------
*.o
*.obj
*.ali
*.a
*.so
*.dylib
*.dll
*.exe

# Pamięć podręczna kompilacji i drzewa GNAT
*.gprc
.gnat/

# ------------------------------------------------------------------------------
# 2. KATALOGI WYJŚCIOWE BUDOWANIA (GPRbuild / Alire / Makefile)
# ------------------------------------------------------------------------------
obj/
bin/
lib/
build/
dist/
release/
debug/

# Obiekty i binaria uprzęży testowej AUnit
tests/obj/
tests/bin/

# ------------------------------------------------------------------------------
# 3. NARZĘDZIA JAKOŚCI KODU, POKRYCIE (GNATcov) I METRYKI
# ------------------------------------------------------------------------------
# Ślady wykonania testów i mapy pamięci linkera
*.trace
*.srctrace
*.map

# Raporty pokrycia kodu oraz lokalna biblioteka uruchomieniowa
coverage_report/
gnatcov_rts/
gnatcov_rts.gpr

# Raporty metryk inżynieryjnych gnatmetric
*_metrics.txt

# ------------------------------------------------------------------------------
# 4. ŚRODOWISKO ALIRE (Pakiety, locki i generowana konfiguracja)
# ------------------------------------------------------------------------------
alire/
.alr/
.alire/
alire.lock
alr.lock

# Automatycznie generowany przez Alire katalog konfiguracji skrzynki
config/
*_install_manifest.xml

# ------------------------------------------------------------------------------
# 5. SYSTEM ZRZUTÓW KONTEKSTU (dump-txt/) I DZIENNIKI ZDARZEŃ
# ------------------------------------------------------------------------------
dump-txt/
context.txt
logs/
*.log
*.stdout
*.stderr

# Tymczasowe kopie zapasowe formatowania gnatpp
*.npp

# ------------------------------------------------------------------------------
# 6. ŚRODOWISKA IDE I EDYTORY KODU
# ------------------------------------------------------------------------------
# JetBrains (IntelliJ IDEA / CLion)
.idea/
*.iml
out/
cmake-build-*/

# Visual Studio Code
.vscode/
.history/
*.code-workspace

# Kopie zapasowe i pliki tymczasowe edytorów
*.bak
*.tmp
*.swp
*.swo
*~
*.orig

# ------------------------------------------------------------------------------
# 7. SYSTEMY OPERACYJNE (macOS / Linux / Windows)
# ------------------------------------------------------------------------------
# macOS
.DS_Store
.AppleDouble
.LSOverride

# Linux / FreeBSD
.cache/
.nfs*

# Windows
Thumbs.db
Desktop.ini
$RECYCLE.BIN/
