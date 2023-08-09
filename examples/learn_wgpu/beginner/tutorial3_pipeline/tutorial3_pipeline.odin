package tutorial3_pipeline

// Core
import "core:fmt"
import "core:runtime"

// Vendor
import sdl "vendor:sdl2"

// Package
import wgpu "../../../../wrapper"
import wgpu_sdl "../../../../utils/sdl"

State :: struct {
    minimized:       bool,
    surface:         wgpu.Surface,
    device:          wgpu.Device,
    config:          wgpu.Surface_Configuration,
    render_pipeline: wgpu.Render_Pipeline,
}

Physical_Size :: struct {
    width:  u32,
    height: u32,
}

_log_callback :: proc "c" (level: wgpu.Log_Level, message: cstring, user_data: rawptr) {
    context = runtime.default_context()
    fmt.eprintf("[wgpu] [%v] %s\n\n", level, message)
}

@(init)
init :: proc() {
    wgpu.set_log_callback(_log_callback, nil)
    wgpu.set_log_level(.Warn)
}

init_state := proc(window: ^sdl.Window) -> (s: State, err: wgpu.Error_Type) {
    state := State{}

    instance_descriptor := wgpu.Instance_Descriptor {
        backends             = wgpu.Instance_Backend_Primary,
        dx12_shader_compiler = wgpu.Dx12_Compiler_Default,
    }

    instance := wgpu.create_instance(&instance_descriptor)
    defer instance->release()

    surface_descriptor := wgpu_sdl.get_surface_descriptor(window) or_return
    state.surface = instance->create_surface(&surface_descriptor) or_return
    defer if err != .No_Error do state.surface->release()

    adapter_options := wgpu.Request_Adapter_Options {
        power_preference       = .High_Performance,
        compatible_surface     = &state.surface,
        force_fallback_adapter = false,
    }

    adapter := instance->request_adapter(&adapter_options) or_return
    defer adapter->release()

    device_options := wgpu.Device_Options {
        label  = adapter.info.name,
        limits = wgpu.Default_Limits,
    }

    state.device = adapter->request_device(&device_options) or_return
    defer if err != .No_Error do state.device->release()

    caps := state.surface->get_capabilities(adapter)
    defer {
        delete(caps.formats)
        delete(caps.present_modes)
        delete(caps.alpha_modes)
    }

    width, height: i32
    sdl.GetWindowSize(window, &width, &height)

    state.config = {
        usage = {.Render_Attachment},
        format = state.surface->get_preferred_format(&adapter),
        width = cast(u32)width,
        height = cast(u32)height,
        present_mode = .Fifo,
        alpha_mode = caps.alpha_modes[0],
    }

    state.surface->configure(&state.device, &state.config) or_return

    shader := state.device->load_wgsl_shader_module(
        "assets/learn_wgpu/tutorial3/shader.wgsl",
        "shader.wgsl",
    ) or_return
    defer shader->release()

    render_pipeline_layout := state.device->create_pipeline_layout(
        &{label = "Render Pipeline Layout"},
    ) or_return

    render_pipeline_descriptor := wgpu.Render_Pipeline_Descriptor {
        label = "Render Pipeline",
        layout = &render_pipeline_layout,
        vertex = {module = &shader, entry_point = "vs_main"},
        fragment = &{
            module = &shader,
            entry_point = "fs_main",
            targets = {
                {
                    format = state.config.format,
                    blend = &wgpu.Blend_State_Replace,
                    write_mask = wgpu.Color_Write_Mask_All,
                },
            },
        },
        primitive = {topology = .Triangle_List, front_face = .CCW, cull_mode = .Back},
        depth_stencil = nil,
        multisample = {count = 1, mask = ~u32(0), alpha_to_coverage_enabled = false},
    }

    state.render_pipeline = state.device->create_render_pipeline(
        &render_pipeline_descriptor,
    ) or_return

    return state, .No_Error
}

resize_window :: proc(state: ^State, size: Physical_Size) -> wgpu.Error_Type {
    if size.width > 0 && size.height > 0 {
        state.config.width = size.width
        state.config.height = size.height
        state.surface->configure(&state.device, &state.config) or_return
    }
    return .No_Error
}

render :: proc(state: ^State) -> wgpu.Error_Type {
    frame := state.surface->get_current_texture() or_return

    encoder := state.device->create_command_encoder(
        &wgpu.Command_Encoder_Descriptor{label = "Command Encoder"},
    ) or_return
    defer encoder->release()

    render_pass := encoder->begin_render_pass(
        &{
            label = "Render Pass",
            color_attachments = []wgpu.Render_Pass_Color_Attachment{
                {
                    view = &frame.view,
                    resolve_target = nil,
                    load_op = .Clear,
                    store_op = .Store,
                    clear_value = {0.1, 0.2, 0.3, 1.0},
                },
            },
            depth_stencil_attachment = nil,
        },
    )
    defer render_pass->release()

    render_pass->set_pipeline(&state.render_pipeline)
    render_pass->draw(3)
    render_pass->end()

    command_buffer := encoder->finish() or_return
    defer command_buffer->release()

    state.device.queue->submit(command_buffer)
    frame->present()

    return .No_Error
}

main :: proc() {
    sdl_flags := sdl.InitFlags{.VIDEO, .JOYSTICK, .GAMECONTROLLER, .EVENTS}

    if res := sdl.Init(sdl_flags); res != 0 {
        fmt.eprintf("ERROR: Failed to initialize SDL: [%s]\n", sdl.GetError())
        return
    }
    defer sdl.Quit()

    window_flags: sdl.WindowFlags = {.SHOWN, .ALLOW_HIGHDPI, .RESIZABLE}

    sdl_window := sdl.CreateWindow(
        "Tutorial 3 - Pipeline",
        sdl.WINDOWPOS_CENTERED,
        sdl.WINDOWPOS_CENTERED,
        800,
        600,
        window_flags,
    )
    defer sdl.DestroyWindow(sdl_window)

    if sdl_window == nil {
        fmt.eprintf("ERROR: Failed to create the SDL Window: [%s]\n", sdl.GetError())
        return
    }

    state, state_err := init_state(sdl_window)
    if state_err != .No_Error do return
    defer {
        state.render_pipeline->release()
        state.device->release()
        state.surface->release()
    }

    err := wgpu.Error_Type{}

    main_loop: for {
        e: sdl.Event

        for sdl.PollEvent(&e) {
            #partial switch (e.type) {
            case .QUIT:
                break main_loop

            case .WINDOWEVENT:
                #partial switch (e.window.event) {
                case .SIZE_CHANGED:
                case .RESIZED:
                    err = resize_window(
                        &state,
                        {cast(u32)e.window.data1, cast(u32)e.window.data2},
                    )
                    if err != .No_Error do break main_loop

                case .MINIMIZED:
                    state.minimized = true

                case .RESTORED:
                    state.minimized = false
                }
            }
        }

        if !state.minimized {
            err = render(&state)
            if err != .No_Error do break main_loop
        }
    }

    if err != .No_Error {
        fmt.eprintf("Error occurred while rendering: %v\n", err)
    }

    fmt.println("Exiting...")
}
