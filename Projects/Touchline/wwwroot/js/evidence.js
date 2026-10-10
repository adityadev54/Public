// Normalize punctuation only; preserve raw OCR output for verification and export.
export function numericReadings(readings) {
    return readings.flatMap(item => {
        const match = item.text.match(/^\s*(\d{1,2})[-.,]?\s*$/);
        return match ? [{ ...item, rawText: item.text, text: match[1] }] : [];
    });
}
