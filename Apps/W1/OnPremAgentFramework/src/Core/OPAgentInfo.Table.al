// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

using System.Agents;

/// <summary>
/// Temporary table for displaying agent information in lists and lookups.
/// </summary>
table 50101 "OP Agent Info"
{
  TableType = Temporary;
  Extensible = false;
  InherentPermissions = RIMDX;
  InherentEntitlements = RIMDX;
  Caption = 'OnPrem Agent Information';

  fields
  {
    field(1; "User Security ID"; Guid)
    {
      DataClassification = SystemMetadata;
      Caption = 'User Security ID';
      ToolTip = 'Specifies the user ID of the agent.';
    }
    field(2; "User Name"; Code[50])
    {
      DataClassification = SystemMetadata;
      Caption = 'User Name';
      ToolTip = 'Specifies the user name of the agent.';
    }
    field(3; State; Option)
    {
      FieldClass = FlowField;
      Caption = 'State';
      OptionMembers = Enabled,Disabled;
      OptionCaption = 'Active,Inactive';
      ToolTip = 'Specifies the state of the agent.';
      CalcFormula = lookup(Agent.State where("User Security ID" = field("User Security ID")));
    }
    field(4; "Agent Type"; Option)
    {
      DataClassification = SystemMetadata;
      Caption = 'Agent Type';
      OptionMembers = General,Payables,Sales;
      OptionCaption = 'General,Payables,Sales';
      ToolTip = 'Specifies the type of agent.';
    }
  }

  keys
  {
    key(PK; "User Security ID")
    {
      Clustered = true;
    }
  }
}
