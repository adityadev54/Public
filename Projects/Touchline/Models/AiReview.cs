namespace Touchline.Models;

public sealed record AiCrop(int TrackId, double Timestamp, string Trigger, string ImageBase64);
public sealed record AiReviewRequest(IReadOnlyList<AiCrop> Crops, string Sport = "soccer");
public sealed record AiAnswer(int TrackId, double Timestamp, string Trigger, int? Number,
    bool? IsPlayer, string Explanation, string Status);
public sealed record AiReviewResult(string Model, int Calls, int InputTokens, int OutputTokens,
    IReadOnlyList<AiAnswer> Answers);

public sealed record AiKeyRequest(string? Key);
