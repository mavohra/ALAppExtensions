// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

using System.Agents;
using System.Environment.Configuration;

/// <summary>
/// Handles agent session lifecycle events.
/// Detects when a session belongs to an OnPrem Agent and performs initialization.
/// </summary>
codeunit 50104 "OP Agent Session"
{
  Access = Internal;
  InherentEntitlements = X;
  InherentPermissions = X;
  SingleInstance = true;
  Permissions = tabledata "OP Agent Setup" = r;

  [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterLogin, '', false, false)]
  local procedure OnAfterAgentLogin()
  var
    OPAgentSetup: Record "OP Agent Setup";
  begin
    if not IsOnPremAgentSession() then
      exit;

    if not OPAgentSetup.Get(UserSecurityId()) then
      exit;

    // Agent session initialized — future enhancement:
    // bind additional event subscribers, load agent-specific config, etc.
  end;

  local procedure IsOnPremAgentSession(): Boolean
  var
    AgentSession: Codeunit "Agent Session";
    AgentMetadataProvider: Enum "Agent Metadata Provider";
  begin
    if not AgentSession.IsAgentSession(AgentMetadataProvider) then
      exit(false);

    if AgentMetadataProvider <> Enum::"Agent Metadata Provider"::"OnPrem Agent" then
      exit(false);

    exit(true);
  end;
}
