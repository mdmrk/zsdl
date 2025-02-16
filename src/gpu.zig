const std = @import("std");

const c = @import("c.zig").c;
const Error = @import("Error.zig");
const internal = @import("internal.zig");
const errify = internal.errify;
const Window = @import("video.zig").Window;
const FColor = @import("pixels.zig").FColor;
const FlipMode = @import("surface.zig").FlipMode;

pub const Viewport = extern struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    min_depth: f32,
    max_depth: f32,
};

pub const BufferBinding = extern struct {
    buffer: *Buffer,
    offset: u32,
};

pub const BufferLocation = extern struct {
    buffer: *Buffer,
    offset: u32,
};

pub const BufferRegion = extern struct {
    buffer: *Buffer,
    offset: u32,
    size: u32,
};

pub const TextureSamplerBinding = extern struct {
    texture: *Texture,
    sampler: *Sampler,
};

pub const TextureLocation = extern struct {
    texture: *Texture,
    mip_level: u32,
    layer: u32,
    x: u32,
    y: u32,
    z: u32,
};

pub const TextureRegion = extern struct {
    texture: *Texture,
    mip_level: u32,
    layer: u32,
    x: u32,
    y: u32,
    z: u32,
    w: u32,
    h: u32,
    d: u32,
};

pub const TextureTransferInfo = extern struct {
    transfer_buffer: *TransferBuffer,
    offset: u32,
    pixels_per_row: u32,
    rows_per_layer: u32,
};

pub const TransferBufferUsage = enum(u32) {
    upload = c.SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD,
    download = c.SDL_GPU_TRANSFERBUFFERUSAGE_DOWNLOAD,
};

pub const TransferBufferLocation = extern struct {
    transfer_buffer: *TransferBuffer,
    offset: u32,
};

pub const StorageTextureReadWriteBinding = extern struct {
    texture: *Texture,
    mip_level: u32,
    layer: u32,
    cycle: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

pub const StorageBufferReadWriteBinding = extern struct {
    buffer: *Buffer,
    cycle: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

pub const BlitRegion = extern struct {
    texture: *Texture,
    mip_level: u32,
    layer_or_depth_plane: u32,
    x: u32,
    y: u32,
    w: u32,
    h: u32,
};

pub const ColorTargetInfo = extern struct {
    texture: *Texture,
    mip_level: u32,
    layer_or_depth_plane: u32,
    clear_color: FColor,
    load_op: LoadOp,
    store_op: StoreOp,
    resolve_texture: *Texture,
    resolve_mip_level: u32,
    resolve_layer: u32,
    cycle: bool,
    cycle_resolve_texture: bool,
    padding1: u8,
    padding2: u8,
};

pub const DepthStencilTargetInfo = extern struct {
    texture: *Texture,
    clear_depth: f32,
    load_op: LoadOp,
    store_op: StoreOp,
    stencil_load_op: LoadOp,
    stencil_store_op: StoreOp,
    cycle: bool,
    clear_stencil: u8,
    padding1: u8,
    padding2: u8,
};

pub const BlitInfo = extern struct {
    source: BlitRegion,
    destination: BlitRegion,
    load_op: LoadOp,
    clear_color: FColor,
    flip_mode: FlipMode,
    filter: Filter,
    cycle: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

pub const Fence = c.SDL_GPUFence;
pub const Buffer = c.SDL_GPUBuffer;
pub const Texture = c.SDL_GPUTexture;
pub const TransferBuffer = c.SDL_GPUTransferBuffer;
pub const Sampler = c.SDL_GPUSampler;
pub const Shader = c.SDL_GPUShader;
pub const ComputePipeline = c.SDL_GPUComputePipeline;
pub const GraphicsPipeline = c.SDL_GPUGraphicsPipeline;

pub const StencilOpState = extern struct {
    fail_op: StencilOp,
    pass_op: StencilOp,
    depth_fail_op: StencilOp,
    compare_op: CompareOp,

    pub fn toNative(self: *const StencilOpState) c.SDL_GPUStencilOpState {
        return .{
            .fail_op = @intFromEnum(self.fail_op),
            .pass_op = @intFromEnum(self.pass_op),
            .depth_fail_op = @intFromEnum(self.depth_fail_op),
            .compare_op = @intFromEnum(self.compare_op),
        };
    }
};

pub const ShaderStage = enum(u32) {
    vertex = c.SDL_GPU_SHADERSTAGE_VERTEX,
    fragment = c.SDL_GPU_SHADERSTAGE_FRAGMENT,
};

pub const DepthStencilState = extern struct {
    compare_op: CompareOp,
    back_stencil_state: StencilOpState,
    front_stencil_state: StencilOpState,
    compare_mask: u8,
    write_mask: u8,
    enable_depth_test: bool,
    enable_depth_write: bool,
    enable_stencil_test: bool,

    pub fn toNative(self: *const DepthStencilState) c.SDL_GPUDepthStencilState {
        return .{
            .compare_op = @intFromEnum(self.compare_op),
            .back_stencil_state = self.back_stencil_state.toNative(),
            .front_stencil_state = self.front_stencil_state.toNative(),
            .compare_mask = self.compare_mask,
            .write_mask = self.write_mask,
            .enable_depth_test = self.enable_depth_test,
            .enable_depth_write = self.enable_depth_write,
            .enable_stencil_test = self.enable_stencil_test,
        };
    }
};

pub const ColorTargetBlendState = extern struct {
    src_color_blendfactor: BlendFactor,
    dst_color_blendfactor: BlendFactor,
    color_blend_op: BlendOp,
    src_alpha_blendfactor: BlendFactor,
    dst_alpha_blendfactor: BlendFactor,
    alpha_blend_op: BlendOp,
    color_write_mask: ColorComponentFlags,
    enable_blend: bool,
    enable_color_write_mask: bool,

    pub fn toNative(self: *const ColorTargetBlendState) c.SDL_GPUColorTargetBlendState {
        return .{
            .src_color_blendfactor = @intFromEnum(self.src_color_blendfactor),
            .dst_color_blendfactor = @intFromEnum(self.dst_color_blendfactor),
            .color_blend_op = @intFromEnum(self.color_blend_op),
            .src_alpha_blendfactor = @intFromEnum(self.src_alpha_blendfactor),
            .dst_alpha_blendfactor = @intFromEnum(self.dst_alpha_blendfactor),
            .alpha_blend_op = @intFromEnum(self.alpha_blend_op),
            .color_write_mask = self.color_write_mask.toInt(),
            .enable_blend = self.enable_blend,
            .enable_color_write_mask = self.enable_color_write_mask,
        };
    }
};

pub const ColorTargetDescription = extern struct {
    format: TextureFormat,
    blend_state: ColorTargetBlendState,

    pub fn toNative(self: *const ColorTargetDescription) c.SDL_GPUColorTargetDescription {
        return .{
            .format = @intFromEnum(self.format),
            .blend_state = self.blend_state.toNative(),
        };
    }
};

pub const MultisampleState = extern struct {
    sample_count: SampleCount,
    sample_mask: u32,
    enable_mask: bool,

    pub fn toNative(self: *const MultisampleState) c.SDL_GPUMultisampleState {
        return .{
            .sample_count = @intFromEnum(self.sample_count),
            .sample_mask = self.sample_mask,
            .enable_mask = self.enable_mask,
        };
    }
};

pub const RasterizerState = extern struct {
    fill_mode: FillMode,
    cull_mode: CullMode,
    front_face: FrontFace,
    depth_bias_constant_factor: f32,
    depth_bias_clamp: f32,
    depth_bias_slope_factor: f32,
    enable_depth_bias: bool,
    enable_depth_clip: bool,

    pub fn toNative(self: *const RasterizerState) c.SDL_GPURasterizerState {
        return .{
            .fill_mode = @intFromEnum(self.fill_mode),
            .cull_mode = @intFromEnum(self.cull_mode),
            .front_face = @intFromEnum(self.front_face),
            .depth_bias_constant_factor = self.depth_bias_constant_factor,
            .depth_bias_clamp = self.depth_bias_clamp,
            .depth_bias_slope_factor = self.depth_bias_slope_factor,
            .enable_depth_bias = self.enable_depth_bias,
            .enable_depth_clip = self.enable_depth_clip,
        };
    }
};

pub const GraphicsPipelineTargetInfo = struct {
    color_target_descriptions: []const ColorTargetDescription,
    depth_stencil_format: TextureFormat,
    has_depth_stencil_target: bool,

    pub fn toNative(self: *const GraphicsPipelineTargetInfo) c.SDL_GPUGraphicsPipelineTargetInfo {
        return .{
            .color_target_descriptions = @ptrCast(self.color_target_descriptions),
            .num_color_targets = @intCast(self.color_target_descriptions.len),
            .depth_stencil_format = @intFromEnum(self.depth_stencil_format),
            .has_depth_stencil_target = self.has_depth_stencil_target,
        };
    }
};

pub const BlendOp = enum(u32) {
    invalid = c.SDL_GPU_BLENDOP_INVALID,
    add = c.SDL_GPU_BLENDOP_ADD,
    subtract = c.SDL_GPU_BLENDOP_SUBTRACT,
    reverse_subtract = c.SDL_GPU_BLENDOP_REVERSE_SUBTRACT,
    min = c.SDL_GPU_BLENDOP_MIN,
    max = c.SDL_GPU_BLENDOP_MAX,
};

pub const BlendFactor = enum(u32) {
    invalid = c.SDL_GPU_BLENDFACTOR_INVALID,
    zero = c.SDL_GPU_BLENDFACTOR_ZERO,
    one = c.SDL_GPU_BLENDFACTOR_ONE,
    src_color = c.SDL_GPU_BLENDFACTOR_SRC_COLOR,
    one_minus_src_color = c.SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_COLOR,
    dst_color = c.SDL_GPU_BLENDFACTOR_DST_COLOR,
    one_minus_dst_color = c.SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_COLOR,
    src_alpha = c.SDL_GPU_BLENDFACTOR_SRC_ALPHA,
    one_minus_src_alpha = c.SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
    dst_alpha = c.SDL_GPU_BLENDFACTOR_DST_ALPHA,
    one_minus_dst_alpha = c.SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_ALPHA,
    constant_color = c.SDL_GPU_BLENDFACTOR_CONSTANT_COLOR,
    one_minus_constant_color = c.SDL_GPU_BLENDFACTOR_ONE_MINUS_CONSTANT_COLOR,
    src_alpha_saturate = c.SDL_GPU_BLENDFACTOR_SRC_ALPHA_SATURATE,
};

pub const VertexElementFormat = enum(u32) {
    invalid = c.SDL_GPU_VERTEXELEMENTFORMAT_INVALID,
    int = c.SDL_GPU_VERTEXELEMENTFORMAT_INT,
    int2 = c.SDL_GPU_VERTEXELEMENTFORMAT_INT2,
    int3 = c.SDL_GPU_VERTEXELEMENTFORMAT_INT3,
    int4 = c.SDL_GPU_VERTEXELEMENTFORMAT_INT4,
    uint = c.SDL_GPU_VERTEXELEMENTFORMAT_UINT,
    uint2 = c.SDL_GPU_VERTEXELEMENTFORMAT_UINT2,
    uint3 = c.SDL_GPU_VERTEXELEMENTFORMAT_UINT3,
    uint4 = c.SDL_GPU_VERTEXELEMENTFORMAT_UINT4,
    float = c.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT,
    float2 = c.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2,
    float3 = c.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3,
    float4 = c.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4,
    byte2 = c.SDL_GPU_VERTEXELEMENTFORMAT_BYTE2,
    byte4 = c.SDL_GPU_VERTEXELEMENTFORMAT_BYTE4,
    ubyte2 = c.SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2,
    ubyte4 = c.SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4,
    byte2_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_BYTE2_NORM,
    byte4_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_BYTE4_NORM,
    ubyte2_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2_NORM,
    ubyte4_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4_NORM,
    short2 = c.SDL_GPU_VERTEXELEMENTFORMAT_SHORT2,
    short4 = c.SDL_GPU_VERTEXELEMENTFORMAT_SHORT4,
    ushort2 = c.SDL_GPU_VERTEXELEMENTFORMAT_USHORT2,
    ushort4 = c.SDL_GPU_VERTEXELEMENTFORMAT_USHORT4,
    short2_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_SHORT2_NORM,
    short4_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_SHORT4_NORM,
    ushort2_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_USHORT2_NORM,
    ushort4_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_USHORT4_NORM,
    half2 = c.SDL_GPU_VERTEXELEMENTFORMAT_HALF2,
    half4 = c.SDL_GPU_VERTEXELEMENTFORMAT_HALF4,
};

pub const ColorComponentFlags = extern struct {
    r: bool = false,
    g: bool = false,
    b: bool = false,
    a: bool = false,

    pub fn toInt(self: ColorComponentFlags) c.SDL_GPUColorComponentFlags {
        return (if (self.r) c.SDL_GPU_COLORCOMPONENT_R else 0) |
            (if (self.g) c.SDL_GPU_COLORCOMPONENT_G else 0) |
            (if (self.b) c.SDL_GPU_COLORCOMPONENT_B else 0) |
            (if (self.a) c.SDL_GPU_COLORCOMPONENT_A else 0);
    }

    pub fn fromInt(flags: c.SDL_GPUColorComponentFlags) ColorComponentFlags {
        return .{
            .r = (flags & c.SDL_GPU_COLORCOMPONENT_R) != 0,
            .g = (flags & c.SDL_GPU_COLORCOMPONENT_G) != 0,
            .b = (flags & c.SDL_GPU_COLORCOMPONENT_B) != 0,
            .a = (flags & c.SDL_GPU_COLORCOMPONENT_A) != 0,
        };
    }
};

pub const BufferUsageFlags = extern struct {
    vertex: bool = false,
    index: bool = false,
    indirect: bool = false,
    storage_graphics_read: bool = false,
    storage_compute_read: bool = false,
    storage_compute_write: bool = false,

    pub fn toInt(self: BufferUsageFlags) c.SDL_GPUBufferUsageFlags {
        return (if (self.vertex) c.SDL_GPU_BUFFERUSAGE_VERTEX else 0) |
            (if (self.index) c.SDL_GPU_BUFFERUSAGE_INDEX else 0) |
            (if (self.indirect) c.SDL_GPU_BUFFERUSAGE_INDIRECT else 0) |
            (if (self.storage_graphics_read) c.SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ else 0) |
            (if (self.storage_compute_read) c.SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ else 0) |
            (if (self.storage_compute_write) c.SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE else 0);
    }

    pub fn fromInt(flags: c.SDL_GPUBufferUsageFlags) BufferUsageFlags {
        return .{
            .vertex = (flags & c.SDL_GPU_BUFFERUSAGE_VERTEX) != 0,
            .index = (flags & c.SDL_GPU_BUFFERUSAGE_INDEX) != 0,
            .indirect = (flags & c.SDL_GPU_BUFFERUSAGE_INDIRECT) != 0,
            .storage_graphics_read = (flags & c.SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ) != 0,
            .storage_compute_read = (flags & c.SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ) != 0,
            .storage_compute_write = (flags & c.SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE) != 0,
        };
    }
};

pub const VertexBufferDescription = extern struct {
    slot: u32,
    pitch: u32,
    input_rate: VertexInputRate,
    instance_step_rate: u32,

    pub fn toNative(self: *const VertexBufferDescription) c.SDL_GPUVertexBufferDescription {
        return .{
            .slot = self.slot,
            .pitch = self.pitch,
            .input_rate = @intFromEnum(self.input_rate),
            .instance_step_rate = self.instance_step_rate,
        };
    }
};

pub const VertexAttribute = extern struct {
    location: u32,
    buffer_slot: u32,
    format: VertexElementFormat,
    offset: u32,

    pub fn toNative(self: *const VertexAttribute) c.SDL_GPUVertexAttribute {
        return .{
            .location = self.location,
            .buffer_slot = self.buffer_slot,
            .format = @intFromEnum(self.format),
            .offset = self.offset,
        };
    }
};

pub const VertexInputState = struct {
    vertex_buffer_descriptions: []const VertexBufferDescription,
    vertex_attributes: []const VertexAttribute,

    pub fn toNative(self: *const VertexInputState) c.SDL_GPUVertexInputState {
        return .{
            .vertex_buffer_descriptions = @ptrCast(self.vertex_buffer_descriptions),
            .num_vertex_buffers = @intCast(self.vertex_buffer_descriptions.len),
            .vertex_attributes = @ptrCast(self.vertex_attributes),
            .num_vertex_attributes = @intCast(self.vertex_attributes.len),
        };
    }
};

pub const ComputePipelineCreateInfo = struct {
    code: [*:0]const u8,
    entrypoint: [*:0]const u8,
    format: u32,
    num_samplers: u32,
    num_readonly_storage_textures: u32,
    num_readonly_storage_buffers: u32,
    num_readwrite_storage_textures: u32,
    num_readwrite_storage_buffers: u32,
    num_uniform_buffers: u32,
    threadcount_x: u32,
    threadcount_y: u32,
    threadcount_z: u32,
    props: c.SDL_PropertiesID,

    pub fn toNative(self: *const ComputePipelineCreateInfo) c.SDL_GPUComputePipelineCreateInfo {
        return .{
            .code_size = @intCast(self.code.len),
            .code = self.code.ptr,
            .entrypoint = self.entrypoint,
            .format = self.format.toInt(),
            .num_samplers = self.num_samplers,
            .num_readonly_storage_textures = self.num_readonly_storage_textures,
            .num_readonly_storage_buffers = self.num_readonly_storage_buffers,
            .num_readwrite_storage_textures = self.num_readwrite_storage_textures,
            .num_readwrite_storage_buffers = self.num_readwrite_storage_buffers,
            .num_uniform_buffers = self.num_uniform_buffers,
            .threadcount_x = self.threadcount_x,
            .threadcount_y = self.threadcount_y,
            .threadcount_z = self.threadcount_z,
            .props = self.props,
        };
    }
};

pub const GraphicsPipelineCreateInfo = struct {
    vertex_shader: *Shader,
    fragment_shader: *Shader,
    vertex_input_state: VertexInputState,
    primitive_type: PrimitiveType,
    rasterizer_state: RasterizerState,
    multisample_state: MultisampleState,
    depth_stencil_state: DepthStencilState,
    target_info: GraphicsPipelineTargetInfo,
    props: c.SDL_PropertiesID = 0,

    pub fn toNative(self: *const GraphicsPipelineCreateInfo) c.SDL_GPUGraphicsPipelineCreateInfo {
        return .{
            .vertex_shader = self.vertex_shader,
            .fragment_shader = self.fragment_shader,
            .vertex_input_state = self.vertex_input_state.toNative(),
            .primitive_type = @intFromEnum(self.primitive_type),
            .rasterizer_state = self.rasterizer_state.toNative(),
            .multisample_state = self.multisample_state.toNative(),
            .depth_stencil_state = self.depth_stencil_state.toNative(),
            .target_info = self.target_info.toNative(),
            .props = 0,
        };
    }
};

pub const Filter = enum(u32) {
    nearest = c.SDL_GPU_FILTER_NEAREST,
    linear = c.SDL_GPU_FILTER_LINEAR,
};

pub const SamplerMipmapMode = enum(u32) {
    nearest = c.SDL_GPU_SAMPLERMIPMAPMODE_NEAREST,
    linear = c.SDL_GPU_SAMPLERMIPMAPMODE_LINEAR,
};

pub const SamplerAddressMode = enum(u32) {
    repeat = c.SDL_GPU_SAMPLERADDRESSMODE_REPEAT,
    mirrored_repeat = c.SDL_GPU_SAMPLERADDRESSMODE_MIRRORED_REPEAT,
    clamp_to_edge = c.SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE,
};

pub const SamplerCreateInfo = extern struct {
    min_filter: Filter,
    mag_filter: Filter,
    mipmap_mode: SamplerMipmapMode,
    address_mode_u: SamplerAddressMode,
    address_mode_v: SamplerAddressMode,
    address_mode_w: SamplerAddressMode,
    mip_lod_bias: f32,
    max_anisotropy: f32,
    compare_op: CompareOp,
    min_lod: f32,
    max_lod: f32,
    enable_anisotropy: bool,
    enable_compare: bool,
};

pub const ShaderCreateInfo = struct {
    code: [*:0]const u8,
    entry_point: [*:0]const u8,
    format: std.meta.FieldEnum(ShaderFormat),
    stage: ShaderStage,
    num_samplers: u32,
    num_storage_textures: u32,
    num_storage_buffers: u32,
    num_uniform_buffers: u32,

    pub fn toNative(self: *const ShaderCreateInfo) c.SDL_GPUShaderCreateInfo {
        return .{
            .code = self.code,
            .code_len = self.code.len,
            .entry_point = self.entry_point,
            .format = self.format.toInt(),
            .stage = self.stage,
            .num_samplers = self.num_samplers,
            .num_storage_textures = self.num_storage_textures,
            .num_storage_buffers = self.num_storage_buffers,
            .num_uniform_buffers = self.num_uniform_buffers,
        };
    }
};

pub const TextureCreateInfo = extern struct {
    type: TextureType,
    format: TextureFormat,
    usage: TextureUsageFlags,
    width: u32,
    height: u32,
    layer_count_or_depth: u32,
    num_levels: u32,
    sample_count: SampleCount,
    props: c.SDL_PropertiesID,
};

pub const MemoryFlags = packed struct {
    host_visible: bool = false,
    device_local: bool = false,

    pub fn toInt(self: MemoryFlags) u32 {
        return (if (self.host_visible) c.SDL_GPU_MEMORYFLAGS_HOST_VISIBLE else 0) |
            (if (self.device_local) c.SDL_GPU_MEMORYFLAGS_DEVICE_LOCAL else 0);
    }

    pub fn fromInt(flags: u32) MemoryFlags {
        return .{
            .host_visible = (flags & c.SDL_GPU_MEMORYFLAGS_HOST_VISIBLE) != 0,
            .device_local = (flags & c.SDL_GPU_MEMORYFLAGS_DEVICE_LOCAL) != 0,
        };
    }
};

pub const BufferCreateInfo = extern struct {
    size: u32,
    usage: BufferUsageFlags,

    pub fn toNative(self: *const BufferCreateInfo) c.SDL_GPUBufferCreateInfo {
        return .{
            .size = self.size,
            .usage = self.usage.toInt(),
        };
    }
};

pub const TransferBufferCreateInfo = extern struct {
    size: u32,
    usage: TransferBufferUsage,

    pub fn toNative(self: *const TransferBufferCreateInfo) c.SDL_GPUTransferBufferCreateInfo {
        return .{
            .size = self.size,
            .usage = @intFromEnum(self.usage),
            .props = 0,
        };
    }
};

pub const DeviceProperties = struct {
    debug_mode: ?bool = null,
    prefer_low_power: ?bool = null,
    name: ?[*:0]const u8 = null,
    shaders_private: ?bool = null,
    shaders_spirv: ?bool = null,
    shaders_dxbc: ?bool = null,
    shaders_dxil: ?bool = null,
    shaders_msl: ?bool = null,
    shaders_metallib: ?bool = null,
    d3d12_semantic_name: ?[*:0]const u8 = null,

    fn apply(self: DeviceProperties, props: c.SDL_PropertiesID) void {
        if (self.debug_mode) |dm| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_DEBUGMODE_BOOLEAN, dm);
        if (self.prefer_low_power) |plp| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_PREFERLOWPOWER_BOOLEAN, plp);
        if (self.name) |n| _ = c.SDL_SetStringProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING, n);
        if (self.shaders_private) |sp| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_SHADERS_PRIVATE_BOOLEAN, sp);
        if (self.shaders_spirv) |ss| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOLEAN, ss);
        if (self.shaders_dxbc) |sd| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXBC_BOOLEAN, sd);
        if (self.shaders_dxil) |sdx| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOLEAN, sdx);
        if (self.shaders_msl) |sm| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOLEAN, sm);
        if (self.shaders_metallib) |sml| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_SHADERS_METALLIB_BOOLEAN, sml);
        if (self.d3d12_semantic_name) |dsn| _ = c.SDL_SetStringProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING, dsn);
    }
};

pub const ShaderFormat = extern struct {
    private: bool = false,
    spirv: bool = false,
    dxbc: bool = false,
    dxil: bool = false,
    msl: bool = false,
    metallib: bool = false,

    pub fn toInt(self: *const ShaderFormat) c.SDL_GPUShaderFormat {
        return (if (self.private) c.SDL_GPU_SHADERFORMAT_PRIVATE else 0) |
            (if (self.spirv) c.SDL_GPU_SHADERFORMAT_SPIRV else 0) |
            (if (self.dxbc) c.SDL_GPU_SHADERFORMAT_DXBC else 0) |
            (if (self.dxil) c.SDL_GPU_SHADERFORMAT_DXIL else 0) |
            (if (self.msl) c.SDL_GPU_SHADERFORMAT_MSL else 0) |
            (if (self.metallib) c.SDL_GPU_SHADERFORMAT_METALLIB else 0);
    }

    pub fn fromInt(flags: c.SDL_GPUShaderFormat) ShaderFormat {
        return .{
            .private = flags & c.SDL_GPU_SHADERFORMAT_PRIVATE != 0,
            .spirv = flags & c.SDL_GPU_SHADERFORMAT_SPIRV != 0,
            .dxbc = flags & c.SDL_GPU_SHADERFORMAT_DXBC != 0,
            .dxil = flags & c.SDL_GPU_SHADERFORMAT_DXIL != 0,
            .msl = flags & c.SDL_GPU_SHADERFORMAT_MSL != 0,
            .metallib = flags & c.SDL_GPU_SHADERFORMAT_METALLIB != 0,
        };
    }
};

pub const TextureFormat = enum(u32) {
    invalid = c.SDL_GPU_TEXTUREFORMAT_INVALID,
    a8_unorm = c.SDL_GPU_TEXTUREFORMAT_A8_UNORM,
    r8_unorm = c.SDL_GPU_TEXTUREFORMAT_R8_UNORM,
    r8g8_unorm = c.SDL_GPU_TEXTUREFORMAT_R8G8_UNORM,
    r8g8b8a8_unorm = c.SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM,
    r16_unorm = c.SDL_GPU_TEXTUREFORMAT_R16_UNORM,
    r16g16_unorm = c.SDL_GPU_TEXTUREFORMAT_R16G16_UNORM,
    r16g16b16a16_unorm = c.SDL_GPU_TEXTUREFORMAT_R16G16B16A16_UNORM,
    r10g10b10a2_unorm = c.SDL_GPU_TEXTUREFORMAT_R10G10B10A2_UNORM,
    b5g6r5_unorm = c.SDL_GPU_TEXTUREFORMAT_B5G6R5_UNORM,
    b5g5r5a1_unorm = c.SDL_GPU_TEXTUREFORMAT_B5G5R5A1_UNORM,
    b4g4r4a4_unorm = c.SDL_GPU_TEXTUREFORMAT_B4G4R4A4_UNORM,
    b8g8r8a8_unorm = c.SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM,
    bc1_rgba_unorm = c.SDL_GPU_TEXTUREFORMAT_BC1_RGBA_UNORM,
    bc2_rgba_unorm = c.SDL_GPU_TEXTUREFORMAT_BC2_RGBA_UNORM,
    bc3_rgba_unorm = c.SDL_GPU_TEXTUREFORMAT_BC3_RGBA_UNORM,
    bc4_r_unorm = c.SDL_GPU_TEXTUREFORMAT_BC4_R_UNORM,
    bc5_rg_unorm = c.SDL_GPU_TEXTUREFORMAT_BC5_RG_UNORM,
    bc7_rgba_unorm = c.SDL_GPU_TEXTUREFORMAT_BC7_RGBA_UNORM,
    bc6h_rgb_float = c.SDL_GPU_TEXTUREFORMAT_BC6H_RGB_FLOAT,
    bc6h_rgb_ufloat = c.SDL_GPU_TEXTUREFORMAT_BC6H_RGB_UFLOAT,
    r8_snorm = c.SDL_GPU_TEXTUREFORMAT_R8_SNORM,
    r8g8_snorm = c.SDL_GPU_TEXTUREFORMAT_R8G8_SNORM,
    r8g8b8a8_snorm = c.SDL_GPU_TEXTUREFORMAT_R8G8B8A8_SNORM,
    r16_snorm = c.SDL_GPU_TEXTUREFORMAT_R16_SNORM,
    r16g16_snorm = c.SDL_GPU_TEXTUREFORMAT_R16G16_SNORM,
    r16g16b16a16_snorm = c.SDL_GPU_TEXTUREFORMAT_R16G16B16A16_SNORM,
    r16_float = c.SDL_GPU_TEXTUREFORMAT_R16_FLOAT,
    r16g16_float = c.SDL_GPU_TEXTUREFORMAT_R16G16_FLOAT,
    r16g16b16a16_float = c.SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT,
    r32_float = c.SDL_GPU_TEXTUREFORMAT_R32_FLOAT,
    r32g32_float = c.SDL_GPU_TEXTUREFORMAT_R32G32_FLOAT,
    r32g32b32a32_float = c.SDL_GPU_TEXTUREFORMAT_R32G32B32A32_FLOAT,
    r11g11b10_ufloat = c.SDL_GPU_TEXTUREFORMAT_R11G11B10_UFLOAT,
    r8_uint = c.SDL_GPU_TEXTUREFORMAT_R8_UINT,
    r8g8_uint = c.SDL_GPU_TEXTUREFORMAT_R8G8_UINT,
    r8g8b8a8_uint = c.SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UINT,
    r16_uint = c.SDL_GPU_TEXTUREFORMAT_R16_UINT,
    r16g16_uint = c.SDL_GPU_TEXTUREFORMAT_R16G16_UINT,
    r16g16b16a16_uint = c.SDL_GPU_TEXTUREFORMAT_R16G16B16A16_UINT,
    r32_uint = c.SDL_GPU_TEXTUREFORMAT_R32_UINT,
    r32g32_uint = c.SDL_GPU_TEXTUREFORMAT_R32G32_UINT,
    r32g32b32a32_uint = c.SDL_GPU_TEXTUREFORMAT_R32G32B32A32_UINT,
    r8_int = c.SDL_GPU_TEXTUREFORMAT_R8_INT,
    r8g8_int = c.SDL_GPU_TEXTUREFORMAT_R8G8_INT,
    r8g8b8a8_int = c.SDL_GPU_TEXTUREFORMAT_R8G8B8A8_INT,
    r16_int = c.SDL_GPU_TEXTUREFORMAT_R16_INT,
    r16g16_int = c.SDL_GPU_TEXTUREFORMAT_R16G16_INT,
    r16g16b16a16_int = c.SDL_GPU_TEXTUREFORMAT_R16G16B16A16_INT,
    r32_int = c.SDL_GPU_TEXTUREFORMAT_R32_INT,
    r32g32_int = c.SDL_GPU_TEXTUREFORMAT_R32G32_INT,
    r32g32b32a32_int = c.SDL_GPU_TEXTUREFORMAT_R32G32B32A32_INT,
    r8g8b8a8_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM_SRGB,
    b8g8r8a8_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM_SRGB,
    bc1_rgba_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_BC1_RGBA_UNORM_SRGB,
    bc2_rgba_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_BC2_RGBA_UNORM_SRGB,
    bc3_rgba_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_BC3_RGBA_UNORM_SRGB,
    bc7_rgba_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_BC7_RGBA_UNORM_SRGB,
    d16_unorm = c.SDL_GPU_TEXTUREFORMAT_D16_UNORM,
    d24_unorm = c.SDL_GPU_TEXTUREFORMAT_D24_UNORM,
    d32_float = c.SDL_GPU_TEXTUREFORMAT_D32_FLOAT,
    d24_unorm_s8_uint = c.SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT,
    d32_float_s8_uint = c.SDL_GPU_TEXTUREFORMAT_D32_FLOAT_S8_UINT,
    astc_4x4_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_4x4_UNORM,
    astc_5x4_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_5x4_UNORM,
    astc_5x5_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_5x5_UNORM,
    astc_6x5_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_6x5_UNORM,
    astc_6x6_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_6x6_UNORM,
    astc_8x5_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x5_UNORM,
    astc_8x6_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x6_UNORM,
    astc_8x8_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x8_UNORM,
    astc_10x5_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x5_UNORM,
    astc_10x6_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x6_UNORM,
    astc_10x8_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x8_UNORM,
    astc_10x10_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x10_UNORM,
    astc_12x10_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_12x10_UNORM,
    astc_12x12_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_12x12_UNORM,
    astc_4x4_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_4x4_UNORM_SRGB,
    astc_5x4_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_5x4_UNORM_SRGB,
    astc_5x5_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_5x5_UNORM_SRGB,
    astc_6x5_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_6x5_UNORM_SRGB,
    astc_6x6_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_6x6_UNORM_SRGB,
    astc_8x5_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x5_UNORM_SRGB,
    astc_8x6_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x6_UNORM_SRGB,
    astc_8x8_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x8_UNORM_SRGB,
    astc_10x5_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x5_UNORM_SRGB,
    astc_10x6_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x6_UNORM_SRGB,
    astc_10x8_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x8_UNORM_SRGB,
    astc_10x10_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x10_UNORM_SRGB,
    astc_12x10_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_12x10_UNORM_SRGB,
    astc_12x12_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_12x12_UNORM_SRGB,
    astc_4x4_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_4x4_FLOAT,
    astc_5x4_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_5x4_FLOAT,
    astc_5x5_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_5x5_FLOAT,
    astc_6x5_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_6x5_FLOAT,
    astc_6x6_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_6x6_FLOAT,
    astc_8x5_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x5_FLOAT,
    astc_8x6_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x6_FLOAT,
    astc_8x8_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x8_FLOAT,
    astc_10x5_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x5_FLOAT,
    astc_10x6_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x6_FLOAT,
    astc_10x8_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x8_FLOAT,
    astc_10x10_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x10_FLOAT,
    astc_12x10_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_12x10_FLOAT,
    astc_12x12_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_12x12_FLOAT,
};

pub const TextureType = enum(u32) {
    @"2d" = c.SDL_GPU_TEXTURETYPE_2D,
    @"2d_array" = c.SDL_GPU_TEXTURETYPE_2D_ARRAY,
    @"3d" = c.SDL_GPU_TEXTURETYPE_3D,
    cube = c.SDL_GPU_TEXTURETYPE_CUBE,
    cube_array = c.SDL_GPU_TEXTURETYPE_CUBE_ARRAY,
};

pub const TextureUsageFlags = extern struct {
    sampler: bool = false,
    color_target: bool = false,
    depth_stencil_target: bool = false,
    graphics_storage_read: bool = false,
    compute_storage_read: bool = false,
    compute_storage_write: bool = false,
    compute_storage_simultaneous_read_write: bool = false,

    pub fn toInt(self: TextureUsageFlags) u32 {
        return (if (self.sampler) c.SDL_GPU_TEXTUREUSAGE_SAMPLER else 0) |
            (if (self.color_target) c.SDL_GPU_TEXTUREUSAGE_COLOR_TARGET else 0) |
            (if (self.depth_stencil_target) c.SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET else 0) |
            (if (self.graphics_storage_read) c.SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ else 0) |
            (if (self.compute_storage_read) c.SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ else 0) |
            (if (self.compute_storage_write) c.SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE else 0) |
            (if (self.compute_storage_simultaneous_read_write) c.SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE else 0);
    }

    pub fn fromInt(flags: u32) TextureUsageFlags {
        return .{
            .sampler = flags & c.SDL_GPU_TEXTUREUSAGE_SAMPLER,
            .color_target = flags & c.SDL_GPU_TEXTUREUSAGE_COLOR_TARGET,
            .depth_stencil_target = flags & c.SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET,
            .graphics_storage_read = flags & c.SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ,
            .compute_storage_read = flags & c.SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ,
            .compute_storage_write = flags & c.SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE,
            .compute_storage_simultaneous_read_write = flags & c.SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE,
        };
    }
};

pub const SampleCount = enum(u32) {
    @"1" = c.SDL_GPU_SAMPLECOUNT_1,
    @"2" = c.SDL_GPU_SAMPLECOUNT_2,
    @"4" = c.SDL_GPU_SAMPLECOUNT_4,
    @"8" = c.SDL_GPU_SAMPLECOUNT_8,
};

pub const SwapchainComposition = enum(u32) {
    automatic = c.SDL_GPU_SWAPCHAIN_AUTOMATIC,
    copy = c.SDL_GPU_SWAPCHAIN_COPY,
    flip = c.SDL_GPU_SWAPCHAIN_FLIP,
};

pub const PresentMode = enum(u32) {
    immediate = c.SDL_GPU_PRESENTMODE_IMMEDIATE,
    vsync = c.SDL_GPU_PRESENTMODE_VSYNC,
    mailbox = c.SDL_GPU_PRESENTMODE_MAILBOX,
};

pub const PrimitiveType = enum(u32) {
    triangle_list = c.SDL_GPU_PRIMITIVETYPE_TRIANGLELIST,
    triangle_strip = c.SDL_GPU_PRIMITIVETYPE_TRIANGLESTRIP,
    line_list = c.SDL_GPU_PRIMITIVETYPE_LINELIST,
    line_strip = c.SDL_GPU_PRIMITIVETYPE_LINESTRIP,
    point_list = c.SDL_GPU_PRIMITIVETYPE_POINTLIST,
};

pub const LoadOp = enum(u32) {
    load = c.SDL_GPU_LOADOP_LOAD,
    clear = c.SDL_GPU_LOADOP_CLEAR,
    dont_care = c.SDL_GPU_LOADOP_DONT_CARE,
};

pub const StoreOp = enum(u32) {
    store = c.SDL_GPU_STOREOP_STORE,
    dont_care = c.SDL_GPU_STOREOP_DONT_CARE,
    resolve = c.SDL_GPU_STOREOP_RESOLVE,
    resolve_and_store = c.SDL_GPU_STOREOP_RESOLVE_AND_STORE,
};

pub const IndexElementSize = enum(u32) {
    @"16bit" = c.SDL_GPU_INDEXELEMENTSIZE_16BIT,
    @"32bit" = c.SDL_GPU_INDEXELEMENTSIZE_32BIT,
};

pub const VertexInputRate = enum(u32) {
    vertex = c.SDL_GPU_VERTEXINPUTRATE_VERTEX,
    instance = c.SDL_GPU_VERTEXINPUTRATE_INSTANCE,
};

pub const FillMode = enum(u32) {
    fill = c.SDL_GPU_FILLMODE_FILL,
    line = c.SDL_GPU_FILLMODE_LINE,
};

pub const CullMode = enum(u32) {
    none = c.SDL_GPU_CULLMODE_NONE,
    front = c.SDL_GPU_CULLMODE_FRONT,
    back = c.SDL_GPU_CULLMODE_BACK,
};

pub const FrontFace = enum(u32) {
    counter_clockwise = c.SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE,
    clockwise = c.SDL_GPU_FRONTFACE_CLOCKWISE,
};

pub const CompareOp = enum(u32) {
    invalid = c.SDL_GPU_COMPAREOP_INVALID,
    never = c.SDL_GPU_COMPAREOP_NEVER,
    less = c.SDL_GPU_COMPAREOP_LESS,
    equal = c.SDL_GPU_COMPAREOP_EQUAL,
    less_or_equal = c.SDL_GPU_COMPAREOP_LESS_OR_EQUAL,
    greater = c.SDL_GPU_COMPAREOP_GREATER,
    not_equal = c.SDL_GPU_COMPAREOP_NOT_EQUAL,
    greater_or_equal = c.SDL_GPU_COMPAREOP_GREATER_OR_EQUAL,
    always = c.SDL_GPU_COMPAREOP_ALWAYS,
};

pub const StencilOp = enum(u32) {
    invalid = c.SDL_GPU_STENCILOP_INVALID,
    keep = c.SDL_GPU_STENCILOP_KEEP,
    zero = c.SDL_GPU_STENCILOP_ZERO,
    replace = c.SDL_GPU_STENCILOP_REPLACE,
    increment_and_clamp = c.SDL_GPU_STENCILOP_INCREMENT_AND_CLAMP,
    decrement_and_clamp = c.SDL_GPU_STENCILOP_DECREMENT_AND_CLAMP,
    invert = c.SDL_GPU_STENCILOP_INVERT,
    increment_and_wrap = c.SDL_GPU_STENCILOP_INCREMENT_AND_WRAP,
    decrement_and_wrap = c.SDL_GPU_STENCILOP_DECREMENT_AND_WRAP,
};

pub const Device = struct {
    ptr: *c.SDL_GPUDevice,

    /// Check for GPU runtime support with specified format flags and name
    pub fn supportsShaderFormats(flags: ShaderFormat, name: [*:0]const u8) bool {
        return c.SDL_GPUSupportsShaderFormats(flags, name);
    }

    /// Check for GPU runtime support with properties
    pub fn supportsProperties(props: c.SDL_PropertiesID) bool {
        return c.SDL_GPUSupportsProperties(props);
    }

    /// Create a GPU device with format flags and debug mode
    pub fn create(flags: ShaderFormat, debug_mode: bool, name: ?[*:0]const u8) !Device {
        return Device{
            .ptr = try errify(c.SDL_CreateGPUDevice(flags.toInt(), debug_mode, name)),
        };
    }

    /// Create a GPU device with properties
    pub fn createWithProperties(props: DeviceProperties) !Device {
        const properties = c.SDL_CreateProperties();
        defer c.SDL_DestroyProperties(properties);
        props.apply(properties);
        const device = try errify(c.SDL_CreateGPUDeviceWithProperties(properties));
        return Device{
            .ptr = device,
        };
    }

    /// Destroy the GPU device
    pub fn destroy(self: *const Device) void {
        c.SDL_DestroyGPUDevice(self.ptr);
    }

    /// Get the number of GPU drivers compiled into SDL
    pub fn getNumDrivers() i32 {
        return c.SDL_GetNumGPUDrivers();
    }

    /// Get the name of a built-in GPU driver
    pub fn getDriver(index: i32) ![]const u8 {
        return std.mem.span(try errify(c.SDL_GetGPUDriver(index)));
    }

    /// Get the name of the backend used to create this GPU device
    pub fn getDeviceDriver(self: *const Device) ![]const u8 {
        return std.mem.span(try errify(c.SDL_GetGPUDeviceDriver(self.ptr)));
    }

    /// Get supported shader formats for this GPU device
    pub fn getShaderFormats(self: *const Device) ShaderFormat {
        return ShaderFormat.fromInt(c.SDL_GetGPUShaderFormats(self.ptr));
    }

    /// Create a compute pipeline object to be used in a compute workflow
    pub fn createComputePipeline(self: *const Device, createinfo: ComputePipelineCreateInfo) !*ComputePipeline {
        return try errify(c.SDL_CreateGPUComputePipeline(self.ptr, createinfo));
    }

    /// Create a graphics pipeline object to be used in a graphics workflow
    pub fn createGraphicsPipeline(self: *const Device, createinfo: GraphicsPipelineCreateInfo) !*GraphicsPipeline {
        return try errify(c.SDL_CreateGPUGraphicsPipeline(self.ptr, &createinfo.toNative()));
    }

    /// Create a sampler object to be used when binding textures in a graphics workflow
    pub fn createSampler(self: *const Device, createinfo: SamplerCreateInfo) !*Sampler {
        return try errify(c.SDL_CreateGPUSampler(self.ptr, @ptrCast(&createinfo)));
    }

    /// Create a shader to be used when creating a graphics pipeline
    pub fn createShader(self: *const Device, createinfo: ShaderCreateInfo) !*Shader {
        return try errify(c.SDL_CreateGPUShader(self.ptr, @ptrCast(&createinfo)));
    }

    /// Create a texture object to be used in graphics or compute workflows
    pub fn createTexture(self: *const Device, createinfo: TextureCreateInfo) !*Texture {
        return try errify(c.SDL_CreateGPUTexture(self.ptr, @ptrCast(&createinfo)));
    }

    /// Create a buffer object to be used in graphics or compute workflows
    pub fn createBuffer(self: *const Device, createinfo: BufferCreateInfo) !*Buffer {
        return try errify(c.SDL_CreateGPUBuffer(self.ptr, @ptrCast(&createinfo.toNative())));
    }

    /// Create a transfer buffer to be used when uploading to or downloading from graphics resources
    pub fn createTransferBuffer(self: *const Device, createinfo: TransferBufferCreateInfo) !*TransferBuffer {
        return try errify(c.SDL_CreateGPUTransferBuffer(self.ptr, @ptrCast(&createinfo.toNative())));
    }

    /// Set an arbitrary string constant to label a buffer
    pub fn setBufferName(self: *const Device, buffer: *Buffer, text: [*:0]const u8) void {
        c.SDL_SetGPUBufferName(self.ptr, buffer, text);
    }

    /// Set an arbitrary string constant to label a texture
    pub fn setTextureName(self: *const Device, texture: *Texture, text: [*:0]const u8) void {
        c.SDL_SetGPUTextureName(self.ptr, texture, text);
    }

    /// Free the given texture as soon as it is safe to do so
    pub fn releaseTexture(self: *const Device, texture: *Texture) void {
        c.SDL_ReleaseGPUTexture(self.ptr, texture);
    }

    /// Free the given sampler as soon as it is safe to do so
    pub fn releaseSampler(self: *const Device, sampler: *Sampler) void {
        c.SDL_ReleaseGPUSampler(self.ptr, sampler);
    }

    /// Free the given buffer as soon as it is safe to do so
    pub fn releaseBuffer(self: *const Device, buffer: *Buffer) void {
        c.SDL_ReleaseGPUBuffer(self.ptr, buffer);
    }

    /// Free the given transfer buffer as soon as it is safe to do so
    pub fn releaseTransferBuffer(self: *const Device, transfer_buffer: *TransferBuffer) void {
        c.SDL_ReleaseGPUTransferBuffer(self.ptr, transfer_buffer);
    }

    /// Free the given compute pipeline as soon as it is safe to do so
    pub fn releaseComputePipeline(self: *const Device, compute_pipeline: *ComputePipeline) void {
        c.SDL_ReleaseGPUComputePipeline(self.ptr, compute_pipeline);
    }

    /// Free the given shader as soon as it is safe to do so
    pub fn releaseShader(self: *const Device, shader: *Shader) void {
        c.SDL_ReleaseGPUShader(self.ptr, shader);
    }

    /// Free the given graphics pipeline as soon as it is safe to do so
    pub fn releaseGraphicsPipeline(self: *const Device, graphics_pipeline: *GraphicsPipeline) void {
        c.SDL_ReleaseGPUGraphicsPipeline(self.ptr, graphics_pipeline);
    }

    /// Acquire a command buffer
    pub fn acquireCommandBuffer(self: *const Device) !*CommandBuffer {
        return .{
            .ptr = try errify(c.SDL_AcquireGPUCommandBuffer(self.ptr)),
        };
    }

    /// Check if a window supports the specified swapchain composition
    pub fn windowSupportsSwapchainComposition(self: *const Device, window: *const Window, swapchain_composition: SwapchainComposition) bool {
        return c.SDL_WindowSupportsGPUSwapchainComposition(self.ptr, window.ptr, swapchain_composition);
    }

    /// Check if a window supports the specified present mode
    pub fn windowSupportsPresentMode(self: *const Device, window: *const Window, present_mode: PresentMode) bool {
        return c.SDL_WindowSupportsGPUPresentMode(self.ptr, window.ptr, present_mode);
    }

    /// Claim a window, creating a swapchain structure for it
    pub fn claimWindow(self: *const Device, window: Window) !void {
        try errify(c.SDL_ClaimWindowForGPUDevice(self.ptr, window.ptr));
    }

    /// Unclaim a window, destroying its swapchain structure
    pub fn releaseWindow(self: *const Device, window: Window) void {
        c.SDL_ReleaseWindowFromGPUDevice(self.ptr, window.ptr);
    }

    /// Change the swapchain parameters for the given claimed window
    pub fn setSwapchainParameters(self: *const Device, window: Window, swapchain_composition: SwapchainComposition, present_mode: PresentMode) !void {
        try errify(c.SDL_SetGPUSwapchainParameters(self.ptr, window.ptr, swapchain_composition, present_mode));
    }

    /// Configure the maximum allowed number of frames in flight
    pub fn setAllowedFramesInFlight(self: *const Device, allowed_frames_in_flight: u32) !void {
        try errify(c.SDL_SetGPUAllowedFramesInFlight(self.ptr, allowed_frames_in_flight));
    }

    /// Get the texture format of the swapchain for the given window
    pub fn getSwapchainTextureFormat(self: *const Device, window: Window) TextureFormat {
        return @enumFromInt(c.SDL_GetGPUSwapchainTextureFormat(self.ptr, window.ptr));
    }

    /// Block the thread until the GPU is completely idle
    pub fn waitForIdle(self: *const Device) !void {
        try errify(c.SDL_WaitForGPUIdle(self.ptr));
    }

    /// Block the thread until the given fences are signaled
    pub fn waitForFences(self: *const Device, wait_all: bool, fences: [*]const *Fence, num_fences: u32) !void {
        try errify(c.SDL_WaitForGPUFences(self.ptr, wait_all, fences, num_fences));
    }

    /// Check the status of a fence
    pub fn queryFence(self: *const Device, fence: *Fence) bool {
        return c.SDL_QueryGPUFence(self.ptr, fence);
    }

    /// Release a fence obtained from SDL_SubmitGPUCommandBufferAndAcquireFence
    pub fn releaseFence(self: *const Device, fence: *Fence) void {
        c.SDL_ReleaseGPUFence(self.ptr, fence);
    }

    /// Get the texel block size for a texture format
    pub fn textureFormatTexelBlockSize(format: TextureFormat) u32 {
        return c.SDL_TextureFormatTexelBlockSize(format);
    }

    /// Check if a texture format is supported for a given type and usage
    pub fn textureSupportsFormat(self: *const Device, format: TextureFormat, type_: TextureType, usage: TextureUsageFlags) bool {
        return c.SDL_TextureSupportsFormat(self.ptr, format, type_, usage);
    }

    /// Check if a sample count for a texture format is supported
    pub fn textureSupportsSampleCount(self: *const Device, format: TextureFormat, sample_count: SampleCount) bool {
        return c.SDL_TextureSupportsSampleCount(self.ptr, format, sample_count);
    }

    /// Calculate the size in bytes of a texture format with dimensions
    pub fn calculateTextureFormatSize(format: TextureFormat, width: u32, height: u32, depth_or_layer_count: u32) u32 {
        return c.SDL_CalculateGPUTextureFormatSize(format, width, height, depth_or_layer_count);
    }

    /// Suspend GPU operation on Xbox when receiving SDL_EVENT_DID_ENTER_BACKGROUND event
    pub fn gdkSuspend(self: *const Device) void {
        c.SDL_GDKSuspendGPU(self.ptr);
    }

    /// Resume GPU operation on Xbox when receiving SDL_EVENT_WILL_ENTER_FOREGROUND event
    pub fn gdkResume(self: *const Device) void {
        c.SDL_GDKResumeGPU(self.ptr);
    }

    /// Map a transfer buffer into application address space
    pub fn mapTransferBuffer(device: *const Device, transfer_buffer: *TransferBuffer, cycle: bool) !*anyopaque {
        return try errify(c.SDL_MapGPUTransferBuffer(device, transfer_buffer, cycle));
    }

    /// Unmap a previously mapped transfer buffer
    pub fn unmapTransferBuffer(device: *const Device, transfer_buffer: *TransferBuffer) void {
        c.SDL_UnmapGPUTransferBuffer(device, transfer_buffer);
    }

    /// Block the thread until a swapchain texture is available
    pub fn waitForSwapchain(device: *const Device, window: Window) !void {
        try errify(c.SDL_WaitForGPUSwapchain(device, window.ptr));
    }
};

pub const CommandBuffer = struct {
    ptr: *c.SDL_GPUCommandBuffer,

    /// Push data to a vertex uniform slot on the command buffer
    pub fn pushVertexUniformData(self: *const CommandBuffer, slot_index: u32, data: *const anyopaque, length: u32) void {
        c.SDL_PushGPUVertexUniformData(self.ptr, slot_index, data, length);
    }

    /// Push data to a fragment uniform slot on the command buffer
    pub fn pushFragmentUniformData(self: *const CommandBuffer, slot_index: u32, data: *const anyopaque, length: u32) void {
        c.SDL_PushGPUFragmentUniformData(self.ptr, slot_index, data, length);
    }

    /// Push data to a uniform slot on the command buffer
    pub fn pushComputeUniformData(self: *const CommandBuffer, slot_index: u32, data: *const anyopaque, length: u32) void {
        c.SDL_PushGPUComputeUniformData(self.ptr, slot_index, data, length);
    }

    /// Insert an arbitrary string label into the command buffer callstream
    pub fn insertDebugLabel(self: *const CommandBuffer, text: [*:0]const u8) void {
        c.SDL_InsertGPUDebugLabel(self.ptr, text);
    }

    /// Begin a debug group with an arbitrary name
    pub fn pushDebugGroup(self: *const CommandBuffer, name: [*:0]const u8) void {
        c.SDL_PushGPUDebugGroup(self.ptr, name);
    }

    /// End the most-recently pushed debug group
    pub fn popDebugGroup(self: *const CommandBuffer) void {
        c.SDL_PopGPUDebugGroup(self.ptr);
    }

    /// Submit command buffer for GPU processing
    pub fn submit(self: *const CommandBuffer) !void {
        try errify(c.SDL_SubmitGPUCommandBuffer(self.ptr));
    }

    /// Submit command buffer and acquire a fence
    pub fn submitAndAcquireFence(self: *const CommandBuffer) !*Fence {
        return try errify(c.SDL_SubmitGPUCommandBufferAndAcquireFence(self.ptr));
    }

    /// Cancel command buffer execution
    pub fn cancel(self: *const CommandBuffer) !void {
        try errify(c.SDL_CancelGPUCommandBuffer(self.ptr));
    }

    /// Begin a render pass on a command buffer
    pub fn beginRenderPass(self: *const CommandBuffer, color_target_infos: [*]const ColorTargetInfo, depth_stencil_target_info: DepthStencilTargetInfo) !*RenderPass {
        return .{
            .ptr = try errify(c.SDL_BeginGPURenderPass(self.ptr, color_target_infos, @intCast(color_target_infos.len), depth_stencil_target_info)),
        };
    }

    /// Begin a compute pass on a command buffer
    pub fn beginComputePass(self: *const CommandBuffer, storage_texture_bindings: [*]const StorageTextureReadWriteBinding, num_storage_texture_bindings: u32, storage_buffer_bindings: [*]const StorageBufferReadWriteBinding, num_storage_buffer_bindings: u32) !*ComputePass {
        return .{
            .ptr = try errify(c.SDL_BeginGPUComputePass(self.ptr, storage_texture_bindings, num_storage_texture_bindings, storage_buffer_bindings, num_storage_buffer_bindings)),
        };
    }

    /// Begin a copy pass on a command buffer
    pub fn beginCopyPass(self: *const CommandBuffer) !*CopyPass {
        return .{
            .ptr = try errify(c.SDL_BeginGPUCopyPass(self.ptr)),
        };
    }

    /// Generate mipmaps for the given texture
    pub fn generateMipmapsForTexture(self: *const CommandBuffer, texture: *Texture) void {
        c.SDL_GenerateMipmapsForGPUTexture(self.ptr, texture);
    }

    /// Blit from a source texture region to a destination texture region
    pub fn blitTexture(self: *const CommandBuffer, info: *const BlitInfo) void {
        c.SDL_BlitGPUTexture(self.ptr, info);
    }

    /// Acquire a texture to use in presentation
    pub fn acquireSwapchainTexture(self: *const CommandBuffer, window: *const Window, swapchain_texture: **Texture, swapchain_texture_width: *u32, swapchain_texture_height: *u32) !void {
        try errify(c.SDL_AcquireGPUSwapchainTexture(self.ptr, window.ptr, swapchain_texture, swapchain_texture_width, swapchain_texture_height));
    }

    /// Wait and acquire a swapchain texture
    pub fn waitAndAcquireSwapchainTexture(self: *const CommandBuffer, window: *const Window, swapchain_texture: **Texture, swapchain_texture_width: *u32, swapchain_texture_height: *u32) !void {
        try errify(c.SDL_WaitAndAcquireGPUSwapchainTexture(self.ptr, window.ptr, swapchain_texture, swapchain_texture_width, swapchain_texture_height));
    }
};

pub const RenderPass = struct {
    ptr: *c.SDL_GPURenderPass,

    /// Bind a graphics pipeline for use in rendering
    pub fn bindGraphicsPipeline(self: *const RenderPass, graphics_pipeline: *GraphicsPipeline) void {
        c.SDL_BindGPUGraphicsPipeline(self.ptr, graphics_pipeline);
    }

    /// Set the current viewport state
    pub fn setViewport(self: *const RenderPass, viewport: *const Viewport) void {
        c.SDL_SetGPUViewport(self.ptr, viewport);
    }

    /// Set the current scissor state
    pub fn setScissor(self: *const RenderPass, scissor: *const c.SDL_Rect) void {
        c.SDL_SetGPUScissor(self.ptr, scissor);
    }

    /// Set the current blend constants
    pub fn setBlendConstants(self: *const RenderPass, blend_constants: c.SDL_FColor) void {
        c.SDL_SetGPUBlendConstants(self.ptr, blend_constants);
    }

    /// Set the current stencil reference value
    pub fn setStencilReference(self: *const RenderPass, reference: u8) void {
        c.SDL_SetGPUStencilReference(self.ptr, reference);
    }

    /// Bind vertex buffers for use with subsequent draw calls
    pub fn bindVertexBuffers(self: *const RenderPass, first_slot: u32, bindings: [*]const BufferBinding, num_bindings: u32) void {
        c.SDL_BindGPUVertexBuffers(self.ptr, first_slot, bindings, num_bindings);
    }

    /// Bind an index buffer for use with subsequent draw calls
    pub fn bindIndexBuffer(self: *const RenderPass, binding: *const BufferBinding, index_element_size: c.SDL_GPUIndexElementSize) void {
        c.SDL_BindGPUIndexBuffer(self.ptr, binding, index_element_size);
    }

    /// Bind texture-sampler pairs for use on the vertex shader
    pub fn bindVertexSamplers(self: *const RenderPass, first_slot: u32, texture_sampler_bindings: [*]const TextureSamplerBinding, num_bindings: u32) void {
        c.SDL_BindGPUVertexSamplers(self.ptr, first_slot, texture_sampler_bindings, num_bindings);
    }

    /// Bind storage textures for use on the vertex shader
    pub fn bindVertexStorageTextures(self: *const RenderPass, first_slot: u32, storage_textures: [*]const *Texture, num_bindings: u32) void {
        c.SDL_BindGPUVertexStorageTextures(self.ptr, first_slot, storage_textures, num_bindings);
    }

    /// Bind storage buffers for use on the vertex shader
    pub fn bindVertexStorageBuffers(self: *const RenderPass, first_slot: u32, storage_buffers: [*]const *Buffer, num_bindings: u32) void {
        c.SDL_BindGPUVertexStorageBuffers(self.ptr, first_slot, storage_buffers, num_bindings);
    }

    /// Bind texture-sampler pairs for use on the fragment shader
    pub fn bindFragmentSamplers(self: *const RenderPass, first_slot: u32, texture_sampler_bindings: [*]const TextureSamplerBinding, num_bindings: u32) void {
        c.SDL_BindGPUFragmentSamplers(self.ptr, first_slot, texture_sampler_bindings, num_bindings);
    }

    /// Bind storage textures for use on the fragment shader
    pub fn bindFragmentStorageTextures(self: *const RenderPass, first_slot: u32, storage_textures: [*]const *Texture, num_bindings: u32) void {
        c.SDL_BindGPUFragmentStorageTextures(self.ptr, first_slot, storage_textures, num_bindings);
    }

    /// Bind storage buffers for use on the fragment shader
    pub fn bindFragmentStorageBuffers(self: *const RenderPass, first_slot: u32, storage_buffers: [*]const *Buffer, num_bindings: u32) void {
        c.SDL_BindGPUFragmentStorageBuffers(self.ptr, first_slot, storage_buffers, num_bindings);
    }

    /// Draw using bound graphics state with an index buffer and instancing enabled
    pub fn drawIndexedPrimitives(self: *const RenderPass, num_indices: u32, num_instances: u32, first_index: u32, vertex_offset: i32, first_instance: u32) void {
        c.SDL_DrawGPUIndexedPrimitives(self.ptr, num_indices, num_instances, first_index, vertex_offset, first_instance);
    }

    /// Draw using bound graphics state
    pub fn drawPrimitives(self: *const RenderPass, num_vertices: u32, num_instances: u32, first_vertex: u32, first_instance: u32) void {
        c.SDL_DrawGPUPrimitives(self.ptr, num_vertices, num_instances, first_vertex, first_instance);
    }

    /// Draw using bound graphics state and with draw parameters set from a buffer
    pub fn drawPrimitivesIndirect(self: *const RenderPass, buffer: *Buffer, offset: u32, draw_count: u32) void {
        c.SDL_DrawGPUPrimitivesIndirect(self.ptr, buffer, offset, draw_count);
    }

    /// Draw using bound graphics state with an index buffer enabled and with draw parameters set from a buffer
    pub fn drawIndexedPrimitivesIndirect(self: *const RenderPass, buffer: *Buffer, offset: u32, draw_count: u32) void {
        c.SDL_DrawGPUIndexedPrimitivesIndirect(self.ptr, buffer, offset, draw_count);
    }

    /// End the current render pass
    pub fn end(self: *const RenderPass) void {
        c.SDL_EndGPURenderPass(self.ptr);
    }
};

pub const ComputePass = struct {
    ptr: *c.SDL_GPUComputePass,

    /// Bind a compute pipeline for use in dispatch
    pub fn bindComputePipeline(self: *const ComputePass, compute_pipeline: *ComputePipeline) void {
        c.SDL_BindGPUComputePipeline(self.ptr, compute_pipeline);
    }

    /// Bind texture-sampler pairs for use on the compute shader
    pub fn bindComputeSamplers(self: *const ComputePass, first_slot: u32, texture_sampler_bindings: [*]const TextureSamplerBinding, num_bindings: u32) void {
        c.SDL_BindGPUComputeSamplers(self.ptr, first_slot, texture_sampler_bindings, num_bindings);
    }

    /// Bind storage textures as readonly for use on the compute pipeline
    pub fn bindComputeStorageTextures(self: *const ComputePass, first_slot: u32, storage_textures: [*]const *Texture, num_bindings: u32) void {
        c.SDL_BindGPUComputeStorageTextures(self.ptr, first_slot, storage_textures, num_bindings);
    }

    /// Bind storage buffers as readonly for use on the compute pipeline
    pub fn bindComputeStorageBuffers(self: *const ComputePass, first_slot: u32, storage_buffers: [*]const *Buffer, num_bindings: u32) void {
        c.SDL_BindGPUComputeStorageBuffers(self.ptr, first_slot, storage_buffers, num_bindings);
    }

    /// Dispatch compute work
    pub fn dispatchCompute(self: *const ComputePass, groupcount_x: u32, groupcount_y: u32, groupcount_z: u32) void {
        c.SDL_DispatchGPUCompute(self.ptr, groupcount_x, groupcount_y, groupcount_z);
    }

    /// Dispatch compute work with parameters set from a buffer
    pub fn dispatchComputeIndirect(self: *const ComputePass, buffer: *Buffer, offset: u32) void {
        c.SDL_DispatchGPUComputeIndirect(self.ptr, buffer, offset);
    }

    /// End the current compute pass
    pub fn end(self: *const ComputePass) void {
        c.SDL_EndGPUComputePass(self.ptr);
    }
};

pub const CopyPass = struct {
    ptr: *c.SDL_GPUCopyPass,

    /// Upload data from a transfer buffer to a texture
    pub fn uploadToTexture(self: *const CopyPass, source: *const TextureTransferInfo, destination: *const TextureRegion, cycle: bool) void {
        c.SDL_UploadToGPUTexture(self.ptr, source, destination, cycle);
    }

    /// Upload data from a transfer buffer to a buffer
    pub fn uploadToBuffer(self: *const CopyPass, source: *const TransferBufferLocation, destination: *const BufferRegion, cycle: bool) void {
        c.SDL_UploadToGPUBuffer(self.ptr, source, destination, cycle);
    }

    /// Perform a texture-to-texture copy
    pub fn copyTextureToTexture(self: *const CopyPass, source: *const TextureLocation, destination: *const TextureLocation, w: u32, h: u32, d: u32, cycle: bool) void {
        c.SDL_CopyGPUTextureToTexture(self.ptr, source, destination, w, h, d, cycle);
    }

    /// Perform a buffer-to-buffer copy
    pub fn copyBufferToBuffer(self: *const CopyPass, source: *const BufferLocation, destination: *const BufferLocation, size: u32, cycle: bool) void {
        c.SDL_CopyGPUBufferToBuffer(self.ptr, source, destination, size, cycle);
    }

    /// Copy data from a texture to a transfer buffer on the GPU timeline
    pub fn downloadFromTexture(self: *const CopyPass, source: *const TextureRegion, destination: *const TextureTransferInfo) void {
        c.SDL_DownloadFromGPUTexture(self.ptr, source, destination);
    }

    /// Copy data from a buffer to a transfer buffer on the GPU timeline
    pub fn downloadFromBuffer(self: *const CopyPass, source: *const BufferRegion, destination: *const TransferBufferLocation) void {
        c.SDL_DownloadFromGPUBuffer(self.ptr, source, destination);
    }

    /// End the current copy pass
    pub fn end(self: *const CopyPass) void {
        c.SDL_EndGPUCopyPass(self.ptr);
    }
};
