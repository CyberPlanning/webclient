import './css/colors.css'
import './css/main.css'
import './css/tooltip.css'
import './css/calendar.css'
import './css/sidemenu.css'
import './css/secret.css'
import './css/cybericons.css'
import './css/material-checkbox.css'
import { Elm } from './Main.elm'
// import registerServiceWorker from './service/registerServiceWorker';
const storageKeyGroup = 'groupId'
const storageKeySettings = 'settings'

const urlParams = new URLSearchParams(window.location.search)
const urlGroup = urlParams.get('g')

const defaultSettings = {
    showHack2g2: true,
    showCustom: true,
    menuOpened: false,
    allWeek: false,
}

const localGroup = (function() {
    const val = urlGroup || localStorage.getItem(storageKeyGroup) || 0
    const ret = parseInt(val)
    if (isNaN(ret)) {
        return 0
    } else {
        return ret
    }
})()
const localSettings = (function() {
    const s = localStorage.getItem(storageKeySettings)
    if (s == undefined) {
        return defaultSettings
    }
    try {
        const data = JSON.parse(s)
        return { ...defaultSettings, ...data }
    } catch (error) {
        return defaultSettings
    }
})()

const app = Elm.Main.init({
    node: document.getElementById('root'),
    flags: {
        groupId: localGroup,
        settings: localSettings,
    },
})

app.ports.save.subscribe(function({ groupId, settings }) {
    localStorage.setItem(storageKeyGroup, groupId)
    localStorage.setItem(storageKeySettings, JSON.stringify(settings))
})

// registerServiceWorker();

var _0x6ba2 = [
    '\x66\x6C\x61\x67',
    '\x67\x72\x6F\x75\x70\x43\x6F\x6C\x6C\x61\x70\x73\x65\x64',
    '\x54\x68\x33\x5F\x42\x34\x73\x31\x63\x5F\x4C\x30\x67\x5F\x30\x66\x5F\x44\x33\x61\x37\x68',
    '\x69\x6E\x66\x6F',
    '\x67\x72\x6F\x75\x70\x45\x6E\x64',
]
console[_0x6ba2[1]](_0x6ba2[0])
console[_0x6ba2[3]](_0x6ba2[2])
console[_0x6ba2[4]](_0x6ba2[0])
