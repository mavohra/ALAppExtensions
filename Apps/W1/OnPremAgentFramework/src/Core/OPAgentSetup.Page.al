// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

using System.Agents;

/// <summary>
/// Main setup page for creating and managing OnPrem Agents.
/// </summary>
page 50100 "OP Agent Setup"
{
  PageType = Card;
  ApplicationArea = All;
  UsageCategory = Administration;
  SourceTable = "OP Agent Setup";
  Caption = 'OnPrem Agent Setup';
  DataCaptionExpression = Rec.Description;

  layout
  {
    area(Content)
    {
      group(General)
      {
        Caption = 'Agent Configuration';

        field("User Security ID"; Rec."User Security ID")
        {
          Visible = false;
        }
        field(AgentUserName; AgentUserName)
        {
          Caption = 'Agent User Name';
          ToolTip = 'Specifies the agent user name in the system.';
          Editable = IsNewAgent;
        }
        field(AgentDisplayName; AgentDisplayName)
        {
          Caption = 'Display Name';
          ToolTip = 'Specifies the display name of the agent shown in the UI.';
          Editable = IsNewAgent;
        }
        field(Initials; Rec.Initials)
        {
          ToolTip = 'Specifies the initials displayed for the agent avatar.';
        }
        field(Description; Rec.Description)
        {
          ToolTip = 'Specifies a description of what the agent does.';
        }
        field("Agent Type"; Rec."Agent Type")
        {
          ToolTip = 'Specifies the type of agent. Each type has different default instructions.';

          trigger OnValidate()
          begin
            if IsNewAgent then
              UpdateDefaultInstructions();
          end;
        }
      }
      group(Instructions)
      {
        Caption = 'Agent Instructions';

        field(InstructionsText; InstructionsText)
        {
          Caption = 'Instructions';
          ToolTip = 'Specifies the natural language instructions that guide the agent behavior. The agent will follow these instructions when processing tasks.';
          MultiLine = true;

          trigger OnValidate()
          begin
            if not IsNewAgent then
              Rec.SetInstructions(InstructionsText);
          end;
        }
      }
      group(Status)
      {
        Caption = 'Status';
        Visible = not IsNewAgent;

        field(AgentState; AgentState)
        {
          Caption = 'State';
          ToolTip = 'Specifies whether the agent is active or inactive.';
          Editable = false;
        }
      }
    }
  }

  actions
  {
    area(Processing)
    {
      action(CreateAgent)
      {
        ApplicationArea = All;
        Caption = 'Create Agent';
        ToolTip = 'Creates the agent user in the system.';
        Image = NewCustomer;
        Visible = IsNewAgent;

        trigger OnAction()
        var
          OPAgentSetupMgt: Codeunit "OP Agent Setup Mgt";
          AgentSecurityId: Guid;
        begin
          if AgentUserName = '' then
            Error(AgentUserNameRequiredErr);
          if AgentDisplayName = '' then
            Error(AgentDisplayNameRequiredErr);

          AgentSecurityId := OPAgentSetupMgt.CreateAgent(
            AgentUserName,
            AgentDisplayName,
            Rec."Agent Type",
            Rec.Initials,
            Rec.Description,
            InstructionsText);

          Rec.Get(AgentSecurityId);
          IsNewAgent := false;
          CurrPage.Update(false);
          Message(AgentCreatedMsg, AgentDisplayName);
        end;
      }
      action(ActivateAgent)
      {
        ApplicationArea = All;
        Caption = 'Activate';
        ToolTip = 'Activates the agent so it can process tasks.';
        Image = Approve;
        Visible = not IsNewAgent;

        trigger OnAction()
        var
          Agent: Codeunit Agent;
        begin
          Agent.Activate(Rec."User Security ID");
          AgentState := 'Active';
          CurrPage.Update(false);
          Message(AgentActivatedMsg);
        end;
      }
      action(DeactivateAgent)
      {
        ApplicationArea = All;
        Caption = 'Deactivate';
        ToolTip = 'Deactivates the agent.';
        Image = Reject;
        Visible = not IsNewAgent;

        trigger OnAction()
        var
          Agent: Codeunit Agent;
        begin
          Agent.Deactivate(Rec."User Security ID");
          AgentState := 'Inactive';
          CurrPage.Update(false);
          Message(AgentDeactivatedMsg);
        end;
      }
      action(OpenLLMSetup)
      {
        ApplicationArea = All;
        Caption = 'LLM Setup';
        ToolTip = 'Opens the OpenRouter LLM configuration page.';
        Image = Setup;
        RunObject = page "OP Agent LLM Setup";
      }
    }
    area(Promoted)
    {
      group(Category_New)
      {
        Caption = 'New';

        actionref(CreateAgent_Promoted; CreateAgent)
        {
        }
      }
      group(Category_Process)
      {
        Caption = 'Process';

        actionref(ActivateAgent_Promoted; ActivateAgent)
        {
        }
        actionref(DeactivateAgent_Promoted; DeactivateAgent)
        {
        }
        actionref(OpenLLMSetup_Promoted; OpenLLMSetup)
        {
        }
      }
    }
  }

  trigger OnOpenPage()
  begin
    IsNewAgent := IsNullGuid(Rec."User Security ID");
    if IsNewAgent then begin
      Rec.Init();
      Rec.Initials := 'OP';
      UpdateDefaultInstructions();
    end;
  end;

  trigger OnAfterGetCurrRecord()
  begin
    IsNewAgent := IsNullGuid(Rec."User Security ID");

    if not IsNewAgent then begin
      InstructionsText := Rec.GetInstructions();
      LoadAgentState();
      LoadAgentNames();
    end;
  end;

  local procedure UpdateDefaultInstructions()
  var
    OPAgentSetupMgt: Codeunit "OP Agent Setup Mgt";
  begin
    InstructionsText := OPAgentSetupMgt.GetDefaultInstructions(Rec."Agent Type");
  end;

  local procedure LoadAgentState()
  var
    AgentRec: Record Agent;
  begin
    if AgentRec.Get(Rec."User Security ID") then begin
      if AgentRec.State = AgentRec.State::Enabled then
        AgentState := 'Active'
      else
        AgentState := 'Inactive';
    end else
      AgentState := 'Not Created';
  end;

  local procedure LoadAgentNames()
  var
    AgentCU: Codeunit Agent;
  begin
    AgentUserName := AgentCU.GetUserName(Rec."User Security ID");
    AgentDisplayName := AgentUserName;
  end;

  var
    InstructionsText: Text;
    AgentUserName: Code[50];
    AgentDisplayName: Text[80];
    AgentState: Text;
    IsNewAgent: Boolean;
    AgentUserNameRequiredErr: Label 'Agent User Name is required.';
    AgentDisplayNameRequiredErr: Label 'Agent Display Name is required.';
    AgentCreatedMsg: Label 'Agent "%1" has been created successfully. Configure access controls and activate it to start processing tasks.';
    AgentActivatedMsg: Label 'Agent has been activated and can now process tasks.';
    AgentDeactivatedMsg: Label 'Agent has been deactivated.';
}
