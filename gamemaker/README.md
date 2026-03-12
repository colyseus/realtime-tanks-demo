# GameMaker Client

2D client built with GameMaker Studio 2 using [Kenney Top-Down Tanks](https://kenney.nl/assets/top-down-tanks-redux) sprites.

## Setup

1. Open `TankBattle/TankBattle.yyp` in GameMaker Studio 2 (2024.x or later).
2. Download and import the [GameMaker Colyseus SDK](https://github.com/colyseus/native-sdk/releases?q=%22GameMaker+SDK%22&expanded=true) into the project.
3. Make sure the server is running first (`cd ../server && npm run dev`).

## Running

- **Native (macOS/Windows/Linux):** Press F5 or click Run in GameMaker.
- **HTML5:** Select HTML5 as target platform, then Run.

The client connects to `ws://localhost:2567` by default.
