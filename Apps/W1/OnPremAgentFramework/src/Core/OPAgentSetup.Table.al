// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

/// <summary>
/// Stores per-agent configuration for OnPrem Agents.
/// Each agent user gets one record in this table.
/// </summary>
table 50100 "OP Agent Setup"
{
  DataClassification = SystemMetadata;
  Access = Internal;
  InherentEntitlements = RIMDX;
  InherentPermissions = RIMDX;
  Caption = 'OnPrem Agent Setup';
  ReplicateData = false;
  DataPerCompany = false;

  fields
  {
    field(1; "User Security ID"; Guid)
    {
      Caption = 'User Security ID';
      ToolTip = 'Specifies the user ID of the agent.';
    }
    field(2; Instructions; Blob)
    {
      ToolTip = 'Specifies the instructions for the agent.';
      Caption = 'Instructions';
    }
    field(3; Initials; Code[4])
    {
      Caption = 'Initials';
      ToolTip = 'Specifies the initials displayed for the agent.';
      DataClassification = CustomerContent;
    }
    field(4; Description; Text[250])
    {
      Caption = 'Description';
      ToolTip = 'Specifies the description of the agent.';
      DataClassification = CustomerContent;
    }
    field(5; "Agent Type"; Option)
    {
      Caption = 'Agent Type';
      ToolTip = 'Specifies the type of agent (General, Payables, Sales).';
      OptionMembers = General,Payables,Sales;
      OptionCaption = 'General,Payables,Sales';
      DataClassification = CustomerContent;
    }
  }

  keys
  {
    key(Key1; "User Security ID")
    {
      Clustered = true;
    }
  }

  /// <summary>
  /// Gets the instructions text from the blob field.
  /// </summary>
  [Scope('OnPrem')]
  procedure GetInstructions(): Text
  var
    InStream: InStream;
    InstructionText: Text;
  begin
    CalcFields(Instructions);
    if not Instructions.HasValue() then
      exit('');

    Instructions.CreateInStream(InStream, TextEncoding::UTF8);
    InStream.ReadText(InstructionText);
    exit(InstructionText);
  end;

  /// <summary>
  /// Sets the instructions text into the blob field.
  /// </summary>
  [Scope('OnPrem')]
  procedure SetInstructions(NewInstructions: Text)
  var
    OutStream: OutStream;
  begin
    Clear(Instructions);
    Instructions.CreateOutStream(OutStream, TextEncoding::UTF8);
    OutStream.WriteText(NewInstructions);
    Modify(true);
  end;
}
