import { defineRoom, defineServer, playground, monitor, Server } from "colyseus";
import { BattleRoom } from "./rooms/BattleRoom";

const port = parseInt(process.env.PORT || "2567");

const server = defineServer({
  rooms: {
    battle: defineRoom(BattleRoom)
  },
  express: (app) => {
    app.use("/", playground());
    app.use("/monitor", monitor());
  }
});

server.listen(port).then(() => {
  console.log(`Tank Battle server listening on http://localhost:${port}`);
});
