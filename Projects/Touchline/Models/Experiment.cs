namespace Touchline.Models;

public sealed record FrameRequest(string ImageBase64);
public sealed record TextReading(string Text, float Confidence, double X, double Y, double Width, double Height);
// IDs belong to this frame only; they do not imply cross-frame tracking.
public sealed record PersonEvidence(int Id, float Confidence, double X, double Y,
    double Width, double Height, IReadOnlyList<TextReading> Readings);
public sealed record FrameResult(IReadOnlyList<TextReading> Readings, IReadOnlyList<PersonEvidence> People);

public sealed record TrackingFrame(double Timestamp, IReadOnlyList<PersonEvidence> People);
public sealed record TrackingRequest(IReadOnlyList<TrackingFrame> Frames);
public sealed record TrackObservation(double Timestamp, int PersonId, double X, double Y, double Width, double Height);
public sealed record NumberSupport(int Number, int Observations, double MeanOcrScore);
public sealed record PlayerTrack(int Id, double FirstSeen, double LastSeen, int Sightings,
    int? Number, string NumberStatus, IReadOnlyList<NumberSupport> Candidates,
    IReadOnlyList<TrackObservation> Observations);
public sealed record TrackingResult(string Method, IReadOnlyList<PlayerTrack> Tracks);
