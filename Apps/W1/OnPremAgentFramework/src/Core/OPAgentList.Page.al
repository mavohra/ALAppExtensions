// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

/// <summary>
/// List page showing all OnPrem Agents configured in the system.
/// </summary>
page 50102 "OP Agent List"
{
  PageType = List;
  ApplicationArea = All;
  UsageCategory = Lists;
  SourceTable = "OP Agent Setup";
  Caption = 'OnPrem Agents';
  CardPageId = "OP Agent Setup";
  Editable = false;

  layout
  {
    area(Content)
    {
      repeater(Agents)
      {
        field(Initials; Rec.Initials)
        {
          ToolTip = 'Specifies the initials of the agent.';
        }
        field(Description; Rec.Description)
        {
          ToolTip = 'Specifies the description of the agent.';
        }
        field("Agent Type"; Rec."Agent Type")
        {
          ToolTip = 'Specifies the type of agent.';
        }
      }
    }
  }

  actions
  {
    area(Processing)
    {
      action(NewAgent)
      {
        ApplicationArea = All;
        Caption = 'New Agent';
        ToolTip = 'Creates a new OnPrem Agent.';
        Image = New;
        RunObject = page "OP Agent Setup";
        RunPageMode = Create;
      }
      action(OpenLLMSetup)
      {
        ApplicationArea = All;
        Caption = 'LLM Setup';
        ToolTip = 'Opens the OpenRouter LLM configuration.';
        Image = Setup;
        RunObject = page "OP Agent LLM Setup";
      }
    }
    area(Promoted)
    {
      group(Category_New)
      {
        actionref(NewAgent_Promoted; NewAgent)
        {
        }
      }
      group(Category_Process)
      {
        actionref(OpenLLMSetup_Promoted; OpenLLMSetup)
        {
        }
      }
    }
  }
}
