variable "alert_email" {
  description = "Email address for budget and cost anomaly alerts"
  type        = string
  # No default so it never gets committed.
}
