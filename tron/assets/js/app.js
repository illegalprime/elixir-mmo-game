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
import * as Phaser from 'phaser';

/**
 * Setup Socket
 */
const socket = new Socket("/socket", {
    params: { token: window.userToken }
});

socket.connect();

const channel = socket.channel('world:lobby', {});

channel.join()
    .receive("ok", resp => console.log("Joined successfully", resp))
    .receive("error", resp => console.log("Unable to join", resp));


/**
 * Setup Game Engine
 */
const config = {
    type: Phaser.AUTO,
    width: 700,
    height: 600,
    parent: 'game_container',
    scene: {
        preload: preload,
        create: create
    }
};

const game = new Phaser.Game(config);

function preload ()
{
    this.load.setBaseURL('http://labs.phaser.io');

    this.load.image('sky', 'assets/skies/space3.png');
    this.load.image('logo', 'assets/sprites/phaser3-logo.png');
    this.load.image('red', 'assets/particles/red.png');
}

function create ()
{
    this.add.image(400, 300, 'sky');

    const particles = this.add.particles('red');

    const emitter = particles.createEmitter({
        speed: 100,
        scale: { start: 1, end: 0 },
        blendMode: 'ADD'
    });

    const logo = this.add.image(400, 100, 'logo').setInteractive();
    this.input.setDraggable(logo);
    this.input.on('drag', function (pointer, gameObject, dragX, dragY) {
        // update local game
        gameObject.x = dragX;
        gameObject.y = dragY;

        // update everyone else
        channel.push('shout', {
            x: dragX,
            y: dragY,
        });
    });

    // Listen for changes and update message box
    channel.on('shout', payload => {
        logo.x = payload.x;
        logo.y = payload.y;
    });

    emitter.startFollow(logo);
}
