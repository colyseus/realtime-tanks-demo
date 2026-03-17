const C3 = globalThis.C3;
const Colyseus = globalThis['Colyseus'];

C3.Plugins.Colyseus_SDK.Acts =
{
  SetEndpoint(endpoint) {
    this.endpoint = endpoint || this.endpoint;
    this.client = new Colyseus.Client(this.endpoint);
  },

  JoinRoom(roomName, options) {
    this._MatchMake("join", roomName, options);
  },

  JoinOrCreateRoom(roomName, options) {
    this._MatchMake("joinOrCreate", roomName, options);
  },

  CreateRoom(roomName, options) {
    this._MatchMake("create", roomName, options);
  },

  JoinRoomById(roomId, options) {
    this._MatchMake("joinById", roomId, options);
  },

  ConsumeSeatReservation(reservation) {
    this._MatchMake("consumeSeatReservation", undefined, reservation);
  },

  ReconnectRoom(reconnectionToken) {
    this._MatchMake("reconnect", undefined, reconnectionToken);
  },

  RoomSend(type, message) {
    if (this.room && this.room.connection) {
      this.room.send(type, message);

    } else {
      console.log("RoomSend: not connected.");
    }
  },

  RoomSendJSON(type, message) {
    C3.Plugins.Colyseus_SDK.Acts.RoomSend.call(this, type, JSON.parse(message));
  },

  RoomLeave(consented) {
    if (this.room) {
      this.room.leave(consented);
    }
  },

  GetRoomPing() {
    if (this.room && this.room.connection) {
      this.room.ping((ms) => {
        this.lastPing = ms;
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnRoomPing);
      });
    }
  },

  GetLatency() {
    if (this.client) {
      this.client.getLatency().then((ms) => {
        this.lastLatency = ms;
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnLatency);
      }).catch((err) => {
        this._onError(err);
      });
    }
  },

  /**
   * Auth methods
   */

  SetAuthToken(token) {
    this.client.auth.token = token;
  },

  AuthGetUserData() {
    this.client.auth.getUserData()
      .then((authData) => {
        this.lastAuthUserData = authData.user || {};
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAuthChange);
      })
      .catch((e) => {
        this.lastError = e;
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAuthError);
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAnyError);
      });
  },

  RegisterWithEmailAndPassword(name, password, options) {
    this.client.auth.registerWithEmailAndPassword(name, password, JSON.parse(options))
      .then((authData) => {
        this.lastAuthUserData = authData.user || {};
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAuthChange);
      })
      .catch((e) => {
        this.lastError = e;
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAuthError);
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAnyError);
      });
  },

  SignInWithEmailAndPassword(name, password) {
    this.client.auth.signInWithEmailAndPassword(name, password)
      .then((authData) => {
        this.lastAuthUserData = authData.user || {};
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAuthChange);
      })
      .catch((e) => {
        this.lastError = e;
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAuthError);
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAnyError);
      });
  },

  SignInAnonymously(options) {
    this.client.auth.signInAnonymously(JSON.parse(options))
      .then((authData) => {
        this.lastAuthUserData = authData.user || {};
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAuthChange);
      })
      .catch((e) => {
        this.lastError = e;
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAuthError);
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAnyError);
      });
  },

  SignInWithProvider(provider) {
    throw new Error("SignInWithProvider is not supported on this SDK because it rely on window.open() which is not available inside Web Workers.");
    // this.client.auth.signInWithProvider(provider)
    //   .then((authData) => {
    //     this.lastAuthUserData = authData.user || {};
    //     this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAuthChange);
    //   })
    //   .catch((e) => {
    //     this.lastError = e;
    //     this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAuthError);
    //   });
  },

  SendPasswordResetEmail(email) {
    this.client.auth.sendPasswordResetEmail(email)
      .then(() => {
        console.log("SendPasswordResetEmail complete.");
      })
      .catch((e) => {
        this.lastError = e;
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAuthError);
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAnyError);
      });
  },

  SignOut() {
    this.client.auth.signOut();
    this.lastError = undefined;
    this.lastAuthUserData = undefined;
    this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAuthChange);
  },

  /**
   * HTTP Methods
   */
  HttpGet(tag, path, headers) { this._HttpRequest('get', tag, path, undefined, headers); },
  HttpPost(tag, path, body, headers) { this._HttpRequest('post', tag, path, body, headers); },
  HttpDel(tag, path, body, headers) { this._HttpRequest('del', tag, path, body, headers); },
  HttpPut(tag, path, body, headers) { this._HttpRequest('put', tag, path, body, headers); },

}
