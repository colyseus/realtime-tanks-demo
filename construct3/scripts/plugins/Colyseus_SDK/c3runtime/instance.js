const Colyseus = globalThis['Colyseus'];

const C3 = globalThis.C3;

C3.Plugins.Colyseus_SDK.Instance = class ColyseusInstance extends globalThis.ISDKInstanceBase {
  constructor() {
    super();

    const properties = this._getInitProperties();

    if (properties) {
      this.endpoint = properties[0] || this.endpoint;
      this.client = new Colyseus.Client(this.endpoint);
    }
  }

  _release() { super._release(); }

    // data to be saved for savegames
  _saveToJson() { return {}; }

		// load state for savegames
  _loadFromJson(o) { }

  _MatchMake(methodName, roomName, rawOptions) {
    const self = this;

    const options = (methodName !== "reconnect")
      ? JSON.parse(rawOptions || "{}")
      : rawOptions;

    const args = (methodName === "consumeSeatReservation" || methodName === "reconnect")
      ? [options]
      : [roomName, options];

    this.client[methodName](...args).then(function (room) {
      self.room = room;

      self.sessionId = self.room.sessionId;
      self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnJoinRoom);

      room.onError(function (code, message) {
        self.lastError = { code: code, message: message };
        self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnRoomError);
        self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAnyError);
      });

      room.onLeave(function (code) {
        self.lastCloseCode = code;
        self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnLeaveRoom);
      });

      room.onStateChange(function (state) {
        self.lastPath = "";
        self.lastKey = undefined;
        self.lastValue = state;
        self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnStateChange);
      });

      room.onMessage("*", function (type, message) {
        if (self.debug) {
          console.info("Colyseus: onMessage", type, message);
        }
        self.lastMessage = message;
        self.lastType = type;
        self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnMessage);
      });

      // listen for changes on the room's state
      room.onStateChange.once(function () {
        const callbacks = Colyseus.Callbacks.get(room);

        function registerCallbacksOnStructure(schemaInstance, path) {
          const metadata = schemaInstance.constructor[Symbol.metadata];

          for (const index in metadata) {
            const field = metadata[index].name;
            const type = metadata[index].type;
            const schemaType = typeof(type);

            if (schemaType === "object") {
              const isSchemaChild = Object.values(type).some((value) => value[Symbol.metadata]);

              // on item added to collection
              callbacks.onAdd(schemaInstance, field, function (item, key) {
                self.lastCollection = schemaInstance[field];
                onItemAdd([...path, field], item, key, isSchemaChild);

                //
                // if it's a Schema child, detect changes on it and trigger
                // "On item change" in the collection itself
                //
                if (isSchemaChild) {
                  // trigger "On item change"
                  callbacks.onChange(item, function () {
                    onItemChange([...path, field], item, key);
                  });
                }
              });

              // on item removed from collection
              callbacks.onRemove(schemaInstance, field, function (item, key) {
                self.lastCollection = schemaInstance[field];
                onItemRemove([...path, field], item, key);
              });

              //
              // only register onChange in the collection itself if it's not
              // a Schema child.
              //
              if (!isSchemaChild) {
                // on item changed in collection
                callbacks.onChange(schemaInstance, field, function (item, key) {
                  self.lastCollection = schemaInstance[field];
                  onItemChange([...path, field], item, key);
                });
              }

            } else if (schemaType === "function") {
              callbacks.listen(schemaInstance, field, function (instance, _) {
                // created the schema instance
                onChangeAtPath(field, path, instance, undefined);

                // direct schema instance
                callbacks.onChange(instance, function () {
                  onChangeAtPath(field, path, instance, undefined);
                });

                // "listen" on all instance fields
                registerCallbacksOnStructure(instance, [...path, field]);
              });

            } else {

              // field on schema instance
              callbacks.listen(schemaInstance, field, function (value, previousValue) {
                onChangeAtPath(field, path, value, previousValue);
              });
            }
          }
        }

        function onChangeAtPath(key, path, value, previousValue) {
          self.lastKey = key;
          self.lastPath = [...path, key].join(".");
          self.lastValue = value;
          self.lastPreviousValue = previousValue;
          if (self.debug) {
            console.log("onChange", self.lastPath, self.lastKey, self.lastValue);
          }
          self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnChangeAtPath);
        }

        function onItemAdd(path, instance, key, isSchemaChild) {
          // only register callbacks on child Schema structures.
          if (isSchemaChild) {
            registerCallbacksOnStructure(instance, [...path, key]);
          }

          self.lastCollectionPath = path.join(".");
          self.lastPath = self.lastCollectionPath + "." + key;
          self.lastKey = key;
          self.lastValue = instance;
          self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnChangeAtPath);
          self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnCollectionItemAdd);
        }

        function onItemChange(path, instance, key) {
          self.lastCollectionPath = path.join(".");
          self.lastPath = self.lastCollectionPath + "." + key;
          self.lastKey = key;
          self.lastValue = instance;
          self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnCollectionItemChange);
        }

        function onItemRemove(path, instance, key) {
          self.lastCollectionPath = path.join(".");
          self.lastPath = self.lastCollectionPath + "." + key;
          self.lastKey = key;
          self.lastValue = instance;
          self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnCollectionItemRemove);
        }

        registerCallbacksOnStructure(self.room.state, []);
      });

    }).catch(function (e) {
      if (self.debug) {
        console.error("Colyseus Error:", e.code);
        console.error(e.message);
      }
      if (e instanceof ProgressEvent) {
        self.lastError = { code: e.target.status, message: e.target.statusText };
      } else {
        self.lastError = e;
      }
      self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnJoinError);
      self._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAnyError);
    });
  }

  _HttpRequest(method, tag, path, _body, _headers) {
    let body;
    try { body = JSON.parse(_body); } catch (e) { body = _body; }

    let headers;
    try { headers = JSON.parse(_headers); } catch (e) { headers = {}; }

    this.client.http[method](path, { headers, body })
      .then(async (response) => {
        this.lastRequestTag = tag;
        this.lastHttpStatusCode = response.statusCode;

        //
        // TODO: The HTTP client should parse text data internally. We shouldn't do it ourselves here.
        //
        if (response.data instanceof ReadableStream) {
          const reader = response.body.getReader();
          const decoder = new TextDecoder();
          let result = '';
          while (true) {
            const { done, value } = await reader.read();
            if (done) break;
            result += decoder.decode(value);
          }
          this.lastValue = result;

        } else {
          this.lastValue = response.data;
        }

        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnRequestComplete);
      })
      .catch((e) => {
        this.lastValue = undefined;
        this.lastRequestTag = tag;
        this.lastError = e;
        this.lastHttpStatusCode = e.code;
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnRequestError);
        this._trigger(C3.Plugins.Colyseus_SDK.Cnds.OnAnyError);
      });
  }

  getDeepVariable(rawPath, container) {
    const path = rawPath.split(".");
    let value = container;

    // deeply get the requested variable from the room's state.
    try {
      do {
        value = (typeof (value.get) !== "function") // MapSchema's .get() method
          ? value[path.shift()]
          : value.get(path.shift());
      } while (path.length > 0);

    } catch (e) {
      if (this.debug) {
        console.warn("Colyseus: no value at path '" + rawPath + "'. Using empty string: \"\"", { path: rawPath, value: JSON.stringify(container) });
      }
      value = "";
    }

    return value;
  }

  castType(value) {
    //
    // Some types are not easily usable by C3, so we need to cast them.
    //
    switch (typeof (value)) {
      case "boolean":
        // convert boolean to number
        return Number(value);

      case "object":
        return JSON.stringify(value);

      case "number":
        return value;

      default:
        // Everything else
        // (in case of undefined, convert it to empty string)
        return value || "";
    }
  }
};
