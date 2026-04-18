// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

/// <summary>
/// Configuration page for OpenRouter LLM connection settings.
/// </summary>
page 50101 "OP Agent LLM Setup"
{
  PageType = Card;
  ApplicationArea = All;
  UsageCategory = Administration;
  SourceTable = "OP Agent LLM Setup";
  Caption = 'OnPrem Agent LLM Setup';
  InsertAllowed = false;
  DeleteAllowed = false;
  DataCaptionExpression = '';

  layout
  {
    area(Content)
    {
      group(Connection)
      {
        Caption = 'OpenRouter Connection';

        field("API Endpoint"; Rec."API Endpoint")
        {
          ToolTip = 'Specifies the OpenRouter API endpoint URL. Default: https://openrouter.ai/api/v1';
        }
        field(ApiKeyField; ApiKeyValue)
        {
          Caption = 'API Key';
          ToolTip = 'Specifies the OpenRouter API key. Get one at https://openrouter.ai/keys';
          ExtendedDatatype = Masked;

          trigger OnValidate()
          begin
            if ApiKeyValue <> '' then
              Rec.SetApiKey(ApiKeyValue)
            else
              Rec.SetApiKey('');
          end;
        }
        field(ApiKeyStatus; ApiKeyStatusText)
        {
          Caption = 'API Key Status';
          ToolTip = 'Shows whether the API key has been configured.';
          Editable = false;
          Style = Favorable;
          StyleExpr = Rec.HasApiKey();
        }
      }
      group(ModelSettings)
      {
        Caption = 'Model Settings';

        field("Default Model"; Rec."Default Model")
        {
          ToolTip = 'Specifies the default LLM model. Examples: openrouter/auto, openai/gpt-4o, anthropic/claude-sonnet-4-20250514, meta-llama/llama-3.1-8b-instruct:free';
        }
        field("Max Tokens"; Rec."Max Tokens")
        {
          ToolTip = 'Specifies the maximum response length in tokens.';
        }
        field(Temperature; Rec.Temperature)
        {
          ToolTip = 'Specifies creativity (0.0 = deterministic, 1.0 = creative). Recommended: 0.3 for business tasks.';
        }
      }
    }
  }

  actions
  {
    area(Processing)
    {
      action(TestConnection)
      {
        ApplicationArea = All;
        Caption = 'Test Connection';
        ToolTip = 'Tests the connection to OpenRouter with a simple prompt.';
        Image = TestReport;

        trigger OnAction()
        var
          OPAgentLLM: Codeunit "OP Agent LLM";
          StatusMessage: Text;
        begin
          if OPAgentLLM.TestConnection(StatusMessage) then
            Message(StatusMessage)
          else
            Error(StatusMessage);
        end;
      }
    }
    area(Promoted)
    {
      group(Category_Process)
      {
        actionref(TestConnection_Promoted; TestConnection)
        {
        }
      }
    }
  }

  trigger OnOpenPage()
  begin
    Rec.GetSetup();
    UpdateApiKeyStatus();
  end;

  trigger OnAfterGetCurrRecord()
  begin
    UpdateApiKeyStatus();
  end;

  local procedure UpdateApiKeyStatus()
  begin
    if Rec.HasApiKey() then
      ApiKeyStatusText := '✓ API Key is configured'
    else
      ApiKeyStatusText := '✗ API Key is NOT configured';
    ApiKeyValue := '';
  end;

  var
    ApiKeyValue: Text;
    ApiKeyStatusText: Text;
}
