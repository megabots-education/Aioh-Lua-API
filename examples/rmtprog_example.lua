require("rmtprog")

wifi_sta_config = {}
wifi_sta_config.ssid = "MCAF"
wifi_sta_config.pwd = "27111997"

rmtprog.start(wifi_sta_config, 80)
