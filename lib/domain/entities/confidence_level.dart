/// Confidence of an AI-derived value. Per the "show missing data, don't guess"
/// principle (ERS RF-05/RF-06), fields the recognizer could not determine
/// should be left null rather than defaulted to zero.
enum ConfidenceLevel { high, medium, low }
