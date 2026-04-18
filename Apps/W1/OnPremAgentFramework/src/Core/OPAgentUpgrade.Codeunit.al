// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

/// <summary>
/// Upgrade codeunit that ensures capability registration after app upgrades.
/// </summary>
codeunit 50105 "OP Agent Upgrade"
{
  Access = Internal;
  InherentEntitlements = X;
  InherentPermissions = X;
  Subtype = Upgrade;

  trigger OnUpgradePerDatabase()
  var
    OPAgentSetupMgt: Codeunit "OP Agent Setup Mgt";
  begin
    OPAgentSetupMgt.RegisterCapability();
  end;
}
