provider "google" {
  project = "jcqueiroz-devops-iac"
  region  = "us-central1"
  zone    = "us-central1-c"
  credentials = "${file("serviceaccount.yaml")}"
}

data "google_billing_account" "account" {
  billing_account = "011679-77322D-6BBCBE"
}

data "google_project" "jcqueiroz-sales-mobile-dev" {
}

resource "google_billing_budget" "budget_project_sales_mobile_dev" {
  billing_account = data.google_billing_account.account.id
  display_name    = "Monthly costs project sales-mobile-dev"

  budget_filter {
    projects = ["projects/${data.google_project.jcqueiroz-sales-mobile-dev.number}"]
  }

  amount {
    specified_amount {
      currency_code = "R$"
      units         = "1000"
    }
  }

  threshold_rules {
    threshold_percent = 0.5
    
  }
  threshold_rules {
    threshold_percent = 0.9
    spend_basis       = "FORECASTED_SPEND"
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.notification_channel.id,
    ]
    disable_default_iam_recipients = true
  }
}

resource "google_monitoring_notification_channel" "notification_channel" {
  display_name = "Example Notification Channel"
  type         = "email"

  labels = {
    email_address = "user@xpto.com"
  }
}