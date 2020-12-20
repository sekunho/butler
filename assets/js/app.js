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
import _ from "lodash"

let selectedSlots = {}
let isDown = false
const className = "events__time-slot"
let Hooks = {}
let debounceFn = null

Hooks.FocusNameField = {
    mounted() {
        this.el.focus()
    }
}

Hooks.MobileMenu = {
    mounted() {
        let menuBtn = document.getElementById("mobile-menu")
        let menuExitBtn = document.getElementById("mobile-menu-exit")
        let drawer = document.getElementById("mobile-menu-drawer")

        menuBtn.addEventListener("click", () => drawer.classList.remove("hidden"))
        menuExitBtn.addEventListener("click", () => drawer.classList.add("hidden"))
    }
}

Hooks.TimeSlots = {
    mounted() {
        let slots = document.getElementsByClassName(className)
        isDown = false

        for (let x = 0; x < slots.length; x++) {
            const slotDate = slots[x].getAttribute("phx-value-day")
            const slotId = slots[x].getAttribute("phx-value-id")
            const isSelectedSlot = slots[x].classList.contains("events__time-slot--active")

            if (isSelectedSlot) {
                updateDaySlots(slotDate, slotId)
            }

            slots[x].addEventListener("mousedown", onMouseDown)
            slots[x].addEventListener("mouseenter", onMouseEnter, false)
        }

        document.addEventListener("mouseup", onMouseUp.bind(this))

        // Update local copy of selected slots.
        this.handleEvent("refresh_local_slots", ({ selected_slots }) => {
            selectedSlots = selected_slots
            // isExecutable = true
        })
    },

    beforeDestroy() {
        // Listeners have to be remove because they will be added once the hook
        // gets mounted again. It will not be able to tell if it already has an
        // existing listener, or at least I currently don't know. Had to get this
        // done ASAP. So maybe I'll leave a todo to investigate?
        // TODO: Check if there is a better way than this.
        let slots = document.getElementsByClassName(className)

        for (let x = 0; x < slots.length; x++) {
            slots[x].removeEventListener("mousedown", onMouseDown)
            slots[x].removeEventListener("mouseenter", onMouseEnter, false)
        }

        document.removeEventListener("mouseup", onMouseUp)
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

// Toggles a slot, and updates `selectedSlots` accordingly.
function toggleSlot(slotEl) {
    const activeClass = "events__time-slot--active"
    slotEl.classList.toggle(activeClass)

    const isSelected = slotEl.classList.contains(activeClass)
    const index = slotEl.getAttribute("phx-value-id")
    const day = slotEl.getAttribute("phx-value-day")

    // Check if the new toggled state is selected.
    if (isSelected) {
        updateDaySlots(day, index)
    } else {
        const ndx = selectedSlots[day].findIndex((el) => {
            return el == index
        })

        if (ndx > -1) {
            selectedSlots[day].splice(ndx, 1)
        }
    }
}

// Update local copy of selected slots.
function updateDaySlots(date, slotId) {
    if (date in selectedSlots && !selectedSlots[date].includes(slotId)) {
        selectedSlots[date].push(slotId)
    } else {
        selectedSlots[date] = [slotId]
    }
}

// Listener functions
const onMouseDown = (e) => {
    if (!isDown) {
        toggleSlot(e.target)
    }

    isDown = true
}

const onMouseEnter = (e) => {
    if (isDown) {
        const elem = e.target.closest(`.${className}`);

        if (elem) {
            toggleSlot(elem)
        }
    }
}

function onMouseUp() {
    if (isDown) {
        isDown = false

        debounceFn?.cancel()
        debounceFn = _.debounce(function () {
            // Send list of selected slots to the server
            this.pushEvent("update_time_slots", { "selected_slots": selectedSlots })
        }.bind(this), 1000)

        debounceFn()
    }
}