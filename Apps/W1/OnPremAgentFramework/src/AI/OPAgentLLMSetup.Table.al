// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

/// <summary>
/// Stores the LLM (OpenRouter) configuration.
/// API key is stored in IsolatedStorage for security.
/// </summary>
table 50102 "OP Agent LLM Setup"
{
  DataClassification = SystemMetadata;
  Access = Internal;
  InherentEntitlements = RIMDX;
  InherentPermissions = RIMDX;
  Caption = 'OnPrem Agent LLM Setup';
  DataPerCompany = false;

  fields
  {
    field(1; "Primary Key"; Code[10])
    {
      Caption = 'Primary Key';
      ToolTip = 'Specifies the primary key.';
    }
    field(2; "API Endpoint"; Text[250])
    {
      Caption = 'API Endpoint';
      ToolTip = 'Specifies the OpenRouter API endpoint URL.';
      InitValue = 'https://openrouter.ai/api/v1';
      DataClassification = CustomerContent;
    }
    field(3; "Default Model"; Text[100])
    {
      Caption = 'Default Model';
      ToolTip = 'Specifies the default LLM model to use (e.g., openrouter/auto, openai/gpt-4o, anthropic/claude-sonnet-4-20250514).';
      InitValue = 'openrouter/auto';
      DataClassification = CustomerContent;
    }
    field(4; "Max Tokens"; Integer)
    {
      Caption = 'Max Tokens';
      ToolTip = 'Specifies the maximum number of tokens in the LLM response.';
      InitValue = 4096;
      MinValue = 100;
      MaxValue = 128000;
      DataClassification = CustomerContent;
    }
    field(5; Temperature; Decimal)
    {
      Caption = 'Temperature';
      ToolTip = 'Specifies the sampling temperature (0.0 = deterministic, 1.0 = creative).';
      InitValue = 0.3;
      MinValue = 0;
      MaxValue = 2;
      DataClassification = CustomerContent;
    }
    field(6; "API Key Set"; Boolean)
    {
      Caption = 'API Key Set';
      ToolTip = 'Indicates whether the API key has been configured.';
      FieldClass = FlowField;
      CalcFormula = exist("OP Agent LLM Setup" where("Primary Key" = field("Primary Key")));
      Editable = false;
    }
  }

  keys
  {
    key(Key1; "Primary Key")
    {
      Clustered = true;
    }
  }

  /// <summary>
  /// Gets the singleton setup record, creating it if needed.
  /// </summary>
  procedure GetSetup()
  begin
    if not Get('') then begin
      Init();
      "Primary Key" := '';
      Insert(true);
    end;
  end;

  /// <summary>
  /// Sets the API key in IsolatedStorage.
  /// </summary>
  [NonDebuggable]
  procedure SetApiKey(ApiKey: SecretText)
  begin
    if ApiKey.IsEmpty() then
      if IsolatedStorage.Contains(ApiKeyStorageKeyTok, DataScope::Module) then
        IsolatedStorage.Delete(ApiKeyStorageKeyTok, DataScope::Module);

    if not ApiKey.IsEmpty() then
      IsolatedStorage.Set(ApiKeyStorageKeyTok, ApiKey, DataScope::Module);
  end;

  /// <summary>
  /// Gets the API key from IsolatedStorage.
  /// </summary>
  [NonDebuggable]
  procedure GetApiKey(): SecretText
  var
    ApiKey: SecretText;
  begin
    if IsolatedStorage.Get(ApiKeyStorageKeyTok, DataScope::Module, ApiKey) then;
    exit(ApiKey);
  end;

  /// <summary>
  /// Checks if the API key has been configured.
  /// </summary>
  procedure HasApiKey(): Boolean
  begin
    exit(IsolatedStorage.Contains(ApiKeyStorageKeyTok, DataScope::Module));
  end;

  var
    ApiKeyStorageKeyTok: Label 'OPAgentLLMApiKey', Locked = true;
}
