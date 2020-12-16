// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"

let Hooks = {}
Hooks.TimeSlots = {
    mounted() {
        // TODO: Send data of selected slots to server once `mouseup` occurs.
        highlightSlots(this.el.id)
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
    params: { _csrf_token: csrfToken },
    hooks: Hooks,
})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

function highlightSlots() {
    let slots = document.getElementsByClassName('time-slot')
    console.log(slots.length)
    let isDown = false

    for (let x = 0; x < slots.length; x++) {
        slots[x].addEventListener("mousedown", function () {
            let hasClass = this.classList.contains("bg-green-500")
            this.classList.toggle("bg-green-500")

            isDown = true
        })

        slots[x].addEventListener("mouseover", (e) => mdownHandler(e, isDown), false)
        document.addEventListener("mouseup", function () {
            isDown = false
            slots[x].removeEventListener("mouseover", mdownHandler)
        })
    }
}

function mdownHandler(e, isDown) {
    if (isDown) {
        var elem = e.target.closest(".time-slot");
        if (elem) {
            e.target.classList.toggle("bg-green-500")
        }
    }
}