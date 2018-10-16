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

function preload ()
{
    this.load.image('player', 'images/player.png');
}

function create ()
{
    state.players = {};
    const create_player = (nick, x, y) => {
        const nick_text = this.add.text(0, 0, nick, {
            fontSize: '32px',
            fill: '#fff',
        });
        const avatar = this.physics.add.sprite(x, y, 'player');
        avatar.setTint(Math.random() * 0xffffff);
        return {
            nick_text,
            avatar,
        };
    };

    state.cursors = this.input.keyboard.createCursorKeys();
    state.score_text = this.add.text(10, 10, 'score: 0', {
        fontSize: '32px',
        fill: '#fff',
    });

    // create our player
    const nick = window.game_config.username;
    const player = create_player(nick, width/2, height/2);
    state.avatar = player.avatar;
    state.prev_pos = { x: 0, y: 0 };
    state.players[nick] = player;

    state.channel.on('shout', ({ x, y, nick }) => {
        // create new players when they join
        if (!state.players[nick]) {
            state.players[nick] = create_player(nick, x, y);
        }
        // otherwise move the player to the correct location
        else {
            const player = state.players[nick].avatar;
            player.x = x;
            player.y = y;
        }
    });
}

function update ()
{
    const {
        avatar,
        cursors,
    } = state;

    // manage keyboard controls
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

    // keep name aligned with character
    for (const [_, { avatar, nick_text }] of Object.entries(state.players)) {
        nick_text.x = avatar.x - nick_text.width / 2;
        nick_text.y = avatar.y - 50;
    }

    // send position update only when changed
    const [x, y] = [avatar.x, avatar.y];
    if (state.prev_pos.x !== x || state.prev_pos.y !== y) {
        state.update_pos(x, y);
        state.prev_pos = { x, y };
    }
}

function start_game(game_config) {
    const nick = game_config.username;
    state.game = new Phaser.Game(config);

    /**
     * Setup Socket
     */
    const socket = new Socket("/socket", {
        params: { token: window.userToken }
    });

    socket.connect();

    // connect to a player-specific socket
    state.channel = socket.channel('world:lobby', {});
    state.channel.join()
        .receive('ok', resp => console.log('Joined successfully', resp))
        .receive('error', resp => console.log('Unable to join', resp));

    state.update_pos = (x, y) => {
        state.channel.push('shout', { x, y, nick });
    };
}

if (window.game_config && window.game_config.enable) {
    start_game(window.game_config);
}
