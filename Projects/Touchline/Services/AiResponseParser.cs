using System.Text.Json;
namespace Touchline.Services;

// Strictly validate the final answer. Reasoning text and partial JSON are never predictions.
public static class AiResponseParser
{
    public static (int? Number, bool? IsPlayer, string Explanation) Parse(JsonElement root)
    {
        if (!root.TryGetProperty("choices", out var choices) || choices.ValueKind != JsonValueKind.Array || choices.GetArrayLength() == 0)
            throw new JsonException("The model returned no answer choices.");
        var choice = choices[0];
        var finish = choice.TryGetProperty("finish_reason", out var reason) ? reason.GetString() : null;
        if (finish == "length") throw new JsonException("The model reached its output limit before completing the answer. No number was accepted.");
        if (finish == "content_filter") throw new JsonException("The model declined this image. No number was accepted.");
        if (finish != "stop") throw new JsonException("The model did not complete the answer. No number was accepted.");
        if (!choice.TryGetProperty("message", out var message) || !message.TryGetProperty("content", out var content) ||
            content.ValueKind != JsonValueKind.String || string.IsNullOrWhiteSpace(content.GetString()))
            throw new JsonException("The model returned empty final content, possibly after using its budget for reasoning.");
        JsonDocument parsed;
        try { parsed = JsonDocument.Parse(content.GetString()!); }
        catch (JsonException) { throw new JsonException("The model returned invalid structured JSON. No number was accepted."); }
        using (parsed)
        {
            var answer = parsed.RootElement;
            if (answer.ValueKind != JsonValueKind.Object || !answer.TryGetProperty("number", out var number) ||
                !answer.TryGetProperty("isPlayer", out var player) || !answer.TryGetProperty("explanation", out var explanation) ||
                explanation.ValueKind != JsonValueKind.String ||
                (number.ValueKind != JsonValueKind.Null && (number.ValueKind != JsonValueKind.Number || !number.TryGetInt32(out var value) || value is < 0 or > 99)) ||
                player.ValueKind is not (JsonValueKind.Null or JsonValueKind.True or JsonValueKind.False))
                throw new JsonException("The model answer did not match the required number/player schema.");
            return (number.ValueKind == JsonValueKind.Null ? null : number.GetInt32(),
                player.ValueKind == JsonValueKind.Null ? null : player.GetBoolean(), explanation.GetString()!);
        }
    }
}
