// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

using System.Agents;
using System.AI;
using System.Reflection;
using System.Security.AccessControl;

/// <summary>
/// Implements IAgentMetadata and IAgentFactory for the OnPrem Agent.
/// This is the core provider that the BC platform calls to get agent metadata,
/// setup pages, and factory operations.
/// </summary>
codeunit 50100 "OP Agent Provider" implements IAgentMetadata, IAgentFactory
{
  InherentEntitlements = X;
  InherentPermissions = X;
  Access = Internal;

  procedure GetDefaultInitials(): Text[4]
  begin
    exit(DefaultInitialsLbl);
  end;

  procedure GetInitials(AgentUserId: Guid): Text[4]
  var
    OPAgentSetup: Record "OP Agent Setup";
  begin
    if IsNullGuid(AgentUserId) then
      exit(DefaultInitialsLbl);

    if not OPAgentSetup.Get(AgentUserId) then
      exit(DefaultInitialsLbl);

    if OPAgentSetup.Initials = '' then
      exit(DefaultInitialsLbl);

    exit(OPAgentSetup.Initials);
  end;

  procedure GetFirstTimeSetupPageId(): Integer
  begin
    exit(Page::"OP Agent Setup");
  end;

  procedure GetSetupPageId(AgentUserId: Guid): Integer
  begin
    exit(Page::"OP Agent Setup");
  end;

  procedure GetSummaryPageId(AgentUserId: Guid): Integer
  begin
    exit(0);
  end;

  procedure ShowCanCreateAgent(): Boolean
  begin
    // On-prem: allow any user with the right permissions to create agents
    exit(true);
  end;

  procedure GetCopilotCapability(): Enum "Copilot Capability"
  begin
    exit("Copilot Capability"::"OnPrem Agent");
  end;

  procedure GetAgentAnnotations(AgentUserId: Guid; var Annotations: Record "Agent Annotation")
  begin
    Clear(Annotations);
  end;

  procedure GetAgentTaskMessagePageId(AgentUserId: Guid; MessageId: Guid): Integer
  begin
    // Use the default platform task message card
    exit(0);
  end;

  procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
  var
    Agent: Codeunit Agent;
  begin
    Agent.PopulateDefaultProfile(DefaultProfileTok, SystemApplicationAppIdLbl, TempAllProfile);
  end;

  procedure GetDefaultAccessControls(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
  begin
    // On-prem: no default access controls, they must be configured by admin
  end;

  var
    DefaultInitialsLbl: Label 'OP', MaxLength = 4;
    DefaultProfileTok: Label 'BLANK', Locked = true;
    SystemApplicationAppIdLbl: Label '63ca2fa4-4f03-4f2b-a480-172fef340d3f', Locked = true;
}
