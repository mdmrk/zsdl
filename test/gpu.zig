const zsdl = @import("zsdl");
const std = @import("std");
const gpu = zsdl.gpu;
const video = zsdl.video;
const math = std.math;

pub fn rotateMatrix(angle: f32, x: f32, y: f32, z: f32, result: *[16]f32) void {
    const radians = angle * math.pi / 180.0;
    const c = @cos(radians);
    const s = @sin(radians);
    const c1 = 1.0 - c;

    const length = @sqrt(x * x + y * y + z * z);
    const u = [3]f32{
        x / length,
        y / length,
        z / length,
    };

    // Zero the matrix first
    for (result) |*val| {
        val.* = 0.0;
    }
    result[15] = 1.0;

    // Set up rotation matrix
    for (0..3) |i| {
        result[i * 4 + ((i + 1) % 3)] = u[(i + 2) % 3] * s;
        result[i * 4 + ((i + 2) % 3)] = -u[(i + 1) % 3] * s;
    }

    for (0..3) |i| {
        for (0..3) |j| {
            result[i * 4 + j] += c1 * u[i] * u[j] + (if (i == j) c else 0.0);
        }
    }
}

pub fn perspectiveMatrix(fovy: f32, aspect: f32, znear: f32, zfar: f32, result: *[16]f32) void {
    const f = 1.0 / @tan(fovy * 0.5);

    // Zero the matrix first
    for (result) |*val| {
        val.* = 0.0;
    }

    result[0] = f / aspect;
    result[5] = f;
    result[10] = (znear + zfar) / (znear - zfar);
    result[11] = -1.0;
    result[14] = (2.0 * znear * zfar) / (znear - zfar);
    result[15] = 0.0;
}

pub fn multiplyMatrix(lhs: *const [16]f32, rhs: *const [16]f32, result: *[16]f32) void {
    var tmp: [16]f32 = undefined;

    for (0..4) |i| {
        for (0..4) |j| {
            tmp[j * 4 + i] = 0.0;

            for (0..4) |k| {
                tmp[j * 4 + i] += lhs[k * 4 + i] * rhs[j * 4 + k];
            }
        }
    }

    // Copy result
    for (0..16) |i| {
        result[i] = tmp[i];
    }
}

pub fn translateMatrix(matrix: *[16]f32, x: f32, y: f32, z: f32) void {
    matrix[12] += x;
    matrix[13] += y;
    matrix[14] += z;
}

test "graphics pipeline" {
    const Vertex = extern struct {
        pos: [3]f32,
        color: [3]f32,
    };

    const vertices = [_]Vertex{
        .{ .pos = .{ -0.5, 0.5, -0.5 }, .color = .{ 1.0, 0.0, 0.0 } },
        .{ .pos = .{ 0.5, -0.5, -0.5 }, .color = .{ 0.0, 0.0, 1.0 } },
        .{ .pos = .{ -0.5, -0.5, -0.5 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ -0.5, 0.5, -0.5 }, .color = .{ 1.0, 0.0, 0.0 } },
        .{ .pos = .{ 0.5, 0.5, -0.5 }, .color = .{ 1.0, 1.0, 0.0 } },
        .{ .pos = .{ 0.5, -0.5, -0.5 }, .color = .{ 0.0, 0.0, 1.0 } },
        .{ .pos = .{ -0.5, 0.5, 0.5 }, .color = .{ 1.0, 1.0, 1.0 } },
        .{ .pos = .{ -0.5, -0.5, -0.5 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ -0.5, -0.5, 0.5 }, .color = .{ 0.0, 1.0, 1.0 } },
        .{ .pos = .{ -0.5, 0.5, 0.5 }, .color = .{ 1.0, 1.0, 1.0 } },
        .{ .pos = .{ -0.5, 0.5, -0.5 }, .color = .{ 1.0, 0.0, 0.0 } },
        .{ .pos = .{ -0.5, -0.5, -0.5 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ -0.5, 0.5, 0.5 }, .color = .{ 1.0, 1.0, 1.0 } },
        .{ .pos = .{ 0.5, 0.5, -0.5 }, .color = .{ 1.0, 1.0, 0.0 } },
        .{ .pos = .{ -0.5, 0.5, -0.5 }, .color = .{ 1.0, 0.0, 0.0 } },
        .{ .pos = .{ -0.5, 0.5, 0.5 }, .color = .{ 1.0, 1.0, 1.0 } },
        .{ .pos = .{ 0.5, 0.5, 0.5 }, .color = .{ 0.0, 0.0, 0.0 } },
        .{ .pos = .{ 0.5, 0.5, -0.5 }, .color = .{ 1.0, 1.0, 0.0 } },
        .{ .pos = .{ 0.5, 0.5, -0.5 }, .color = .{ 1.0, 1.0, 0.0 } },
        .{ .pos = .{ 0.5, -0.5, 0.5 }, .color = .{ 1.0, 0.0, 1.0 } },
        .{ .pos = .{ 0.5, -0.5, -0.5 }, .color = .{ 0.0, 0.0, 1.0 } },
        .{ .pos = .{ 0.5, 0.5, -0.5 }, .color = .{ 1.0, 1.0, 0.0 } },
        .{ .pos = .{ 0.5, 0.5, 0.5 }, .color = .{ 0.0, 0.0, 0.0 } },
        .{ .pos = .{ 0.5, -0.5, 0.5 }, .color = .{ 1.0, 0.0, 1.0 } },
        .{ .pos = .{ 0.5, 0.5, 0.5 }, .color = .{ 0.0, 0.0, 0.0 } },
        .{ .pos = .{ -0.5, -0.5, 0.5 }, .color = .{ 0.0, 1.0, 1.0 } },
        .{ .pos = .{ 0.5, -0.5, 0.5 }, .color = .{ 1.0, 0.0, 1.0 } },
        .{ .pos = .{ 0.5, 0.5, 0.5 }, .color = .{ 0.0, 0.0, 0.0 } },
        .{ .pos = .{ -0.5, 0.5, 0.5 }, .color = .{ 1.0, 1.0, 1.0 } },
        .{ .pos = .{ -0.5, -0.5, 0.5 }, .color = .{ 0.0, 1.0, 1.0 } },
        .{ .pos = .{ -0.5, -0.5, -0.5 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ 0.5, -0.5, 0.5 }, .color = .{ 1.0, 0.0, 1.0 } },
        .{ .pos = .{ -0.5, -0.5, 0.5 }, .color = .{ 0.0, 1.0, 1.0 } },
        .{ .pos = .{ -0.5, -0.5, -0.5 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ 0.5, -0.5, -0.5 }, .color = .{ 0.0, 0.0, 1.0 } },
        .{ .pos = .{ 0.5, -0.5, 0.5 }, .color = .{ 1.0, 0.0, 1.0 } },
    };

    const vertex_shader_source = [_]u8{ 0x03, 0x02, 0x23, 0x07, 0x00, 0x00, 0x01, 0x00, 0x0b, 0x00, 0x08, 0x00, 0x2a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x02, 0x00, 0x01, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x47, 0x4c, 0x53, 0x4c, 0x2e, 0x73, 0x74, 0x64, 0x2e, 0x34, 0x35, 0x30, 0x00, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x6d, 0x61, 0x69, 0x6e, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0x22, 0x00, 0x00, 0x00, 0x03, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x00, 0xc2, 0x01, 0x00, 0x00, 0x05, 0x00, 0x04, 0x00, 0x04, 0x00, 0x00, 0x00, 0x6d, 0x61, 0x69, 0x6e, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x05, 0x00, 0x09, 0x00, 0x00, 0x00, 0x6f, 0x75, 0x74, 0x5f, 0x63, 0x6f, 0x6c, 0x6f, 0x72, 0x00, 0x00, 0x00, 0x05, 0x00, 0x05, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x69, 0x6e, 0x5f, 0x63, 0x6f, 0x6c, 0x6f, 0x72, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x06, 0x00, 0x16, 0x00, 0x00, 0x00, 0x67, 0x6c, 0x5f, 0x50, 0x65, 0x72, 0x56, 0x65, 0x72, 0x74, 0x65, 0x78, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x06, 0x00, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x67, 0x6c, 0x5f, 0x50, 0x6f, 0x73, 0x69, 0x74, 0x69, 0x6f, 0x6e, 0x00, 0x06, 0x00, 0x07, 0x00, 0x16, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x67, 0x6c, 0x5f, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x53, 0x69, 0x7a, 0x65, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x07, 0x00, 0x16, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x67, 0x6c, 0x5f, 0x43, 0x6c, 0x69, 0x70, 0x44, 0x69, 0x73, 0x74, 0x61, 0x6e, 0x63, 0x65, 0x00, 0x06, 0x00, 0x07, 0x00, 0x16, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x67, 0x6c, 0x5f, 0x43, 0x75, 0x6c, 0x6c, 0x44, 0x69, 0x73, 0x74, 0x61, 0x6e, 0x63, 0x65, 0x00, 0x05, 0x00, 0x03, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x03, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x55, 0x42, 0x4f, 0x00, 0x06, 0x00, 0x07, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6d, 0x6f, 0x64, 0x65, 0x6c, 0x56, 0x69, 0x65, 0x77, 0x50, 0x72, 0x6f, 0x6a, 0x00, 0x00, 0x00, 0x05, 0x00, 0x03, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x05, 0x00, 0x22, 0x00, 0x00, 0x00, 0x69, 0x6e, 0x5f, 0x70, 0x6f, 0x73, 0x69, 0x74, 0x69, 0x6f, 0x6e, 0x00, 0x47, 0x00, 0x04, 0x00, 0x09, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x47, 0x00, 0x04, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x48, 0x00, 0x05, 0x00, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x00, 0x05, 0x00, 0x16, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x48, 0x00, 0x05, 0x00, 0x16, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x48, 0x00, 0x05, 0x00, 0x16, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x47, 0x00, 0x03, 0x00, 0x16, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x48, 0x00, 0x04, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0x48, 0x00, 0x05, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x23, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x00, 0x05, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x47, 0x00, 0x03, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x47, 0x00, 0x04, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x22, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x47, 0x00, 0x04, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x21, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x47, 0x00, 0x04, 0x00, 0x22, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13, 0x00, 0x02, 0x00, 0x02, 0x00, 0x00, 0x00, 0x21, 0x00, 0x03, 0x00, 0x03, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x16, 0x00, 0x03, 0x00, 0x06, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x17, 0x00, 0x04, 0x00, 0x07, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00, 0x08, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00, 0x08, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x17, 0x00, 0x04, 0x00, 0x0a, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x0a, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x2b, 0x00, 0x04, 0x00, 0x06, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x3f, 0x15, 0x00, 0x04, 0x00, 0x13, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2b, 0x00, 0x04, 0x00, 0x13, 0x00, 0x00, 0x00, 0x14, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x04, 0x00, 0x15, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x14, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x06, 0x00, 0x16, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x15, 0x00, 0x00, 0x00, 0x15, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00, 0x17, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x16, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00, 0x17, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x15, 0x00, 0x04, 0x00, 0x19, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x2b, 0x00, 0x04, 0x00, 0x19, 0x00, 0x00, 0x00, 0x1a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x04, 0x00, 0x1b, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x03, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x1b, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00, 0x1d, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00, 0x1d, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00, 0x1f, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x1b, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x22, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x36, 0x00, 0x05, 0x00, 0x02, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0xf8, 0x00, 0x02, 0x00, 0x05, 0x00, 0x00, 0x00, 0x3d, 0x00, 0x04, 0x00, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x51, 0x00, 0x05, 0x00, 0x06, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x00, 0x0d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x51, 0x00, 0x05, 0x00, 0x06, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x0d, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x51, 0x00, 0x05, 0x00, 0x06, 0x00, 0x00, 0x00, 0x11, 0x00, 0x00, 0x00, 0x0d, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x50, 0x00, 0x07, 0x00, 0x07, 0x00, 0x00, 0x00, 0x12, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x11, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x03, 0x00, 0x09, 0x00, 0x00, 0x00, 0x12, 0x00, 0x00, 0x00, 0x41, 0x00, 0x05, 0x00, 0x1f, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x1a, 0x00, 0x00, 0x00, 0x3d, 0x00, 0x04, 0x00, 0x1b, 0x00, 0x00, 0x00, 0x21, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x3d, 0x00, 0x04, 0x00, 0x0a, 0x00, 0x00, 0x00, 0x23, 0x00, 0x00, 0x00, 0x22, 0x00, 0x00, 0x00, 0x51, 0x00, 0x05, 0x00, 0x06, 0x00, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x23, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x51, 0x00, 0x05, 0x00, 0x06, 0x00, 0x00, 0x00, 0x25, 0x00, 0x00, 0x00, 0x23, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x51, 0x00, 0x05, 0x00, 0x06, 0x00, 0x00, 0x00, 0x26, 0x00, 0x00, 0x00, 0x23, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x50, 0x00, 0x07, 0x00, 0x07, 0x00, 0x00, 0x00, 0x27, 0x00, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x25, 0x00, 0x00, 0x00, 0x26, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x91, 0x00, 0x05, 0x00, 0x07, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00, 0x21, 0x00, 0x00, 0x00, 0x27, 0x00, 0x00, 0x00, 0x41, 0x00, 0x05, 0x00, 0x08, 0x00, 0x00, 0x00, 0x29, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0x1a, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x03, 0x00, 0x29, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x01, 0x00, 0x38, 0x00, 0x01, 0x00 };

    const fragment_shader_source = [_]u8{ 0x03, 0x02, 0x23, 0x07, 0x00, 0x00, 0x01, 0x00, 0x0b, 0x00, 0x08, 0x00, 0x0d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x02, 0x00, 0x01, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x47, 0x4c, 0x53, 0x4c, 0x2e, 0x73, 0x74, 0x64, 0x2e, 0x34, 0x35, 0x30, 0x00, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x07, 0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x6d, 0x61, 0x69, 0x6e, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x10, 0x00, 0x03, 0x00, 0x04, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x03, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x00, 0xc2, 0x01, 0x00, 0x00, 0x05, 0x00, 0x04, 0x00, 0x04, 0x00, 0x00, 0x00, 0x6d, 0x61, 0x69, 0x6e, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x05, 0x00, 0x09, 0x00, 0x00, 0x00, 0x6f, 0x75, 0x74, 0x5f, 0x63, 0x6f, 0x6c, 0x6f, 0x72, 0x00, 0x00, 0x00, 0x05, 0x00, 0x05, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x69, 0x6e, 0x5f, 0x63, 0x6f, 0x6c, 0x6f, 0x72, 0x00, 0x00, 0x00, 0x00, 0x47, 0x00, 0x04, 0x00, 0x09, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x47, 0x00, 0x04, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13, 0x00, 0x02, 0x00, 0x02, 0x00, 0x00, 0x00, 0x21, 0x00, 0x03, 0x00, 0x03, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x16, 0x00, 0x03, 0x00, 0x06, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x17, 0x00, 0x04, 0x00, 0x07, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00, 0x08, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00, 0x08, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00, 0x0a, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00, 0x0a, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x36, 0x00, 0x05, 0x00, 0x02, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0xf8, 0x00, 0x02, 0x00, 0x05, 0x00, 0x00, 0x00, 0x3d, 0x00, 0x04, 0x00, 0x07, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x03, 0x00, 0x09, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x01, 0x00, 0x38, 0x00, 0x01, 0x00 };

    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    const window = try video.Window.create(
        "Test",
        600,
        400,
        .{ .resizable = true },
    );
    defer window.destroy();

    const device = try gpu.Device.create(
        .{ .spirv = true },
        true,
        null,
    );
    defer device.destroy();

    try device.claimWindow(window);
    defer device.releaseWindow(window);

    const vertex_shader = try device.createShader(.{
        .code = &vertex_shader_source,
        .entrypoint = "main",
        .format = .{ .spirv = true },
        .stage = .vertex,
        .num_samplers = 0,
        .num_storage_textures = 0,
        .num_storage_buffers = 0,
        .num_uniform_buffers = 1,
    });
    defer device.releaseShader(vertex_shader);

    const fragment_shader = try device.createShader(.{
        .code = &fragment_shader_source,
        .entrypoint = "main",
        .format = .{ .spirv = true },
        .stage = .fragment,
        .num_samplers = 0,
        .num_storage_textures = 0,
        .num_storage_buffers = 0,
        .num_uniform_buffers = 0,
    });
    defer device.releaseShader(fragment_shader);

    const vertex_buffer = try device.createBuffer(.{
        .size = @sizeOf(@TypeOf(vertices)),
        .usage = .{
            .vertex = true,
        },
    });
    defer device.releaseBuffer(vertex_buffer);

    const transfer_buffer = try device.createTransferBuffer(.{
        .size = @sizeOf(@TypeOf(vertices)),
        .usage = .upload,
    });

    const map_tb: [*]u8 = @ptrCast(try device.mapTransferBuffer(transfer_buffer, false));
    @memcpy(map_tb[0..@sizeOf(@TypeOf(vertices))], std.mem.asBytes(&vertices));
    device.unmapTransferBuffer(transfer_buffer);

    var cmd_buffer = try device.acquireCommandBuffer();
    const copy_pass = try cmd_buffer.beginCopyPass();
    const buf_location: gpu.TransferBufferLocation = .{
        .transfer_buffer = transfer_buffer,
        .offset = 0,
    };
    var buf_region: gpu.BufferRegion = .{
        .buffer = vertex_buffer,
        .offset = 0,
        .size = @sizeOf(@TypeOf(vertices)),
    };
    copy_pass.uploadToBuffer(&buf_location, &buf_region, false);
    copy_pass.end();
    try cmd_buffer.submit();
    device.releaseTransferBuffer(transfer_buffer);

    const desc: gpu.GraphicsPipelineCreateInfo = .{
        .vertex_shader = vertex_shader,
        .fragment_shader = fragment_shader,
        .vertex_input_state = .{
            .vertex_buffer_descriptions = &[_]gpu.VertexBufferDescription{
                .{
                    .slot = 0,
                    .pitch = @sizeOf(Vertex),
                    .input_rate = .vertex,
                    .instance_step_rate = 0,
                },
            },
            .vertex_attributes = &[_]gpu.VertexAttribute{
                .{
                    .location = 0,
                    .buffer_slot = 0,
                    .format = .float3,
                    .offset = @offsetOf(Vertex, "pos"),
                },
                .{
                    .location = 1,
                    .buffer_slot = 0,
                    .format = .float3,
                    .offset = @offsetOf(Vertex, "color"),
                },
            },
        },
        .primitive_type = .triangle_list,
        .multisample_state = .{
            .sample_count = .@"1",
        },
        .depth_stencil_state = .{
            .compare_op = .less_or_equal,
            .enable_depth_write = true,
            .enable_depth_test = true,
        },
        .target_info = .{
            .color_target_descriptions = &[_]gpu.ColorTargetDescription{
                .{
                    .format = device.getSwapchainTextureFormat(window),
                },
            },
            .depth_stencil_format = .d16_unorm,
            .has_depth_stencil_target = true,
        },
    };
    const pipeline = try device.createGraphicsPipeline(desc);
    defer device.releaseGraphicsPipeline(pipeline);

    const window_size = try window.getSizeInPixels();

    const depth_texture = try device.createTexture(.{
        .type = .@"2d",
        .format = .d16_unorm,
        .width = window_size.width,
        .height = window_size.height,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
        .usage = .{ .depth_stencil_target = true },
        .props = 0,
    });
    defer device.releaseTexture(depth_texture);

    const msaa_texture = try device.createTexture(.{
        .type = .@"2d",
        .format = device.getSwapchainTextureFormat(window),
        .width = window_size.width,
        .height = window_size.height,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
        .usage = .{ .color_target = true },
        .props = 0,
    });
    defer device.releaseTexture(msaa_texture);

    const resolve_texture = try device.createTexture(.{
        .type = .@"2d",
        .format = device.getSwapchainTextureFormat(window),
        .width = window_size.width,
        .height = window_size.height,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
        .usage = .{ .color_target = true, .sampler = true },
        .props = 0,
    });
    defer device.releaseTexture(resolve_texture);

    var angle_x: f32 = 0.0;
    var angle_y: f32 = 0.0;
    var angle_z: f32 = 0.0;
    main_loop: while (true) {
        while (zsdl.events.pollEvent()) |event| {
            switch (event) {
                .quit => {
                    break :main_loop;
                },
                else => {},
            }
        }

        cmd_buffer = try device.acquireCommandBuffer();

        var swapchain_tex_size_w: u32 = undefined;
        var swapchain_tex_size_h: u32 = undefined;
        const swapchain_tex = try cmd_buffer.waitAndAcquireSwapchainTexture(window, &swapchain_tex_size_w, &swapchain_tex_size_h);

        const color_target = std.mem.zeroInit(gpu.ColorTargetInfo, .{
            .texture = swapchain_tex,
            .load_op = .clear,
            .store_op = .store,
        });

        const depth_target = std.mem.zeroInit(gpu.DepthStencilTargetInfo, .{
            .clear_depth = 1,
            .load_op = .clear,
            .store_op = .dont_care,
            .stencil_load_op = .dont_care,
            .stencil_store_op = .dont_care,
            .texture = depth_texture,
            .cycle = true,
        });

        const vertex_binding: gpu.BufferBinding = .{
            .buffer = vertex_buffer,
            .offset = 0,
        };

        var matrix_rotate: [16]f32 = undefined;
        var matrix_modelview: [16]f32 = undefined;
        var matrix_perspective: [16]f32 = undefined;
        var matrix_final: [16]f32 = undefined;
        rotateMatrix(angle_x, 1.0, 0.0, 0.0, &matrix_modelview);

        // Rotate around Y axis
        rotateMatrix(angle_y, 0.0, 1.0, 0.0, &matrix_rotate);
        multiplyMatrix(&matrix_rotate, &matrix_modelview, &matrix_modelview);

        // Rotate around Z axis
        rotateMatrix(angle_z, 0.0, 0.0, 1.0, &matrix_rotate);
        multiplyMatrix(&matrix_rotate, &matrix_modelview, &matrix_modelview);

        // Pull the camera back from the cube
        translateMatrix(&matrix_modelview, 0.0, 0.0, -2.5);

        // Create perspective projection
        const aspect = @as(f32, @floatFromInt(swapchain_tex_size_w)) / @as(f32, @floatFromInt(swapchain_tex_size_h));
        perspectiveMatrix(45.0, aspect, 0.01, 100.0, &matrix_perspective);

        // Combine modelview and perspective matrices
        multiplyMatrix(&matrix_perspective, &matrix_modelview, &matrix_final);

        // Update angles for animation
        angle_x += 3.0;
        angle_y += 2.0;
        angle_z += 1.0;

        // Keep angles in 0-360 range
        angle_x = @mod(angle_x, 360.0);
        angle_y = @mod(angle_y, 360.0);
        angle_z = @mod(angle_z, 360.0);

        cmd_buffer.pushVertexUniformData(0, &matrix_final, @sizeOf(@TypeOf(matrix_final)));
        const render_pass = try cmd_buffer.beginRenderPass(&.{color_target}, depth_target);
        render_pass.bindGraphicsPipeline(pipeline);
        render_pass.bindVertexBuffers(0, &.{vertex_binding});
        render_pass.drawPrimitives(vertices.len, 1, 0, 0);
        render_pass.end();
        try cmd_buffer.submit();
    }
}
