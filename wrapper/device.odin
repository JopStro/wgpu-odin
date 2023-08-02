package wgpu

// Core
import "core:mem"

// Package
import wgpu "../bindings"

// Open connection to a graphics and/or compute device.
Device :: struct {
    ptr:          WGPU_Device,
    features:     []Feature_Name,
    limits:       Limits,
    queue:        Queue,
    using vtable: ^Device_VTable,
}

@(private)
Device_VTable :: struct {
    create_bind_group:             proc(
        self: ^Device,
        descriptor: ^Bind_Group_Descriptor,
    ) -> (
        Bind_Group,
        Error_Type,
    ),
    create_bind_group_layout:      proc(
        self: ^Device,
        descriptor: ^Bind_Group_Layout_Descriptor,
    ) -> (
        Bind_Group_Layout,
        Error_Type,
    ),
    create_buffer:                 proc(
        self: ^Device,
        descriptor: ^Buffer_Descriptor,
    ) -> (
        Buffer,
        Error_Type,
    ),
    create_buffer_with_data:       proc(
        self: ^Device,
        descriptor: ^Buffer_Data_Descriptor,
    ) -> (
        Buffer,
        Error_Type,
    ),
    create_command_encoder:        proc(
        using self: ^Device,
        descriptor: ^Command_Encoder_Descriptor = nil,
    ) -> (
        Command_Encoder,
        Error_Type,
    ),
    create_compute_pipeline:       proc(
        self: ^Device,
        descriptor: ^Compute_Pipeline_Descriptor,
    ) -> (
        Compute_Pipeline,
        Error_Type,
    ),
    create_compute_pipeline_async: proc(self: ^Device),
    create_pipeline_layout:        proc(
        self: ^Device,
        bind_group_layouts: []Bind_Group_Layout,
        label: cstring = "Default pipeline layout",
    ) -> (
        Pipeline_Layout,
        Error_Type,
    ),
    create_query_set:              proc(
        self: ^Device,
        descriptor: ^Query_Set_Descriptor,
    ) -> (
        Query_Set,
        Error_Type,
    ),
    create_render_bundle_encoder:  proc(
        self: ^Device,
        descriptor: ^Render_Bundle_Encoder_Descriptor,
    ) -> (
        Render_Bundle_Encoder,
        Error_Type,
    ),
    create_render_pipeline:        proc(
        self: ^Device,
        descriptor: ^Render_Pipeline_Descriptor,
    ) -> (
        Render_Pipeline,
        Error_Type,
    ),
    create_render_pipeline_async:  proc(self: ^Device),
    create_sampler:                proc(
        self: ^Device,
        descriptor: ^Sampler_Descriptor,
    ) -> (
        Sampler,
        Error_Type,
    ),
    create_shader_module:          proc(
        self: ^Device,
        descriptor: ^Shader_Module_Descriptor,
    ) -> (
        Shader_Module,
        Error_Type,
    ),
    load_wgsl_shader_module:       proc(
        self: ^Device,
        path: cstring,
        label: cstring = nil,
        allocator: mem.Allocator = context.allocator,
    ) -> (
        Shader_Module,
        Error_Type,
    ),
    load_spirv_shader_module:      proc(
        self: ^Device,
        path: cstring,
        label: cstring = nil,
        allocator: mem.Allocator = context.allocator,
    ) -> (
        Shader_Module,
        Error_Type,
    ),
    create_swap_chain:             proc(
        self: ^Device,
        surface: WGPU_Surface,
        descriptor: ^Swap_Chain_Descriptor,
    ) -> (
        Swap_Chain,
        Error_Type,
    ),
    create_texture:                proc(
        self: ^Device,
        descriptor: ^Texture_Descriptor,
    ) -> (
        Texture,
        Error_Type,
    ),
    get_features:                  proc(
        self: ^Device,
        allocator: mem.Allocator = context.allocator,
    ) -> []Feature_Name,
    get_limits:                    proc(self: ^Device) -> Limits,
    get_queue:                     proc(self: ^Device) -> Queue,
    has_feature:                   proc(self: ^Device, feature: Feature_Name) -> bool,
    set_uncaptured_error_callback: proc(
        self: ^Device,
        callback: Error_Callback,
        user_data: rawptr,
    ),
    pop_error_scope:               proc(
        self: ^Device,
        callback: Error_Callback,
        user_data: rawptr,
    ),
    push_error_scope:              proc(self: ^Device, filter: Error_Filter),
    set_label:                     proc(self: ^Device, label: cstring),
    reference:                     proc(self: ^Device),
    release:                       proc(self: ^Device),
    poll:                          proc(
        self: ^Device,
        wait: bool = true,
        wrapped_submission_index: ^Wrapped_Submission_Index = nil,
    ) -> bool,
}

@(private)
default_device_vtable := Device_VTable {
    create_bind_group             = device_create_bind_group,
    create_bind_group_layout      = device_create_bind_group_layout,
    create_buffer                 = device_create_buffer,
    create_buffer_with_data       = device_create_buffer_with_data,
    create_command_encoder        = device_create_command_encoder,
    create_compute_pipeline       = device_create_compute_pipeline,
    create_pipeline_layout        = device_create_pipeline_layout,
    create_query_set              = device_create_query_set,
    create_render_bundle_encoder  = device_create_render_bundle_encoder,
    create_render_pipeline        = device_create_render_pipeline,
    create_sampler                = device_create_sampler,
    create_shader_module          = device_create_shader_module,
    load_wgsl_shader_module       = device_load_wgsl_shader_module,
    load_spirv_shader_module      = device_load_spirv_shader_module,
    create_swap_chain             = device_create_swap_chain,
    create_texture                = device_create_texture,
    get_features                  = device_enumerate_features,
    get_limits                    = device_get_limits,
    get_queue                     = device_get_queue,
    has_feature                   = device_has_feature,
    set_uncaptured_error_callback = device_set_uncaptured_error_callback,
    pop_error_scope               = device_pop_error_scope,
    push_error_scope              = device_push_error_scope,
    set_label                     = device_set_label,
    reference                     = device_reference,
    release                       = device_release,
    poll                          = device_poll,
}

@(private)
default_device := Device {
    ptr    = nil,
    vtable = &default_device_vtable,
}

Bind_Group_Descriptor :: struct {
    label:   cstring,
    layout:  ^Bind_Group_Layout,
    entries: []Bind_Group_Entry,
}

// Creates a new `Bind_Group`.
device_create_bind_group :: proc(
    using self: ^Device,
    descriptor: ^Bind_Group_Descriptor,
) -> (
    Bind_Group,
    Error_Type,
) {
    desc := wgpu.Bind_Group_Descriptor{}

    if descriptor != nil {
        desc.label = descriptor.label

        if descriptor.layout != nil {
            desc.layout = descriptor.layout.ptr
        }

        entry_count := cast(uint)len(descriptor.entries)

        if entry_count > 0 {
            desc.entry_count = entry_count
            desc.entries = raw_data(descriptor.entries)
        }
    }

    err_scope := Error_Scope {
        info = #procedure,
    }

    wgpu.device_push_error_scope(ptr, .Validation)
    bind_group_ptr := wgpu.device_create_bind_group(ptr, &desc)
    wgpu.device_pop_error_scope(ptr, error_scope_callback, &err_scope)

    if err_scope.type != .No_Error {
        if bind_group_ptr != nil {
            wgpu.bind_group_release(bind_group_ptr)
        }
        return {}, err_scope.type
    }

    bind_group := default_bind_group
    bind_group.ptr = bind_group_ptr

    return bind_group, .No_Error
}

Bind_Group_Layout_Descriptor :: struct {
    label:   cstring,
    entries: []Bind_Group_Layout_Entry,
}

// Creates a `Bind_Group_Layout`.
device_create_bind_group_layout :: proc(
    using self: ^Device,
    descriptor: ^Bind_Group_Layout_Descriptor,
) -> (
    Bind_Group_Layout,
    Error_Type,
) {
    desc := wgpu.Bind_Group_Layout_Descriptor{}

    if descriptor != nil {
        desc.label = descriptor.label

        entry_count := cast(uint)len(descriptor.entries)

        if entry_count > 0 {
            desc.entry_count = entry_count
            desc.entries = raw_data(descriptor.entries)
        }
    }

    err_scope := Error_Scope {
        info = #procedure,
    }

    wgpu.device_push_error_scope(ptr, .Validation)
    bind_group_layout_ptr := wgpu.device_create_bind_group_layout(ptr, &desc)
    wgpu.device_pop_error_scope(ptr, error_scope_callback, &err_scope)

    if err_scope.type != .No_Error {
        if bind_group_layout_ptr != nil {
            wgpu.bind_group_layout_release(bind_group_layout_ptr)
        }
        return {}, err_scope.type
    }

    bind_group_layout := default_bind_group_layout
    bind_group_layout.ptr = bind_group_layout_ptr

    return bind_group_layout, .No_Error
}

// Creates a `Buffer`.
device_create_buffer :: proc(
    using self: ^Device,
    descriptor: ^Buffer_Descriptor,
) -> (
    Buffer,
    Error_Type,
) {
    err_scope := Error_Scope {
        info = #procedure,
    }

    wgpu.device_push_error_scope(ptr, .Validation)
    buffer_ptr := wgpu.device_create_buffer(ptr, descriptor)
    wgpu.device_pop_error_scope(ptr, error_scope_callback, &err_scope)

    if err_scope.type != .No_Error {
        if buffer_ptr != nil {
            wgpu.buffer_release(buffer_ptr)
        }
        return {}, err_scope.type
    }

    wgpu.device_reference(ptr)

    buffer := default_buffer
    buffer.ptr = buffer_ptr
    buffer.device_ptr = self.ptr
    buffer.size = descriptor.size
    buffer.usage = descriptor.usage

    return buffer, .No_Error
}

// Creates an empty `Command_Encoder`.
device_create_command_encoder :: proc(
    using self: ^Device,
    descriptor: ^Command_Encoder_Descriptor = nil,
) -> (
    Command_Encoder,
    Error_Type,
) {
    command_encoder := default_gpu_command_encoder

    err_scope := Error_Scope {
        info = #procedure,
    }

    wgpu.device_push_error_scope(ptr, .Validation)
    if descriptor != nil {
        command_encoder.ptr = wgpu.device_create_command_encoder(ptr, descriptor)
    } else {
        command_encoder.ptr = wgpu.device_create_command_encoder(
            ptr,
            &Command_Encoder_Descriptor{label = "Default command encoder"},
        )
    }
    wgpu.device_pop_error_scope(ptr, error_scope_callback, &err_scope)

    if err_scope.type != .No_Error {
        if command_encoder.ptr != nil {
            wgpu.command_encoder_release(command_encoder.ptr)
        }
        return {}, err_scope.type
    }

    wgpu.device_reference(ptr)

    command_encoder.device_ptr = self.ptr

    return command_encoder, .No_Error
}

Programmable_Stage_Descriptor :: struct {
    module:         ^Shader_Module,
    entry_point:    cstring,
    constant_count: uint,
    constants:      ^Constant_Entry,
}

Compute_Pipeline_Descriptor :: struct {
    label:   cstring,
    layout:  ^Pipeline_Layout,
    compute: Programmable_Stage_Descriptor,
}

// Creates a `Compute_Pipeline`.
device_create_compute_pipeline :: proc(
    using self: ^Device,
    descriptor: ^Compute_Pipeline_Descriptor,
) -> (
    Compute_Pipeline,
    Error_Type,
) {
    desc := wgpu.Compute_Pipeline_Descriptor{}

    if descriptor != nil {
        desc.label = descriptor.label

        if descriptor.layout != nil {
            desc.layout = descriptor.layout.ptr
        }

        compute := wgpu.Programmable_Stage_Descriptor{}

        if descriptor.compute.module != nil {
            compute.module = descriptor.compute.module.ptr
        }

        compute.entry_point = descriptor.compute.entry_point

        desc.compute = compute
    }

    err_scope := Error_Scope {
        info = #procedure,
    }

    wgpu.device_push_error_scope(ptr, .Validation)
    compute_pipeline_ptr := wgpu.device_create_compute_pipeline(ptr, &desc)
    wgpu.device_pop_error_scope(ptr, error_scope_callback, &err_scope)

    if err_scope.type != .No_Error {
        if compute_pipeline_ptr != nil {
            wgpu.compute_pipeline_release(compute_pipeline_ptr)
        }
        return {}, err_scope.type
    }

    compute_pipeline := default_compute_pipeline
    compute_pipeline.ptr = compute_pipeline_ptr

    return compute_pipeline, .No_Error
}

// Creates a `Pipeline_Layout`.
device_create_pipeline_layout :: proc(
    using self: ^Device,
    bind_group_layouts: []Bind_Group_Layout,
    label: cstring = "Default pipeline layout",
) -> (
    Pipeline_Layout,
    Error_Type,
) {
    bind_group_layout_count := cast(uint)len(bind_group_layouts)

    descriptor := Pipeline_Layout_Descriptor {
        next_in_chain           = nil,
        label                   = label,
        bind_group_layout_count = bind_group_layout_count,
    }

    if bind_group_layout_count > 0 {
        if bind_group_layout_count == 1 {
            descriptor.bind_group_layouts = &bind_group_layouts[0].ptr
        } else {
            bind_group_layouts_ptrs := make(
                []WGPU_Bind_Group_Layout,
                len(bind_group_layouts),
            )
            defer delete(bind_group_layouts_ptrs)

            for b, i in bind_group_layouts {
                bind_group_layouts_ptrs[i] = b.ptr
            }

            descriptor.bind_group_layouts = raw_data(bind_group_layouts_ptrs)
        }
    } else {
        descriptor.bind_group_layouts = nil
    }

    err_scope := Error_Scope {
        info = #procedure,
    }

    wgpu.device_push_error_scope(ptr, .Validation)
    pipeline_layout_ptr := wgpu.device_create_pipeline_layout(ptr, &descriptor)
    wgpu.device_pop_error_scope(ptr, error_scope_callback, &err_scope)

    if err_scope.type != .No_Error {
        if pipeline_layout_ptr != nil {
            wgpu.pipeline_layout_release(pipeline_layout_ptr)
        }
        return {}, err_scope.type
    }

    pipeline_layout := default_pipeline_layout
    pipeline_layout.ptr = pipeline_layout_ptr

    return pipeline_layout, .No_Error
}

Query_Set_Descriptor :: struct {
    label:               cstring,
    type:                Query_Type,
    count:               u32,
    pipeline_statistics: []Pipeline_Statistic_Name,
}

device_create_query_set :: proc(
    using self: ^Device,
    descriptor: ^Query_Set_Descriptor,
) -> (
    Query_Set,
    Error_Type,
) {
    desc := wgpu.Query_Set_Descriptor{}

    if descriptor != nil {
        desc.label = descriptor.label
        desc.type = descriptor.type
        desc.count = descriptor.count

        pipeline_statistics_count := cast(uint)len(descriptor.pipeline_statistics)

        if pipeline_statistics_count > 0 {
            desc.pipeline_statistics_count = pipeline_statistics_count
            desc.pipeline_statistics = raw_data(descriptor.pipeline_statistics)
        }
    }

    err_scope := Error_Scope {
        info = #procedure,
    }

    wgpu.device_push_error_scope(ptr, .Validation)
    query_set_ptr := wgpu.device_create_query_set(ptr, &desc)
    wgpu.device_pop_error_scope(ptr, error_scope_callback, &err_scope)

    if err_scope.type != .No_Error {
        if query_set_ptr != nil {
            wgpu.query_set_release(query_set_ptr)
        }
        return {}, err_scope.type
    }

    query_set := default_query_set
    query_set.ptr = query_set_ptr

    return query_set, .No_Error
}

Render_Bundle_Encoder_Descriptor :: struct {
    label:                cstring,
    color_formats:        []Texture_Format,
    depth_stencil_format: Texture_Format,
    sample_count:         u32,
    depth_read_only:      bool,
    stencil_read_only:    bool,
}

device_create_render_bundle_encoder :: proc(
    using self: ^Device,
    descriptor: ^Render_Bundle_Encoder_Descriptor,
) -> (
    Render_Bundle_Encoder,
    Error_Type,
) {
    desc := wgpu.Render_Bundle_Encoder_Descriptor {
        label = descriptor.label,
    }

    color_formats_count := cast(uint)len(descriptor.color_formats)

    if color_formats_count > 0 {
        desc.color_formats_count = color_formats_count
        desc.color_formats = raw_data(descriptor.color_formats)
    }

    desc.depth_stencil_format = descriptor.depth_stencil_format
    desc.sample_count = descriptor.sample_count
    desc.depth_read_only = descriptor.depth_read_only
    desc.stencil_read_only = descriptor.stencil_read_only

    render_bundle_encoder := default_render_bundle_encoder
    render_bundle_encoder.ptr = wgpu.device_create_render_bundle_encoder(ptr, &desc)

    return render_bundle_encoder, .No_Error
}

Vertex_Buffer_Layout :: struct {
    array_stride: u64,
    step_mode:    Vertex_Step_Mode,
    attributes:   []Vertex_Attribute,
}

Vertex_State :: struct {
    module:      ^Shader_Module,
    entry_point: cstring,
    buffers:     []Vertex_Buffer_Layout,
}

Fragment_State :: struct {
    module:      ^Shader_Module,
    entry_point: cstring,
    targets:     []Color_Target_State,
}

Primitive_Topology :: enum {
    Triangle_List, // Default
    Point_List,
    Line_List,
    Line_Strip,
    Triangle_Strip,
}

Primitive_State :: struct {
    topology:           Primitive_Topology,
    strip_index_format: Index_Format,
    front_face:         Front_Face,
    cull_mode:          Cull_Mode,
}

Render_Pipeline_Descriptor :: struct {
    label:         cstring,
    layout:        ^Pipeline_Layout,
    vertex:        Vertex_State,
    primitive:     Primitive_State,
    depth_stencil: ^Depth_Stencil_State,
    multisample:   Multisample_State,
    fragment:      ^Fragment_State,
}

Multisample_State_Default := Multisample_State {
    next_in_chain             = nil,
    count                     = 1,
    mask                      = ~u32(0), // 0xFFFFFFFF
    alpha_to_coverage_enabled = false,
}

// Creates a `Render_Pipeline`.
device_create_render_pipeline :: proc(
    using self: ^Device,
    descriptor: ^Render_Pipeline_Descriptor,
) -> (
    Render_Pipeline,
    Error_Type,
) {
    // Initial pipeline descriptor
    desc := wgpu.Render_Pipeline_Descriptor {
        next_in_chain = nil,
        label = descriptor.label,
        layout = nil,
        vertex = {module = nil, buffer_count = 0, buffers = nil},
        depth_stencil = nil,
        fragment = &{module = nil, target_count = 0, targets = nil},
    }

    if descriptor.layout != nil {
        desc.layout = descriptor.layout.ptr
    }

    if descriptor.vertex.module != nil {
        desc.vertex.module = descriptor.vertex.module.ptr
    }

    desc.vertex.entry_point = descriptor.vertex.entry_point

    buffer_count := cast(uint)len(descriptor.vertex.buffers)

    if buffer_count > 0 {
        buffers_slice := make([]wgpu.Vertex_Buffer_Layout, buffer_count)
        defer delete(buffers_slice)

        for v, i in descriptor.vertex.buffers {
            buffer := wgpu.Vertex_Buffer_Layout {
                array_stride = v.array_stride,
                step_mode    = v.step_mode,
            }

            attribute_count := cast(uint)len(v.attributes)

            if attribute_count > 0 {
                buffer.attribute_count = attribute_count
                buffer.attributes = raw_data(v.attributes)
            }

            buffers_slice[i] = buffer
        }

        desc.vertex.buffer_count = buffer_count
        desc.vertex.buffers = raw_data(buffers_slice)
    }

    desc.primitive = {
        strip_index_format = descriptor.primitive.strip_index_format,
        front_face         = descriptor.primitive.front_face,
        cull_mode          = descriptor.primitive.cull_mode,
    }

    // Because everything in Odin by default is set to 0, the default Primitive_Topology
    // enum value is `Point_List`. We make `Triangle_List` default value by creating a
    // new enum, but here we set the correct/expected wgpu value:
    switch descriptor.primitive.topology {
    case .Triangle_List:
        desc.primitive.topology = wgpu.Primitive_Topology.Triangle_List
    case .Point_List:
        desc.primitive.topology = wgpu.Primitive_Topology.Point_List
    case .Line_List:
        desc.primitive.topology = wgpu.Primitive_Topology.Line_List
    case .Line_Strip:
        desc.primitive.topology = wgpu.Primitive_Topology.Line_Strip
    case .Triangle_Strip:
        desc.primitive.topology = wgpu.Primitive_Topology.Triangle_Strip
    }

    if descriptor.depth_stencil != nil {
        desc.depth_stencil = descriptor.depth_stencil
    }

    desc.multisample = descriptor.multisample

    // Multisample count cannot be 0, defaulting to 1
    if desc.multisample.count == 0 {
        desc.multisample.count = 1
    }

    if descriptor.fragment != nil {
        target_count := cast(uint)len(descriptor.fragment.targets)

        if descriptor.fragment.module != nil {
            desc.fragment.module = descriptor.fragment.module.ptr
        }

        if target_count > 0 {
            targets := make([]Color_Target_State, target_count)
            defer delete(targets)

            for v, i in descriptor.fragment.targets {
                target := Color_Target_State {
                    format     = v.format,
                    write_mask = v.write_mask,
                    blend      = v.blend,
                }

                targets[i] = target
            }

            desc.fragment.entry_point = descriptor.fragment.entry_point
            desc.fragment.target_count = target_count
            desc.fragment.targets = raw_data(targets)
        } else {
            desc.fragment.target_count = 0
            desc.fragment.targets = nil
        }
    }

    err_scope := Error_Scope {
        info = #procedure,
    }

    wgpu.device_push_error_scope(ptr, .Validation)
    render_pipeline_ptr := wgpu.device_create_render_pipeline(ptr, &desc)
    wgpu.device_pop_error_scope(ptr, error_scope_callback, &err_scope)

    if err_scope.type != .No_Error {
        if render_pipeline_ptr != nil {
            wgpu.render_pipeline_release(render_pipeline_ptr)
        }
        return {}, err_scope.type
    }

    render_pipeline := default_render_pipeline
    render_pipeline.ptr = render_pipeline_ptr

    return render_pipeline, .No_Error
}

device_create_sampler :: proc(
    using self: ^Device,
    descriptor: ^Sampler_Descriptor,
) -> (
    Sampler,
    Error_Type,
) {
    err_scope := Error_Scope {
        info = #procedure,
    }

    wgpu.device_push_error_scope(ptr, .Validation)
    sampler_ptr := wgpu.device_create_sampler(ptr, descriptor)
    wgpu.device_pop_error_scope(ptr, error_scope_callback, &err_scope)

    if err_scope.type != .No_Error {
        if sampler_ptr != nil {
            wgpu.sampler_release(sampler_ptr)
        }
        return {}, err_scope.type
    }

    sampler := default_sampler
    sampler.ptr = sampler_ptr

    return sampler, .No_Error
}

Shader_Module_SPIRV_Descriptor :: struct {
    code: []byte,
}

Shader_Module_WGSL_Descriptor :: struct {
    code: cstring,
}

Shader_Module_Descriptor :: struct {
    label:            cstring,
    spirv_descriptor: ^Shader_Module_SPIRV_Descriptor,
    wgsl_descriptor:  ^Shader_Module_WGSL_Descriptor,
}

// Creates a shader module from either `SPIR-V` or `WGSL` source code.
device_create_shader_module :: proc(
    using self: ^Device,
    descriptor: ^Shader_Module_Descriptor,
) -> (
    Shader_Module,
    Error_Type,
) {
    desc := wgpu.Shader_Module_Descriptor{}

    if descriptor != nil {
        desc.label = descriptor.label

        if descriptor.spirv_descriptor != nil {
            spirv := wgpu.Shader_Module_SPIRV_Descriptor {
                chain = {next = nil, stype = .Shader_Module_SPIRV_Descriptor},
                code = nil,
            }

            if descriptor.spirv_descriptor.code != nil {
                code_size := cast(u32)len(descriptor.spirv_descriptor.code)

                if code_size > 0 {
                    spirv.code_size = code_size
                    spirv.code = (^u32)(raw_data(descriptor.spirv_descriptor.code))
                }
            }

            desc.next_in_chain = cast(^Chained_Struct)&spirv
        } else if descriptor.wgsl_descriptor != nil {
            wgsl := wgpu.Shader_Module_WGSL_Descriptor {
                chain = {next = nil, stype = .Shader_Module_WGSL_Descriptor},
                code = descriptor.wgsl_descriptor.code,
            }

            desc.next_in_chain = cast(^Chained_Struct)&wgsl
        }
    }

    err_scope := Error_Scope {
        info = #procedure,
    }

    wgpu.device_push_error_scope(ptr, .Validation)
    shader_module_ptr := wgpu.device_create_shader_module(ptr, &desc)
    wgpu.device_pop_error_scope(ptr, error_scope_callback, &err_scope)

    if err_scope.type != .No_Error {
        if shader_module_ptr != nil {
            wgpu.shader_module_release(shader_module_ptr)
        }
        return {}, err_scope.type
    }

    shader_module := default_shader_module
    shader_module.ptr = shader_module_ptr

    return shader_module, .No_Error
}

Swap_Chain_Descriptor :: struct {
    label:        cstring,
    usage:        Texture_Usage_Flags,
    format:       Texture_Format,
    width:        u32,
    height:       u32,
    present_mode: Present_Mode,
    alpha_mode:   Composite_Alpha_Mode,
    view_formats: []Texture_Format,
}

// Creates a `Swap_Chain` with a compatible `Surface`.
device_create_swap_chain :: proc(
    using self: ^Device,
    surface: WGPU_Surface,
    descriptor: ^Swap_Chain_Descriptor,
) -> (
    Swap_Chain,
    Error_Type,
) {
    desc := wgpu.Swap_Chain_Descriptor{}

    if descriptor != nil {
        desc.label = descriptor.label
        desc.usage = descriptor.usage
        desc.format = descriptor.format
        desc.width = descriptor.width
        desc.height = descriptor.height
        desc.present_mode = descriptor.present_mode

        extras := Swap_Chain_Descriptor_Extras {
            chain = {
                next = nil,
                stype = cast(SType)Native_SType.Swap_Chain_Descriptor_Extras,
            },
        }

        extras.alpha_mode = descriptor.alpha_mode

        view_format_count := cast(uint)len(descriptor.view_formats)

        if view_format_count > 0 {
            extras.view_format_count = view_format_count
            extras.view_formats = raw_data(descriptor.view_formats)
        }

        desc.next_in_chain = cast(^Chained_Struct)&extras
    }

    swap_chain_ptr := wgpu.device_create_swap_chain(ptr, surface, &desc)

    wgpu.device_reference(ptr)

    swap_chain := default_swap_chain
    swap_chain.ptr = swap_chain_ptr
    swap_chain.device_ptr = ptr

    return swap_chain, .No_Error
}

device_create_texture :: proc(
    using self: ^Device,
    descriptor: ^Texture_Descriptor,
) -> (
    Texture,
    Error_Type,
) {
    err_scope := Error_Scope {
        info = #procedure,
    }

    wgpu.device_push_error_scope(ptr, .Validation)
    texture_ptr := wgpu.device_create_texture(ptr, descriptor)
    wgpu.device_pop_error_scope(ptr, error_scope_callback, &err_scope)

    if err_scope.type != .No_Error {
        if texture_ptr != nil {
            wgpu.texture_release(texture_ptr)
        }
        return {}, err_scope.type
    }

    wgpu.device_reference(ptr)

    texture := default_texture
    texture.ptr = texture_ptr
    texture.device_ptr = ptr

    return texture, .No_Error
}

// List all features that may be used with this device.
device_enumerate_features :: proc(
    using self: ^Device,
    allocator := context.allocator,
) -> []Feature_Name {
    count := wgpu.device_enumerate_features(ptr, nil)
    adapter_features := make([]Feature_Name, count, allocator)
    wgpu.device_enumerate_features(ptr, raw_data(adapter_features))

    return adapter_features[:]
}

// List all limits that were requested of this device.
device_get_limits :: proc(using self: ^Device) -> Limits {
    supported_limits: Supported_Limits
    wgpu.device_get_limits(ptr, &supported_limits)

    return supported_limits.limits
}

// Get a handle to a command queue on the device
device_get_queue :: proc(using self: ^Device) -> Queue {
    gpu_queue := Queue {
        ptr    = wgpu.device_get_queue(ptr),
        vtable = &default_queue_vtable,
    }

    wgpu.device_reference(ptr)

    return gpu_queue
}

// Check if device support the given feature name.
device_has_feature :: proc(using self: ^Device, feature: Feature_Name) -> bool {
    if feature == .Undefined do return false
    return wgpu.device_has_feature(ptr, feature)
}

device_set_uncaptured_error_callback :: proc(
    using self: ^Device,
    callback: Error_Callback,
    user_data: rawptr,
) {
    wgpu.device_set_uncaptured_error_callback(ptr, callback, user_data)
}

device_pop_error_scope :: proc(
    using self: ^Device,
    callback: Error_Callback,
    user_data: rawptr,
) {
    wgpu.device_pop_error_scope(ptr, callback, user_data)
}

device_push_error_scope :: proc(using self: ^Device, filter: Error_Filter) {
    wgpu.device_push_error_scope(ptr, filter)
}

device_set_label :: proc(using self: ^Device, label: cstring) {
    wgpu.device_set_label(ptr, label)
}

device_reference :: proc(using self: ^Device) {
    wgpu.device_reference(ptr)
}

// Executes the destructor.
device_release :: proc(using self: ^Device) {
    if ptr != nil {
        delete(features)
        wgpu.device_release(ptr)
    }
}

device_poll :: proc(
    using self: ^Device,
    wait: bool = true,
    wrapped_submission_index: ^Wrapped_Submission_Index = nil,
) -> bool {
    return wgpu.device_poll(ptr, wait, wrapped_submission_index)
}