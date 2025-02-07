const internal = @import("internal.zig");
const c = internal.c;
const errify = internal.errify;

pub const PowerState = enum(i32) {
    @"error" = c.SDL_POWERSTATE_ERROR,
    unknown = c.SDL_POWERSTATE_UNKNOWN,
    on_battery = c.SDL_POWERSTATE_ON_BATTERY,
    no_battery = c.SDL_POWERSTATE_NO_BATTERY,
    charging = c.SDL_POWERSTATE_CHARGING,
    charged = c.SDL_POWERSTATE_CHARGED,
};

pub fn getPowerInfo(seconds: ?*i32, percent: ?*i32) !PowerState {
    const state = c.SDL_GetPowerInfo(seconds, percent);
    try errify(state != c.SDL_POWERSTATE_ERROR);
    return @enumFromInt(state);
}
