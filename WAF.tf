resource "azurerm_web_application_firewall_policy" "WAF-policy" {
  name                = "wafpolicy"
  resource_group_name = azurerm_resource_group.CyberWatch.name
  location            = azurerm_resource_group.CyberWatch.location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    exclusion {
      match_variable          = "RequestHeaderNames"
      selector                = "x-company-secret-header"
      selector_match_operator = "Equals"
    }
    exclusion {
      match_variable          = "RequestCookieNames"
      selector                = "too-tasty"
      selector_match_operator = "EndsWith"
    }

    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
      rule_group_override {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        rule {
          id      = "920300"
          enabled = true
          action  = "Log"
        }

        rule {
          id      = "920440"
          enabled = true
          action  = "Block"
        }
      }
    }
  }
}
#These are general settings for the WAF:
#Enabled: This means the WAF is turned on.
#Prevention Mode: The WAF will block harmful traffic, not just log it.
#Request Body Check: The WAF will check the content of requests to make sure there’s no harmful data.
#File Upload Limit: The WAF limits file uploads to 100MB to avoid big files that could cause problems.
#Max Request Size: It also limits how large a request can be (up to 128KB).
#Managed Rules: These are pre-configured rules that help protect against common threats.
#OWASP: This is a set of rules created by security experts to protect websites from known vulnerabilities.
#Rule 920300: This rule logs any suspicious activity, but doesn’t block it.
#Rule 920440: This rule blocks HTTP request smuggling attacks, which can trick the website into allowing dangerous requests.
