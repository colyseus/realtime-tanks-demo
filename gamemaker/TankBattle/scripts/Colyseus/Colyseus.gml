// =============================================================================
// Colyseus GML Wrapper — event constants, callback dispatch, helper functions
// =============================================================================

// Event type constants
#macro COLYSEUS_EVENT_NONE            0
#macro COLYSEUS_EVENT_ROOM_JOIN       1
#macro COLYSEUS_EVENT_STATE_CHANGE    2
#macro COLYSEUS_EVENT_ROOM_MESSAGE    3
#macro COLYSEUS_EVENT_ROOM_ERROR      4
#macro COLYSEUS_EVENT_ROOM_LEAVE      5
#macro COLYSEUS_EVENT_CLIENT_ERROR    6
#macro COLYSEUS_EVENT_PROPERTY_CHANGE 7
#macro COLYSEUS_EVENT_ITEM_ADD        8
#macro COLYSEUS_EVENT_ITEM_REMOVE     9

// Field type constants (matches colyseus_field_type_t)
#macro COLYSEUS_TYPE_STRING   0
#macro COLYSEUS_TYPE_NUMBER   1
#macro COLYSEUS_TYPE_BOOLEAN  2
#macro COLYSEUS_TYPE_INT8     3
#macro COLYSEUS_TYPE_UINT8    4
#macro COLYSEUS_TYPE_INT16    5
#macro COLYSEUS_TYPE_UINT16   6
#macro COLYSEUS_TYPE_INT32    7
#macro COLYSEUS_TYPE_UINT32   8
#macro COLYSEUS_TYPE_INT64    9
#macro COLYSEUS_TYPE_UINT64   10
#macro COLYSEUS_TYPE_FLOAT32  11
#macro COLYSEUS_TYPE_FLOAT64  12
#macro COLYSEUS_TYPE_REF      13
#macro COLYSEUS_TYPE_ARRAY    14
#macro COLYSEUS_TYPE_MAP      15

// Message payload type constants (matches colyseus_message_type_t)
#macro COLYSEUS_MSG_NIL    0
#macro COLYSEUS_MSG_BOOL   1
#macro COLYSEUS_MSG_INT    2
#macro COLYSEUS_MSG_UINT   3
#macro COLYSEUS_MSG_FLOAT  4
#macro COLYSEUS_MSG_STR    5
#macro COLYSEUS_MSG_BIN    6
#macro COLYSEUS_MSG_ARRAY  7
#macro COLYSEUS_MSG_MAP    8

// Internal globals for dispatch
global.__colyseus_room_handlers = ds_map_create();  // keyed by room_ref (real)
global.__colyseus_schema_handlers = array_create(256, undefined);

// =============================================================================
// Room event handler registration (keyed by room ref)
// =============================================================================

/// @param {Real} _room_ref  The room reference returned by join_or_create / join / etc.
/// @param {Function} _handler  handler(room_ref)
function colyseus_on_join(_room_ref, _handler) {
    var _entry = __colyseus_get_room_entry(_room_ref);
    _entry.on_join = _handler;
}

/// @param {Real} _room_ref
/// @param {Function} _handler  handler(room_ref)
function colyseus_on_state_change(_room_ref, _handler) {
    var _entry = __colyseus_get_room_entry(_room_ref);
    _entry.on_state_change = _handler;
}

/// @param {Real} _room_ref
/// @param {Function} _handler  handler(code, message)
function colyseus_on_error(_room_ref, _handler) {
    var _entry = __colyseus_get_room_entry(_room_ref);
    _entry.on_error = _handler;
}

/// @param {Real} _room_ref
/// @param {Function} _handler  handler(code, reason)
function colyseus_on_leave(_room_ref, _handler) {
    var _entry = __colyseus_get_room_entry(_room_ref);
    _entry.on_leave = _handler;
}

/// @param {Real} _room_ref
/// @param {Function} _handler  handler(room_ref, type_string, data)
///   data is auto-decoded: struct for maps, string/number/bool for primitives, undefined for nil/binary.
function colyseus_on_message(_room_ref, _handler) {
    var _entry = __colyseus_get_room_entry(_room_ref);
    _entry.on_message = _handler;
}

/// Internal: get or create room handler entry
function __colyseus_get_room_entry(_room_ref) {
    if (!ds_map_exists(global.__colyseus_room_handlers, _room_ref)) {
        ds_map_set(global.__colyseus_room_handlers, _room_ref, {});
    }
    return ds_map_find_value(global.__colyseus_room_handlers, _room_ref);
}

// =============================================================================
// Schema callback wrappers — register native callback + store GML handler
// =============================================================================

/// Listen for property changes: handler(value, previous_value)
/// Usage: colyseus_listen(callbacks, "field", handler)          — listens on root state
///        colyseus_listen(callbacks, instance, "field", handler) — listens on a child instance
function colyseus_listen(_callbacks, _instance_or_property, _property_or_handler, _handler) {
    if (is_string(_instance_or_property)) {
        // Root shorthand: colyseus_listen(callbacks, "field", handler)
        _handler = _property_or_handler;
        var _handle = colyseus_callbacks_listen(_callbacks, 0, _instance_or_property);
    } else {
        // Full form: colyseus_listen(callbacks, instance, "field", handler)
        var _handle = colyseus_callbacks_listen(_callbacks, _instance_or_property, _property_or_handler);
    }
    if (_handle >= 0) {
        global.__colyseus_schema_handlers[_handle] = _handler;
    }
    return _handle;
}

/// Listen for items added to a collection: handler(instance_handle, key)
/// Usage: colyseus_on_add(callbacks, "field", handler)          — listens on root state
///        colyseus_on_add(callbacks, instance, "field", handler) — listens on a child instance
function colyseus_on_add(_callbacks, _instance_or_property, _property_or_handler, _handler) {
    if (is_string(_instance_or_property)) {
        _handler = _property_or_handler;
        var _handle = colyseus_callbacks_on_add(_callbacks, 0, _instance_or_property);
    } else {
        var _handle = colyseus_callbacks_on_add(_callbacks, _instance_or_property, _property_or_handler);
    }
    if (_handle >= 0) {
        global.__colyseus_schema_handlers[_handle] = _handler;
    }
    return _handle;
}

/// Listen for items removed from a collection: handler(instance_handle, key)
/// Usage: colyseus_on_remove(callbacks, "field", handler)          — listens on root state
///        colyseus_on_remove(callbacks, instance, "field", handler) — listens on a child instance
function colyseus_on_remove(_callbacks, _instance_or_property, _property_or_handler, _handler) {
    if (is_string(_instance_or_property)) {
        _handler = _property_or_handler;
        var _handle = colyseus_callbacks_on_remove(_callbacks, 0, _instance_or_property);
    } else {
        var _handle = colyseus_callbacks_on_remove(_callbacks, _instance_or_property, _property_or_handler);
    }
    if (_handle >= 0) {
        global.__colyseus_schema_handlers[_handle] = _handler;
    }
    return _handle;
}

// =============================================================================
// Schema field access — unified getter
// =============================================================================

/// Get a field value from a schema instance, auto-dispatching by type.
/// Returns: string for string fields, number for numeric/bool fields,
///          instance handle (real) for ref/array/map fields, undefined if unknown.
/// @param {Real} _instance  Schema instance handle
/// @param {String} _field   Field name
function colyseus_schema_get(_instance, _field) {
    var _type = __colyseus_schema_get(_instance, _field);
    if (_type == COLYSEUS_TYPE_STRING) {
        return __colyseus_schema_get_result_string();
    } else if (_type < 0) {
        return undefined;
    } else {
        return __colyseus_schema_get_result_number();
    }
}

// =============================================================================
// Message sending helper
// =============================================================================

/// Send a value as a message to the room.
/// Supports: structs (sent as map), booleans, numbers, and strings.
/// Examples:
///   colyseus_send(room, "move", { x: 10, y: 20 });
///   colyseus_send(room, "shoot", true);
///   colyseus_send(room, "target", 90);
///   colyseus_send(room, "name", "player1");
function colyseus_send(_room_ref, _type, _data) {
    var _msg;
    if (is_struct(_data)) {
        _msg = colyseus_message_create_map();
        var _keys = variable_struct_get_names(_data);
        for (var _i = 0; _i < array_length(_keys); _i++) {
            var _key = _keys[_i];
            var _val = variable_struct_get(_data, _key);
            if (is_string(_val)) {
                colyseus_message_put_str(_msg, _key, _val);
            } else if (is_bool(_val)) {
                colyseus_message_put_bool(_msg, _key, _val);
            } else {
                colyseus_message_put_number(_msg, _key, _val);
            }
        }
    } else if (is_bool(_data)) {
        _msg = colyseus_message_create_bool(_data);
    } else if (is_string(_data)) {
        _msg = colyseus_message_create_string(_data);
    } else if (is_numeric(_data)) {
        if (_data == floor(_data)) {
            _msg = colyseus_message_create_int(_data);
        } else {
            _msg = colyseus_message_create_number(_data);
        }
    } else {
        show_debug_message("colyseus_send: unsupported data type for message '" + _type + "'");
        return;
    }
    colyseus_room_send_message(_room_ref, _type, _msg);
}

// =============================================================================
// Message decoding helper — auto-decode received message into GML value
// =============================================================================

/// @returns {Struct|String|Real|Bool|Undefined}
function __colyseus_decode_message() {
    var _msg_type = colyseus_message_get_type();

    switch (_msg_type) {
        case COLYSEUS_MSG_MAP:
            var _struct = {};
            colyseus_message_iter_begin();
            while (colyseus_message_iter_next()) {
                var _key = colyseus_message_iter_key();
                var _vtype = colyseus_message_iter_value_type();
                if (_vtype == COLYSEUS_MSG_STR) {
                    variable_struct_set(_struct, _key, colyseus_message_iter_value_string());
                } else if (_vtype == COLYSEUS_MSG_BOOL) {
                    variable_struct_set(_struct, _key, colyseus_message_iter_value_number() > 0.5);
                } else {
                    variable_struct_set(_struct, _key, colyseus_message_iter_value_number());
                }
            }
            return _struct;

        case COLYSEUS_MSG_STR:
            return colyseus_message_read_string_value();

        case COLYSEUS_MSG_INT:
        case COLYSEUS_MSG_UINT:
        case COLYSEUS_MSG_FLOAT:
            return colyseus_message_read_number_value();

        case COLYSEUS_MSG_BOOL:
            return colyseus_message_read_number_value() > 0.5;

        default:
            return undefined;
    }
}

// =============================================================================
// Event processing — polls all events and dispatches to registered handlers
// =============================================================================

/// Poll and dispatch all queued Colyseus events. Call once per frame in Step.
function colyseus_process() {
    var _evt = colyseus_poll_event();

    while (_evt != COLYSEUS_EVENT_NONE) {
        var _room_ref = colyseus_event_get_room();
        var _entry = ds_map_exists(global.__colyseus_room_handlers, _room_ref)
            ? ds_map_find_value(global.__colyseus_room_handlers, _room_ref)
            : undefined;

        switch (_evt) {
            case COLYSEUS_EVENT_ROOM_JOIN:
                if (_entry != undefined && variable_struct_exists(_entry, "on_join")) {
                    _entry.on_join(_room_ref);
                }
                break;

            case COLYSEUS_EVENT_STATE_CHANGE:
                if (_entry != undefined && variable_struct_exists(_entry, "on_state_change")) {
                    _entry.on_state_change(_room_ref);
                }
                break;

            case COLYSEUS_EVENT_ROOM_MESSAGE:
                if (_entry != undefined && variable_struct_exists(_entry, "on_message")) {
                    _entry.on_message(
                        _room_ref,
                        colyseus_event_get_message(),
                        __colyseus_decode_message()
                    );
                }
                break;

            case COLYSEUS_EVENT_ROOM_ERROR:
                if (_entry != undefined && variable_struct_exists(_entry, "on_error")) {
                    _entry.on_error(
                        colyseus_event_get_code(),
                        colyseus_event_get_message()
                    );
                }
                break;

            case COLYSEUS_EVENT_CLIENT_ERROR:
                show_debug_message("Colyseus client error [" + string(colyseus_event_get_code()) + "]: " + colyseus_event_get_message());
                if (_entry != undefined && variable_struct_exists(_entry, "on_error")) {
                    _entry.on_error(
                        colyseus_event_get_code(),
                        colyseus_event_get_message()
                    );
                }
                break;

            case COLYSEUS_EVENT_ROOM_LEAVE:
                if (_entry != undefined && variable_struct_exists(_entry, "on_leave")) {
                    _entry.on_leave(
                        colyseus_event_get_code(),
                        colyseus_event_get_message()
                    );
                }
                break;

            case COLYSEUS_EVENT_PROPERTY_CHANGE:
                var _cb = colyseus_event_get_callback_handle();
                var _handler = global.__colyseus_schema_handlers[_cb];
                if (_handler != undefined) {
                    var _type = colyseus_event_get_value_type();
                    var _val, _prev;
                    if (_type == COLYSEUS_TYPE_STRING) {
                        _val = colyseus_event_get_value_string();
                        _prev = colyseus_event_get_prev_value_string();
                    } else if (_type == COLYSEUS_TYPE_REF) {
                        _val = colyseus_event_get_instance();
                        _prev = 0;
                    } else {
                        _val = colyseus_event_get_value_number();
                        _prev = colyseus_event_get_prev_value_number();
                    }
                    _handler(_val, _prev);
                }
                break;

            case COLYSEUS_EVENT_ITEM_ADD:
                var _cb = colyseus_event_get_callback_handle();
                var _handler = global.__colyseus_schema_handlers[_cb];
                if (_handler != undefined) {
                    _handler(
                        colyseus_event_get_instance(),
                        colyseus_event_get_key_string()
                    );
                }
                break;

            case COLYSEUS_EVENT_ITEM_REMOVE:
                var _cb = colyseus_event_get_callback_handle();
                var _handler = global.__colyseus_schema_handlers[_cb];
                if (_handler != undefined) {
                    _handler(
                        colyseus_event_get_instance(),
                        colyseus_event_get_key_string()
                    );
                }
                break;
        }

        _evt = colyseus_poll_event();
    }
}
