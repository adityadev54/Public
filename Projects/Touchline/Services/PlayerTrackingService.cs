using System.Text.RegularExpressions;
using Touchline.Models;

namespace Touchline.Services;

/// <summary>Motion-aware spatial association baseline for short, continuous camera shots.</summary>
public sealed class PlayerTrackingService
{
    private sealed class TrackState(int id, TrackingFrame frame, PersonEvidence person)
    {
        public int Id { get; } = id;
        public PersonEvidence LastBox { get; set; } = person;
        public double LastSeen { get; set; } = frame.Timestamp;
        public double VelocityX { get; set; }
        public double VelocityY { get; set; }
        public List<TrackObservation> Observations { get; } = [];
        public Dictionary<int, List<float>> Votes { get; } = [];
    }

    public TrackingResult Link(TrackingRequest request)
    {
        var states = new List<TrackState>();
        foreach (var frame in request.Frames.OrderBy(frame => frame.Timestamp))
        {
            var matches = new List<(double Score, TrackState Track, PersonEvidence Person)>();
            foreach (var track in states.Where(track => frame.Timestamp - track.LastSeen <= 2.5))
                foreach (var person in frame.People)
                {
                    var score = AssociationScore(track, person, frame.Timestamp);
                    if (score > 0) matches.Add((score, track, person));
                }
            var usedTracks = new HashSet<int>();
            var usedPeople = new HashSet<int>();
            foreach (var match in matches.OrderByDescending(match => match.Score))
            {
                if (usedTracks.Contains(match.Track.Id) || usedPeople.Contains(match.Person.Id)) continue;
                // A close alternative on either side is ambiguous. Leave it unmatched rather
                // than silently choosing a player's identity from iteration order.
                var alternative = matches.Where(other =>
                    (other.Track.Id == match.Track.Id && other.Person.Id != match.Person.Id) ||
                    (other.Person.Id == match.Person.Id && other.Track.Id != match.Track.Id))
                    .Select(other => other.Score).DefaultIfEmpty(0).Max();
                if (match.Score - alternative < 0.08) continue;
                usedTracks.Add(match.Track.Id); usedPeople.Add(match.Person.Id);
                Append(match.Track, frame, match.Person);
            }
            foreach (var person in frame.People.Where(person => !usedPeople.Contains(person.Id)))
            {
                var track = new TrackState(states.Count + 1, frame, person);
                states.Add(track); Append(track, frame, person);
            }
        }
        return new TrackingResult("Motion-aware spatial association; identities require verification",
            states.Select(Summarize).ToList());
    }

    private static void Append(TrackState track, TrackingFrame frame, PersonEvidence person)
    {
        var elapsed = frame.Timestamp - track.LastSeen;
        if (elapsed > 0 && track.Observations.Count > 0)
        {
            // Estimate center velocity in normalized image coordinates per second.
            var vx = (person.X + person.Width / 2 - track.LastBox.X - track.LastBox.Width / 2) / elapsed;
            var vy = (person.Y + person.Height / 2 - track.LastBox.Y - track.LastBox.Height / 2) / elapsed;
            var weight = track.Observations.Count == 1 ? 1.0 : 0.6;
            track.VelocityX = weight * vx + (1 - weight) * track.VelocityX;
            track.VelocityY = weight * vy + (1 - weight) * track.VelocityY;
        }
        track.LastBox = person; track.LastSeen = frame.Timestamp;
        track.Observations.Add(new(frame.Timestamp, person.Id, person.X, person.Y, person.Width, person.Height));
        // One vote per number per sighting prevents multiple OCR fragments inflating support.
        var numbers = person.Readings.Select(reading => (Reading: reading,
            Match: Regex.Match(reading.Text, @"^\s*(\d{1,2})[-.,]?\s*$")))
            .Where(item => item.Match.Success && item.Reading.Confidence >= 0.4f)
            .GroupBy(item => int.Parse(item.Match.Groups[1].Value));
        foreach (var group in numbers)
        {
            if (!track.Votes.TryGetValue(group.Key, out var votes))
                track.Votes[group.Key] = votes = [];
            votes.Add(group.Max(item => item.Reading.Confidence));
        }
    }

    private static PlayerTrack Summarize(TrackState track)
    {
        var candidates = track.Votes.Select(pair => new NumberSupport(pair.Key, pair.Value.Count,
            pair.Value.Average(value => (double)value)))
            .OrderByDescending(candidate => candidate.Observations).ThenByDescending(candidate => candidate.MeanOcrScore).ToList();
        var best = candidates.FirstOrDefault();
        // Repeated support is a consistency rule, not a calibrated correctness probability.
        var repeated = best is not null && best.Observations >= 2 &&
            (candidates.Count == 1 || best.Observations >= candidates[1].Observations + 2);
        return new(track.Id, track.Observations[0].Timestamp, track.LastSeen, track.Observations.Count,
            repeated ? best!.Number : null,
            repeated ? "Repeated support" : candidates.Count > 1 ? "Conflicting readings" : best is not null ? "Single reading" : "Unreadable",
            candidates, track.Observations);
    }

    private static double AssociationScore(TrackState track, PersonEvidence person, double timestamp)
    {
        var last = track.LastBox;
        // Large scale changes usually indicate a different person or a camera cut.
        var widthRatio = person.Width / Math.Max(last.Width, 0.0001);
        var heightRatio = person.Height / Math.Max(last.Height, 0.0001);
        if (widthRatio is < 0.5 or > 2 || heightRatio is < 0.5 or > 2) return 0;
        var elapsed = timestamp - track.LastSeen;
        // Cap extrapolation to one body width/height to avoid runaway predictions.
        var predicted = last with
        {
            X = last.X + Math.Clamp(track.VelocityX * elapsed, -last.Width, last.Width),
            Y = last.Y + Math.Clamp(track.VelocityY * elapsed, -last.Height, last.Height)
        };
        var dx = (person.X + person.Width / 2 - predicted.X - predicted.Width / 2) / last.Width;
        var dy = (person.Y + person.Height / 2 - predicted.Y - predicted.Height / 2) / last.Height;
        var distance = Math.Sqrt(dx * dx + dy * dy);
        var overlap = Overlap(predicted, person);
        // Permit small non-overlapping moves, but never use OCR to force an identity match.
        if (distance > 1.25 || (overlap < 0.1 && distance > 0.8)) return 0;
        return 0.6 * overlap + 0.4 * (1 - distance / 1.25);
    }

    private static double Overlap(PersonEvidence a, PersonEvidence b)
    {
        var width = Math.Max(0, Math.Min(a.X + a.Width, b.X + b.Width) - Math.Max(a.X, b.X));
        var height = Math.Max(0, Math.Min(a.Y + a.Height, b.Y + b.Height) - Math.Max(a.Y, b.Y));
        var intersection = width * height;
        var union = a.Width * a.Height + b.Width * b.Height - intersection;
        return union > 0 ? intersection / union : 0;
    }
}
