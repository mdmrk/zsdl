const std = @import("std");

const c = @import("c.zig").c;
const errify = @import("internal.zig").errify;
const pixels = @import("pixels.zig");
const PixelFormat = pixels.PixelFormat;
const rect = @import("rect.zig");

pub const Surface = struct {
    ptr: *c.SDL_Surface,

    /// Creates a new Surface that can be safely destroyed with deinit().
    pub fn create(width: c_int, height: c_int, format: PixelFormat) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_CreateSurface(width, height, @intFromEnum(format))),
        };
    }

    /// Creates a new Surface from existing pixel data.
    pub fn createFrom(width: c_int, height: c_int, format: PixelFormat, pixels_ptr: ?*anyopaque, pitch: c_int) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_CreateSurfaceFrom(width, height, format.toNative(), pixels_ptr, pitch)),
        };
    }

    /// Destroys the Surface and frees its associated memory.
    pub fn destroy(self: *const Surface) void {
        c.SDL_DestroySurface(self.ptr);
    }

    /// Gets the properties associated with the surface.
    pub fn getProperties(self: *const Surface) c.SDL_PropertiesID {
        return c.SDL_GetSurfaceProperties(self.ptr);
    }

    /// Sets the colorspace used by the surface.
    pub fn setColorspace(self: *const Surface, colorspace: c.SDL_Colorspace) !void {
        try errify(c.SDL_SetSurfaceColorspace(self.ptr, colorspace));
    }

    /// Gets the colorspace used by the surface.
    pub fn getColorspace(self: *const Surface) c.SDL_Colorspace {
        return c.SDL_GetSurfaceColorspace(self.ptr);
    }

    /// Creates a palette and associates it with the surface.
    pub fn createPalette(self: *const Surface) !*c.SDL_Palette {
        return try errify(c.SDL_CreateSurfacePalette(self.ptr));
    }

    /// Sets the palette used by the surface.
    pub fn setPalette(self: *const Surface, palette: ?*c.SDL_Palette) !void {
        try errify(c.SDL_SetSurfacePalette(self.ptr, palette));
    }

    /// Gets the palette used by the surface.
    pub fn getPalette(self: *const Surface) ?*c.SDL_Palette {
        return c.SDL_GetSurfacePalette(self.ptr);
    }

    /// Adds an alternate version of the surface.
    pub fn addAlternateImage(self: *const Surface, image: *Surface) !void {
        try errify(c.SDL_AddSurfaceAlternateImage(self.ptr, image.ptr));
    }

    /// Returns whether the surface has alternate versions available.
    pub fn hasAlternateImages(self: *const Surface) bool {
        return c.SDL_SurfaceHasAlternateImages(self.ptr);
    }

    /// Gets an array including all versions of the surface.
    pub fn getImages(self: *const Surface, count: ?*c_int) ![]*c.SDL_Surface {
        return try errify(c.SDL_GetSurfaceImages(self.ptr, count));
    }

    /// Removes all alternate versions of the surface.
    pub fn removeAlternateImages(self: *const Surface) void {
        c.SDL_RemoveSurfaceAlternateImages(self.ptr);
    }

    /// Sets up the surface for directly accessing the pixels.
    pub fn lock(self: *const Surface) !void {
        try errify(c.SDL_LockSurface(self.ptr));
    }

    /// Releases the surface after directly accessing the pixels.
    pub fn unlock(self: *const Surface) void {
        c.SDL_UnlockSurface(self.ptr);
    }

    /// Load a BMP image from a file.
    pub fn loadBMP(file: []const u8) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_LoadBMP(file.ptr)),
        };
    }

    /// Save the surface to a file in BMP format.
    pub fn saveBMP(self: *const Surface, file: []const u8) !void {
        try errify(c.SDL_SaveBMP(self.ptr, file.ptr));
    }

    /// Sets the RLE acceleration hint for the surface.
    pub fn setRLE(self: *const Surface, enabled: bool) !void {
        try errify(c.SDL_SetSurfaceRLE(self.ptr, enabled));
    }

    /// Returns whether the surface is RLE enabled.
    pub fn hasRLE(self: *const Surface) bool {
        return c.SDL_SurfaceHasRLE(self.ptr);
    }

    /// Sets the color key (transparent pixel) in the surface.
    pub fn setColorKey(self: *const Surface, enabled: bool, key: u32) !void {
        try errify(c.SDL_SetSurfaceColorKey(self.ptr, enabled, key));
    }

    /// Returns whether the surface has a color key.
    pub fn hasColorKey(self: *const Surface) bool {
        return c.SDL_SurfaceHasColorKey(self.ptr);
    }

    /// Gets the color key (transparent pixel) for the surface.
    pub fn getColorKey(self: *const Surface) !u32 {
        var key: u32 = undefined;
        try errify(c.SDL_GetSurfaceColorKey(self.ptr, &key));
        return key;
    }

    /// Sets an additional color value multiplied into blit operations.
    pub fn setColorMod(self: *const Surface, r: u8, g: u8, b: u8) !void {
        try errify(c.SDL_SetSurfaceColorMod(self.ptr, r, g, b));
    }

    /// Gets the additional color value multiplied into blit operations.
    pub fn getColorMod(self: *const Surface) !struct { r: u8, g: u8, b: u8 } {
        var r: u8 = undefined;
        var g: u8 = undefined;
        var b: u8 = undefined;
        try errify(c.SDL_GetSurfaceColorMod(self.ptr, &r, &g, &b));
        return .{ .r = r, .g = g, .b = b };
    }

    /// Sets an additional alpha value used in blit operations.
    pub fn setAlphaMod(self: *const Surface, alpha: u8) !void {
        try errify(c.SDL_SetSurfaceAlphaMod(self.ptr, alpha));
    }

    /// Gets the additional alpha value used in blit operations.
    pub fn getAlphaMod(self: *const Surface) !u8 {
        var alpha: u8 = undefined;
        try errify(c.SDL_GetSurfaceAlphaMod(self.ptr, &alpha));
        return alpha;
    }

    /// Sets the blend mode used for blit operations.
    pub fn setBlendMode(self: *const Surface, blend_mode: c.SDL_BlendMode) !void {
        try errify(c.SDL_SetSurfaceBlendMode(self.ptr, blend_mode));
    }

    /// Gets the blend mode used for blit operations.
    pub fn getBlendMode(self: *const Surface) !c.SDL_BlendMode {
        var blend_mode: c.SDL_BlendMode = undefined;
        try errify(c.SDL_GetSurfaceBlendMode(self.ptr, &blend_mode));
        return blend_mode;
    }

    /// Sets the clipping rectangle for the surface.
    pub fn setClipRect(self: *const Surface, rect_opt: ?rect.Rectangle) bool {
        const rect_ptr = if (rect_opt) |r| &r.toNative() else null;
        return c.SDL_SetSurfaceClipRect(self.ptr, rect_ptr);
    }

    /// Gets the clipping rectangle for the surface.
    pub fn getClipRect(self: *const Surface) !rect.Rectangle {
        var r: c.SDL_Rect = undefined;
        try errify(c.SDL_GetSurfaceClipRect(self.ptr, &r));
        return rect.Rectangle.fromNative(r);
    }

    /// Flips the surface vertically or horizontally.
    pub fn flip(self: *const Surface, flip_mode: c.SDL_FlipMode) !void {
        try errify(c.SDL_FlipSurface(self.ptr, flip_mode));
    }

    /// Creates a new surface identical to the existing surface.
    pub fn duplicate(self: *const Surface) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_DuplicateSurface(self.ptr)),
        };
    }

    /// Creates a new surface identical to the existing surface, scaled to the desired size.
    pub fn scale(self: *const Surface, width: c_int, height: c_int, scale_mode: c.SDL_ScaleMode) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_ScaleSurface(self.ptr, width, height, scale_mode)),
        };
    }

    /// Converts the surface to a new format.
    pub fn convert(self: *const Surface, format: PixelFormat) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_ConvertSurface(self.ptr, format.toNative())),
        };
    }

    /// Converts the surface to a new format and colorspace.
    pub fn convertAndColorspace(
        self: *const Surface,
        format: PixelFormat,
        palette: ?*c.SDL_Palette,
        colorspace: c.SDL_Colorspace,
        props: c.SDL_PropertiesID,
    ) !Surface {
        return Surface{
            .ptr = try errify(c.SDL_ConvertSurfaceAndColorspace(
                self.ptr,
                format.toNative(),
                palette,
                colorspace,
                props,
            )),
        };
    }

    /// Clears the surface with a specific color.
    pub fn clear(self: *const Surface, r: f32, g: f32, b: f32, a: f32) !void {
        try errify(c.SDL_ClearSurface(self.ptr, r, g, b, a));
    }

    /// Performs a fast fill of a rectangle with a specific color.
    pub fn fillRect(self: *const Surface, rect_opt: ?rect.Rectangle, color: u32) !void {
        const rect_ptr = if (rect_opt) |r| &r.toNative() else null;
        try errify(c.SDL_FillSurfaceRect(self.ptr, rect_ptr, color));
    }

    /// Performs a fast fill of a set of rectangles with a specific color.
    pub fn fillRects(self: *const Surface, rects: []const rect.Rectangle, color: u32) !void {
        var native_rects = try std.ArrayList(c.SDL_Rect).initCapacity(std.heap.c_allocator, rects.len);
        defer native_rects.deinit();

        for (rects) |r| {
            native_rects.appendAssumeCapacity(r.toNative());
        }

        try errify(c.SDL_FillSurfaceRects(self.ptr, native_rects.items.ptr, @intCast(rects.len), color));
    }

    /// Performs a fast blit from the source surface to the destination surface.
    pub fn blit(self: *const Surface, src_rect: ?rect.Rectangle) !rect.Rectangle {
        const src_rect_ptr = if (src_rect) |r| &r else null;
        var dst: rect.Rectangle = undefined;

        try errify(c.SDL_BlitSurface(self.ptr, src_rect_ptr, &dst, &dst));

        return dst;
    }

    /// Performs a scaled blit from the source surface to the destination surface.
    pub fn blitScaled(
        self: *const Surface,
        src_rect: ?rect.Rectangle,
        dst: *Surface,
        dst_rect: ?rect.Rectangle,
        scale_mode: c.SDL_ScaleMode,
    ) !void {
        const src_rect_ptr = if (src_rect) |r| &r.toNative() else null;
        const dst_rect_ptr = if (dst_rect) |r| &r.toNative() else null;
        try errify(c.SDL_BlitSurfaceScaled(self.ptr, src_rect_ptr, dst.ptr, dst_rect_ptr, scale_mode));
    }

    /// Maps an RGB triple to an opaque pixel value for the surface.
    pub fn mapRGB(self: *const Surface, r: u8, g: u8, b: u8) u32 {
        return c.SDL_MapSurfaceRGB(self.ptr, r, g, b);
    }

    /// Maps an RGBA quadruple to a pixel value for the surface.
    pub fn mapRGBA(self: *const Surface, r: u8, g: u8, b: u8, a: u8) u32 {
        return c.SDL_MapSurfaceRGBA(self.ptr, r, g, b, a);
    }

    /// Retrieves a single pixel from the surface.
    pub fn readPixel(self: *const Surface, x: c_int, y: c_int) !struct { r: u8, g: u8, b: u8, a: u8 } {
        var r: u8 = undefined;
        var g: u8 = undefined;
        var b: u8 = undefined;
        var a: u8 = undefined;
        try errify(c.SDL_ReadSurfacePixel(self.ptr, x, y, &r, &g, &b, &a));
        return .{ .r = r, .g = g, .b = b, .a = a };
    }

    /// Retrieves a single pixel from the surface as floating point values.
    pub fn readPixelFloat(self: *const Surface, x: c_int, y: c_int) !struct { r: f32, g: f32, b: f32, a: f32 } {
        var r: f32 = undefined;
        var g: f32 = undefined;
        var b: f32 = undefined;
        var a: f32 = undefined;
        try errify(c.SDL_ReadSurfacePixelFloat(self.ptr, x, y, &r, &g, &b, &a));
        return .{ .r = r, .g = g, .b = b, .a = a };
    }

    /// Writes a single pixel to the surface.
    pub fn writePixel(self: *const Surface, x: c_int, y: c_int, r: u8, g: u8, b: u8, a: u8) !void {
        try errify(c.SDL_WriteSurfacePixel(self.ptr, x, y, r, g, b, a));
    }

    /// Writes a single pixel to the surface using floating point values.
    pub fn writePixelFloat(self: *const Surface, x: c_int, y: c_int, r: f32, g: f32, b: f32, a: f32) !void {
        try errify(c.SDL_WriteSurfacePixelFloat(self.ptr, x, y, r, g, b, a));
    }

    /// Performs a low-level surface blitting only.
    pub fn blitUnchecked(self: *const Surface, src_rect: rect.Rectangle, dst: *Surface, dst_rect: rect.Rectangle) !void {
        try errify(c.SDL_BlitSurfaceUnchecked(self.ptr, &src_rect.toNative(), dst.ptr, &dst_rect.toNative()));
    }

    /// Performs a low-level surface scaled blitting only.
    pub fn blitUncheckedScaled(self: *const Surface, src_rect: rect.Rectangle, dst: *Surface, dst_rect: rect.Rectangle, scale_mode: c.SDL_ScaleMode) !void {
        try errify(c.SDL_BlitSurfaceUncheckedScaled(self.ptr, &src_rect.toNative(), dst.ptr, &dst_rect.toNative(), scale_mode));
    }

    /// Performs a stretched pixel copy from one surface to another.
    pub fn stretch(self: *const Surface, src_rect: rect.Rectangle, dst: *Surface, dst_rect: rect.Rectangle, scale_mode: c.SDL_ScaleMode) !void {
        try errify(c.SDL_StretchSurface(self.ptr, &src_rect.toNative(), dst.ptr, &dst_rect.toNative(), scale_mode));
    }

    /// Performs a tiled blit to a destination surface.
    pub fn blitTiled(self: *const Surface, src_rect: ?rect.Rectangle, dst: *Surface, dst_rect: ?rect.Rectangle) !void {
        const src_rect_ptr = if (src_rect) |r| &r.toNative() else null;
        const dst_rect_ptr = if (dst_rect) |r| &r.toNative() else null;
        try errify(c.SDL_BlitSurfaceTiled(self.ptr, src_rect_ptr, dst.ptr, dst_rect_ptr));
    }

    /// Performs a scaled and tiled blit to a destination surface.
    pub fn blitTiledWithScale(
        self: *const Surface,
        src_rect: ?rect.Rectangle,
        scal: f32,
        scale_mode: c.SDL_ScaleMode,
        dst: *Surface,
        dst_rect: ?rect.Rectangle,
    ) !void {
        const src_rect_ptr = if (src_rect) |r| &r.toNative() else null;
        const dst_rect_ptr = if (dst_rect) |r| &r.toNative() else null;
        try errify(c.SDL_BlitSurfaceTiledWithScale(self.ptr, src_rect_ptr, scal, scale_mode, dst.ptr, dst_rect_ptr));
    }

    /// Performs a scaled blit using the 9-grid algorithm.
    pub fn blit9Grid(
        self: *const Surface,
        src_rect: ?rect.Rectangle,
        left_width: c_int,
        right_width: c_int,
        top_height: c_int,
        bottom_height: c_int,
        scal: f32,
        scale_mode: c.SDL_ScaleMode,
        dst: *Surface,
        dst_rect: ?rect.Rectangle,
    ) !void {
        const src_rect_ptr = if (src_rect) |r| &r.toNative() else null;
        const dst_rect_ptr = if (dst_rect) |r| &r.toNative() else null;
        try errify(c.SDL_BlitSurface9Grid(
            self.ptr,
            src_rect_ptr,
            left_width,
            right_width,
            top_height,
            bottom_height,
            scal,
            scale_mode,
            dst.ptr,
            dst_rect_ptr,
        ));
    }

    /// Premultiply the alpha in a surface.
    pub fn premultiplyAlpha(self: *const Surface, linear: bool) !void {
        try errify(c.SDL_PremultiplySurfaceAlpha(self.ptr, linear));
    }
};

/// Copy a block of pixels of one format to another format.
pub fn convertPixels(
    width: c_int,
    height: c_int,
    src_format: PixelFormat,
    src: *const anyopaque,
    src_pitch: c_int,
    dst_format: PixelFormat,
    dst: *anyopaque,
    dst_pitch: c_int,
) !void {
    try errify(c.SDL_ConvertPixels(
        width,
        height,
        src_format.toNative(),
        src,
        src_pitch,
        dst_format.toNative(),
        dst,
        dst_pitch,
    ));
}

/// Copy a block of pixels of one format and colorspace to another format and colorspace.
pub fn convertPixelsAndColorspace(
    width: c_int,
    height: c_int,
    src_format: PixelFormat,
    src_colorspace: c.SDL_Colorspace,
    src_properties: c.SDL_PropertiesID,
    src: *const anyopaque,
    src_pitch: c_int,
    dst_format: PixelFormat,
    dst_colorspace: c.SDL_Colorspace,
    dst_properties: c.SDL_PropertiesID,
    dst: *anyopaque,
    dst_pitch: c_int,
) !void {
    try errify(c.SDL_ConvertPixelsAndColorspace(
        width,
        height,
        src_format.toNative(),
        src_colorspace,
        src_properties,
        src,
        src_pitch,
        dst_format.toNative(),
        dst_colorspace,
        dst_properties,
        dst,
        dst_pitch,
    ));
}

/// Premultiply the alpha on a block of pixels.
pub fn premultiplyAlpha(
    width: c_int,
    height: c_int,
    src_format: PixelFormat,
    src: *const anyopaque,
    src_pitch: c_int,
    dst_format: PixelFormat,
    dst: *anyopaque,
    dst_pitch: c_int,
    linear: bool,
) !void {
    try errify(c.SDL_PremultiplyAlpha(
        width,
        height,
        src_format.toNative(),
        src,
        src_pitch,
        dst_format.toNative(),
        dst,
        dst_pitch,
        linear,
    ));
}
