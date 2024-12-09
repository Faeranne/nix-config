import { App } from "astal/gtk3"
import { Variable, GLib, bind } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk3"
import Battery from "gi://AstalBattery"
import Tray from "gi://AstalTray"

function BatteryLevel() {
	const bat = Battery.get_default()
	return <box className="Battery"
		visible={bind(bat, "isPresent")}>
		<icon icon={bind(bat, "batteryIconName")} />
		<label label={bind(bat, "percentage").as(p =>
			`${Math.floor(p * 100)} %`
		)} />
	</box>
}

function SysTray() {
	const tray = Tray.get_default()

	return <box>
		{bind(tray, "items").as(items => items.map(item => {
			if (item.iconThemePath)
				App.add_icons(item.iconThemePath)

			const menu = item.create_menu()

			return <button
				tooltipMarkup={bind(item, "tooltipMarkup")}
				onDestroy={() => menu?.destroy()}
				onClickRelease={self => {
					menu?.popup_at_widget(self, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH, null)
				}}>
				<icon gIcon={bind(item, "gicon")} />
			</button>
		}))}
	</box>
}

export default function Bar(monitor: Gdk.Monitor) {
	const anchor = Astal.WindowAnchor.TOP
		| Astal.WindowAnchor.LEFT
		| Astal.WindowAnchor.RIGHT
	return <window
		className="Bar"
		gdkmonitor={monitor}
		exclusivity={Astal.Exclusivity.EXCLUSIVE}
		anchor={anchor}>
		<centerbox>
			<box hexpand halign={Gtk.Align.START} >
				<BatteryLevel />
				<SysTray />
			</box>
			<box>
			</box>
			<box hexpand halign={Gtk.Align.END} >
			</box>
		</centerbox>
	</window>
}
