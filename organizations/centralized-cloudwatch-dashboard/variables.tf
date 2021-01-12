variable "monitoring_acc_id" {
    type = string
}

variable "permissions_policies" {
    type = list(string)
    default = [
        "AWSXrayReadOnlyAccess", 
        "CloudWatchReadOnlyAccess", 
        "CloudWatchAutomaticDashboardsAccess"
    ]
}