{...}:{
  services.grafana.provision = {
    datasources.settings.datasources = [
      {
        name="yesoreyeram-infinity-datasource";
        type="yesoreyeram-infinity-datasource";
        uid="ee8mxxpus3ny8b";
      }
    ];
    dashboards.settings.providers = [
      {
        name = "weather dashboard";
        options.path = ./dashboards/weather.json;
      }
    ];
  };
}
