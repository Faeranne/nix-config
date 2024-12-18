import { App } from "astal/gtk3"
import Bar from "./Bar"
import Applauncher from "./Launcher"
import style from "./style.scss"

/*
App.start({
	instanceName: "bar",
	requestHandler(request,res) {
		print(request)
		res("ok")
	},
	main: () => App.get_monitors().map(Bar),
})
*/

App.start({
	instanceName: "launcher",
	css: style,
	main: Applauncher,
})
