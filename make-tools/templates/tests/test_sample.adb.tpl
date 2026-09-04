--  ============================================================================
--  PROJECT:          @PROJECT@ Tests
--  AUTHOR:           @AUTHOR@
--  EMAIL:            @EMAIL@
--  GITHUB:           @GITHUB@
--  LICENSE:          Apache License 2.0
--  ============================================================================
--  DESCRIPTION:      Wzorcowy przypadek testowy AUnit dla @PROJECT@ (implementacja).
--                    Zawiera domyślną zieloną asercję weryfikującą uprząż.
--  ============================================================================
--  PATH:             tests/test_sample.adb
--  CREATED:          @DATE@
--  ============================================================================

with AUnit.Assertions;

package body Test_Sample is

   procedure Test_Sanity (T : in out AUnit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      AUnit.Assertions.Assert (True, "Weryfikacja sprawnosci uprzezy testowej AUnit");
   end Test_Sanity;

   procedure Register_Tests (T : in out Test_Case) is
   begin
      AUnit.Test_Cases.Registration.Register_Routine
        (T, Test_Sanity'Access, "Test startowy srodowiska (Sanity Check)");
   end Register_Tests;

   function Name (T : Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("@PROJECT@.Sanity_Check");
   end Name;

end Test_Sample;
