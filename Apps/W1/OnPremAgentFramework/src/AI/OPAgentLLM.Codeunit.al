// ------------------------------------------------------------------------------------------------
// BC OnPrem Agents - Custom AI Agents for Business Central On-Premises
// ------------------------------------------------------------------------------------------------

namespace OnPrem.Agents;

/// <summary>
/// OpenRouter LLM HTTP client.
/// Provides chat completion capabilities via the OpenRouter API.
/// Supports both simple text completions and tool/function calling.
/// </summary>
codeunit 50103 "OP Agent LLM"
{
  Access = Internal;
  InherentEntitlements = X;
  InherentPermissions = X;

  /// <summary>
  /// Sends a chat completion request to OpenRouter and returns the response text.
  /// </summary>
  /// <param name="SystemPrompt">The system prompt that sets the agent behavior.</param>
  /// <param name="UserMessage">The user message to process.</param>
  /// <param name="ResponseText">The LLM response text (output).</param>
  /// <returns>True if the request was successful.</returns>
  [NonDebuggable]
  procedure ChatCompletion(SystemPrompt: Text; UserMessage: Text; var ResponseText: Text): Boolean
  var
    LLMSetup: Record "OP Agent LLM Setup";
    HttpClient: HttpClient;
    HttpContent: HttpContent;
    HttpResponse: HttpResponseMessage;
    ContentHeaders: HttpHeaders;
    RequestJson: JsonObject;
    MessagesArray: JsonArray;
    SystemMessage: JsonObject;
    UserMsg: JsonObject;
    ResponseBody: Text;
    ResponseJson: JsonObject;
    ChoicesArray: JsonArray;
    ChoiceToken: JsonToken;
    MessageToken: JsonToken;
    ContentToken: JsonToken;
  begin
    LLMSetup.GetSetup();
    if not LLMSetup.HasApiKey() then
      Error(ApiKeyNotSetErr);

    // Build messages array
    SystemMessage.Add('role', 'system');
    SystemMessage.Add('content', SystemPrompt);
    MessagesArray.Add(SystemMessage);

    UserMsg.Add('role', 'user');
    UserMsg.Add('content', UserMessage);
    MessagesArray.Add(UserMsg);

    // Build request body
    RequestJson.Add('model', LLMSetup."Default Model");
    RequestJson.Add('messages', MessagesArray);
    RequestJson.Add('max_tokens', LLMSetup."Max Tokens");
    RequestJson.Add('temperature', LLMSetup.Temperature);

    // Set content
    HttpContent.WriteFrom(Format(RequestJson));
    HttpContent.GetHeaders(ContentHeaders);
    ContentHeaders.Remove('Content-Type');
    ContentHeaders.Add('Content-Type', 'application/json');

    // Set auth headers
    HttpClient.DefaultRequestHeaders().Add(
      'Authorization',
      SecretStrSubstNo('Bearer %1', LLMSetup.GetApiKey()));
    HttpClient.DefaultRequestHeaders().Add('X-Title', 'BC OnPrem Agents');
    HttpClient.DefaultRequestHeaders().Add('HTTP-Referer', 'https://businesscentral.onprem');

    // Send request
    if not HttpClient.Post(LLMSetup."API Endpoint" + '/chat/completions', HttpContent, HttpResponse) then begin
      ResponseText := HttpRequestFailedErr;
      exit(false);
    end;

    if not HttpResponse.IsSuccessStatusCode() then begin
      HttpResponse.Content().ReadAs(ResponseText);
      ResponseText := StrSubstNo(HttpErrorResponseErr, HttpResponse.HttpStatusCode(), ResponseText);
      exit(false);
    end;

    // Parse response
    HttpResponse.Content().ReadAs(ResponseBody);
    ResponseJson.ReadFrom(ResponseBody);

    if not ResponseJson.Get('choices', ChoiceToken) then begin
      ResponseText := UnexpectedResponseErr;
      exit(false);
    end;

    ChoicesArray := ChoiceToken.AsArray();
    if ChoicesArray.Count() = 0 then begin
      ResponseText := EmptyResponseErr;
      exit(false);
    end;

    ChoicesArray.Get(0, ChoiceToken);
    ChoiceToken.AsObject().Get('message', MessageToken);
    MessageToken.AsObject().Get('content', ContentToken);
    ResponseText := ContentToken.AsValue().AsText();

    exit(true);
  end;

  /// <summary>
  /// Sends a chat completion request with tool definitions for function calling.
  /// </summary>
  /// <param name="SystemPrompt">The system prompt.</param>
  /// <param name="UserMessage">The user message.</param>
  /// <param name="Tools">JSON array of tool definitions.</param>
  /// <param name="ResponseJson">The full response JSON object (output).</param>
  /// <returns>True if the request was successful.</returns>
  [NonDebuggable]
  procedure ChatCompletionWithTools(SystemPrompt: Text; UserMessage: Text; Tools: JsonArray; var ResponseJson: JsonObject): Boolean
  var
    LLMSetup: Record "OP Agent LLM Setup";
    HttpClient: HttpClient;
    HttpContent: HttpContent;
    HttpResponse: HttpResponseMessage;
    ContentHeaders: HttpHeaders;
    RequestJson: JsonObject;
    MessagesArray: JsonArray;
    SystemMessage: JsonObject;
    UserMsg: JsonObject;
    ResponseBody: Text;
  begin
    LLMSetup.GetSetup();
    if not LLMSetup.HasApiKey() then
      Error(ApiKeyNotSetErr);

    // Build messages array
    SystemMessage.Add('role', 'system');
    SystemMessage.Add('content', SystemPrompt);
    MessagesArray.Add(SystemMessage);

    UserMsg.Add('role', 'user');
    UserMsg.Add('content', UserMessage);
    MessagesArray.Add(UserMsg);

    // Build request body with tools
    RequestJson.Add('model', LLMSetup."Default Model");
    RequestJson.Add('messages', MessagesArray);
    RequestJson.Add('tools', Tools);
    RequestJson.Add('max_tokens', LLMSetup."Max Tokens");
    RequestJson.Add('temperature', LLMSetup.Temperature);

    // Set content
    HttpContent.WriteFrom(Format(RequestJson));
    HttpContent.GetHeaders(ContentHeaders);
    ContentHeaders.Remove('Content-Type');
    ContentHeaders.Add('Content-Type', 'application/json');

    // Set auth headers
    HttpClient.DefaultRequestHeaders().Add(
      'Authorization',
      SecretStrSubstNo('Bearer %1', LLMSetup.GetApiKey()));
    HttpClient.DefaultRequestHeaders().Add('X-Title', 'BC OnPrem Agents');
    HttpClient.DefaultRequestHeaders().Add('HTTP-Referer', 'https://businesscentral.onprem');

    // Send request
    if not HttpClient.Post(LLMSetup."API Endpoint" + '/chat/completions', HttpContent, HttpResponse) then
      exit(false);

    if not HttpResponse.IsSuccessStatusCode() then
      exit(false);

    // Parse response
    HttpResponse.Content().ReadAs(ResponseBody);
    ResponseJson.ReadFrom(ResponseBody);
    exit(true);
  end;

  /// <summary>
  /// Tests the OpenRouter connection with a simple prompt.
  /// </summary>
  /// <param name="StatusMessage">Returns a status message about the connection test.</param>
  /// <returns>True if the connection is working.</returns>
  procedure TestConnection(var StatusMessage: Text): Boolean
  var
    Response: Text;
    IsSuccess: Boolean;
  begin
    IsSuccess := ChatCompletion(
      'You are a connection test. Respond with exactly: CONNECTION_OK',
      'Test connection.',
      Response);

    if IsSuccess then
      StatusMessage := StrSubstNo(ConnectionSuccessMsg, Response)
    else
      StatusMessage := StrSubstNo(ConnectionFailedMsg, Response);

    exit(IsSuccess);
  end;

  var
    ApiKeyNotSetErr: Label 'OpenRouter API key is not configured. Go to OnPrem Agent LLM Setup to set it.';
    HttpRequestFailedErr: Label 'HTTP request to OpenRouter failed. Check your network connection and API endpoint.';
    HttpErrorResponseErr: Label 'OpenRouter API returned error %1: %2';
    UnexpectedResponseErr: Label 'Unexpected response format from OpenRouter API.';
    EmptyResponseErr: Label 'OpenRouter API returned an empty response.';
    ConnectionSuccessMsg: Label 'Connection successful! Response: %1';
    ConnectionFailedMsg: Label 'Connection failed: %1';
}
