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
    imgui_lib.root_module.addIncludePath(b.path("src"));
    imgui_lib.root_module.addIncludePath(b.path("src/dcimgui"));

    for (sdl_lib.root_module.include_dirs.items) |*included| {
        switch (included.*) {
            .path => imgui_lib.root_module.addIncludePath(included.path),
            else => {},
        }
    }

    imgui_lib.addCSourceFiles(.{
        .files = &.{
            "src/imgui.cpp",
            "src/imgui_demo.cpp",
            "src/imgui_draw.cpp",
            "src/imgui_tables.cpp",
            "src/imgui_widgets.cpp",
            "src/imgui_impl_sdl3.cpp",
            "src/imgui_impl_sdlgpu3.cpp",
            "src/dcimgui/dcimgui.cpp",
            "src/dcimgui/dcimgui_internal.cpp",
            "src/dcimgui/dcimgui_impl_sdl3.cpp",
            "src/dcimgui/dcimgui_impl_sdl3gpu.cpp",
        },
        .flags = &.{
            "-std=c++11",
            "-fno-exceptions",
            "-fno-rtti",
        },
    });

    imgui_lib.installHeadersDirectory(b.path("src"), ".", .{});
    imgui_lib.installHeadersDirectory(b.path("src/dcimgui"), "src/dcimgui", .{});
    b.installArtifact(imgui_lib);
}
