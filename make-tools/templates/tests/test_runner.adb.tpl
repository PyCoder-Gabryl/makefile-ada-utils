--  ============================================================================
--  PROJECT:          @PROJECT@ Tests
--  AUTHOR:           @AUTHOR@
--  EMAIL:            @EMAIL@
--  GITHUB:           @GITHUB@
--  LICENSE:          Apache License 2.0
--  ============================================================================
--  DESCRIPTION:      Uprząż testowa AUnit dla projektu @PROJECT@.
--                    Buduje zestaw testów, uruchamia go i ustawia kod wyjścia.
--  ============================================================================
--  PATH:             tests/test_runner.adb
--  CREATED:          @DATE@
--  ============================================================================

with Ada.Command_Line;
with AUnit;
with AUnit.Reporter.Text;
with AUnit.Run;
with AUnit.Test_Cases;
with AUnit.Test_Suites;
with Test_Sample;

procedure Test_Runner is

   use type AUnit.Status;

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

   function Runner is new AUnit.Run.Test_Runner_With_Status (Suite);

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Ret : constant AUnit.Test_Suites.Access_Test_Suite :=
        new AUnit.Test_Suites.Test_Suite;
      TC  : constant AUnit.Test_Cases.Test_Case_Access :=
        new Test_Sample.Test_Case;
   begin
      Ret.Add_Test (TC);
      return Ret;
   end Suite;

   Reporter : AUnit.Reporter.Text.Text_Reporter;
   Status   : AUnit.Status;
begin
   Status := Runner (Reporter);
   if Status = AUnit.Failure then
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Test_Runner;
