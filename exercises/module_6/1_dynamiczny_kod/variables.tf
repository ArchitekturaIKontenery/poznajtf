variable "network_rules" {
    type = list(object({
        default_action             = string
        ip_rules                   = list(string)
        virtual_network_subnet_ids = optional(list(string))
    }))
    default = [{
        default_action             = "Deny"
        ip_rules                   = ["10.0.0.1"]
    }]
}