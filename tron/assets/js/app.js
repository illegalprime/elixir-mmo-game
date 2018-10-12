// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import { Socket } from "phoenix";

const socket = new Socket("/socket", {
    params: { token: window.userToken }
});

socket.connect();

const channel = socket.channel('world:lobby', {});

// Get UI Elements
const ul = document.getElementById('msg-list');
const name = document.getElementById('name');
const msg = document.getElementById('msg');

// Listen for changes and update message box
channel.on('shout', payload => {
    const li = document.createElement('li');
    const name = payload.name || 'anon';
    li.innerHTML = `<b>${name}</b>: ${payload.message}`;
    ul.appendChild(li);
});

channel.join()
    .receive("ok", resp => console.log("Joined successfully", resp))
    .receive("error", resp => console.log("Unable to join", resp));

// Send message when the user hits 'Enter'
msg.addEventListener('keypress', event => {
    if (event.keyCode === 13 && msg.value.length > 0) {
        channel.push('shout', {
            name: name.value,
            message: msg.value,
        });
        msg.value = '';
    }
});
