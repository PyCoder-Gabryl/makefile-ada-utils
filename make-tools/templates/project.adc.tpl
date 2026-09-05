--  ============================================================================
--  PROJECT:          @PROJECT@ Configuration Pragmas
--  LICENSE:          Apache License 2.0
--  ----------------------------------------------------------------------------
--  DESCRIPTION:      Globalne pragmy kompilatora GNAT dla projektu @PROJECT@.
--                    Wymusza sprawdzanie asercji, blokuje przestarzale funkcje
--                    oraz zabezpiecza elaboracje kodu.
--  ----------------------------------------------------------------------------
--  PATH:             data/config/@PROJECT_LOWER@.adc
--  CREATED:          @DATE@
--  ============================================================================

--  Wymuszenie sprawdzania asercji i kontraktow Pre/Post.
pragma Assertion_Policy (Check);

--  Blokada przestarzalych funkcji jezyka.
pragma Restrictions (No_Obsolescent_Features);

--  Wymuszenie bezpiecznej inicjalizacji (elaboracji).
pragma Restrictions (No_Entry_Calls_In_Elaboration_Code);

--  Wyciszenie falszywych ostrzezen o aliasingu.
pragma Warnings (Off, "possible aliasing problem*");
