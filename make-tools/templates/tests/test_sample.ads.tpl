--  ============================================================================
--  PROJECT:          @PROJECT@ Tests
--  AUTHOR:           @AUTHOR@
--  EMAIL:            @EMAIL@
--  GITHUB:           @GITHUB@
--  LICENSE:          Apache License 2.0
--  ============================================================================
--  DESCRIPTION:      Wzorcowy przypadek testowy AUnit dla @PROJECT@ (specyfikacja).
--  ============================================================================
--  PATH:             tests/test_sample.ads
--  CREATED:          @DATE@
--  ============================================================================

with AUnit;
with AUnit.Test_Cases;

package Test_Sample is

   type Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   overriding procedure Register_Tests (T : in out Test_Case);

   overriding function Name (T : Test_Case) return AUnit.Message_String;

end Test_Sample;
