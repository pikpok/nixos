{
  services.windmill = {
    enable = true;

    serverPort = 8000;

    database = {
      name = "windmill";
      user = "windmill";
      createLocally = false;
      url = "postgres://windmill?host=/var/run/postgresql";
    };

    baseUrl = "https://windmill.pikpok.xyz";

    logLevel = "warn";
  };
}
