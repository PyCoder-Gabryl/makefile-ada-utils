# ==============================================================================
# PROJECT:          Blue Dragon Framework
# AUTHOR:           PyCoder Gabryl
# EMAIL:            pycoder.gabryl@gmail.com
# GITHUB:           https://github.com/PyCoder-Gabryl/
# LICENSE:          Apache License 2.0
# ------------------------------------------------------------------------------
#  DESCRIPTION:      Konfiguracja standardów formatowania tekstu dla projektu.
#                    Definiuje zasady wcięć (3 spacje dla Ady), kodowanie znaków
#                    oraz sposób kończenia linii, zapewniając identyczny wygląd
#                    kodu na systemach Windows i macOS.
# ------------------------------------------------------------------------------
# PATH:             .editorconfig
# FILE VERSION:     0.1.0
# CREATED:          2026-07-07
# UPDATED:          2026-07-07
# ==============================================================================


root = true

#  Ustawienia globalne dla wszystkich plików
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 4

#  Specyficzne ustawienia dla języka Ada (standard 3 spacje)
[{*.ads,*.adb}]
indent_size = 3
max_line_length = 120

#  Pliki projektu GPR i Makefile (spójność z projektem)
[{*.gpr,Makefile}]
indent_size = 3

#  Pliki konfiguracyjne (standard 2 spacje)
[{*.toml,*.yaml,*.yml}]
indent_size = 2

#  Dokumentacja
[*.md]
indent_size = 2
trim_trailing_whitespace = false
