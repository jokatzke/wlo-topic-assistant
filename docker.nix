{dockerTools, wlo-topic-assistant}:
dockerTools.buildLayeredImage {
  name = wlo-topic-assistant.pname;
  tag = "latest";
  config = {
    Cmd = [ "${wlo-topic-assistant}/bin/wlo-topic-assistant" ];
  };
}
