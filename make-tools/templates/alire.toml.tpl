#  ==============================================================================
#  PROJECT:          Gabyx
#  AUTHOR:           PyCoder Gabryl
#  EMAIL:            pycoder.gabryl@gmail.com
#  GITHUB:           https://github.com/PyCoder-Gabryl/
#  LICENSE:          Apache License 2.0
#  ------------------------------------------------------------------------------
#  DESCRIPTION:      Manifest projektu Alire dla gry Gabyx.
#                    Zarządza metadanymi, zależnościami (Raylib, TOML, SPARK)
#                    oraz konfiguruje izolowane środowisko budowania.
#                    Zawiera specyficzne poprawki dla konsolidatora macOS
#                    oraz definicje profili kompilacji (debug/release).
#  ------------------------------------------------------------------------------
#  PATH:             alire.toml
#  CREATED:          2026-08-04
#  ==============================================================================


#  ============================================================================
#  METADANE PROJEKTU
#  ============================================================================

name = "bielik"
description = "Bielik CLI TXT"
long-description = """
Interfejs w Adzie do komunikacji z lokalnym modelem Bielika przez Ollamę.
"""
version = "0.1.0"

authors = ["PyCoder Gabryl"]
maintainers = ["PyCoder Gabryl <pycoder.gabryl@gmail.com>"]
maintainers-logins = ["pycoder-gabryl"]
licenses = "Apache-2.0"
website = "https://github.com/PyCoder-Gabryl/bielik-cli"
tags = ["ada", "framework", "spark", "aunit", "txt-asistant", "bielik", "toml"]

#  ============================================================================
#  INTEGRACJA Z GNAT / GPRBUILD
#  ============================================================================

executables = ["bielik"]
project-files = ["bielik.gpr"]

#  ============================================================================
#  WARUNKOWE ZARZĄDZANIE ŚRODOWISKIEM (DEPENDENT ON OS)
#  ============================================================================

[environment.'case(os)'.macos]
#  EDUKACJA: Ustawienie zmiennej platformy, aby plik projektu bielik.gpr
#  poprawnie rozpoznał system macOS i zaaplikował odpowiednie flagi linkera.
ALIRE_HOST_OS.set = "macos"

#  Instrukcja sprawdzania wersji systemu:
#  1. Otwórz terminal i wpisz polecenie: sw_vers -productVersion
#  2. Przepisz tylko pierwszą, główną liczbę (Major Version) do zmiennej poniżej.
MACOSX_DEPLOYMENT_TARGET.set = "26.0"

#  Poniższe ustawienia są specyficzne dla macOS ARM (M1/M2/M3).
#  Przekazanie ścieżki SDK do każdej zewnętrznej zależności w C oraz linkera.
CFLAGS.set = "-isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
CXXFLAGS.set = "-isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
LDFLAGS.set = "-isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"

#  Globalna zmienna środowiskowa Apple, wymuszająca na wszystkich narzędziach
#  użycie odpowiedniego SDK (rozwiązuje m.in. błąd "-lSystem").
SDKROOT.set = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"

[environment.'case(os)'.windows]
#  Dla systemu Windows wymuszamy zmienną środowiskową platformy dla Alire / GNAT
ALIRE_HOST_OS.set = "windows"

[environment.'case(os)'.linux]
ALIRE_HOST_OS.set = "linux"

[environment.'case(os)'.'...']
#  Dla systemu BSD nie wymagamy dodatkowych flag SDK [TODO: do sprawdzenia].

#  ============================================================================
#  ZALEŻNOŚCI PROJEKTU (DEPENDENCIES)
#  ============================================================================
#  EDUKACJA: Alire zarządza zależnościami w sposób deklaratywny.
#  Wersjonowanie semantyczne (np. ^16.1.0) zapewnia stabilność buildu
#  przy jednoczesnym dopuszczeniu bezpiecznych poprawek błędów.

[[depends-on]]
gnatprove = "*"       # Narzędzie do formalnej weryfikacji SPARK
gnatcov = "*"         # Narzędzie do analizy pokrycia kodu (Coverage)
aunit = "*"           # Framework do testów jednostkowych (xUnit style)

ada_toml = "*"         # Parser plików konfiguracyjnych TOML

#  ============================================================================
#  PROFILE KOMPILACJI (PRZEKAZYWANE DO PLIKU .GPR)
#  ============================================================================

[gpr-externals]
#  Zmienna BUILD_MODE pozwala na przełączanie flag kompilatora z poziomu Alire.
#  Użycie: alr build -- -XBUILD_MODE=release
BUILD_MODE = ["debug", "release", "validation"]

BIELIK_MODE = ["terminal", "graphical"]
BIELIK_TERM_DRIVER = ["ansi", "ncurses", "trendy"]

SPARK_MODE = ["Off", "On"]
