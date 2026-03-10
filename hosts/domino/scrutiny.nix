{
  services.scrutiny = {
    enable = true;
    settings = {
      web.listen.port = 8082;
      notify.urls = [
        "ntfy://127.0.0.1:2586/scrutiny?scheme=http"
      ];
    };
  };
}
