// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

/// <summary>
/// Permission set for OnPrem Agent administration.
/// </summary>
permissionset 50100 "OP Agent Admin"
{
  Caption = 'OnPrem Agent Administrator';
  Assignable = true;

  Permissions =
    table "OP Agent Setup" = X,
    table "OP Agent Info" = X,
    table "OP Agent LLM Setup" = X,
    codeunit "OP Agent Provider" = X,
    codeunit "OP Agent Setup Mgt" = X,
    codeunit "OP Agent Install" = X,
    codeunit "OP Agent LLM" = X,
    codeunit "OP Agent Session" = X,
    codeunit "OP Agent Upgrade" = X,
    page "OP Agent Setup" = X,
    page "OP Agent List" = X,
    page "OP Agent LLM Setup" = X;
}
