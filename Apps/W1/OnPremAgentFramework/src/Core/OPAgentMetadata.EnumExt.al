// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

using System.Agents;

enumextension 50101 "OP Agent Metadata" extends "Agent Metadata Provider"
{
  value(50100; "OnPrem Agent")
  {
    Caption = 'OnPrem Agent';
    Implementation = IAgentFactory = "OP Agent Provider",
                     IAgentMetadata = "OP Agent Provider";
  }
}
