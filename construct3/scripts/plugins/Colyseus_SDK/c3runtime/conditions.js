const C3 = globalThis.C3;

const ANY = ":any:";
const typesByIndex = ["string", "number", "boolean", "undefined", "object"];

function checkPath(lastPath, path) {
  if (lastPath === path) {
    return true;

  } else if (path.indexOf(ANY) >= 0) {
    const lastSegments = lastPath.split(".");
    const segments = path.split(".");

    if (lastSegments.length === segments.length) {
      for (let i = 0; i < segments.length; i++) {
        if (segments[i] !== ANY && segments[i] !== lastSegments[i]) {
          return false;
        }
      }
      return true;

    } else {
      return false;
    }

  } else {
    return false;
  }
}

C3.Plugins.Colyseus_SDK.Cnds =
{
  // Client
  OnLatency() { return true; },

  // Matchmaking
  OnJoinRoom() { return true; },
  OnJoinError() { return true; },
  OnAnyError() { return true; },

  // Room
  OnLeaveRoom() { return true; },
  OnRoomError() { return true; },
  OnStateChange() { return true; },
  OnRoomPing() { return true; },
  OnMessage(type) {
    return (
      type === "*" ||
      this.lastType === type
    );
  },

  // Messages
  CompareMessageType(cmp, type) { return C3.compare(this.lastType, cmp, type); },
  CompareMessageValue(cmp, value) { return C3.compare(this.lastMessage, cmp, value); },
  CompareMessageValueAt(path, cmp, value) { return C3.compare(this.getDeepVariable(path, this.lastMessage), cmp, value); },
  CompareMessageValueOfType(cmp, type) { return C3.compare(typeof (this.lastMessage), cmp, typesByIndex[type]); },
  CompareMessageValueAtOfType(path, cmp, type) { return C3.compare(typeof (this.getDeepVariable(path, this.lastMessage)), cmp, typesByIndex[type]); },

  // Auth
  OnAuthChange() { return true; },
  OnAuthError() { return true; },

  // HTTP
  OnRequestComplete() { return true; },
  OnRequestError() { return true; },

  // State/Schema
  OnChangeAtPath(path) { return checkPath(this.lastPath, path); },
  CompareStateValueAt(path, cmp, value) { return C3.compare(this.getDeepVariable(path, this.room && this.room.state), cmp, value); },

  // State/Schema/Collections
  OnCollectionItemAdd(path) { return this.lastCollectionPath === path; },
  OnCollectionItemRemove(path) { return this.lastCollectionPath === path; },
  OnCollectionItemChange(path) { return this.lastCollectionPath === path; },
  CompareItemsAtCount(path, cmp, count) {
    const collection = this.getDeepVariable(path, (this.room && this.room.state));
    const itemsCount = (typeof (collection.indexOf) === "function"
      ? (collection.length || 0)
      : (collection.size || 0));
    return C3.compare(itemsCount, cmp, count);
  },
  CompareCurrentItemsCount(cmp, count) {
    const collection = this.lastCollection || "";
    const itemsCount = (typeof (collection.indexOf) === "function"
      ? (collection.length || 0)
      : (collection.size || 0));
    return C3.compare(itemsCount, cmp, count);
  },
  ArrayHasValue(path, value) {
    const arr = this.getDeepVariable(path, this.room && this.room.state);
    return arr && typeof (arr.includes) === "function" && arr.includes(value)
  },
  MapHasKey(path, key) {
    const map = this.getDeepVariable(path, this.room && this.room.state);
    return map && typeof (map.has) === "function" && map.has(key);
  },

  // State
  CompareCurrentKey(cmp, key) { return C3.compare(this.lastKey, cmp, key); },
  CompareCurrentValue(cmp, value) { return C3.compare(this.lastValue, cmp, value); },
  CompareCurrentValueAt(path, cmp, value) { return C3.compare(this.getDeepVariable(path, this.lastValue), cmp, value); },
  ForEachItemAt(path) {
    const self = this;
    const collection = this.getDeepVariable(path, this.room && this.room.state);

    if (collection && typeof (collection.forEach) === "function") {

      this.lastCollectionPath = path;
      this.lastCollection = collection;

      const loopCtx = this.runtime.sdk.createLoopingConditionContext();

      collection.forEach(function (item, key) {
        self.lastKey = key;
        self.lastPath = path + "." + key;
        self.lastValue = item;

        loopCtx.retrigger();

        if (loopCtx.isStopped) {
          return;
        }
      });

      loopCtx.release();
    }
    // Return false since event already executed
    return false;
  },

  // HTTP
  OnRequestComplete(tag) { return this.lastRequestTag === tag; },
  OnRequestError(tag) { return this.lastRequestTag === tag; },

  // Error handling
  HasErrorCode(cmp, code) { return this.lastError && C3.compare(this.lastError.code, cmp, code); },
  HasErrorMessage(cmp, message) { return this.lastError && C3.compare(this.lastError.message, cmp, message); }

};