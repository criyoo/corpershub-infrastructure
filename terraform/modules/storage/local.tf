locals {
  api_secure_parameter_keys = tomap({
    for key in keys(nonsensitive(var.api_secure_parameters)) : key => key
  })
}
