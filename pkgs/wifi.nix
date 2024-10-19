{
  writeScriptBin
}: writeScriptBin "setupWifi" ''
  set -e
  SSID=\"$1\"
  PSK=\"$2\"
  ID=$(wpa_cli -- add_network | cut -d " " -f 4)
  wpa_cli -- set_network $ID ssid $SSID
  wpa_cli -- set_network $ID key_mgmt WPA-PSK
  wpa_cli -- set_network $ID psk $PSK
  wpa_cli -- enable_network $ID
''
