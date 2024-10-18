# Commonly configured through config/credentials.yml.enc.
# For deployment to Render, we support configuration through ENV variables
Rails.application.configure do
  Rails.logger.info "Configuring active record encryption from environment"
  config.active_record.encryption.primary_key = "WVIIBqooaH2SY8dyUDuGJmcYXWECTQFh"
  config.active_record.encryption.deterministic_key = "Fe8QXqavmJ8rGCFH6BE8nVgRudXdvVoS"
  config.active_record.encryption.key_derivation_salt = "sUj9DR8na2SlmvyVDRGFEsmfKVHy5PVP"
end