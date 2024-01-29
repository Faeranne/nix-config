{ ... }: {
  services.traefik.dynamicConfigOptions.http = {
    routers = {
      traefik = {
        rule = "Host(`traefik.oracle1.faeranne.com`)";
        service = "api@internal";
        entryPoints = [ "websecure" ];
        middlewares = [ "dash-auth" ];
      };
      dns = {
        rule = "Host(`ns1.faeranne.com`)";
        service = "dns";
        entryPoints = [ "websecure" ];
      };
    };
    services = {
      dns.loadBalancer.servers = [ {url = "http://10.200.1.4:5380";} ];
    };
  };
