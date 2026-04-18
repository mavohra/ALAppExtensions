// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

/// <summary>
/// Install codeunit that registers the OnPrem Agent capability on extension install.
/// </summary>
codeunit 50102 "OP Agent Install"
{
  Access = Internal;
  InherentEntitlements = X;
  InherentPermissions = X;
  Subtype = Install;

  trigger OnInstallAppPerDatabase()
  var
    OPAgentSetupMgt: Codeunit "OP Agent Setup Mgt";
  begin
    OPAgentSetupMgt.RegisterCapability();
  end;
}
