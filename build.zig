const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // -------
    //  SDL3
    // -------
    const sdl_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
        .preferred_linkage = .static,
    });
    const sdl_lib = sdl_dep.artifact("SDL3");

    const imgui_lib = b.addLibrary(.{
        .name = "imgui",
        .root_module = b.addModule("imgui", .{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        }),
        .linkage = .static,
    });
    imgui_lib.root_module.addIncludePath(b.path("."));
    imgui_lib.root_module.addIncludePath(b.path("backends"));
    imgui_lib.root_module.addIncludePath(b.path("dcimgui"));

    for (sdl_lib.root_module.include_dirs.items) |*included| {
        switch (included.*) {
            .path => imgui_lib.root_module.addIncludePath(included.path),
            else => {},
        }
    }

    imgui_lib.addCSourceFiles(.{
        .files = &.{
            "imgui.cpp",
            "imgui_demo.cpp",
            "imgui_draw.cpp",
            "imgui_tables.cpp",
            "imgui_widgets.cpp",
            "backends/imgui_impl_sdl3.cpp",
            "backends/imgui_impl_sdlgpu3.cpp",
            "dcimgui/dcimgui.cpp",
            "dcimgui/dcimgui_impl_sdl3.cpp",
            "dcimgui/dcimgui_impl_sdl3gpu.cpp",
        },
        .flags = &.{
            "-std=c++11",
            "-fno-exceptions",
            "-fno-rtti",
        },
    });

    imgui_lib.installHeadersDirectory(b.path("."), ".", .{});
    imgui_lib.installHeadersDirectory(b.path("backends"), "backends", .{});
    imgui_lib.installHeadersDirectory(b.path("dcimgui"), "dcimgui", .{});
    b.installArtifact(imgui_lib);
}
