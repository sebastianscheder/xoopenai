try {
  ::xoopenai::Package require_site_wide_pages -refetch_if_modified true
} on error {errorMsg} {
  ns_log error "xoopenai-init: require_site_wide_pages lead to: $errorMsg"
}
