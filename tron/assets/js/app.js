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
const width = 700;
const height = 600;
const config = {
    type: Phaser.AUTO,
    width,
    height,
    parent: 'game_container',
    physics: {
        default: 'arcade',
        arcade: {debug: false}
    },
    scene: {
        preload,
        create,
        update,
    }
};

const state = {};
if (window.game_config.enable) {
    state.game = new Phaser.Game(config);
}

function preload ()
{
    this.load.image('player', 'images/player.png');
}

function create ()
{
    state.cursors = this.input.keyboard.createCursorKeys();
    state.score_text = this.add.text(10, 10, 'score: 0', {
        fontSize: '32px',
        fill: '#fff',
    });
    state.nick_text = this.add.text(0, 0, window.game_config.username, {
        fontSize: '32px',
        fill: '#fff',
    });
    state.avatar_color = Math.random() * 0xffffff;
    state.avatar = this.physics.add.sprite(width/2, height/2, 'player');
    state.avatar.setTint(state.avatar_color);
    window.game_state = state;
}

function update ()
{
    const {
        nick_text,
        avatar,
        cursors,
    } = state;

    if (cursors.left.isDown) {
        avatar.setVelocityX(-160);
    }
    else if (cursors.right.isDown) {
        avatar.setVelocityX(160);
    }
    else {
        avatar.setVelocityX(0);
    }
    if (cursors.up.isDown) {
        avatar.setVelocityY(-160);
    }
    else if (cursors.down.isDown) {
        avatar.setVelocityY(160);
    }
    else {
        avatar.setVelocityY(0);
    }

    nick_text.x = avatar.x - nick_text.width / 2;
    nick_text.y = avatar.y - 50;
}
