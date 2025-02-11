const std = @import("std");
const internal = @import("internal.zig");
const c = @import("c.zig").c;
const errify = internal.errify;
const joystick = @import("joystick.zig");
const JoystickID = joystick.JoystickID;
const Joystick = joystick.Joystick;
const JoystickConnectionState = joystick.JoystickConnectionState;

pub const GamepadType = enum(u32) {
    unknown = c.SDL_GAMEPAD_TYPE_UNKNOWN,
    standard = c.SDL_GAMEPAD_TYPE_STANDARD,
    xbox360 = c.SDL_GAMEPAD_TYPE_XBOX360,
    xboxone = c.SDL_GAMEPAD_TYPE_XBOXONE,
    ps3 = c.SDL_GAMEPAD_TYPE_PS3,
    ps4 = c.SDL_GAMEPAD_TYPE_PS4,
    ps5 = c.SDL_GAMEPAD_TYPE_PS5,
    nintendo_switch_pro = c.SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_PRO,
    nintendo_switch_joycon_left = c.SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT,
    nintendo_switch_joycon_right = c.SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT,
    nintendo_switch_joycon_pair = c.SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR,
};

pub const GamepadButton = enum(i32) {
    invalid = c.SDL_GAMEPAD_BUTTON_INVALID,
    south = c.SDL_GAMEPAD_BUTTON_SOUTH,
    east = c.SDL_GAMEPAD_BUTTON_EAST,
    west = c.SDL_GAMEPAD_BUTTON_WEST,
    north = c.SDL_GAMEPAD_BUTTON_NORTH,
    back = c.SDL_GAMEPAD_BUTTON_BACK,
    guide = c.SDL_GAMEPAD_BUTTON_GUIDE,
    start = c.SDL_GAMEPAD_BUTTON_START,
    left_stick = c.SDL_GAMEPAD_BUTTON_LEFT_STICK,
    right_stick = c.SDL_GAMEPAD_BUTTON_RIGHT_STICK,
    left_shoulder = c.SDL_GAMEPAD_BUTTON_LEFT_SHOULDER,
    right_shoulder = c.SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER,
    dpad_up = c.SDL_GAMEPAD_BUTTON_DPAD_UP,
    dpad_down = c.SDL_GAMEPAD_BUTTON_DPAD_DOWN,
    dpad_left = c.SDL_GAMEPAD_BUTTON_DPAD_LEFT,
    dpad_right = c.SDL_GAMEPAD_BUTTON_DPAD_RIGHT,
    misc1 = c.SDL_GAMEPAD_BUTTON_MISC1,
    right_paddle1 = c.SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1,
    left_paddle1 = c.SDL_GAMEPAD_BUTTON_LEFT_PADDLE1,
    right_paddle2 = c.SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2,
    left_paddle2 = c.SDL_GAMEPAD_BUTTON_LEFT_PADDLE2,
    touchpad = c.SDL_GAMEPAD_BUTTON_TOUCHPAD,
    misc2 = c.SDL_GAMEPAD_BUTTON_MISC2,
    misc3 = c.SDL_GAMEPAD_BUTTON_MISC3,
    misc4 = c.SDL_GAMEPAD_BUTTON_MISC4,
    misc5 = c.SDL_GAMEPAD_BUTTON_MISC5,
    misc6 = c.SDL_GAMEPAD_BUTTON_MISC6,
};

pub const GamepadButtonLabel = enum(u32) {
    unknown = c.SDL_GAMEPAD_BUTTON_LABEL_UNKNOWN,
    a = c.SDL_GAMEPAD_BUTTON_LABEL_A,
    b = c.SDL_GAMEPAD_BUTTON_LABEL_B,
    x = c.SDL_GAMEPAD_BUTTON_LABEL_X,
    y = c.SDL_GAMEPAD_BUTTON_LABEL_Y,
    cross = c.SDL_GAMEPAD_BUTTON_LABEL_CROSS,
    circle = c.SDL_GAMEPAD_BUTTON_LABEL_CIRCLE,
    square = c.SDL_GAMEPAD_BUTTON_LABEL_SQUARE,
    triangle = c.SDL_GAMEPAD_BUTTON_LABEL_TRIANGLE,
};

pub const GamepadAxis = enum(i32) {
    invalid = c.SDL_GAMEPAD_AXIS_INVALID,
    leftx = c.SDL_GAMEPAD_AXIS_LEFTX,
    lefty = c.SDL_GAMEPAD_AXIS_LEFTY,
    rightx = c.SDL_GAMEPAD_AXIS_RIGHTX,
    righty = c.SDL_GAMEPAD_AXIS_RIGHTY,
    left_trigger = c.SDL_GAMEPAD_AXIS_LEFT_TRIGGER,
    right_trigger = c.SDL_GAMEPAD_AXIS_RIGHT_TRIGGER,
};

pub const Gamepad = struct {
    ptr: *c.SDL_Gamepad,

    /// Open a gamepad for use.
    pub fn openGamepad(instance_id: JoystickID) !Gamepad {
        return .{
            .ptr = try errify(c.SDL_OpenGamepad(instance_id)),
        };
    }

    /// Get the SDL_Gamepad associated with a joystick instance ID, if it has been opened.
    pub fn getGamepadFromID(instance_id: JoystickID) !Gamepad {
        return .{
            .ptr = try errify(c.SDL_GetGamepadFromID(instance_id)),
        };
    }

    /// Get the implementation-dependent name for an opened gamepad.
    pub fn getName(self: *const Gamepad) ?[]const u8 {
        if (c.SDL_GetGamepadName(self.ptr)) |name| {
            return std.mem.span(name);
        }
        return null;
    }

    /// Get the implementation-dependent path for an opened gamepad.
    pub fn getPath(self: *const Gamepad) ?[]const u8 {
        if (c.SDL_GetGamepadPath(self.ptr)) |path| {
            return std.mem.span(path);
        }
        return null;
    }

    /// Get the type of an opened gamepad.
    pub fn getType(self: *const Gamepad) GamepadType {
        return @enumFromInt(c.SDL_GetGamepadType(self.ptr));
    }

    /// Get the type of an opened gamepad, ignoring any mapping override.
    pub fn getRealType(self: *const Gamepad) GamepadType {
        return @enumFromInt(c.SDL_GetRealGamepadType(self.ptr));
    }

    /// Get the player index of an opened gamepad.
    pub fn getPlayerIndex(self: *const Gamepad) i32 {
        return c.SDL_GetGamepadPlayerIndex(self.ptr);
    }

    /// Set the player index of an opened gamepad.
    pub fn setPlayerIndex(self: *const Gamepad, player_index: i32) !void {
        try errify(c.SDL_SetGamepadPlayerIndex(self.ptr, player_index));
    }

    /// Get the USB vendor ID of an opened gamepad, if available.
    pub fn getVendor(self: *const Gamepad) u16 {
        return c.SDL_GetGamepadVendor(self.ptr);
    }

    /// Get the USB product ID of an opened gamepad, if available.
    pub fn getProduct(self: *const Gamepad) u16 {
        return c.SDL_GetGamepadProduct(self.ptr);
    }

    /// Get the product version of an opened gamepad, if available.
    pub fn getProductVersion(self: *const Gamepad) u16 {
        return c.SDL_GetGamepadProductVersion(self.ptr);
    }

    /// Get the firmware version of an opened gamepad, if available.
    pub fn getFirmwareVersion(self: *const Gamepad) u16 {
        return c.SDL_GetGamepadFirmwareVersion(self.ptr);
    }

    /// Get the serial number of an opened gamepad, if available.
    pub fn getSerial(self: *const Gamepad) ?[]const u8 {
        if (c.SDL_GetGamepadSerial(self.ptr)) |serial| {
            return std.mem.span(serial);
        }
        return null;
    }

    /// Get the Steam Input handle of an opened gamepad, if available.
    pub fn getSteamHandle(self: *const Gamepad) u64 {
        return c.SDL_GetGamepadSteamHandle(self.ptr);
    }

    /// Get the connection state of a gamepad.
    pub fn getConnectionState(self: *const Gamepad) !JoystickConnectionState {
        const state: JoystickConnectionState = @enumFromInt(c.SDL_GetGamepadConnectionState(self.ptr));
        try errify(state != .invalid);
        return state;
    }

    /// Get the battery state of a gamepad.
    pub fn getPowerInfo(self: *const Gamepad, percent: ?*i32) c.SDL_PowerState {
        return c.SDL_GetGamepadPowerInfo(self.ptr, percent);
    }

    /// Check if a gamepad has been opened and is currently connected.
    pub fn connected(self: *const Gamepad) bool {
        return c.SDL_GamepadConnected(self.ptr);
    }

    /// Get the underlying joystick from a gamepad.
    pub fn getJoystick(self: *const Gamepad) !*Joystick {
        return try errify(c.SDL_GetGamepadJoystick(self.ptr));
    }

    /// Get the SDL joystick layer bindings for a gamepad.
    pub fn getBindings(self: *const Gamepad, count: *i32) ![]*c.SDL_GamepadBinding {
        return try errify(c.SDL_GetGamepadBindings(self.ptr, count));
    }

    /// Query whether a gamepad has a given axis.
    pub fn hasAxis(self: *const Gamepad, axis: GamepadAxis) bool {
        return c.SDL_GamepadHasAxis(self.ptr, @intFromEnum(axis));
    }

    /// Get the current state of an axis control on a gamepad.
    pub fn getAxis(self: *const Gamepad, axis: GamepadAxis) i16 {
        return c.SDL_GetGamepadAxis(self.ptr, @intFromEnum(axis));
    }

    /// Query whether a gamepad has a given button.
    pub fn hasButton(self: *const Gamepad, button: GamepadButton) bool {
        return c.SDL_GamepadHasButton(self.ptr, @intFromEnum(button));
    }

    /// Get the current state of a button on a gamepad.
    pub fn getButton(self: *const Gamepad, button: GamepadButton) bool {
        return c.SDL_GetGamepadButton(self.ptr, @intFromEnum(button));
    }

    /// Get the label of a button on a gamepad.
    pub fn getButtonLabel(self: *const Gamepad, button: GamepadButton) GamepadButtonLabel {
        return @enumFromInt(c.SDL_GetGamepadButtonLabel(self.ptr, @intFromEnum(button)));
    }

    /// Get the number of touchpads on a gamepad.
    pub fn getNumTouchpads(self: *const Gamepad) i32 {
        return c.SDL_GetNumGamepadTouchpads(self.ptr);
    }

    /// Get the number of supported simultaneous fingers on a touchpad on a game gamepad.
    pub fn getNumTouchpadFingers(self: *const Gamepad, touchpad: i32) i32 {
        return c.SDL_GetNumGamepadTouchpadFingers(self.ptr, touchpad);
    }

    /// Get the current state of a finger on a touchpad on a gamepad.
    pub fn getTouchpadFinger(self: *const Gamepad, touchpad: i32, finger: i32, down: ?*bool, x: ?*f32, y: ?*f32, pressure: ?*f32) !void {
        try errify(c.SDL_GetGamepadTouchpadFinger(self.ptr, touchpad, finger, down, x, y, pressure));
    }

    /// Return whether a gamepad has a particular sensor.
    pub fn hasSensor(self: *const Gamepad, sensor_type: c.SDL_SensorType) bool {
        return c.SDL_GamepadHasSensor(self.ptr, sensor_type);
    }

    /// Set whether data reporting for a gamepad sensor is enabled.
    pub fn setSensorEnabled(self: *const Gamepad, sensor_type: c.SDL_SensorType, enabled: bool) !void {
        try errify(c.SDL_SetGamepadSensorEnabled(self.ptr, sensor_type, enabled));
    }

    /// Query whether sensor data reporting is enabled for a gamepad.
    pub fn sensorEnabled(self: *const Gamepad, sensor_type: c.SDL_SensorType) bool {
        return c.SDL_GamepadSensorEnabled(self.ptr, sensor_type);
    }

    /// Get the data rate (number of events per second) of a gamepad sensor.
    pub fn getSensorDataRate(self: *const Gamepad, sensor_type: c.SDL_SensorType) f32 {
        return c.SDL_GetGamepadSensorDataRate(self.ptr, sensor_type);
    }

    /// Get the current state of a gamepad sensor.
    pub fn getSensorData(self: *const Gamepad, sensor_type: c.SDL_SensorType, data: [*]f32, num_values: i32) !void {
        try errify(c.SDL_GetGamepadSensorData(self.ptr, sensor_type, data, num_values));
    }

    /// Start a rumble effect on a gamepad.
    pub fn rumble(self: *const Gamepad, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) !void {
        try errify(c.SDL_RumbleGamepad(self.ptr, low_frequency_rumble, high_frequency_rumble, duration_ms));
    }

    /// Start a rumble effect in the gamepad's triggers.
    pub fn rumbleTriggers(self: *const Gamepad, left_rumble: u16, right_rumble: u16, duration_ms: u32) !void {
        try errify(c.SDL_RumbleGamepadTriggers(self.ptr, left_rumble, right_rumble, duration_ms));
    }

    /// Update a gamepad's LED color.
    pub fn setLED(self: *const Gamepad, red: u8, green: u8, blue: u8) !void {
        try errify(c.SDL_SetGamepadLED(self.ptr, red, green, blue));
    }

    /// Send a gamepad specific effect packet.
    pub fn sendEffect(self: *const Gamepad, data: *const anyopaque, size: i32) !void {
        try errify(c.SDL_SendGamepadEffect(self.ptr, data, size));
    }

    /// Close a gamepad previously opened with SDL_OpenGamepad().
    pub fn close(self: *const Gamepad) void {
        c.SDL_CloseGamepad(self.ptr);
    }

    /// Return the sfSymbolsName for a given button on a gamepad on Apple platforms.
    pub fn getAppleSFSymbolsNameForButton(self: *const Gamepad, button: GamepadButton) ?[]const u8 {
        if (c.SDL_GetGamepadAppleSFSymbolsNameForButton(self.ptr, button)) |name| {
            return std.mem.span(name);
        }
        return null;
    }

    /// Return the sfSymbolsName for a given axis on a gamepad on Apple platforms.
    pub fn getAppleSFSymbolsNameForAxis(self: *const Gamepad, axis: GamepadAxis) ?[]const u8 {
        if (c.SDL_GetGamepadAppleSFSymbolsNameForAxis(self.ptr, axis)) |name| {
            return std.mem.span(name);
        }
        return null;
    }
};

// Module-level functions

/// Add support for gamepads that SDL is unaware of or change the binding of an existing gamepad.
pub fn addGamepadMapping(mapping: [*:0]const u8) !void {
    const result = c.SDL_AddGamepadMapping(mapping);
    if (result == -1) return error.SdlError;
}

/// Load a set of gamepad mappings from an SDL_IOStream.
pub fn addGamepadMappingsFromIO(src: *c.SDL_IOStream, closeio: bool) !i32 {
    const result = c.SDL_AddGamepadMappingsFromIO(src, closeio);
    if (result == -1) return error.SdlError;
    return result;
}

/// Load a set of gamepad mappings from a file.
pub fn addGamepadMappingsFromFile(file: [*:0]const u8) !i32 {
    const result = c.SDL_AddGamepadMappingsFromFile(file);
    if (result == -1) return error.SdlError;
    return result;
}

/// Reinitialize the SDL mapping database to its initial state.
pub fn reloadGamepadMappings() !void {
    try errify(c.SDL_ReloadGamepadMappings());
}

/// Get the current gamepad mappings.
pub fn getGamepadMappings(count: ?*i32) ![*][*:0]u8 {
    return try errify(c.SDL_GetGamepadMappings(count));
}

/// Get the gamepad mapping string for a given GUID.
pub fn getGamepadMappingForGUID(guid: c.SDL_GUID) ![]const u8 {
    const result = try errify(c.SDL_GetGamepadMappingForGUID(guid));
    return std.mem.span(result);
}

/// Set the current mapping of a joystick or gamepad.
pub fn setGamepadMapping(instance_id: JoystickID, mapping: ?[*:0]const u8) !void {
    try errify(c.SDL_SetGamepadMapping(instance_id, mapping));
}

/// Return whether a gamepad is currently connected.
pub fn hasGamepad() bool {
    return c.SDL_HasGamepad();
}

/// Get a list of currently connected gamepads.
pub fn getGamepads(count: ?*i32) ![*]JoystickID {
    return try errify(c.SDL_GetGamepads(count));
}

/// Check if the given joystick is supported by the gamepad interface.
pub fn isGamepad(instance_id: JoystickID) bool {
    return c.SDL_IsGamepad(instance_id);
}

/// Get the implementation dependent name of a gamepad.
pub fn getGamepadNameForID(instance_id: JoystickID) ?[]const u8 {
    if (c.SDL_GetGamepadNameForID(instance_id)) |name| {
        return std.mem.span(name);
    }
    return null;
}

/// Get the implementation dependent path of a gamepad.
pub fn getGamepadPathForID(instance_id: JoystickID) ?[]const u8 {
    if (c.SDL_GetGamepadPathForID(instance_id)) |path| {
        return std.mem.span(path);
    }
    return null;
}

/// Get the player index of a gamepad.
pub fn getGamepadPlayerIndexForID(instance_id: JoystickID) i32 {
    return c.SDL_GetGamepadPlayerIndexForID(instance_id);
}

/// Get the implementation-dependent GUID of a gamepad.
pub fn getGamepadGUIDForID(instance_id: JoystickID) c.SDL_GUID {
    return c.SDL_GetGamepadGUIDForID(instance_id);
}

/// Get the USB vendor ID of a gamepad, if available.
pub fn getGamepadVendorForID(instance_id: JoystickID) u16 {
    return c.SDL_GetGamepadVendorForID(instance_id);
}

/// Get the USB product ID of a gamepad, if available.
pub fn getGamepadProductForID(instance_id: JoystickID) u16 {
    return c.SDL_GetGamepadProductForID(instance_id);
}

/// Get the product version of a gamepad, if available.
pub fn getGamepadProductVersionForID(instance_id: JoystickID) u16 {
    return c.SDL_GetGamepadProductVersionForID(instance_id);
}

/// Get the type of a gamepad.
pub fn getGamepadTypeForID(instance_id: JoystickID) GamepadType {
    return @enumFromInt(c.SDL_GetGamepadTypeForID(instance_id));
}

/// Get the type of a gamepad, ignoring any mapping override.
pub fn getRealGamepadTypeForID(instance_id: JoystickID) GamepadType {
    return @enumFromInt(c.SDL_GetRealGamepadTypeForID(instance_id));
}

/// Get the mapping of a gamepad.
pub fn getGamepadMappingForID(instance_id: JoystickID) ![]const u8 {
    const result = try errify(c.SDL_GetGamepadMappingForID(instance_id));
    return std.mem.span(result);
}

/// Set the state of gamepad event processing.
pub fn setGamepadEventsEnabled(enabled: bool) void {
    c.SDL_SetGamepadEventsEnabled(enabled);
}

/// Query the state of gamepad event processing.
pub fn gamepadEventsEnabled() bool {
    return c.SDL_GamepadEventsEnabled();
}

/// Manually pump gamepad updates if not using the loop.
pub fn updateGamepads() void {
    c.SDL_UpdateGamepads();
}

/// Convert a string into GamepadType enum.
pub fn getGamepadTypeFromString(str: [*:0]const u8) GamepadType {
    return @enumFromInt(c.SDL_GetGamepadTypeFromString(str));
}

/// Convert from an GamepadType enum to a string.
pub fn getGamepadStringForType(gamepad_type: GamepadType) ?[]const u8 {
    if (c.SDL_GetGamepadStringForType(@intFromEnum(gamepad_type))) |str| {
        return std.mem.span(str);
    }
    return null;
}

/// Convert a string into SDL_GamepadAxis enum.
pub fn getGamepadAxisFromString(str: [*:0]const u8) GamepadAxis {
    return @enumFromInt(c.SDL_GetGamepadAxisFromString(str));
}

/// Convert from an SDL_GamepadAxis enum to a string.
pub fn getGamepadStringForAxis(axis: GamepadAxis) ?[]const u8 {
    if (c.SDL_GetGamepadStringForAxis(axis)) |str| {
        return std.mem.span(str);
    }
    return null;
}

/// Convert a string into an SDL_GamepadButton enum.
pub fn getGamepadButtonFromString(str: [*:0]const u8) GamepadButton {
    return @enumFromInt(c.SDL_GetGamepadButtonFromString(str));
}

/// Convert from an SDL_GamepadButton enum to a string.
pub fn getGamepadStringForButton(button: GamepadButton) ?[]const u8 {
    if (c.SDL_GetGamepadStringForButton(button)) |str| {
        return std.mem.span(str);
    }
    return null;
}

/// Get the label of a button on a gamepad.
pub fn getGamepadButtonLabelForType(gamepad_type: GamepadType, button: GamepadButton) GamepadButtonLabel {
    return c.SDL_GetGamepadButtonLabelForType(@intFromEnum(gamepad_type), button);
}
