#  ==============================================================================
#  PROJECT:          @PROJECT@
#  AUTHOR:           @AUTHOR@
#  EMAIL:            @EMAIL@
#  GITHUB:           @GITHUB@
#  LICENSE:          Apache License 2.0
#  ------------------------------------------------------------------------------
#  DESCRIPTION:      Manifest projektu Alire dla @PROJECT@.
#                    Zarządza metadanymi, zależnościami (TOML, SPARK, AUnit)
#                    oraz konfiguruje izolowane środowisko budowania.
#                    Zawiera specyficzne poprawki dla konsolidatora macOS
#                    oraz definicje profili kompilacji (debug/release).
#  ------------------------------------------------------------------------------
#  PATH:             alire.toml
#  CREATED:          @DATE@
#  ==============================================================================


#  ============================================================================
#  METADANE PROJEKTU
#  ============================================================================

name = "@PROJECT_LOWER@"
description = "@PROJECT@ CLI Application"
long-description = """
Aplikacja w języku Ada 2022 ze SPARK i testami AUnit utworzona z szablonu.
"""
version = "0.1.0"

authors = ["@AUTHOR@"]
maintainers = ["@AUTHOR@ <@EMAIL@>"]
maintainers-logins = ["@GITHUB_USER@"]
licenses = "Apache-2.0"
website = "@GITHUB@/@PROJECT_LOWER@"
tags = ["ada", "framework", "spark", "aunit", "@PROJECT_LOWER@", "toml"]

#  ============================================================================
#  INTEGRACJA Z GNAT / GPRBUILD
#  ============================================================================

executables = ["@PROJECT_LOWER@"]
project-files = ["@PROJECT_LOWER@.gpr"]

#  ============================================================================
#  WARUNKOWE ZARZĄDZANIE ŚRODOWISKIEM (DEPENDENT ON OS)
#  ============================================================================

[environment.'case(os)'.macos]
#  EDUKACJA: Ustawienie zmiennej platformy, aby plik projektu @PROJECT_LOWER@.gpr
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
