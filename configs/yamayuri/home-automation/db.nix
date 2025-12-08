{
  services.home-assistant.config.recorder.db_url = "postgresql://@/hass";

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hass" ];
    ensureUsers = [
      {
        name = "hass";
        ensureDBOwnership = true;
      }
    ];
    # Optimization for the 1GB limit
    settings = {
      effective_cache_size = "256MB";
      shared_buffers = "64MB";
      maintenance_work_mem = "32MB";
      work_mem = "4MB";

      max_wal_size = "256MB";
      wal_level = "minimal";

      max_connections = 8;

      autovacuum_vacuum_cost_delay = "10ms";
      autovacuum_max_workers = 1;
    };
  };
}
