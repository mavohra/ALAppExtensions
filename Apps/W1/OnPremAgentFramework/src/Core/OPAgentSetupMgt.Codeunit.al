// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

using System.Agents;
using System.AI;
using System.Reflection;
using System.Security.AccessControl;

/// <summary>
/// Core setup management for OnPrem Agents.
/// Handles agent creation, capability registration, and configuration.
/// CRITICAL: RegisterCapability() has the SaaS guard REMOVED for on-prem support.
/// </summary>
codeunit 50101 "OP Agent Setup Mgt"
{
  Access = Internal;
  InherentEntitlements = X;
  InherentPermissions = X;

  /// <summary>
  /// Registers the OnPrem Agent copilot capability.
  /// NOTE: The IsSaaSInfrastructure() guard has been intentionally removed
  /// to allow registration on on-premises environments.
  /// </summary>
  procedure RegisterCapability()
  var
    CopilotCapability: Codeunit "Copilot Capability";
    LearnMoreUrlTxt: Label 'https://openrouter.ai', Locked = true;
  begin
    // INTENTIONALLY NO SaaS GUARD — this is the core on-prem patch
    if CopilotCapability.IsCapabilityRegistered(
      Enum::"Copilot Capability"::"OnPrem Agent") then
      exit;

    CopilotCapability.RegisterCapability(
      Enum::"Copilot Capability"::"OnPrem Agent",
      Enum::"Copilot Availability"::"Generally Available",
      Enum::"Copilot Billing Type"::"Self Managed",
      LearnMoreUrlTxt);
  end;

  [EventSubscriber(ObjectType::Page, Page::"Copilot AI Capabilities", OnRegisterCopilotCapability, '', false, false)]
  local procedure OnRegisterCopilotCapability()
  begin
    RegisterCapability();
  end;

  /// <summary>
  /// Creates a new agent user with the specified name and display name.
  /// </summary>
  /// <param name="AgentUserName">The unique user name for the agent.</param>
  /// <param name="AgentDisplayName">The display name shown in the UI.</param>
  /// <param name="AgentType">The type of agent (General, Payables, Sales).</param>
  /// <param name="AgentInitials">The initials displayed for the agent.</param>
  /// <param name="AgentDescription">Description of the agent.</param>
  /// <param name="AgentInstructions">Instructions text for the agent.</param>
  /// <returns>The User Security ID of the created agent.</returns>
  procedure CreateAgent(
    AgentUserName: Code[50];
    AgentDisplayName: Text[80];
    AgentType: Option;
    AgentInitials: Text[4];
    AgentDescription: Text[250];
    AgentInstructions: Text): Guid
  var
    TempAgentAccessControl: Record "Agent Access Control" temporary;
    Agent: Codeunit Agent;
    AgentUserSecurityID: Guid;
  begin
    AgentUserSecurityID := Agent.Create(
      "Agent Metadata Provider"::"OnPrem Agent",
      AgentUserName,
      AgentDisplayName,
      TempAgentAccessControl);

    Agent.SetInstructions(AgentUserSecurityID, AgentInstructions);

    CreateAgentSetup(
      AgentUserSecurityID,
      AgentType,
      AgentInitials,
      AgentDescription,
      AgentInstructions);

    exit(AgentUserSecurityID);
  end;

  local procedure CreateAgentSetup(
    AgentUserSecurityID: Guid;
    AgentType: Option;
    Initials: Text[4];
    Description: Text[250];
    Instructions: Text)
  var
    OPAgentSetup: Record "OP Agent Setup";
  begin
    if Initials = '' then
      Initials := 'OP';

    OPAgentSetup."User Security ID" := AgentUserSecurityID;
    OPAgentSetup.Initials := Initials;
    OPAgentSetup.Description := Description;
    OPAgentSetup."Agent Type" := AgentType;
    OPAgentSetup.Insert(true);
    OPAgentSetup.SetInstructions(Instructions);
  end;

  /// <summary>
  /// Gets the default instructions for a new agent based on its type.
  /// </summary>
  procedure GetDefaultInstructions(AgentType: Option): Text
  var
    GeneralInstructionsLbl: Label 'You are an AI assistant for Business Central. Help users with their business tasks by navigating pages, filling in data, and providing guidance. Always ask for confirmation before making changes.';
    PayablesInstructionsLbl: Label 'You are a Payables Agent for Business Central. Your primary task is to process incoming invoices and create Purchase Invoices. When you receive an invoice document, extract the vendor information, invoice number, line items, and amounts, then create the corresponding Purchase Invoice in Business Central. Always review the data before posting and ask for human confirmation.';
    SalesInstructionsLbl: Label 'You are a Sales Order Agent for Business Central. Your primary task is to process incoming sales orders from emails. Extract customer information, requested items, quantities, and any special instructions. Create Sales Quotes or Sales Orders in Business Central. Send quotes to customers for approval before converting to orders. Always verify item availability.';
  begin
    case AgentType of
      0: // General
        exit(GeneralInstructionsLbl);
      1: // Payables
        exit(PayablesInstructionsLbl);
      2: // Sales
        exit(SalesInstructionsLbl);
      else
        exit(GeneralInstructionsLbl);
    end;
  end;

  /// <summary>
  /// Gets all OnPrem agents as temporary records.
  /// </summary>
  procedure GetAgents(var TempOPAgentInfo: Record "OP Agent Info" temporary)
  var
    OPAgentSetup: Record "OP Agent Setup";
    Agent: Codeunit Agent;
  begin
    if not TempOPAgentInfo.IsEmpty() then
      TempOPAgentInfo.DeleteAll();

    if not OPAgentSetup.FindSet() then
      exit;

    repeat
      Clear(TempOPAgentInfo);
      TempOPAgentInfo."User Security ID" := OPAgentSetup."User Security ID";
      TempOPAgentInfo."User Name" := Agent.GetUserName(OPAgentSetup."User Security ID");
      TempOPAgentInfo."Agent Type" := OPAgentSetup."Agent Type";
      TempOPAgentInfo.Insert();
    until OPAgentSetup.Next() = 0;
  end;

  /// <summary>
  /// Cleans up agent setup when an agent record is deleted.
  /// </summary>
  [EventSubscriber(ObjectType::Table, Database::Agent, OnAfterDeleteEvent, '', true, true)]
  local procedure CleanupAgentSetup(var Rec: Record Agent; RunTrigger: Boolean)
  var
    OPAgentSetup: Record "OP Agent Setup";
  begin
    if not RunTrigger then
      exit;

    if OPAgentSetup.Get(Rec."User Security ID") then
      OPAgentSetup.Delete();
  end;
}
